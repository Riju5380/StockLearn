import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock.dart';
import '../models/transaction.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../models/top_up_log.dart';
import '../models/news_article.dart';
import '../services/api_service.dart';

class AppStateProvider with ChangeNotifier {
  // Persistence Keys
  static const String keyWalletBalance = 'wallet_balance';
  static const String keyTransactions = 'transactions';
  static const String keyTopUpLogs = 'top_up_logs';
  static const String keyWishlist = 'wishlist';
  static const String keyPurchasedCourses = 'purchased_courses';
  static const String keyCourseProgress = 'course_progress';
  static const String keyDarkMode = 'dark_mode';
  static const String keyUsername = 'username';
  static const String keyPassword = 'password';

  // Base currency converter: $1 = ₹83.50
  static const double usdToInr = 83.50;

  // Local State
  double _walletBalance = 100000.00; // Default ₹1,00,000.00
  List<Stock> _stocks = [];
  List<StockTransaction> _transactions = [];
  List<TopUpLog> _topUpLogs = [];
  List<Course> _courses = [];
  List<NewsArticle> _news = [];
  bool _isDarkMode = true; // Default Dark Mode as per premium aesthetic
  String _username = "Alexander Sterling";
  String _password = "password";
  bool _isLoggedIn = true;
  int _navigationIndex = 0;
  List<String> _bookmarkedNewsIds = [];
  String _profilePicturePath = '';

  // Holdings Helper
  // Map of Symbol -> Shares owned
  final Map<String, double> _holdings = {};
  // Map of Symbol -> Average purchase price (in stock currency)
  final Map<String, double> _avgPurchasePrices = {};

  Timer? _priceUpdateTimer;

  // Getters
  double get walletBalance => _walletBalance;
  List<Stock> get stocks => _stocks;
  List<StockTransaction> get transactions => _transactions;
  List<TopUpLog> get topUpLogs => _topUpLogs;
  List<Course> get courses => _courses;
  List<NewsArticle> get news => _news;
  bool get isDarkMode => _isDarkMode;
  String get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  int get navigationIndex => _navigationIndex;
  List<String> get bookmarkedNewsIds => _bookmarkedNewsIds;
  String get profilePicturePath => _profilePicturePath;

  Map<String, double> get holdings => _holdings;
  Map<String, double> get avgPurchasePrices => _avgPurchasePrices;

  AppStateProvider() {
    _initData();
  }

  @override
  void dispose() {
    _priceUpdateTimer?.cancel();
    super.dispose();
  }

  // Calculate current portfolio value in INR
  double get portfolioValue {
    double total = 0.0;
    _holdings.forEach((symbol, shares) {
      final stock = _stocks.firstWhere((s) => s.symbol == symbol, orElse: () => _stocks[0]);
      double priceInInr = stock.price;
      if (stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA') {
        // Convert US stock price to INR
        priceInInr = stock.price * usdToInr;
      }
      total += shares * priceInInr;
    });
    return total;
  }

  // Calculate total invested amount in INR
  double get totalInvested {
    double total = 0.0;
    _holdings.forEach((symbol, shares) {
      final avgPrice = _avgPurchasePrices[symbol] ?? 0.0;
      final stock = _stocks.firstWhere((s) => s.symbol == symbol, orElse: () => _stocks[0]);
      double avgPriceInInr = avgPrice;
      if (stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA') {
        avgPriceInInr = avgPrice * usdToInr;
      }
      total += shares * avgPriceInInr;
    });
    return total;
  }

  // Calculate daily Profit/Loss in percentage and absolute
  double get dailyProfitLossInr {
    double totalPL = 0.0;
    _holdings.forEach((symbol, shares) {
      final stock = _stocks.firstWhere((s) => s.symbol == symbol, orElse: () => _stocks[0]);
      double priceChangeInr = stock.change;
      if (stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA') {
        priceChangeInr = stock.change * usdToInr;
      }
      totalPL += shares * priceChangeInr;
    });
    return totalPL;
  }

  double get dailyProfitLossPercent {
    final invested = totalInvested;
    if (invested == 0) return 0.0;
    return (dailyProfitLossInr / invested) * 100;
  }

  // Calculate overall Profit/Loss (Current Value - Total Invested)
  double get overallProfitLossInr => portfolioValue - totalInvested;

  double get overallProfitLossPercent {
    final invested = totalInvested;
    if (invested == 0) return 0.0;
    return (overallProfitLossInr / invested) * 100;
  }

  // Initialize and load persisted data
  Future<void> _initData() async {
    _initializeMockStocks();
    await _loadPersistedData();
    _recalculateHoldings();
    _startPriceSimulation();
    await loadApiData();
  }

  /// Fetches courses and news from the API and maps persistence states to them.
  Future<void> loadApiData() async {
    final apiService = ApiService();

    // 1. Fetch courses from the database API
    final apiCourses = await apiService.fetchCourses();
    _courses = apiCourses;
    if (apiCourses.isNotEmpty) {
      // Sync purchased status and lesson progress from local persistence
      final prefs = await SharedPreferences.getInstance();
      final purchasedCourseIds = prefs.getStringList(keyPurchasedCourses) ?? ['c1'];
      for (var course in _courses) {
        if (purchasedCourseIds.contains(course.id)) {
          course.isPurchased = true;
        }
        final completedList = prefs.getStringList('${keyCourseProgress}_${course.id}') ?? [];
        course.completedLessons.clear();
        course.completedLessons.addAll(completedList);
      }
    }

    // 2. Fetch news articles from the database API
    _news = await apiService.fetchNews();
    notifyListeners();
  }

  // Mock Stock Data Initialization
  void _initializeMockStocks() {
    final random = Random();

    List<double> generateHistory(double basePrice, int count, double volatility) {
      List<double> history = [basePrice];
      double current = basePrice;
      for (int i = 1; i < count; i++) {
        double changePercent = (random.nextDouble() - 0.48) * volatility; // slight upward bias
        current = current * (1 + changePercent);
        history.add(double.parse(current.toStringAsFixed(2)));
      }
      return history;
    }

    _stocks = [
      Stock(
        symbol: 'TCS',
        name: 'Tata Consultancy Services',
        sector: 'Technology',
        price: 3500.00,
        change: 52.50,
        changePercent: 1.5,
        marketCap: '12.8T',
        peRatio: 29.41,
        dividendYield: 1.15,
        avgVolume: '2.4M',
        high52w: 3900.00,
        low52w: 3100.00,
        description: 'Tata Consultancy Services Limited (TCS) is an Indian multinational information technology (IT) services and consulting company headquartered in Mumbai. It is a part of the Tata Group and operates in 150 locations across 46 countries.',
        history1D: generateHistory(3500.00, 24, 0.005),
        history1W: generateHistory(3420.00, 7, 0.012),
        history1M: generateHistory(3350.00, 30, 0.02),
        history1Y: generateHistory(3150.00, 12, 0.05),
        historyAll: generateHistory(2500.00, 50, 0.1),
      ),
      Stock(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        sector: 'Technology',
        price: 189.43,
        change: 2.45,
        changePercent: 1.31,
        marketCap: '2.94T',
        peRatio: 30.15,
        dividendYield: 0.51,
        avgVolume: '54.2M',
        high52w: 198.23,
        low52w: 124.17,
        description: 'Apple Inc. is an American multinational technology company headquartered in Cupertino, California. Apple is the world\'s largest technology company by revenue, and as of 2026, the world\'s most valuable company.',
        history1D: generateHistory(189.43, 24, 0.006),
        history1W: generateHistory(185.00, 7, 0.015),
        history1M: generateHistory(178.00, 30, 0.025),
        history1Y: generateHistory(150.00, 12, 0.07),
        historyAll: generateHistory(100.00, 50, 0.15),
      ),
      Stock(
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        sector: 'Internet Services',
        price: 142.65,
        change: 1.20,
        changePercent: 0.85,
        marketCap: '1.79T',
        peRatio: 26.40,
        dividendYield: 0.00,
        avgVolume: '28.5M',
        high52w: 155.00,
        low52w: 102.63,
        description: 'Alphabet Inc. is an American multinational technology conglomerate holding company headquartered in Mountain View, California. It was created through a restructuring of Google on October 2, 2015, and became the parent company of Google.',
        history1D: generateHistory(142.65, 24, 0.005),
        history1W: generateHistory(140.00, 7, 0.012),
        history1M: generateHistory(135.00, 30, 0.02),
        history1Y: generateHistory(115.00, 12, 0.06),
        historyAll: generateHistory(80.00, 50, 0.12),
      ),
      Stock(
        symbol: 'TATA',
        name: 'Tata Motors',
        sector: 'Automobiles',
        price: 924.50,
        change: 37.30,
        changePercent: 4.20,
        marketCap: '3.1T',
        peRatio: 18.25,
        dividendYield: 0.65,
        avgVolume: '8.5M',
        high52w: 1010.00,
        low52w: 502.00,
        description: 'Tata Motors Limited is an Indian multinational automotive manufacturing company, headquartered in Mumbai, and part of the Tata Group. The company produces passenger cars, trucks, vans, coaches, and buses.',
        history1D: generateHistory(924.50, 24, 0.01),
        history1W: generateHistory(890.00, 7, 0.022),
        history1M: generateHistory(820.00, 30, 0.04),
        history1Y: generateHistory(550.00, 12, 0.12),
        historyAll: generateHistory(300.00, 50, 0.25),
      ),
      Stock(
        symbol: 'RELI',
        name: 'Reliance Industries',
        sector: 'Energy/Telecom',
        price: 2845.00,
        change: 78.85,
        changePercent: 2.85,
        marketCap: '19.2T',
        peRatio: 25.40,
        dividendYield: 0.32,
        avgVolume: '4.8M',
        high52w: 3020.00,
        low52w: 2200.00,
        description: 'Reliance Industries Limited is an Indian multinational conglomerate, headquartered in Mumbai. Its diverse businesses include energy, petrochemicals, natural gas, retail, telecommunications, mass media, and textiles.',
        history1D: generateHistory(2845.00, 24, 0.007),
        history1W: generateHistory(2780.00, 7, 0.015),
        history1M: generateHistory(2700.00, 30, 0.028),
        history1Y: generateHistory(2300.00, 12, 0.08),
        historyAll: generateHistory(1800.00, 50, 0.15),
      ),
      Stock(
        symbol: 'HDFC',
        name: 'HDFC Bank Ltd.',
        sector: 'Banking',
        price: 1432.20,
        change: 26.95,
        changePercent: 1.92,
        marketCap: '10.9T',
        peRatio: 19.80,
        dividendYield: 1.35,
        avgVolume: '14.2M',
        high52w: 1720.00,
        low52w: 1360.00,
        description: 'HDFC Bank Limited is an Indian banking and financial services company headquartered in Mumbai. It is India\'s largest private sector bank by assets and the world\'s tenth-largest bank by market capitalization as of 2026.',
        history1D: generateHistory(1432.20, 24, 0.006),
        history1W: generateHistory(1410.00, 7, 0.012),
        history1M: generateHistory(1460.00, 30, 0.022),
        history1Y: generateHistory(1550.00, 12, 0.06),
        historyAll: generateHistory(1200.00, 50, 0.11),
      ),
      Stock(
        symbol: 'INFY',
        name: 'Infosys Ltd.',
        sector: 'Technology',
        price: 1475.00,
        change: -52.65,
        changePercent: -3.45,
        marketCap: '6.1T',
        peRatio: 24.12,
        dividendYield: 2.40,
        avgVolume: '6.1M',
        high52w: 1750.00,
        low52w: 1350.00,
        description: 'Infosys Limited is an Indian multinational information technology company that provides business consulting, information technology and outsourcing services. The company was founded in Pune and is headquartered in Bangalore.',
        history1D: generateHistory(1475.00, 24, 0.008),
        history1W: generateHistory(1510.00, 7, 0.016),
        history1M: generateHistory(1540.00, 30, 0.03),
        history1Y: generateHistory(1400.00, 12, 0.07),
        historyAll: generateHistory(1100.00, 50, 0.14),
      ),
      Stock(
        symbol: 'WIPR',
        name: 'Wipro Ltd.',
        sector: 'Technology',
        price: 482.15,
        change: -10.35,
        changePercent: -2.10,
        marketCap: '2.5T',
        peRatio: 21.30,
        dividendYield: 0.21,
        avgVolume: '5.2M',
        high52w: 540.00,
        low52w: 360.00,
        description: 'Wipro Limited is an Indian multinational corporation that provides information technology, consultant and business process services. It is headquartered in Bangalore, Karnataka, India.',
        history1D: generateHistory(482.15, 24, 0.006),
        history1W: generateHistory(490.00, 7, 0.014),
        history1M: generateHistory(465.00, 30, 0.024),
        history1Y: generateHistory(400.00, 12, 0.06),
        historyAll: generateHistory(300.00, 50, 0.12),
      ),
      Stock(
        symbol: 'ADAN',
        name: 'Adani Enterprises',
        sector: 'Conglomerate',
        price: 3210.50,
        change: -53.80,
        changePercent: -1.65,
        marketCap: '3.6T',
        peRatio: 98.40,
        dividendYield: 0.04,
        avgVolume: '1.8M',
        high52w: 3600.00,
        low52w: 1800.00,
        description: 'Adani Enterprises Limited is an Indian multinational conglomerate, headquartered in Ahmedabad. It is the flagship company of the Adani Group, primary involved in mining and trading of coal and iron ore, and expansion in green energy.',
        history1D: generateHistory(3210.50, 24, 0.015),
        history1W: generateHistory(3150.00, 7, 0.035),
        history1M: generateHistory(3300.00, 30, 0.06),
        history1Y: generateHistory(2500.00, 12, 0.18),
        historyAll: generateHistory(1200.00, 50, 0.4),
      ),
      Stock(
        symbol: 'NVDA',
        name: 'NVIDIA Corp.',
        sector: 'Technology',
        price: 894.22,
        change: 10.55,
        changePercent: 1.20,
        marketCap: '2.21T',
        peRatio: 72.40,
        dividendYield: 0.02,
        avgVolume: '42.1M',
        high52w: 974.00,
        low52w: 380.00,
        description: 'NVIDIA Corporation is an American multinational technology company incorporated in Delaware and based in Santa Clara, California. It is a software and fabless company which designs graphics processing units (GPUs).',
        history1D: generateHistory(894.22, 24, 0.012),
        history1W: generateHistory(875.00, 7, 0.028),
        history1M: generateHistory(810.00, 30, 0.05),
        history1Y: generateHistory(450.00, 12, 0.15),
        historyAll: generateHistory(180.00, 50, 0.3),
      ),
      Stock(
        symbol: 'SUNP',
        name: 'Sun Pharmaceutical',
        sector: 'Pharma',
        price: 1240.50,
        change: -5.00,
        changePercent: -0.40,
        marketCap: '2.9T',
        peRatio: 32.10,
        dividendYield: 0.90,
        avgVolume: '1.2M',
        high52w: 1350.00,
        low52w: 950.00,
        description: 'Sun Pharmaceutical Industries Limited is an Indian multinational pharmaceutical company headquartered in Mumbai, Maharashtra, which manufactures and sells pharmaceutical formulations and active pharmaceutical ingredients.',
        history1D: generateHistory(1240.50, 24, 0.005),
        history1W: generateHistory(1230.00, 7, 0.01),
        history1M: generateHistory(1210.00, 30, 0.02),
        history1Y: generateHistory(1050.00, 12, 0.05),
        historyAll: generateHistory(800.00, 50, 0.1),
      ),
    ];
  }

  // Mock Courses Initialization
  void _initializeMockCourses() {
    _courses = [
      Course(
        id: 'c1',
        title: 'Diagnostic Precision in Modern Oncology',
        category: 'Trading', // Keeping the categories relevant
        instructor: 'Dr. Elena Vance',
        price: 199.00,
        hours: 22.5,
        rating: 4.9,
        description: 'Evidence-based sessions designed for healthcare professionals and clinical mastery. Explore latest diagnostic oncology methodologies and precision therapies.',
        lessons: const [
          Lesson(title: 'Course Overview & Introductions', videoUrl: 'https://www.youtube.com/watch?v=17X2xH4XU6w'),
          Lesson(title: 'Biomarkers in Early Detection', videoUrl: 'https://www.youtube.com/watch?v=kYJj1Lz_bmg'),
          Lesson(title: 'Next-Generation Sequencing Applications', videoUrl: 'https://www.youtube.com/watch?v=qTj8KqR9N_M'),
          Lesson(title: 'Advanced Imaging and Radiogenomics', videoUrl: 'https://www.youtube.com/watch?v=kYJj1Lz_bmg'),
          Lesson(title: 'Case Studies: Solid Tumor Analysis', videoUrl: 'https://www.youtube.com/watch?v=17X2xH4XU6w'),
          Lesson(title: 'Liquid Biopsy in Treatment Response Tracking', videoUrl: 'https://www.youtube.com/watch?v=qTj8KqR9N_M'),
          Lesson(title: 'Immuno-oncology Diagnostics', videoUrl: 'https://www.youtube.com/watch?v=kYJj1Lz_bmg'),
          Lesson(title: 'Clinical Decision Support System Integration', videoUrl: 'https://www.youtube.com/watch?v=17X2xH4XU6w'),
        ],
        coverImage: 'oncology_course',
      ),
      Course(
        id: 'c2',
        title: 'Intro to Stock Market Trading',
        category: 'Trading',
        instructor: 'Sarah Jenkins (CFT)',
        price: 1499.00,
        hours: 12.0,
        rating: 4.8,
        description: 'Learn the fundamentals of stock market trading. Master candlestick charts, support & resistance, moving averages, and key risk management principles.',
        lessons: const [
          Lesson(title: 'Introduction to Financial Markets', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Understanding Order Types (Market, Limit)', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Reading Candlestick Charts', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Identifying Trends: Bullish vs Bearish', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Support & Resistance Basics', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Introduction to Moving Averages', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Risk Management and Stop Loss', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Creating Your First Simulated Trading Strategy', videoUrl: 'https://www.google.com'),
        ],
        coverImage: 'trading_course',
      ),
      Course(
        id: 'c3',
        title: 'Vinyasa Yoga Masterclass',
        category: 'Yoga',
        instructor: 'Swami Anand',
        price: 999.00,
        hours: 15.5,
        rating: 4.7,
        description: 'Align your mind, body, and breath. This course covers traditional Vinyasa sequences, breathing techniques (Pranayama), and meditation for stress relief.',
        lessons: const [
          Lesson(title: 'Introduction to Vinyasa & Breath Sync', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Sun Salutation (Surya Namaskar) A & B', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Standing Poses and Core Balance', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Hip Openers and Backbends', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Advanced Inversions: Headstands & Arm Balances', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Pranayama: Alternate Nostril Breathing', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Yogic Sleep (Yoga Nidra) for Restoration', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Daily 20-minute Flow Routine', videoUrl: 'https://www.google.com'),
        ],
        coverImage: 'yoga_course',
      ),
      Course(
        id: 'c4',
        title: 'Acoustic Guitar Blueprint',
        category: 'Music',
        instructor: 'Marcus Aurelius',
        price: 1299.00,
        hours: 18.0,
        rating: 4.9,
        description: 'From absolute beginner to fingerstyle master. Learn fundamental chords, strumming patterns, music theory, and popular song playthroughs step-by-step.',
        lessons: const [
          Lesson(title: 'Parts of the Guitar & Tuning Guide', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Essential Open Chords (G, C, D, Em, Am)', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Strumming Patterns & Rhythm Control', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Understanding Bar Chords (F & B minor)', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Introduction to Fingerstyle Picking', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Reading Tablature & Music Theory Basics', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Classic Song Walkthrough: Country/Rock', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Improvised Soloing & Pentatonic Scale', videoUrl: 'https://www.google.com'),
        ],
        coverImage: 'music_course',
      ),
      Course(
        id: 'c5',
        title: 'Hip Hop Dance & Choreography',
        category: 'Dance',
        instructor: 'Elena Rostova',
        price: 899.00,
        hours: 10.0,
        rating: 4.6,
        description: 'Learn popular street dance styles, grooves, and a complete high-energy routine. Designed for beginners who want to build rhythm and confidence.',
        lessons: const [
          Lesson(title: 'Warm-up & Body Isolations', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Basic Hip Hop Grooves: Bounce & Rock', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Footwork Fundamentals (Running Man, Slides)', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Arm styling and Hand-Eye Coordination', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Combining Grooves and Footwork', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Choreography Section Part 1', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Choreography Section Part 2', videoUrl: 'https://www.google.com'),
          Lesson(title: 'Performance Styling, Musicality & Freestyle', videoUrl: 'https://www.google.com'),
        ],
        coverImage: 'dance_course',
      ),
    ];
  }

  // Load Persisted Data from SharedPreferences
  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Balance
    _walletBalance = prefs.getDouble(keyWalletBalance) ?? 100000.00;

    // 2. Dark Mode
    _isDarkMode = prefs.getBool(keyDarkMode) ?? true;

    // 3. User Details
    _username = prefs.getString(keyUsername) ?? "Alexander Sterling";
    _password = prefs.getString(keyPassword) ?? "password";

    // Bookmarks & Profile Picture
    _bookmarkedNewsIds = prefs.getStringList('bookmarked_news_ids') ?? [];
    _profilePicturePath = prefs.getString('profile_picture_path') ?? '';
    _navigationIndex = prefs.getInt('navigation_index') ?? 0;
    _isLoggedIn = prefs.getBool('is_logged_in') ?? true;

    // 4. Wishlist
    final wishlistSymbols = prefs.getStringList(keyWishlist) ?? ['AAPL', 'GOOGL'];
    for (var stock in _stocks) {
      if (wishlistSymbols.contains(stock.symbol)) {
        stock.isFavorite = true;
      }
    }

    // 5. Transactions
    final txJson = prefs.getString(keyTransactions);
    if (txJson != null) {
      final List<dynamic> list = json.decode(txJson);
      _transactions = list.map((item) => StockTransaction.fromJson(item)).toList();
    } else {
      // Load mock starting transactions matching screenshots
      _transactions = [
        StockTransaction(
          id: 'tx1',
          symbol: 'TCS',
          stockName: 'Tata Consultancy Services',
          type: 'BUY',
          shares: 10,
          price: 3450.00,
          timestamp: DateTime.now().subtract(const Duration(days: 6)),
          totalAmount: 35000.00, // Includes simulated fees or rough rounded number
        ),
        StockTransaction(
          id: 'tx2',
          symbol: 'INFY',
          stockName: 'Infosys Ltd.',
          type: 'SELL',
          shares: 5,
          price: 1550.00,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          totalAmount: 7750.00,
          realizedProfitLoss: 2500.00,
        ),
        StockTransaction(
          id: 'tx3',
          symbol: 'HDFC',
          stockName: 'HDFC Bank Ltd.',
          type: 'BUY',
          shares: 100,
          price: 1654.00,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          totalAmount: 165400.00,
        ),
      ];
      _saveTransactions();
    }

    // 6. Top Up Logs
    final logsJson = prefs.getString(keyTopUpLogs);
    if (logsJson != null) {
      final List<dynamic> list = json.decode(logsJson);
      _topUpLogs = list.map((item) => TopUpLog.fromJson(item)).toList();
    } else {
      _topUpLogs = [
        TopUpLog(
          id: 'log1',
          amount: 50000.00,
          charge: 50.00,
          paymentMethod: 'UPI',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
      _saveTopUpLogs();
    }

    // 7. Course Purchases & Progress
    final purchasedCourseIds = prefs.getStringList(keyPurchasedCourses) ?? ['c1'];
    for (var course in _courses) {
      if (purchasedCourseIds.contains(course.id)) {
        course.isPurchased = true;
      }
      // Load completed lessons list
      final completedList = prefs.getStringList('${keyCourseProgress}_${course.id}') ?? [];
      course.completedLessons.clear();
      course.completedLessons.addAll(completedList);
    }
  }

  // Recalculate Holdings from Transactions
  void _recalculateHoldings() {
    _holdings.clear();
    _avgPurchasePrices.clear();

    // Process transactions in chronological order to calculate holdings and average buy price
    final sortedTx = List<StockTransaction>.from(_transactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (var tx in sortedTx) {
      final symbol = tx.symbol;
      final currentShares = _holdings[symbol] ?? 0.0;
      final currentAvg = _avgPurchasePrices[symbol] ?? 0.0;

      if (tx.type == 'BUY') {
        final newShares = currentShares + tx.shares;
        if (newShares > 0) {
          final newAvg = ((currentShares * currentAvg) + (tx.shares * tx.price)) / newShares;
          _holdings[symbol] = newShares;
          _avgPurchasePrices[symbol] = double.parse(newAvg.toStringAsFixed(2));
        }
      } else if (tx.type == 'SELL') {
        final newShares = max(0.0, currentShares - tx.shares);
        if (newShares == 0) {
          _holdings.remove(symbol);
          _avgPurchasePrices.remove(symbol);
        } else {
          _holdings[symbol] = newShares;
          // Selling does not change the average purchase price of remaining shares
        }
      }
    }
  }

  // Start Background Live Stock Price Simulator
  void _startPriceSimulation() {
    _priceUpdateTimer?.cancel();
    final random = Random();

    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      for (var stock in _stocks) {
        // Mock a small price swing between -0.4% and +0.6% (slight positive drift)
        double percentChange = (random.nextDouble() - 0.4) * 0.01;
        double priceDiff = stock.price * percentChange;
        
        stock.price = double.parse((stock.price + priceDiff).toStringAsFixed(2));
        stock.change = double.parse((stock.change + priceDiff).toStringAsFixed(2));
        
        // Calculate change percent relative to an estimated previous close (base price)
        double prevClose = stock.price - stock.change;
        if (prevClose != 0) {
          stock.changePercent = double.parse(((stock.change / prevClose) * 100).toStringAsFixed(2));
        }

        // Add current price to history charts, rotating out the oldest price
        _updateHistoryList(stock.history1D, stock.price);
      }
      notifyListeners();
    });
  }

  void _updateHistoryList(List<double> history, double currentPrice) {
    if (history.isNotEmpty) {
      history.removeAt(0);
      history.add(currentPrice);
    }
  }

  // Persists the current Wallet Balance
  Future<void> _saveWalletBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyWalletBalance, _walletBalance);
  }

  // Persists Transactions List
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _transactions.map((tx) => tx.toJson()).toList();
    await prefs.setString(keyTransactions, json.encode(jsonList));
  }

  // Persists Top Up Logs
  Future<void> _saveTopUpLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _topUpLogs.map((log) => log.toJson()).toList();
    await prefs.setString(keyTopUpLogs, json.encode(jsonList));
  }

  // Persists User Profile Details
  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUsername, _username);
    await prefs.setString(keyPassword, _password);
  }

  // Persists Wishlist state
  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> wishlistSymbols = _stocks
        .where((s) => s.isFavorite)
        .map((s) => s.symbol)
        .toList();
    await prefs.setStringList(keyWishlist, wishlistSymbols);
  }

  // Persists Course Purchases
  Future<void> _savePurchasedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> purchasedIds = _courses
        .where((c) => c.isPurchased)
        .map((c) => c.id)
        .toList();
    await prefs.setStringList(keyPurchasedCourses, purchasedIds);
  }

  // Persists Lesson Completion List for a specific course
  Future<void> _saveCourseProgress(Course course) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${keyCourseProgress}_${course.id}', course.completedLessons);
  }

  // Public Methods

  // Theme Management
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  // Wishlist / Favorites Toggle
  Future<void> toggleWishlist(Stock stock) async {
    stock.isFavorite = !stock.isFavorite;
    await _saveWishlist();
    notifyListeners();
  }

  // Buy Stock Execution
  Future<bool> buyStock(Stock stock, double shares) async {
    if (shares <= 0) return false;

    // Check price in INR
    double priceInInr = stock.price;
    if (stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA') {
      priceInInr = stock.price * usdToInr;
    }

    final subtotal = priceInInr * shares;
    final brokerageFee = subtotal * 0.001; // 0.1% fee
    final totalCost = subtotal + brokerageFee;

    if (_walletBalance < totalCost) {
      return false; // Insufficient Funds
    }

    _walletBalance -= totalCost;
    await _saveWalletBalance();

    // Record Transaction
    final transaction = StockTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      symbol: stock.symbol,
      stockName: stock.name,
      type: 'BUY',
      shares: shares,
      price: stock.price, // records price in original currency
      timestamp: DateTime.now(),
      totalAmount: totalCost, // transaction cost saved in INR
    );

    _transactions.insert(0, transaction);
    await _saveTransactions();

    _recalculateHoldings();
    notifyListeners();
    return true;
  }

  // Sell Stock Execution
  Future<bool> sellStock(Stock stock, double shares) async {
    final ownedShares = _holdings[stock.symbol] ?? 0.0;
    if (shares <= 0 || shares > ownedShares) {
      return false; // Insufficient shares
    }

    double priceInInr = stock.price;
    if (stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA') {
      priceInInr = stock.price * usdToInr;
    }

    final subtotal = priceInInr * shares;
    final brokerageFee = subtotal * 0.001; // 0.1% fee
    final totalRevenue = subtotal - brokerageFee;

    // Calculate Realized Profit/Loss
    final avgPrice = _avgPurchasePrices[stock.symbol] ?? 0.0;
    double avgPriceInInr = avgPrice;
    if (stock.symbol == 'AAPL' || stock.symbol == 'GOOGL' || stock.symbol == 'NVDA') {
      avgPriceInInr = avgPrice * usdToInr;
    }
    final originalCost = avgPriceInInr * shares;
    final profitLoss = totalRevenue - originalCost;

    _walletBalance += totalRevenue;
    await _saveWalletBalance();

    // Record Transaction
    final transaction = StockTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      symbol: stock.symbol,
      stockName: stock.name,
      type: 'SELL',
      shares: shares,
      price: stock.price,
      timestamp: DateTime.now(),
      totalAmount: totalRevenue,
      realizedProfitLoss: profitLoss,
    );

    _transactions.insert(0, transaction);
    await _saveTransactions();

    _recalculateHoldings();
    notifyListeners();
    return true;
  }

  // Wallet Top-up Simulation
  Future<void> topUpWallet(double amount, double charge, String paymentMethod) async {
    _walletBalance += amount;
    await _saveWalletBalance();

    final log = TopUpLog(
      id: 'topup_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      charge: charge,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
    );

    _topUpLogs.insert(0, log);
    await _saveTopUpLogs();

    notifyListeners();
  }

  // Course Purchase Flow
  Future<bool> purchaseCourse(Course course) async {
    if (course.isPurchased) return true;

    if (_walletBalance < course.price) {
      return false; // Insufficient funds
    }

    _walletBalance -= course.price;
    await _saveWalletBalance();

    course.isPurchased = true;
    await _savePurchasedCourses();

    notifyListeners();
    return true;
  }

  // Lesson Progress management
  Future<void> toggleLessonCompletion(Course course, String lessonTitle) async {
    if (course.completedLessons.contains(lessonTitle)) {
      course.completedLessons.remove(lessonTitle);
    } else {
      course.completedLessons.add(lessonTitle);
    }
    await _saveCourseProgress(course);
    notifyListeners();
  }

  /// Updates the user's password both locally and in the database via API.
  ///
  /// Returns `true` if current password was correct and the server database
  /// successfully committed the change.
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    if (currentPassword == _password) {
      final success = await ApiService().updatePassword(currentPassword, newPassword);
      if (success) {
        _password = newPassword;
        await _saveUserProfile();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Update Profile Name
  void updateUsername(String newName) {
    _username = newName;
    _saveUserProfile();
    notifyListeners();
  }

  // Login / Logout Simulation
  Future<void> loginUser(String user, String pass) async {
    if (user.trim().isNotEmpty && pass == _password) {
      _username = user;
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      notifyListeners();
    }
  }

  Future<void> logoutUser() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    notifyListeners();
  }

  Future<void> setNavigationIndex(int index) async {
    _navigationIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navigation_index', index);
    notifyListeners();
  }

  Future<void> toggleNewsBookmark(String newsId) async {
    if (_bookmarkedNewsIds.contains(newsId)) {
      _bookmarkedNewsIds.remove(newsId);
    } else {
      _bookmarkedNewsIds.add(newsId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarked_news_ids', _bookmarkedNewsIds);
    notifyListeners();
  }

  /// Uploads and sets the user's profile picture.
  ///
  /// Converts the local image file at [localPath] to an optimal base64 JPEG
  /// string, uploads it to the database API, and saves the resulting image
  /// database reference (base64 or remote URL) in local state and persistence.
  Future<void> setProfilePicture(String localPath) async {
    try {
      final bytes = await File(localPath).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64.encode(bytes)}';

      // Store in the database via ApiService
      final resultPath = await ApiService().uploadProfilePicture(base64Image);
      if (resultPath != null) {
        _profilePicturePath = resultPath;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_picture_path', _profilePicturePath);
        notifyListeners();
      }
    } catch (e) {
      print('[AppStateProvider] Error saving profile picture to database: $e');
    }
  }

  int _classesTabIndex = 0;
  int get classesTabIndex => _classesTabIndex;

  void setClassesTabIndex(int index) {
    _classesTabIndex = index;
    notifyListeners();
  }
}
