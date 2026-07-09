# Stock Learn Mobile App - API Documentation

This document describes the mobile API endpoints available for the **Stock Learn Mobile App**. All API endpoints communicate via JSON and are prefixed with `/api`.

---

## 1. Global Specifications

- **Base URL**: `https://<your-backend-domain>/api`
- **Headers**:
  - `Accept: application/json` (Required for all requests to ensure Laravel returns validation errors as JSON instead of HTML redirects).
  - `Content-Type: application/json` (Required for POST/PUT requests with payloads).
- **Authentication**: Powered by **Laravel Sanctum**. Protected endpoints require the client to supply the token as a Bearer Token:
  - Header: `Authorization: Bearer <your-plain-text-token>`

---

## 2. Authentication Endpoints

### 2.1 Register a New Account
Create a new mobile user account. Upon success, a Sanctum token is returned immediately.

- **Method**: `POST`
- **URI**: `/auth/register`
- **Authentication Required**: No
- **Request Body (JSON)**:
  | Field | Type | Rules | Description |
  | :--- | :--- | :--- | :--- |
  | `username` | String | Required, Max: 50, Unique in database | User's unique handle name |
  | `email` | String | Required, Valid Email, Unique in database | User's email address |
  | `password` | String | Required, Min: 8 characters | Account password |

- **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Registration successful.",
    "token": "1|abcdef1234567890...",
    "user": {
      "id": 5,
      "username": "trader_jane",
      "email": "jane@example.com",
      "is_guest": false,
      "is_active": true,
      "wallet_balance": "0.00",
      "profile_image": null,
      "created_at": "2026-07-09T17:30:10.000000Z",
      "updated_at": "2026-07-09T17:30:10.000000Z"
    }
  }
  ```
- **Validation Error Response (`422 Unprocessable Entity`)**:
  ```json
  {
    "message": "The username has already been taken.",
    "errors": {
      "username": ["The username has already been taken."]
    }
  }
  ```

---

### 2.2 User Login
Authenticate an existing user to retrieve a Sanctum token.

- **Method**: `POST`
- **URI**: `/auth/login`
- **Authentication Required**: No
- **Request Body (JSON)**:
  | Field | Type | Rules | Description |
  | :--- | :--- | :--- | :--- |
  | `email` | String | Required, Valid Email | The user's account email |
  | `password` | String | Required | The user's account password |

- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Login successful.",
    "token": "2|xyz789ghijkl...",
    "user": {
      "id": 5,
      "username": "trader_jane",
      "email": "jane@example.com",
      "is_guest": false,
      "is_active": true,
      "wallet_balance": "0.00",
      "profile_image": null,
      "last_login": "2026-07-09T17:35:22.000000Z",
      "created_at": "2026-07-09T17:30:10.000000Z",
      "updated_at": "2026-07-09T17:35:22.000000Z"
    }
  }
  ```
- **Inactive / Disabled Account Response (`403 Forbidden`)**:
  ```json
  {
    "success": false,
    "message": "Account disabled."
  }
  ```
- **Invalid Credentials Response (`401 Unauthorized`)**:
  ```json
  {
    "success": false,
    "message": "Invalid credentials."
  }
  ```

---

### 2.3 Get User Profile
Retrieve the profile details of the currently authenticated user.

- **Method**: `GET`
- **URI**: `/auth/profile`
- **Authentication Required**: **Yes**
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "user": {
      "id": 5,
      "username": "trader_jane",
      "email": "jane@example.com",
      "is_guest": false,
      "is_active": true,
      "wallet_balance": "0.00",
      "profile_image": "uploads/profiles/jane_avatar.png",
      "last_login": "2026-07-09T17:35:22.000000Z",
      "created_at": "2026-07-09T17:30:10.000000Z",
      "updated_at": "2026-07-09T17:35:22.000000Z"
    }
  }
  ```
- **Unauthenticated Response (`401 Unauthorized`)**:
  ```json
  {
    "message": "Unauthenticated."
  }
  ```

---

### 2.4 Logout
Revoke the access token currently used for authentication.

- **Method**: `POST`
- **URI**: `/auth/logout`
- **Authentication Required**: **Yes**
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Logged out successfully."
  }
  ```

---

### 2.5 Change Password
Update the authenticated user's password.

- **Method**: `POST`
- **URI**: `/auth/change-password`
- **Authentication Required**: **Yes**
- **Request Body (JSON)**:
  | Field | Type | Rules | Description |
  | :--- | :--- | :--- | :--- |
  | `current_password` | String | Required | Current account password |
  | `new_password` | String | Required, Min: 8, Different from current | Desired new password |
  | `new_password_confirmation` | String | Required, Must match `new_password` | Confirmation field |

- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Password changed successfully."
  }
  ```
- **Error Response - Incorrect Current Password (`422 Unprocessable Entity`)**:
  ```json
  {
    "success": false,
    "message": "Current password is incorrect."
  }
  ```

---

## 3. News Feed Endpoints

### 3.1 List News Articles
Fetch a paginated list of all published news articles.

- **Method**: `GET`
- **URI**: `/news`
- **Query Parameters**:
  - `page` (Optional, Integer): The page number for pagination. Defaults to `1`.
- **Authentication Required**: No
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "data": {
      "current_page": 1,
      "data": [
        {
          "id": 12,
          "admin_id": 1,
          "category_id": 3,
          "title": "Stock Market Rebounds After Interest Rate Announcement",
          "slug": "stock-market-rebounds-after-interest-rate-announcement",
          "summary": "Major stock indexes surged following the latest policy statement.",
          "content": "<p>Detailed HTML content of the article...</p>",
          "featured_image": "uploads/news/market_rebound.jpg",
          "source_name": "Reuters News",
          "is_featured": true,
          "is_published": true,
          "view_count": 142,
          "published_at": "2026-07-09T10:00:00.000000Z",
          "created_at": "2026-07-09T10:00:00.000000Z",
          "updated_at": "2026-07-09T10:30:15.000000Z",
          "category": {
            "id": 3,
            "name": "Market Analysis",
            "slug": "market-analysis"
          }
        }
      ],
      "first_page_url": "https://domain.com/api/news?page=1",
      "from": 1,
      "last_page": 3,
      "last_page_url": "https://domain.com/api/news?page=3",
      "next_page_url": "https://domain.com/api/news?page=2",
      "path": "https://domain.com/api/news",
      "per_page": 20,
      "prev_page_url": null,
      "to": 20,
      "total": 56
    }
  }
  ```

---

### 3.2 List Featured News Articles
Fetch a quick list of top featured news articles. Up to 10 articles are returned, ordered by publication date.

- **Method**: `GET`
- **URI**: `/news/featured`
- **Authentication Required**: No
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 12,
        "admin_id": 1,
        "category_id": 3,
        "title": "Stock Market Rebounds After Interest Rate Announcement",
        "slug": "stock-market-rebounds-after-interest-rate-announcement",
        "summary": "Major stock indexes surged following the latest policy statement.",
        "content": "<p>Detailed HTML content...</p>",
        "featured_image": "uploads/news/market_rebound.jpg",
        "source_name": "Reuters News",
        "is_featured": true,
        "is_published": true,
        "view_count": 142,
        "published_at": "2026-07-09T10:00:00.000000Z",
        "category": {
          "id": 3,
          "name": "Market Analysis",
          "slug": "market-analysis"
        }
      }
    ]
  }
  ```

---

### 3.3 Get News Article Details
Get detailed information of a single news article by its slug. This action also increments the `view_count` on the backend.

- **Method**: `GET`
- **URI**: `/news/{slug}`
- **Authentication Required**: No
- **Path Parameters**:
  - `slug` (Required, String): The URL-friendly identifier of the article (e.g. `stock-market-rebounds-after-interest-rate-announcement`).
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "data": {
      "id": 12,
      "admin_id": 1,
      "category_id": 3,
      "title": "Stock Market Rebounds After Interest Rate Announcement",
      "slug": "stock-market-rebounds-after-interest-rate-announcement",
      "summary": "Major stock indexes surged following the latest policy statement.",
      "content": "<p>Detailed HTML content...</p>",
      "featured_image": "uploads/news/market_rebound.jpg",
      "source_name": "Reuters News",
      "is_featured": true,
      "is_published": true,
      "view_count": 143,
      "published_at": "2026-07-09T10:00:00.000000Z",
      "created_at": "2026-07-09T10:00:00.000000Z",
      "updated_at": "2026-07-09T17:36:22.000000Z",
      "category": {
        "id": 3,
        "name": "Market Analysis",
        "slug": "market-analysis"
      },
      "admin": {
        "id": 1,
        "name": "Super Admin"
      }
    }
  }
  ```
- **Error Response - Not Found (`404 Not Found`)**:
  ```json
  {
    "message": "The record was not found."
  }
  ```

---

## 4. Learning Courses Endpoints

### 4.1 List Courses
Fetch a paginated list of all published courses.

- **Method**: `GET`
- **URI**: `/courses`
- **Query Parameters**:
  - `page` (Optional, Integer): The page number for pagination. Defaults to `1`.
- **Authentication Required**: No
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "data": {
      "current_page": 1,
      "data": [
        {
          "id": 3,
          "admin_id": 1,
          "category_id": 2,
          "title": "Introduction to Stock Valuation & Financial Statements",
          "slug": "introduction-to-stock-valuation-financial-statements",
          "description": "Learn the core techniques of stock picking and valuation.",
          "thumbnail": "uploads/courses/valuation_thumb.jpg",
          "preview_video_url": "https://www.youtube.com/watch?v=preview",
          "instructor_name": "Sarah Connor",
          "instructor_bio": "Chartered Financial Analyst (CFA) with 12 years wall street experience.",
          "instructor_avatar": "uploads/avatars/sarah.jpg",
          "price": "49.99",
          "is_cme_accredited": true,
          "total_hours": "3.50",
          "avg_rating": "4.90",
          "total_enrollments": 420,
          "is_featured": true,
          "is_published": true,
          "published_at": "2026-07-08T09:00:00.000000Z",
          "created_at": "2026-07-08T08:30:00.000000Z",
          "updated_at": "2026-07-08T09:00:00.000000Z",
          "category": {
            "id": 2,
            "name": "Valuation Basics",
            "slug": "valuation-basics"
          }
        }
      ],
      "first_page_url": "https://domain.com/api/courses?page=1",
      "from": 1,
      "last_page": 2,
      "last_page_url": "https://domain.com/api/courses?page=2",
      "next_page_url": null,
      "path": "https://domain.com/api/courses",
      "per_page": 20,
      "prev_page_url": null,
      "to": 8,
      "total": 8
    }
  }
  ```

---

### 4.2 List Featured Courses
Fetch a list of published and featured courses. Returns up to 10 items.

- **Method**: `GET`
- **URI**: `/courses/featured`
- **Authentication Required**: No
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 3,
        "admin_id": 1,
        "category_id": 2,
        "title": "Introduction to Stock Valuation & Financial Statements",
        "slug": "introduction-to-stock-valuation-financial-statements",
        "description": "Learn the core techniques of stock picking and valuation.",
        "thumbnail": "uploads/courses/valuation_thumb.jpg",
        "preview_video_url": "https://www.youtube.com/watch?v=preview",
        "instructor_name": "Sarah Connor",
        "instructor_bio": "Chartered Financial Analyst (CFA) with 12 years wall street experience.",
        "instructor_avatar": "uploads/avatars/sarah.jpg",
        "price": "49.99",
        "is_cme_accredited": true,
        "total_hours": "3.50",
        "avg_rating": "4.90",
        "total_enrollments": 420,
        "is_featured": true,
        "is_published": true,
        "published_at": "2026-07-08T09:00:00.000000Z",
        "category": {
          "id": 2,
          "name": "Valuation Basics",
          "slug": "valuation-basics"
        }
      }
    ]
  }
  ```

---

### 4.3 Get Course Details (with Modules)
Fetch full details of a specific course, including its modules/chapters sorted by their ordering index.

- **Method**: `GET`
- **URI**: `/courses/{slug}`
- **Authentication Required**: No
- **Path Parameters**:
  - `slug` (Required, String): The URL-friendly identifier of the course.
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "data": {
      "id": 3,
      "admin_id": 1,
      "category_id": 2,
      "title": "Introduction to Stock Valuation & Financial Statements",
      "slug": "introduction-to-stock-valuation-financial-statements",
      "description": "Learn the core techniques of stock picking and valuation.",
      "thumbnail": "uploads/courses/valuation_thumb.jpg",
      "preview_video_url": "https://www.youtube.com/watch?v=preview",
      "instructor_name": "Sarah Connor",
      "instructor_bio": "...",
      "instructor_avatar": "uploads/avatars/sarah.jpg",
      "price": "49.99",
      "is_cme_accredited": true,
      "total_hours": "3.50",
      "avg_rating": "4.90",
      "total_enrollments": 420,
      "is_featured": true,
      "is_published": true,
      "published_at": "2026-07-08T09:00:00.000000Z",
      "created_at": "...",
      "updated_at": "...",
      "category": {
        "id": 2,
        "name": "Valuation Basics",
        "slug": "valuation-basics"
      },
      "admin": {
        "id": 1,
        "name": "Super Admin"
      },
      "modules": [
        {
          "id": 8,
          "course_id": 3,
          "title": "Chapter 1: Understanding Balance Sheets",
          "video_url": "https://www.youtube.com/watch?v=balance_sheet",
          "video_duration_seconds": 3600,
          "thumbnail": "uploads/modules/balance_sheet_thumb.jpg",
          "order_index": 1,
          "is_free_preview": true,
          "created_at": "2026-07-08T09:30:00.000000Z",
          "updated_at": "2026-07-08T09:30:00.000000Z"
        },
        {
          "id": 9,
          "course_id": 3,
          "title": "Chapter 2: Discounted Cash Flow (DCF) Valuation Model",
          "video_url": "https://www.youtube.com/watch?v=dcf_valuation",
          "video_duration_seconds": 9000,
          "thumbnail": "uploads/modules/dcf_thumb.jpg",
          "order_index": 2,
          "is_free_preview": false,
          "created_at": "2026-07-08T09:40:00.000000Z",
          "updated_at": "2026-07-08T09:40:00.000000Z"
        }
      ]
    }
  }
  ```
- **Error Response - Not Found (`404 Not Found`)**:
  ```json
  {
    "message": "The record was not found."
  }
  ```
