# Bevdaa API Documentation

## Overview
This document outlines all required APIs for the Bevdaa Flutter application, including request/response structures, authentication requirements, and error handling.

**Base URL**: `https://gposdataservice.gpossystem.com/api/v1/` (Replace with actual API URL)

**Authentication**: All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer {token}
```

**Content-Type**: `application/json`

---

## Authentication APIs

### 1. Login with Password
**Endpoint**: `POST /login`

**Description**: Authenticate user with identifier (phone/email) and password.

**Request Body**:
```json
{
  "identifier": "string",  // Phone number or email
  "password": "string"
}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "token": "string",  // JWT or session token
  "message": "Login successful"
  "user": // User details
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

---

### 2. Send OTP
**Endpoint**: `POST /send-otp`

**Description**: Send OTP to user's phone/email for login or signup.

**Request Body**:
```json
{
  "phoneoremail": "string",  // Phone number or email
  "purpose": "string"      // "login" or "signup"
}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "message": "Invalid identifier or purpose"
}
```

---

### 3. Verify OTP
**Endpoint**: `POST /verify-otp`

**Description**: Verify OTP code for login or signup.

**Request Body**:
```json
{
  "phoneoremail": "string",  // Phone number or email
  "otp": "string",         // OTP code
  "purpose": "string"      // "login" or "signup"
}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "token": "string",  // JWT token (for login) or null (for signup)
  "message": "OTP verified successfully"
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "message": "Invalid or expired OTP"
}
```

---

### 4. Create Account
**Endpoint**: `POST /create-account`

**Description**: Create new user account (final step after OTP verification).

**Request Body**:
```json
{
  "phoneoremail": "string",  // Phone number or email
  "name": "string",         // User's full name
  "password": "string"      // User's password
}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "token": "string",  // JWT token
  "message": "Account created successfully"
  "user" : // User details
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "message": "Account creation failed"
}
```

---

## Home Screen APIs

### 5. Get User Points
**Endpoint**: `GET /user/points`

**Description**: Get user's current points balance and mission progress.

**Headers**:
```
Authorization: Bearer {token}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "points": 1250,
    "completed_missions": 4,
    "total_missions": 8
  }
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

### 6. Get Special Offers
**Endpoint**: `GET /special-offers`

**Description**: Get list of special offers. Can be filtered by type.

**Headers**:
```
Authorization: Bearer {token}
```

**Query Parameters**:
- `type` (optional): `"all"`, `"discounts"`, or `"buy1get1"`

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "category": "string",
      "availability": "string",
      "expires": "string",  
      "tag": "string",      // "Limited Time", "Popular", etc.
      "type": "string",    // "discounts", "buy1get1"
      "icon_type": "string", // "percentage" or "bottle"
      "stores": [
        {
          "id": "string",
          "name": "string",
          "address": "string",
          "hours": "string",  // Format: "9AM-9PM"
          "stock": "string"   // 
        }
      ]
    }
  ]
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

### 7. Get Recent Activity
**Endpoint**: `GET /recent-activity`

**Description**: Get user's recent activity (points earned/redeemed).

**Headers**:
```
Authorization: Bearer {token}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "type": "string",        // "Points Earned", "Points Redeemed", etc.
      "description": "string", // "Purchase at Downtown Spirits"
      "date": "string",        // 
      "time": "string",        // Format: "6:42 PM"
      "points": 150,
      "is_positive": true      // true for earned, false for redeemed
    }
  ]
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

## Purchase History APIs

### 8. Get Purchase History
**Endpoint**: `GET /purchase-history`

**Description**: Get user's complete purchase history with summary statistics.

**Headers**:
```
Authorization: Bearer {token}
```

**Query Parameters** (Optional - for filtering):
- `type` (optional): `"purchase"` or `"reward"`
- `start_date` (optional): Date filter start (ISO 8601 format)
- `end_date` (optional): Date filter end (ISO 8601 format)

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "points_balance": 1250,
    "points_earned": 406,
    "points_redeemed": 1750,
    "earned_transactions_count": 6,
    "redeemed_transactions_count": 3,
    "transactions": [
      {
        "id": "string",
        "type": "string",        // "purchase" or "reward"
        "description": "string", // "Purchase at Downtown Spirits"
        "date": "string",        // Format: "Aug 15, 2023"
        "time": "string",        // Format: "2:30 PM"
        "points": 500,
        "is_positive": false     // true for earned, false for redeemed
      }
    ]
  }
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

## Barcode/QR Code APIs

### 9. Get User QR Data
**Endpoint**: `GET /user/qr-data`

**Description**: Get user's QR code data for rewards scanning.

**Headers**:
```
Authorization: Bearer {token}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "name": "string",           // User's full name
    "member_number": "string",  // Format: "SP-984752"
    "points": 1250,
    "member_type": "string",    // "VIP Member", "Gold Member", etc.
    "qr_code":"string" // QR code
  }
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

## Rewards/Redemption APIs

### 10. Generate Redemption Code
**Endpoint**: `POST /rewards/generate-code`

**Description**: Generate a redemption code for points redemption.

**Headers**:
```
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "amount": "string",  // Redemption amount (e.g., "75")
  "store": "string"    // Store name (e.g., "Westside")
}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "code": "string",           // Redemption code (e.g., "RED12345678")
  "message": "Redemption code generated successfully",
  "amount": "string",
  "store": "string",
  "expires_at": "string"      // ISO 8601 format
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "message": "Insufficient points" // or other error message
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

## Error Handling

### Standard Error Response Format
All error responses follow this structure:

```json
{
  "success": false,
  "message": "Error message description",
  "error": "Detailed error information (optional)"
}
```

### HTTP Status Codes
- `200 OK`: Request successful
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Missing or invalid authentication token
- `403 Forbidden`: User doesn't have permission
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

### Network Error Handling
The app handles the following network errors:
- `SocketException`: No internet connection
- `TimeoutException`: Request timeout
- `DioException`: HTTP error responses

---

## Data Models

### PointsData
```json
{
  "points": 1250,
  "completed_missions": 4,
  "total_missions": 8
}
```

### SpecialOffer
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "category": "string",
  "availability": "string",
  "expires": "string",
  "tag": "string",
  "type": "string",
  "icon_type": "string",
  "stores": [Store]
}
```

### Store
```json
{
  "id": "string",
  "name": "string",
  "address": "string",
  "hours": "string",
  "stock": "string"
}
```

### RecentActivity
```json
{
  "id": "string",
  "type": "string",
  "description": "string",
  "date": "string",
  "time": "string",
  "points": 150,
  "is_positive": true
}
```

### PurchaseHistory
```json
{
  "id": "string",
  "type": "string",
  "description": "string",
  "date": "string",
  "time": "string",
  "points": 500,
  "is_positive": false
}
```

### PurchaseHistorySummary
```json
{
  "points_balance": 1250,
  "points_earned": 406,
  "points_redeemed": 1750,
  "earned_transactions_count": 6,
  "redeemed_transactions_count": 3,
  "transactions": [PurchaseHistory]
}
```

---

## Date/Time Formats

- **Date Format**: `"MMM dd, yyyy"` (e.g., "Jul 28, 2023", "Aug 15, 2023")
- **Time Format**: `"h:mm a"` (e.g., "6:42 PM", "2:30 PM")
- **ISO 8601**: Used for API date filters and expiration dates (e.g., "2023-08-15T14:30:00Z")

---

## Notes

1. **Token Management**: 
   - Tokens are stored in SharedPreferences as `auth_token`
   - Tokens are automatically added to all authenticated requests via interceptor
   - On 401 response, token should be cleared and user redirected to login

2. **Pagination**: 
   - Currently, all endpoints return complete data
   - Consider adding pagination for large datasets (purchase history, offers)

3. **Caching**: 
   - Consider implementing response caching for offers and user data
   - Cache invalidation on user actions (points update, redemption, etc.)

4. **Rate Limiting**: 
   - Be aware of API rate limits
   - Implement retry logic with exponential backoff

5. **Offline Support**: 
   - Consider caching critical data for offline access
   - Show cached data with offline indicator when network is unavailable

---

## Testing Checklist

- [ ] Test all endpoints with valid authentication
- [ ] Test error handling (401, 400, 500)
- [ ] Test network error scenarios
- [ ] Test token expiration handling
- [ ] Test OTP flow (send, verify, resend)
- [ ] Test redemption code generation with various amounts
- [ ] Test purchase history filtering
- [ ] Test special offers filtering by type
- [ ] Verify date/time formats match expected formats
- [ ] Test with empty/null data responses

---

**Last Updated**: [Current Date]
**Version**: 1.0.0

