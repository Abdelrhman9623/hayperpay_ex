# HyperPay Mobile SDK Integration for Flutter

This guide explains how to integrate the HyperPay Mobile SDK into your Flutter application, following the official [HyperPay Mobile SDK documentation](https://wordpresshyperpay.docs.oppwa.com/integrations/mobile-sdk/).

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Setup Instructions](#setup-instructions)
5. [Integration Steps](#integration-steps)
6. [Usage Examples](#usage-examples)
7. [API Reference](#api-reference)
8. [Security Considerations](#security-considerations)
9. [Testing](#testing)
10. [Troubleshooting](#troubleshooting)

## Overview

The HyperPay Mobile SDK integration follows the official three-step architecture:

1. **Get Checkout ID** - Your server communicates with HyperPay to get a unique checkout ID
2. **Process Payment** - Use the checkout ID to process payment with ready-to-use UI or custom UI
3. **Get Payment Status** - Verify the payment status from your server

### Key Features

- ✅ **Official Architecture Compliance** - Follows HyperPay's three-step process
- ✅ **Server Communication** - Proper server-to-server communication for security
- ✅ **Ready-to-Use UI** - HyperPay's pre-built checkout screens
- ✅ **Custom UI Support** - Build your own payment forms
- ✅ **Tokenization** - Store payment methods for future use
- ✅ **Payment History** - Local storage of transaction history
- ✅ **Error Handling** - Comprehensive error management
- ✅ **Sandbox/Production** - Environment switching support

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Your Server     │    │  HyperPay API   │
│                 │◄──►│                  │◄──►│                 │
│ - UI Components │    │ - Authentication │    │ - Payment       │
│ - SDK Service   │    │ - Checkout ID    │    │ - Processing    │
│ - Local Storage │    │ - Status Check   │    │ - Tokenization  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Integration Flow

1. **App → Server**: Send payment details to get checkout ID
2. **Server → HyperPay**: Request checkout ID with authentication
3. **HyperPay → Server**: Return checkout ID
4. **Server → App**: Provide checkout ID to app
5. **App → HyperPay**: Process payment using checkout ID
6. **App → Server**: Request payment status
7. **Server → HyperPay**: Check payment status
8. **HyperPay → Server**: Return payment status
9. **Server → App**: Provide payment status to app

## Prerequisites

- Flutter SDK 3.7.0 or higher
- HyperPay merchant account
- Access token and merchant ID from HyperPay
- Backend server to handle HyperPay API communication
- Internet connectivity for API calls

## Setup Instructions

### 1. Add Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HyperPay SDK dependencies
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Your Server

You need to set up server endpoints that communicate with HyperPay. The Flutter app will call these endpoints:

#### Required Server Endpoints:

1. **POST /api/checkout/create** - Create checkout ID
2. **GET /api/checkout/{id}/status** - Get payment status
3. **POST /api/tokenize** - Tokenize payment method

#### Example Server Response for Checkout Creation:

```json
{
  "checkoutId": "checkout_123456789",
  "status": "success"
}
```

#### Example Server Response for Payment Status:

```json
{
  "status": "completed",
  "transactionId": "TXN_123456789",
  "amount": 99.99,
  "currency": "USD"
}
```

## Integration Steps

### Step 1: Initialize the SDK

```dart
import 'package:your_app/services/hyperpay_sdk_service.dart';

final hyperPayService = HyperPaySDKService();

// Initialize the SDK
final success = await hyperPayService.initialize(
  merchantId: 'your_merchant_id_here',
  accessToken: 'your_access_token_here',
  isProduction: false, // Use sandbox for testing
);

if (success) {
  print('HyperPay SDK initialized successfully');
} else {
  print('Failed to initialize HyperPay SDK');
}
```

### Step 2: Get Checkout ID

```dart
// Get checkout ID from your server
final checkoutId = await hyperPayService.getCheckoutId(
  amount: 99.99,
  currency: 'USD',
  customerEmail: 'customer@example.com',
  customerName: 'John Doe',
  customerPhone: '+1234567890',
  description: 'Payment for services',
  metadata: {
    'source': 'flutter_app',
    'platform': 'mobile',
  },
);

if (checkoutId != null) {
  print('Checkout ID received: $checkoutId');
} else {
  print('Failed to get checkout ID');
}
```

### Step 3: Process Payment

#### Option A: Ready-to-Use UI

```dart
// Process payment with HyperPay's ready-to-use UI
final result = await hyperPayService.processPaymentWithUI(
  checkoutId: checkoutId,
  amount: 99.99,
  currency: 'USD',
  customerEmail: 'customer@example.com',
  customerName: 'John Doe',
  customerPhone: '+1234567890',
  description: 'Payment via HyperPay',
);

print('Payment result: ${result.transactionId}');
print('Status: ${result.status}');
```

#### Option B: Custom UI

```dart
// Process payment with your own UI
final paymentDetails = {
  'amount': 99.99,
  'currency': 'USD',
  'customerEmail': 'customer@example.com',
  'cardNumber': '4111111111111111',
  'expiryMonth': '12',
  'expiryYear': '2025',
  'cvv': '123',
};

final result = await hyperPayService.processPaymentWithCustomUI(
  checkoutId: checkoutId,
  paymentDetails: paymentDetails,
);

print('Payment result: ${result.transactionId}');
```

### Step 4: Get Payment Status

```dart
// Get payment status from your server
final status = await hyperPayService.getPaymentStatus(checkoutId);

switch (status) {
  case HyperPayPaymentStatus.completed:
    print('Payment completed successfully');
    break;
  case HyperPayPaymentStatus.pending:
    print('Payment is pending');
    break;
  case HyperPayPaymentStatus.failed:
    print('Payment failed');
    break;
  case HyperPayPaymentStatus.cancelled:
    print('Payment was cancelled');
    break;
  default:
    print('Unknown payment status');
}
```

## Usage Examples

### Complete Payment Flow

```dart
Future<void> processCompletePayment() async {
  try {
    // Step 1: Get Checkout ID
    final checkoutId = await hyperPayService.getCheckoutId(
      amount: 99.99,
      currency: 'USD',
      customerEmail: 'customer@example.com',
    );

    if (checkoutId == null) {
      throw Exception('Failed to get checkout ID');
    }

    // Step 2: Process Payment
    final result = await hyperPayService.processPaymentWithUI(
      checkoutId: checkoutId,
      amount: 99.99,
      currency: 'USD',
      customerEmail: 'customer@example.com',
    );

    // Step 3: Get Payment Status
    final status = await hyperPayService.getPaymentStatus(checkoutId);

    if (status == HyperPayPaymentStatus.completed) {
      print('Payment successful: ${result.transactionId}');
    } else {
      print('Payment status: $status');
    }

  } catch (e) {
    print('Payment failed: $e');
  }
}
```

### Tokenization Example

```dart
// Tokenize payment method for future use
final token = await hyperPayService.tokenizePaymentMethod(
  checkoutId: checkoutId,
  paymentDetails: {
    'cardNumber': '4111111111111111',
    'expiryMonth': '12',
    'expiryYear': '2025',
    'cvv': '123',
  },
);

if (token != null) {
  // Store token securely for future use
  print('Payment method tokenized: $token');
}

// Use token for future payments
final result = await hyperPayService.processPaymentWithToken(
  checkoutId: newCheckoutId,
  token: token,
  amount: 50.00,
  currency: 'USD',
);
```

### Payment History

```dart
// Get stored payment history
final history = await hyperPayService.getStoredPaymentHistory();

for (final payment in history) {
  print('Transaction: ${payment.transactionId}');
  print('Amount: \$${payment.amount} ${payment.currency}');
  print('Status: ${payment.status}');
  print('Date: ${payment.timestamp}');
}

// Clear payment history
await hyperPayService.clearStoredPaymentHistory();
```

## API Reference

### HyperPaySDKService

#### Methods

- `initialize()` - Initialize the SDK with credentials
- `getCheckoutId()` - Get checkout ID from server
- `processPaymentWithUI()` - Process payment with ready-to-use UI
- `processPaymentWithCustomUI()` - Process payment with custom UI
- `processPaymentWithToken()` - Process payment using stored token
- `getPaymentStatus()` - Get payment status from server
- `tokenizePaymentMethod()` - Tokenize payment method
- `getStoredPaymentHistory()` - Get local payment history
- `clearStoredPaymentHistory()` - Clear local payment history
- `dispose()` - Clean up SDK resources

#### Properties

- `isInitialized` - Check if SDK is initialized

### HyperPayPaymentResult

#### Properties

- `checkoutId` - Unique checkout identifier
- `transactionId` - Transaction identifier
- `status` - Payment status
- `amount` - Payment amount
- `currency` - Payment currency
- `message` - Status message
- `timestamp` - Transaction timestamp

### HyperPayPaymentStatus

#### Values

- `pending` - Payment is pending
- `completed` - Payment completed successfully
- `failed` - Payment failed
- `cancelled` - Payment was cancelled
- `unknown` - Unknown status

## Security Considerations

### 1. Server-Side Security

- **Never store credentials in the app** - Keep merchant ID and access token on your server
- **Use HTTPS** - Always use secure connections
- **Validate all inputs** - Sanitize and validate all data on your server
- **Implement proper authentication** - Use secure authentication for your API endpoints

### 2. Client-Side Security

- **Don't store sensitive data** - Avoid storing card details locally
- **Use secure storage** - Use Flutter's secure storage for tokens
- **Validate inputs** - Validate all user inputs before sending to server
- **Handle errors securely** - Don't expose sensitive information in error messages

### 3. Network Security

- **Certificate pinning** - Implement certificate pinning for production
- **Request signing** - Sign requests if required by HyperPay
- **Rate limiting** - Implement rate limiting on your server
- **Logging** - Log security events for monitoring

## Testing

### Sandbox Environment

For testing, use the sandbox environment:

```dart
await hyperPayService.initialize(
  merchantId: 'your_sandbox_merchant_id',
  accessToken: 'your_sandbox_access_token',
  isProduction: false,
);
```

### Test Cards

Use the following test card numbers:

- **Visa**: 4111111111111111
- **Mastercard**: 5555555555554444
- **American Express**: 378282246310005

### Error Testing

Test various error scenarios:

```dart
// Test invalid checkout ID
try {
  await hyperPayService.processPaymentWithUI(
    checkoutId: 'invalid_checkout_id',
    amount: 99.99,
    currency: 'USD',
    customerEmail: 'test@example.com',
  );
} catch (e) {
  print('Expected error: $e');
}

// Test network errors
// Disconnect internet and test API calls

// Test server errors
// Configure server to return error responses
```

## Troubleshooting

### Common Issues

1. **SDK Not Initialized**
   - Ensure you call `initialize()` before any operations
   - Check that credentials are correct
   - Verify network connectivity

2. **Checkout ID Errors**
   - Verify server endpoints are working
   - Check authentication credentials
   - Ensure proper request format

3. **Payment Processing Errors**
   - Verify checkout ID is valid
   - Check payment details format
   - Ensure sufficient funds for test cards

4. **Network Errors**
   - Check internet connectivity
   - Verify server URLs are correct
   - Check firewall settings

### Debug Mode

Enable debug logging:

```dart
// Debug prints are automatically included
// Check console output for detailed logs
```

### Error Codes

- `INVALID_ARGUMENTS` - Invalid input parameters
- `NOT_INITIALIZED` - SDK not initialized
- `CHECKOUT_ID_ERROR` - Checkout ID related errors
- `PAYMENT_ERROR` - Payment processing errors
- `NETWORK_ERROR` - Network connectivity issues
- `SERVER_ERROR` - Server communication errors

## Migration Guide

### From Other Payment SDKs

1. **Update initialization** - Replace existing SDK initialization with HyperPay
2. **Update payment flow** - Implement the three-step HyperPay process
3. **Update server endpoints** - Create HyperPay-compatible server endpoints
4. **Test thoroughly** - Test all payment scenarios in sandbox

### Version Updates

1. **Check release notes** - Review HyperPay SDK release notes
2. **Update dependencies** - Update to latest compatible versions
3. **Test compatibility** - Test with existing code
4. **Update documentation** - Update integration documentation

## Support

For additional support:

- [HyperPay Mobile SDK Documentation](https://wordpresshyperpay.docs.oppwa.com/integrations/mobile-sdk/)
- [HyperPay API Reference](https://wordpresshyperpay.docs.oppwa.com/references/api-reference/)
- Contact HyperPay support team
- Review error logs and debug information

## License

This integration is provided as-is. Please refer to HyperPay's terms of service for usage rights and limitations.

---

**Note**: This integration follows the official HyperPay Mobile SDK architecture and is designed to work with HyperPay's hosted payment platform. Make sure to comply with HyperPay's terms of service and security requirements.
