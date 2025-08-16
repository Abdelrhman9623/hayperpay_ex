# HayperPay SDK Integration Guide

This guide explains how to integrate the HayperPay SDK into your Flutter application for payment processing.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [API Reference](#api-reference)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

- Flutter SDK 3.7.0 or higher
- Dart SDK 3.7.0 or higher
- HayperPay merchant account
- API credentials from HayperPay

## Installation

### 1. Add Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HayperPay SDK dependencies
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### 2. Install Dependencies

Run the following command to install dependencies:

```bash
flutter pub get
```

## Configuration

### 1. Update Configuration File

Edit `lib/config/hayperpay_config.dart` and replace the placeholder values:

```dart
class HayperPayConfig {
  // Replace with your actual API credentials
  static const String apiKey = 'your_actual_api_key_here';
  static const String merchantId = 'your_actual_merchant_id_here';
  static const String baseUrl = 'https://api.hayperpay.com';
  
  // Set to true for production environment
  static const bool isProduction = false;
}
```

### 2. Platform Configuration

#### Android Configuration

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS Configuration

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Usage

### 1. Initialize the SDK

```dart
import 'package:your_app/services/hayperpay_service.dart';

final hayperPayService = HayperPayService();

// Initialize the SDK
final success = await hayperPayService.initialize();
if (success) {
  print('HayperPay SDK initialized successfully');
} else {
  print('Failed to initialize HayperPay SDK');
}
```

### 2. Process a Payment

```dart
try {
  final result = await hayperPayService.processPayment(
    amount: 99.99,
    currency: 'USD',
    customerEmail: 'customer@example.com',
    customerName: 'John Doe',
    customerPhone: '+1234567890',
    description: 'Payment for services',
  );
  
  print('Payment successful: ${result.transactionId}');
} catch (e) {
  print('Payment failed: $e');
}
```

### 3. Verify Payment Status

```dart
try {
  final status = await hayperPayService.verifyPayment('transaction_id_here');
  print('Payment status: $status');
} catch (e) {
  print('Verification failed: $e');
}
```

### 4. Get Payment History

```dart
try {
  final history = await hayperPayService.getPaymentHistory(limit: 20);
  for (final transaction in history) {
    print('Transaction: ${transaction.transactionId} - ${transaction.amount}');
  }
} catch (e) {
  print('Failed to get history: $e');
}
```

### 5. Process Refund

```dart
try {
  final refundResult = await hayperPayService.refundPayment(
    transactionId: 'transaction_id_here',
    amount: 50.00,
    reason: 'Customer request',
  );
  
  print('Refund successful: ${refundResult.refundId}');
} catch (e) {
  print('Refund failed: $e');
}
```

## API Reference

### HayperPayService

#### Methods

- `initialize()` - Initialize the HayperPay SDK
- `processPayment()` - Process a new payment
- `verifyPayment()` - Verify payment status
- `getPaymentHistory()` - Get transaction history
- `refundPayment()` - Process a refund
- `getStoredPaymentHistory()` - Get locally stored payment history
- `clearStoredPaymentHistory()` - Clear local payment history
- `dispose()` - Clean up SDK resources

#### Properties

- `isInitialized` - Check if SDK is initialized

### HayperPayResult

#### Properties

- `transactionId` - Unique transaction identifier
- `amount` - Payment amount
- `currency` - Payment currency
- `status` - Payment status
- `message` - Status message
- `timestamp` - Transaction timestamp

### HayperPayPaymentStatus

#### Values

- `pending` - Payment is pending
- `processing` - Payment is being processed
- `completed` - Payment completed successfully
- `failed` - Payment failed
- `cancelled` - Payment was cancelled
- `refunded` - Payment was refunded

## Error Handling

The SDK throws `HayperPayException` for various error conditions:

```dart
try {
  await hayperPayService.processPayment(...);
} on HayperPayException catch (e) {
  print('HayperPay error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Testing

### Sandbox Environment

For testing, use the sandbox environment by setting:

```dart
static const bool isProduction = false;
```

### Test Cards

Use the following test card numbers for testing:

- **Visa**: 4111111111111111
- **Mastercard**: 5555555555554444
- **American Express**: 378282246310005

## Troubleshooting

### Common Issues

1. **SDK not initialized**
   - Ensure you call `initialize()` before using other methods
   - Check that your API credentials are correct

2. **Network errors**
   - Verify internet connectivity
   - Check API endpoint configuration
   - Ensure proper permissions are set

3. **Payment failures**
   - Verify customer email format
   - Check amount is greater than 0
   - Ensure currency is supported

### Debug Mode

Enable debug logging by setting:

```dart
static const bool enableLogging = true;
```

### Support

For additional support:

- Check the HayperPay API documentation
- Contact HayperPay support team
- Review error logs for specific error messages

## Security Best Practices

1. **Never expose API keys in client-side code**
   - Use secure backend services for sensitive operations
   - Implement proper authentication and authorization

2. **Validate all input data**
   - Sanitize user inputs
   - Validate email formats and amounts

3. **Handle errors gracefully**
   - Don't expose sensitive information in error messages
   - Log errors for debugging purposes

4. **Use HTTPS in production**
   - Ensure all API calls use secure connections
   - Validate SSL certificates

## License

This integration is provided as-is. Please refer to HayperPay's terms of service for usage rights and limitations.
