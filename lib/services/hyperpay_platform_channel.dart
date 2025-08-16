import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// HyperPay Platform Channel Service
/// Integrates with native HyperPay SDK through platform channels
/// Supports 3D Secure 2 authentication
class HyperPayPlatformChannel {
  static const MethodChannel _channel = MethodChannel('hyperpay_sdk');
  static const EventChannel _eventChannel = EventChannel('hyperpay_events');

  static final HyperPayPlatformChannel _instance =
      HyperPayPlatformChannel._internal();
  factory HyperPayPlatformChannel() => _instance;
  HyperPayPlatformChannel._internal();

  /// Initialize the HyperPay SDK
  Future<bool> initialize({
    required String merchantId,
    required String accessToken,
    required bool isProduction,
    String? brand,
    Map<String, dynamic>? configuration,
  }) async {
    try {
      final result = await _channel.invokeMethod('initialize', {
        'merchantId': merchantId,
        'accessToken': accessToken,
        'isProduction': isProduction,
        'brand': brand,
        'configuration': configuration,
      });

      debugPrint('HyperPay SDK initialized: $result');
      return result['success'] ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to initialize HyperPay SDK: ${e.message}');
      throw HyperPayException('Initialization failed: ${e.message}');
    }
  }

  /// Get checkout ID from server
  Future<String?> getCheckoutId({
    required double amount,
    required String currency,
    required String customerEmail,
    String? customerName,
    String? customerPhone,
    String? description,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? threeDSecureData,
  }) async {
    try {
      final result = await _channel.invokeMethod('getCheckoutId', {
        'amount': amount,
        'currency': currency,
        'customerEmail': customerEmail,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'description': description,
        'metadata': metadata,
        'threeDSecureData': threeDSecureData,
      });

      debugPrint('Checkout ID received: ${result['checkoutId']}');
      return result['checkoutId'];
    } on PlatformException catch (e) {
      debugPrint('Failed to get checkout ID: ${e.message}');
      throw HyperPayException('Failed to get checkout ID: ${e.message}');
    }
  }

  /// Process payment with 3D Secure 2 support
  Future<HyperPayPaymentResult> processPayment({
    required String checkoutId,
    required double amount,
    required String currency,
    required String brand,
    required String holderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? customerEmail,
    String? description,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? threeDSecureData,
    bool enable3DSecure = true,
  }) async {
    try {
      final result = await _channel.invokeMethod('processPayment', {
        'checkoutId': checkoutId,
        'amount': amount,
        'currency': currency,
        'brand': brand,
        'holderName': holderName,
        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        'customerEmail': customerEmail,
        'description': description,
        'metadata': metadata,
        'threeDSecureData': threeDSecureData,
        'enable3DSecure': enable3DSecure,
      });

      debugPrint('Payment processed: ${result['transactionId']}');
      return HyperPayPaymentResult.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('Payment processing failed: ${e.message}');
      throw HyperPayException('Payment failed: ${e.message}');
    }
  }

  /// Process payment with ready-to-use UI
  Future<HyperPayPaymentResult> processPaymentWithUI({
    required String checkoutId,
    required double amount,
    required String currency,
    required String brand,
    required String holderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? customerEmail,
    String? description,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? threeDSecureData,
    bool enable3DSecure = true,
  }) async {
    try {
      final result = await _channel.invokeMethod('processPaymentWithUI', {
        'checkoutId': checkoutId,
        'amount': amount,
        'currency': currency,
        'brand': brand,
        'holderName': holderName,
        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        'customerEmail': customerEmail,
        'description': description,
        'metadata': metadata,
        'threeDSecureData': threeDSecureData,
        'enable3DSecure': enable3DSecure,
      });

      debugPrint('Payment with UI processed: ${result['transactionId']}');
      return HyperPayPaymentResult.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('Payment with UI failed: ${e.message}');
      throw HyperPayException('Payment with UI failed: ${e.message}');
    }
  }

  /// Get payment status
  Future<HyperPayPaymentStatus> getPaymentStatus(String checkoutId) async {
    try {
      final result = await _channel.invokeMethod('getPaymentStatus', {
        'checkoutId': checkoutId,
      });

      final status = result['status'] as String;
      return HyperPayPaymentStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => HyperPayPaymentStatus.unknown,
      );
    } on PlatformException catch (e) {
      debugPrint('Failed to get payment status: ${e.message}');
      throw HyperPayException('Failed to get payment status: ${e.message}');
    }
  }

  /// Tokenize payment method
  Future<String?> tokenizePaymentMethod({
    required String checkoutId,
    required String brand,
    required String holderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    Map<String, dynamic>? threeDSecureData,
  }) async {
    try {
      final result = await _channel.invokeMethod('tokenizePaymentMethod', {
        'checkoutId': checkoutId,
        'brand': brand,
        'holderName': holderName,
        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        'threeDSecureData': threeDSecureData,
      });

      debugPrint('Payment method tokenized: ${result['token']}');
      return result['token'];
    } on PlatformException catch (e) {
      debugPrint('Tokenization failed: ${e.message}');
      throw HyperPayException('Tokenization failed: ${e.message}');
    }
  }

  /// Process payment with token
  Future<HyperPayPaymentResult> processPaymentWithToken({
    required String checkoutId,
    required String token,
    required double amount,
    required String currency,
    Map<String, dynamic>? threeDSecureData,
  }) async {
    try {
      final result = await _channel.invokeMethod('processPaymentWithToken', {
        'checkoutId': checkoutId,
        'token': token,
        'amount': amount,
        'currency': currency,
        'threeDSecureData': threeDSecureData,
      });

      debugPrint('Token payment processed: ${result['transactionId']}');
      return HyperPayPaymentResult.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('Token payment failed: ${e.message}');
      throw HyperPayException('Token payment failed: ${e.message}');
    }
  }

  /// Get SDK version
  Future<String> getSDKVersion() async {
    try {
      final result = await _channel.invokeMethod('getSDKVersion');
      return result['version'] ?? 'Unknown';
    } on PlatformException catch (e) {
      debugPrint('Failed to get SDK version: ${e.message}');
      return 'Unknown';
    }
  }

  /// Check if SDK is initialized
  Future<bool> isInitialized() async {
    try {
      final result = await _channel.invokeMethod('isInitialized');
      return result['initialized'] ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check initialization: ${e.message}');
      return false;
    }
  }

  /// Set log level
  Future<void> setLogLevel(String level) async {
    try {
      await _channel.invokeMethod('setLogLevel', {'level': level});
    } on PlatformException catch (e) {
      debugPrint('Failed to set log level: ${e.message}');
    }
  }

  /// Dispose SDK resources
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
      debugPrint('HyperPay SDK disposed');
    } on PlatformException catch (e) {
      debugPrint('Failed to dispose SDK: ${e.message}');
    }
  }

  /// Get payment events stream
  Stream<HyperPayPaymentEvent> get paymentEvents {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return HyperPayPaymentEvent.fromMap(Map<String, dynamic>.from(event));
      }
      return HyperPayPaymentEvent(
        type: 'unknown',
        checkoutId: '',
        data: {},
        timestamp: DateTime.now(),
      );
    });
  }
}

/// HyperPay Payment Status Enum
enum HyperPayPaymentStatus { pending, completed, failed, cancelled, unknown }

/// HyperPay Payment Result Model
class HyperPayPaymentResult {
  final String checkoutId;
  final String transactionId;
  final HyperPayPaymentStatus status;
  final double amount;
  final String currency;
  final String brand;
  final String holderName;
  final String cardNumber;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? threeDSecureResult;

  HyperPayPaymentResult({
    required this.checkoutId,
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.brand,
    required this.holderName,
    required this.cardNumber,
    required this.message,
    required this.timestamp,
    this.threeDSecureResult,
  });

  factory HyperPayPaymentResult.fromMap(Map<String, dynamic> map) {
    return HyperPayPaymentResult(
      checkoutId: map['checkoutId'] ?? '',
      transactionId: map['transactionId'] ?? '',
      status: HyperPayPaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => HyperPayPaymentStatus.unknown,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      brand: map['brand'] ?? 'UNKNOWN',
      holderName: map['holderName'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      threeDSecureResult: map['threeDSecureResult'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checkoutId': checkoutId,
      'transactionId': transactionId,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'brand': brand,
      'holderName': holderName,
      'cardNumber': cardNumber,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'threeDSecureResult': threeDSecureResult,
    };
  }
}

/// HyperPay Payment Event Model
class HyperPayPaymentEvent {
  final String type;
  final String checkoutId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  HyperPayPaymentEvent({
    required this.type,
    required this.checkoutId,
    required this.data,
    required this.timestamp,
  });

  factory HyperPayPaymentEvent.fromMap(Map<String, dynamic> map) {
    return HyperPayPaymentEvent(
      type: map['type'] ?? '',
      checkoutId: map['checkoutId'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

/// HyperPay Exception Class
class HyperPayException implements Exception {
  final String message;

  HyperPayException(this.message);

  @override
  String toString() => 'HyperPayException: $message';
}

/// 3D Secure 2 Data Model
class ThreeDSecureData {
  final String? browserInfo;
  final String? deviceChannel;
  final String? notificationURL;
  final Map<String, dynamic>? challengeWindowSize;
  final Map<String, dynamic>? browserData;
  final Map<String, dynamic>? sdkData;

  ThreeDSecureData({
    this.browserInfo,
    this.deviceChannel,
    this.notificationURL,
    this.challengeWindowSize,
    this.browserData,
    this.sdkData,
  });

  Map<String, dynamic> toMap() {
    return {
      'browserInfo': browserInfo,
      'deviceChannel': deviceChannel,
      'notificationURL': notificationURL,
      'challengeWindowSize': challengeWindowSize,
      'browserData': browserData,
      'sdkData': sdkData,
    };
  }
}
