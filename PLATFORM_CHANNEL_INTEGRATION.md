# HayperPay Platform Channel Integration

This guide explains how to integrate the HayperPay mobile SDK using Flutter platform channels for both iOS and Android platforms.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Setup Instructions](#setup-instructions)
4. [Platform-Specific Implementation](#platform-specific-implementation)
5. [Usage Examples](#usage-examples)
6. [API Reference](#api-reference)
7. [Troubleshooting](#troubleshooting)

## Overview

The HayperPay platform channel integration provides a bridge between Flutter and the native HayperPay SDKs on iOS and Android. This allows you to:

- Use native HayperPay SDK features directly from Flutter
- Access platform-specific optimizations
- Handle real-time payment events
- Maintain consistent API across platforms

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Platform Channel │    │  Native SDK     │
│                 │◄──►│                  │◄──►│                 │
│ - UI Components │    │ - Method Channel │    │ - iOS/Android   │
│ - Business Logic│    │ - Event Channel  │    │ - HayperPay SDK │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Components

1. **Flutter Side**
   - `HayperPayPlatformChannel` - Platform channel interface
   - `HayperPayNativeService` - High-level service wrapper
   - UI components for payment processing

2. **Platform Channels**
   - Method Channel: Synchronous operations (initialize, process payment, etc.)
   - Event Channel: Asynchronous events (payment status updates, etc.)

3. **Native Side**
   - Android: Kotlin implementation with HayperPay Android SDK
   - iOS: Swift implementation with HayperPay iOS SDK

## Setup Instructions

### 1. Flutter Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Platform channel dependencies
  shared_preferences: ^2.2.2
```

### 2. Android Setup

#### Add Permissions

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### Add Dependencies

Add the following to `android/app/build.gradle.kts`:

```kotlin
dependencies {
    // HayperPay Android SDK (replace with actual dependency)
    // implementation 'com.hayperpay:hayperpay-sdk:1.0.0'
    
    // Kotlin coroutines for async operations
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.1'
}
```

#### Register Plugin

Update `android/app/src/main/kotlin/com/example/your_app/MainActivity.kt`:

```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the HayperPay plugin
        flutterEngine.plugins.add(HayperPayPlugin())
    }
}
```

### 3. iOS Setup

#### Add Network Security

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

#### Add Dependencies

Add the following to `ios/Podfile`:

```ruby
target 'Runner' do
  # HayperPay iOS SDK (replace with actual dependency)
  # pod 'HayperPaySDK', '~> 1.0.0'
end
```

#### Register Plugin

Update `ios/Runner/AppDelegate.swift`:

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register the HayperPay plugin
    HayperPayPlugin.register(with: self.registrar(forPlugin: "HayperPayPlugin")!)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Platform-Specific Implementation

### Android Implementation

The Android implementation is located in `android/app/src/main/kotlin/com/example/your_app/HayperPayPlugin.kt`.

#### Key Features:

- **Method Channel Handling**: Processes Flutter method calls
- **Event Channel**: Sends payment events back to Flutter
- **Coroutines**: Handles asynchronous operations
- **Error Handling**: Comprehensive error management

#### Integration Points:

```kotlin
// TODO: Replace with actual HayperPay SDK
// hayperPaySDK = HayperPaySDK.Builder()
//     .setApiKey(apiKey)
//     .setMerchantId(merchantId)
//     .setEnvironment(if (isProduction) Environment.PRODUCTION else Environment.SANDBOX)
//     .build()
```

### iOS Implementation

The iOS implementation is located in `ios/Runner/HayperPayPlugin.swift`.

#### Key Features:

- **Method Channel Handling**: Processes Flutter method calls
- **Event Channel**: Sends payment events back to Flutter
- **Grand Central Dispatch**: Handles asynchronous operations
- **Error Handling**: Comprehensive error management

#### Integration Points:

```swift
// TODO: Replace with actual HayperPay SDK
// hayperPaySDK = HayperPaySDK(apiKey: apiKey, merchantId: merchantId, environment: isProduction ? .production : .sandbox)
```

## Usage Examples

### 1. Initialize the SDK

```dart
import 'package:your_app/services/hayperpay_native_service.dart';

final hayperPayService = HayperPayNativeService();

// Initialize the SDK
final success = await hayperPayService.initialize(
  apiKey: 'your_api_key_here',
  merchantId: 'your_merchant_id_here',
  isProduction: false, // Use sandbox for testing
  config: {
    'enableLogging': true,
    'enableAnalytics': true,
  },
);

if (success) {
  print('HayperPay Native SDK initialized successfully');
} else {
  print('Failed to initialize HayperPay Native SDK');
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
    metadata: {
      'source': 'flutter_native',
      'platform': 'ios', // or 'android'
    },
  );
  
  print('Payment successful: ${result['transactionId']}');
  print('Status: ${result['status']}');
  print('Amount: ${result['amount']} ${result['currency']}');
} catch (e) {
  print('Payment failed: $e');
}
```

### 3. Listen to Payment Events

```dart
// Events are automatically handled by the service
// You can also listen to the platform channel directly:

final platformChannel = HayperPayPlatformChannel();
platformChannel.paymentEvents.listen(
  (event) {
    print('Payment event: $event');
    // Handle payment events (completed, failed, cancelled, etc.)
  },
  onError: (error) {
    print('Payment event error: $error');
  },
);
```

### 4. Verify Payment Status

```dart
try {
  final status = await hayperPayService.verifyPayment('transaction_id_here');
  print('Payment status: $status');
} catch (e) {
  print('Verification failed: $e');
}
```

### 5. Get Transaction History

```dart
try {
  final history = await hayperPayService.getTransactionHistory(limit: 20);
  for (final transaction in history) {
    print('Transaction: ${transaction['transactionId']} - ${transaction['amount']}');
  }
} catch (e) {
  print('Failed to get history: $e');
}
```

### 6. Process Refund

```dart
try {
  final refundResult = await hayperPayService.refundPayment(
    transactionId: 'transaction_id_here',
    amount: 50.00,
    reason: 'Customer request',
  );
  
  print('Refund successful: ${refundResult['refundId']}');
} catch (e) {
  print('Refund failed: $e');
}
```

## API Reference

### HayperPayPlatformChannel

#### Methods

- `initialize()` - Initialize the native SDK
- `processPayment()` - Process a payment
- `verifyPayment()` - Verify payment status
- `getTransactionHistory()` - Get transaction history
- `refundPayment()` - Process a refund
- `getSDKVersion()` - Get SDK version
- `isInitialized()` - Check initialization status
- `setLogLevel()` - Set logging level
- `dispose()` - Clean up resources

#### Properties

- `paymentEvents` - Stream of payment events

### HayperPayNativeService

#### Methods

- `initialize()` - Initialize the SDK with configuration
- `processPayment()` - Process a payment with metadata
- `verifyPayment()` - Verify payment status
- `getTransactionHistory()` - Get transaction history
- `refundPayment()` - Process a refund
- `getSDKVersion()` - Get SDK version
- `checkInitializationStatus()` - Check native initialization
- `setLogLevel()` - Set logging level
- `getStoredPaymentHistory()` - Get locally stored history
- `clearStoredPaymentHistory()` - Clear local history
- `dispose()` - Clean up resources

#### Properties

- `isInitialized` - Check if SDK is initialized
- `platform` - Get current platform (iOS/Android)

## Troubleshooting

### Common Issues

1. **Plugin Not Found**
   - Ensure the plugin is properly registered in MainActivity/AppDelegate
   - Check that the plugin class is in the correct package

2. **Method Channel Errors**
   - Verify method names match between Flutter and native code
   - Check argument types and structure
   - Ensure the SDK is initialized before calling methods

3. **Event Channel Issues**
   - Verify event sink is properly set up
   - Check that events are sent on the main thread (iOS)
   - Ensure proper error handling

4. **SDK Initialization Failures**
   - Check API credentials
   - Verify network connectivity
   - Ensure proper permissions are set

### Debug Mode

Enable debug logging:

```dart
await hayperPayService.setLogLevel('DEBUG');
```

### Platform-Specific Debugging

#### Android

Check logcat for plugin logs:
```bash
adb logcat | grep HayperPayPlugin
```

#### iOS

Check Xcode console for plugin logs:
```bash
# Look for "HayperPayPlugin:" prefixed messages
```

### Error Codes

- `INIT_ERROR` - SDK initialization failed
- `NOT_INITIALIZED` - SDK not initialized
- `PAYMENT_ERROR` - Payment processing failed
- `VERIFICATION_ERROR` - Payment verification failed
- `HISTORY_ERROR` - Transaction history error
- `REFUND_ERROR` - Refund processing failed
- `VERSION_ERROR` - SDK version error
- `LOG_LEVEL_ERROR` - Log level setting error
- `DISPOSE_ERROR` - SDK disposal error

## Security Considerations

1. **API Key Management**
   - Never hardcode API keys in production
   - Use secure storage or backend services
   - Implement proper key rotation

2. **Network Security**
   - Always use HTTPS in production
   - Validate SSL certificates
   - Implement certificate pinning if required

3. **Data Validation**
   - Validate all input data on both Flutter and native sides
   - Sanitize user inputs
   - Implement proper error handling

4. **Platform Security**
   - Follow platform-specific security guidelines
   - Implement proper app signing
   - Use secure storage for sensitive data

## Performance Optimization

1. **Async Operations**
   - Use coroutines (Android) and GCD (iOS) for background operations
   - Avoid blocking the main thread
   - Implement proper error handling

2. **Memory Management**
   - Properly dispose of resources
   - Avoid memory leaks in event listeners
   - Use weak references where appropriate

3. **Network Optimization**
   - Implement request caching
   - Use connection pooling
   - Handle network timeouts properly

## Testing

### Unit Testing

Test the Flutter service layer:

```dart
test('should initialize SDK successfully', () async {
  final service = HayperPayNativeService();
  final result = await service.initialize(
    apiKey: 'test_key',
    merchantId: 'test_merchant',
    isProduction: false,
  );
  expect(result, true);
});
```

### Integration Testing

Test platform channel communication:

```dart
testWidgets('should process payment through platform channel', (tester) async {
  // Test implementation
});
```

### Platform Testing

Test native implementations separately:

- **Android**: Use Android Studio and logcat
- **iOS**: Use Xcode and console logs

## Migration Guide

### From Mock SDK to Real SDK

1. Replace mock implementations with real SDK calls
2. Update error handling for real SDK errors
3. Test thoroughly on both platforms
4. Update configuration for production

### Version Updates

1. Update native SDK versions
2. Test compatibility with existing code
3. Update platform-specific implementations
4. Verify all features work correctly

## Support

For additional support:

- Check the HayperPay API documentation
- Review platform-specific SDK documentation
- Contact HayperPay support team
- Check Flutter platform channel documentation

## License

This integration is provided as-is. Please refer to HayperPay's terms of service for usage rights and limitations.
