import 'package:flutter/material.dart';
import '../services/hyperpay_platform_channel.dart';

class HyperPayPlatformScreen extends StatefulWidget {
  const HyperPayPlatformScreen({super.key});

  @override
  State<HyperPayPlatformScreen> createState() => _HyperPayPlatformScreenState();
}

class _HyperPayPlatformScreenState extends State<HyperPayPlatformScreen> {
  final _hyperPayChannel = HyperPayPlatformChannel();
  bool _isLoading = false;
  bool _isInitialized = false;
  String _currentStatus = '';
  String _sdkVersion = '';
  final List<HyperPayPaymentEvent> _paymentEvents = [];

  // Pre-filled payment details as provided
  final String _checkoutId = "CHECKOUT_123";
  final double _amount = 100.0;
  final String _currency = "USD";
  final String _brand = "VISA";
  final String _holderName = "John Doe";
  final String _cardNumber = "4111111111111111";
  final String _expiryMonth = "12";
  final String _expiryYear = "2025";
  final String _cvv = "123";

  @override
  void initState() {
    super.initState();
    _initializeHyperPay();
    _listenToPaymentEvents();
  }

  Future<void> _initializeHyperPay() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _hyperPayChannel.initialize(
        merchantId: 'your_merchant_id_here',
        accessToken: 'your_access_token_here',
        isProduction: false,
        brand: _brand,
        configuration: {
          'enable3DSecure': true,
          'challengeWindowSize': 'FULL_SCREEN',
          'deviceChannel': 'APP',
        },
      );
      
      final version = await _hyperPayChannel.getSDKVersion();
      
      setState(() {
        _isInitialized = success;
        _isLoading = false;
        _sdkVersion = version;
      });
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('HyperPay SDK initialized successfully (v$version)')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initialize HyperPay SDK'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _listenToPaymentEvents() {
    _hyperPayChannel.paymentEvents.listen((event) {
      setState(() {
        _paymentEvents.add(event);
        // Keep only last 10 events
        if (_paymentEvents.length > 10) {
          _paymentEvents.removeAt(0);
        }
      });
      
      // Show event notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event: ${event.type}'),
            backgroundColor: _getEventColor(event.type),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'PAYMENT_SUCCESS':
        return Colors.green;
      case 'PAYMENT_FAILED':
        return Colors.red;
      case '3DS_CHALLENGE':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> _processPaymentWith3DSecure() async {
    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HyperPay SDK not initialized'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      setState(() => _currentStatus = 'Processing payment with 3D Secure 2...');

      // Create 3D Secure 2 data
      final threeDSecureData = {
        'browserInfo': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        'deviceChannel': 'APP',
        'notificationURL': 'https://your-server.com/3ds-callback',
        'challengeWindowSize': {
          'width': 400,
          'height': 600,
        },
        'browserData': {
          'acceptHeader': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'colorDepth': 24,
          'language': 'en-US',
          'javaEnabled': false,
          'screenHeight': 800,
          'screenWidth': 400,
          'timeZone': -300,
          'userAgent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        },
        'sdkData': {
          'appId': 'your-app-id',
          'encData': 'encrypted-data',
          'maxTimeout': 5,
          'referenceNumber': 'REF_${DateTime.now().millisecondsSinceEpoch}',
          'transId': 'TRANS_${DateTime.now().millisecondsSinceEpoch}',
        },
      };

      // Process payment with 3D Secure 2
      final result = await _hyperPayChannel.processPayment(
        checkoutId: _checkoutId,
        amount: _amount,
        currency: _currency,
        brand: _brand,
        holderName: _holderName,
        cardNumber: _cardNumber,
        expiryMonth: _expiryMonth,
        expiryYear: _expiryYear,
        cvv: _cvv,
        customerEmail: 'john.doe@example.com',
        description: 'Payment via HyperPay with 3D Secure 2',
        metadata: {
          'source': 'flutter_app',
          'platform': 'mobile',
          'integration': 'platform_channel',
          'threeDSecure': 'enabled',
        },
        threeDSecureData: threeDSecureData,
        enable3DSecure: true,
      );

      setState(() => _currentStatus = 'Getting payment status...');

      // Get payment status
      final status = await _hyperPayChannel.getPaymentStatus(_checkoutId);

      setState(() {
        _isLoading = false;
        _currentStatus = 'Payment ${status.name}';
      });

      // Show result dialog
      _showPaymentResultDialog(result, status);

    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentStatus = 'Payment failed';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPaymentWithUI() async {
    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HyperPay SDK not initialized'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      setState(() => _currentStatus = 'Launching HyperPay UI...');

      // Process payment with ready-to-use UI
      final result = await _hyperPayChannel.processPaymentWithUI(
        checkoutId: _checkoutId,
        amount: _amount,
        currency: _currency,
        brand: _brand,
        holderName: _holderName,
        cardNumber: _cardNumber,
        expiryMonth: _expiryMonth,
        expiryYear: _expiryYear,
        cvv: _cvv,
        customerEmail: 'john.doe@example.com',
        description: 'Payment via HyperPay UI',
        metadata: {
          'source': 'flutter_app',
          'platform': 'mobile',
          'integration': 'platform_channel_ui',
        },
        enable3DSecure: true,
      );

      setState(() => _currentStatus = 'Getting payment status...');

      // Get payment status
      final status = await _hyperPayChannel.getPaymentStatus(_checkoutId);

      setState(() {
        _isLoading = false;
        _currentStatus = 'Payment ${status.name}';
      });

      // Show result dialog
      _showPaymentResultDialog(result, status);

    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentStatus = 'Payment failed';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _tokenizePaymentMethod() async {
    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HyperPay SDK not initialized'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      setState(() => _currentStatus = 'Tokenizing payment method...');

      // Tokenize the payment method
      final token = await _hyperPayChannel.tokenizePaymentMethod(
        checkoutId: _checkoutId,
        brand: _brand,
        holderName: _holderName,
        cardNumber: _cardNumber,
        expiryMonth: _expiryMonth,
        expiryYear: _expiryYear,
        cvv: _cvv,
      );

      setState(() {
        _isLoading = false;
        _currentStatus = 'Tokenization completed';
      });

      if (token != null) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Payment Method Tokenized'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Token: $token'),
                  const SizedBox(height: 8),
                  Text('Brand: $_brand'),
                  Text('Holder: $_holderName'),
                  Text('Card: ${_maskCardNumber(_cardNumber)}'),
                  Text('Expiry: $_expiryMonth/$_expiryYear'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to tokenize payment method'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentStatus = 'Tokenization failed';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tokenization failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentResultDialog(HyperPayPaymentResult result, HyperPayPaymentStatus status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == HyperPayPaymentStatus.completed
              ? 'Payment Successful!'
              : 'Payment Status',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Checkout ID: ${result.checkoutId}'),
              const SizedBox(height: 8),
              Text('Transaction ID: ${result.transactionId}'),
              const SizedBox(height: 8),
              Text('Amount: \$${result.amount.toStringAsFixed(2)} ${result.currency}'),
              const SizedBox(height: 8),
              Text('Brand: ${result.brand}'),
              const SizedBox(height: 8),
              Text('Card Holder: ${result.holderName}'),
              const SizedBox(height: 8),
              Text('Card Number: ${result.cardNumber}'),
              const SizedBox(height: 8),
              Text('Status: ${status.name.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Message: ${result.message}'),
              const SizedBox(height: 8),
              Text('Time: ${result.timestamp.toString()}'),
              if (result.threeDSecureResult != null) ...[
                const SizedBox(height: 16),
                const Text('3D Secure Result:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...result.threeDSecureResult!.entries.map((entry) => 
                  Text('${entry.key}: ${entry.value}'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    return '${'*' * (cardNumber.length - 4)}${cardNumber.substring(cardNumber.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HyperPay Platform Channel'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SDK Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isInitialized ? Icons.check_circle : Icons.error,
                                color: _isInitialized ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isInitialized
                                    ? 'HyperPay SDK Ready'
                                    : 'HyperPay SDK Not Initialized',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Environment: ${_isInitialized ? 'Sandbox' : 'Unknown'}'),
                          if (_sdkVersion.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('SDK Version: $_sdkVersion'),
                          ],
                          if (_currentStatus.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Status: $_currentStatus'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildDetailRow('Checkout ID', _checkoutId),
                          _buildDetailRow('Amount', '\$${_amount.toStringAsFixed(2)} $_currency'),
                          _buildDetailRow('Brand', _brand),
                          _buildDetailRow('Card Holder', _holderName),
                          _buildDetailRow('Card Number', _maskCardNumber(_cardNumber)),
                          _buildDetailRow('Expiry Date', '$_expiryMonth/$_expiryYear'),
                          _buildDetailRow('CVV', '***'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Payment Actions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          
                          // 3D Secure Payment Button
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _processPaymentWith3DSecure,
                            icon: const Icon(Icons.security),
                            label: const Text('Pay with 3D Secure 2'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Ready-to-Use UI Button
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _processPaymentWithUI,
                            icon: const Icon(Icons.payment),
                            label: const Text('Pay with Ready-to-Use UI'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Tokenize Button
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : _tokenizePaymentMethod,
                            icon: const Icon(Icons.vpn_key),
                            label: const Text('Tokenize Payment Method'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Events
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Events',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _paymentEvents.clear());
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          if (_paymentEvents.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text('No payment events yet'),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _paymentEvents.length,
                              itemBuilder: (context, index) {
                                final event = _paymentEvents[index];
                                return ListTile(
                                  leading: Icon(
                                    _getEventIcon(event.type),
                                    color: _getEventColor(event.type),
                                  ),
                                  title: Text(event.type),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Checkout ID: ${event.checkoutId}'),
                                      Text('Time: ${_formatDate(event.timestamp)}'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.info),
                                    onPressed: () => _showEventDetails(event),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'PAYMENT_SUCCESS':
        return Icons.check_circle;
      case 'PAYMENT_FAILED':
        return Icons.error;
      case '3DS_CHALLENGE':
        return Icons.security;
      default:
        return Icons.info;
    }
  }

  void _showEventDetails(HyperPayPaymentEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Event: ${event.type}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${event.type}'),
              const SizedBox(height: 8),
              Text('Checkout ID: ${event.checkoutId}'),
              const SizedBox(height: 8),
              Text('Time: ${_formatDate(event.timestamp)}'),
              const SizedBox(height: 16),
              const Text('Data:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...event.data.entries.map((entry) => 
                Text('${entry.key}: ${entry.value}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
