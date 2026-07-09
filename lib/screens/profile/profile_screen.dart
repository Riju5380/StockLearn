import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/profile_avatar.dart';
import '../auth_screen.dart';
import 'top_up_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context, appState);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Profile Avatar & Name Info matching screenshots
            _buildProfileHeader(context, appState, isDark),
            const SizedBox(height: 24),

            // 2. Virtual Wallet Card
            _buildWalletCard(context, appState),
            const SizedBox(height: 24),

            // 3. Preferences & Security Section
            Text(
              'PREFERENCES & SECURITY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 12),
            _buildPreferencesList(context, appState, isDark),
            const SizedBox(height: 24),

            // 4. Sign Out button matching screenshots
            OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(context, appState);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: isDark ? Colors.white30 : Colors.black26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // 5. App Version text matching screenshots
            Center(
              child: Text(
                'App Version 2.4.0 (Build 982)',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Profile Header block
  Widget _buildProfileHeader(BuildContext context, AppStateProvider appState, bool isDark) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 54,
              backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
              child: const ProfileAvatar(radius: 50, iconSize: 55),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF2563EB),
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                  onPressed: () {
                    _showAvatarEditOptions(context, appState);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          appState.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          'Premium Member since 2026',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ],
    );
  }

  // Wallet Card matching screenshots
  Widget _buildWalletCard(BuildContext context, AppStateProvider appState) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'VIRTUAL WALLET BALANCE',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '₹${appState.walletBalance.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.trending_up, color: Color(0xFF10B981), size: 14),
              SizedBox(width: 4),
              Text(
                '+2.4% vs last month',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TopUpScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A), // Slate blue primary
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: const Icon(Icons.account_balance_wallet, size: 18),
            label: const Text('Top up Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // Preferences lists matching screenshots
  Widget _buildPreferencesList(BuildContext context, AppStateProvider appState, bool isDark) {
    Widget prefRow(IconData icon, Color color, String title, String subtitle, Widget trailing) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: FaIcon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      );
    }

    return Column(
      children: [
        // 1. Appearance (Theme Switch)
        prefRow(
          FontAwesomeIcons.palette,
          const Color(0xFF2563EB),
          'Appearance',
          'Switch to Light or Dark mode',
          Switch(
            value: appState.isDarkMode,
            activeColor: const Color(0xFF1E3A8A),
            onChanged: (val) {
              appState.toggleDarkMode();
            },
          ),
        ),
        const SizedBox(height: 10),

        // 2. Security (Password change)
        GestureDetector(
          onTap: () => _showChangePasswordDialog(context, appState),
          child: prefRow(
            FontAwesomeIcons.shieldHalved,
            const Color(0xFF10B981),
            'Security',
            'Update password and security details',
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),

        // 3. Purchased Courses Shortcut
        GestureDetector(
          onTap: () {
            appState.setNavigationIndex(1);
            appState.setClassesTabIndex(1);
          },
          child: prefRow(
            FontAwesomeIcons.graduationCap,
            const Color(0xFFD97706),
            'My Courses',
            'View all your unlocked courses',
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),

        // 4. Support
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Contact Support'),
                content: const Text('For support questions, please email support@stocklearn.com. Our simulated staff is available 24/7.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: prefRow(
            FontAwesomeIcons.circleQuestion,
            const Color(0xFF7C3AED),
            'Support',
            'Help center & direct contact details',
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // Edit profile dialog
  void _showEditNameDialog(BuildContext context, AppStateProvider appState) {
    final controller = TextEditingController(text: appState.username);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                appState.updateUsername(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Edit avatar selection flows
  void _showAvatarEditOptions(BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF2563EB)),
              title: const Text('Edit Display Name'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditNameDialog(context, appState);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF10B981)),
              title: const Text('Change Profile Picture'),
              onTap: () {
                Navigator.pop(ctx);
                _showImagePickerSourceSheet(context, appState);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerSourceSheet(BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _promptCameraPermission(context, appState);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF10B981)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _promptGalleryPermission(context, appState);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _promptCameraPermission(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.photo_camera, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Text('Camera Permission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'StockLearn requires camera access to take a profile picture. Do you want to grant this permission?',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permission Denied. Cannot take photo.')),
              );
            },
            child: const Text('Deny', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _pickImage(context, appState, ImageSource.camera);
            },
            child: const Text('Allow', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _promptGalleryPermission(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.photo_library, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text('Media Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'StockLearn requires access to your photo library to choose an image. Do you want to grant access?',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Media access denied. Cannot choose photo.')),
              );
            },
            child: const Text('Deny', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _pickImage(context, appState, ImageSource.gallery);
            },
            child: const Text('Allow', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, AppStateProvider appState, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await appState.setProfilePicture(pickedFile.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Displays the change password dialog, prompting for current and new passwords.
  ///
  /// Calls [AppStateProvider.updatePassword] asynchronously and displays a success
  /// or error SnackBar upon server confirmation.
  void _showChangePasswordDialog(BuildContext context, AppStateProvider appState) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final success = await appState.updatePassword(oldPassCtrl.text, newPassCtrl.text);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Password updated successfully!' : 'Incorrect current password.'),
                    backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Logout dialog
  void _showLogoutDialog(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from the trading simulator?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              appState.logoutUser();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
