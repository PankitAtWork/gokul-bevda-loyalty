# API Integration Readiness Checklist

## ✅ Current Status: Ready for API Integration

### 1. **API Service Structure** ✅
- **Location**: `lib/services/api_service.dart`
- **Status**: Properly structured with Dio HTTP client
- **Base URL**: Centralized in `lib/config/api_config.dart` (`ApiConfig.baseUrl = 'https://gposdataservice.gpossystem.com/api/v1/'`)
- **Timeouts**: Configured (10 seconds connect/receive)

### 2. **API Endpoints** ✅
All endpoints are defined in `lib/services/api_endpoints.dart`:
- ✅ `/login` - Login with password
- ✅ `/send-otp` - Send OTP for login/signup
- ✅ `/verify-otp` - Verify OTP
- ✅ `/create-account` - Create account
- ✅ `/user/points` - Get user points
- ✅ `/special-offers` - Get special offers
- ✅ `/recent-activity` - Get recent activity
- ✅ `/purchase-history` - Get purchase history
- ✅ `/user/qr-data` - Get QR code data
- ✅ `/rewards/generate-code` - Generate redemption code

### 3. **Models with JSON Serialization** ✅
All models have `fromJson` and `toJson` methods:
- ✅ `PointsData` - User points data
- ✅ `SpecialOffer` - Special offers with stores
- ✅ `RecentActivity` - Recent activity items
- ✅ `PurchaseHistory` - Purchase history items
- ✅ `PurchaseHistorySummary` - Purchase history summary
- ✅ `Store` - Store information

### 4. **Authentication** ✅
- ✅ Token storage via SharedPreferences
- ✅ AuthProvider handles login/signup flows
- ✅ Token loading on app start
- ⚠️ **TODO**: Add authentication interceptor to automatically attach tokens

### 5. **Error Handling** ✅
- ✅ Network error detection
- ✅ DioException handling
- ✅ User-friendly error messages
- ✅ Error dialogs in place

### 6. **Loading States** ✅
- ✅ Loading indicators in all screens
- ✅ Button loading states (e.g., redemption code generation)

### 7. **API Methods Ready for Integration** ✅

#### Current Mock Methods (Need Real API Calls):
1. **`getUserPoints()`** - Returns `PointsData`
   - Endpoint: `GET /user/points`
   - Currently: Mock data with delay

2. **`getSpecialOffers({String? type})`** - Returns `List<SpecialOffer>`
   - Endpoint: `GET /special-offers?type={type}`
   - Currently: Mock data with delay

3. **`getRecentActivity()`** - Returns `List<RecentActivity>`
   - Endpoint: `GET /recent-activity`
   - Currently: Mock data with delay

4. **`getPurchaseHistory()`** - Returns `PurchaseHistorySummary`
   - Endpoint: `GET /purchase-history`
   - Currently: Mock data with delay

5. **`getUserQrData()`** - Returns `Map<String, dynamic>`
   - Endpoint: `GET /user/qr-data`
   - Currently: Mock data with delay

6. **`generateRedemptionCode({amount, store})`** - Returns `Map<String, dynamic>`
   - Endpoint: `POST /rewards/generate-code`
   - Body: `{amount: string, store: string}`
   - Currently: Mock data with delay

### 8. **Hardcoded Values to Replace** ⚠️

#### Base URLs:
- ✅ Handled globally via `ApiConfig.baseUrl` (update here to change environments)

#### Mock Data:
- All API methods in `api_service.dart` return mock data
- Auth provider has hardcoded `"serverToken"` in error handlers (lines 194, 203)

### 9. **What Needs to Be Done** 📝

#### Critical:
1. **Add Authentication Interceptor**
   - Automatically add `Authorization: Bearer {token}` header to all requests
   - Handle token refresh if needed
   - Handle 401 errors (unauthorized)

2. **Replace Mock API Calls**
   - Replace all `Future.delayed()` with actual `dio.get()` / `dio.post()` calls
   - Use `ApiEndpoints` constants
   - Parse responses using model `fromJson()` methods

3. **Update Base URL**
   - Replace `'https://gposdataservice.gpossystem.com/api/v1/'` in `main.dart` with actual API URL
   - Consider using environment variables or config file

4. **Centralize ApiService Instance**
   - Currently each screen creates its own instance
   - Should use dependency injection or singleton pattern
   - Pass token from AuthProvider

#### Recommended:
5. **Add Request/Response Logging**
   - Uncomment logging in interceptor for debugging
   - Or use `LogInterceptor` from Dio

6. **Add Retry Logic**
   - For network failures
   - Consider using `retry` package

7. **Add Request Cancellation**
   - Cancel requests when screen is disposed

### 10. **API Response Format Expected**

#### Success Response Format:
```json
{
  "success": true,
  "data": {...},
  "message": "Success message"
}
```

#### Error Response Format:
```json
{
  "success": false,
  "message": "Error message",
  "error": "Error details"
}
```

### 11. **Authentication Token Format**
- Token stored in SharedPreferences as `'auth_token'`
- Should be added to headers as: `Authorization: Bearer {token}`
- Token should be loaded from AuthProvider

### 12. **Files That Need API Integration**

1. **`lib/services/api_service.dart`**
   - Replace all mock methods with real API calls
   - Add authentication interceptor

2. **`lib/main.dart`**
   - Update base URL
   - Consider dependency injection for ApiService

3. **`lib/providers/auth_provider.dart`**
   - Remove hardcoded `"serverToken"` strings
   - Ensure proper error handling

### 13. **Testing Checklist**
- [ ] Test all endpoints with real API
- [ ] Test authentication flow
- [ ] Test error handling (network errors, 401, 500, etc.)
- [ ] Test loading states
- [ ] Test on different screen sizes
- [ ] Test token expiration handling

---

## Quick Start Guide

1. **Update Base URL** in `lib/main.dart`:
   ```dart
   final apiService = ApiService.create(baseUrl: 'YOUR_ACTUAL_API_URL');
   ```

2. **Add Auth Interceptor** (see example below)

3. **Replace Mock Methods** in `api_service.dart`:
   ```dart
   Future<PointsData> getUserPoints() async {
     final response = await dio.get(ApiEndpoints.getUserPoints);
     return PointsData.fromJson(response.data['data']);
   }
   ```

4. **Test Each Endpoint** one by one

---

## Example: Adding Authentication Interceptor

Add this to `ApiService.create()` method:
```dart
// Add auth interceptor
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Load token from SharedPreferences
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (err, handler) {
      if (err.response?.statusCode == 401) {
        // Handle unauthorized - clear token and navigate to login
        // You may want to use a callback or event bus here
      }
      handler.next(err);
    },
  ),
);
```

---

**Status**: ✅ **READY FOR API INTEGRATION**
All models, endpoints, and error handling are in place. Just need to replace mock calls with real API calls.

