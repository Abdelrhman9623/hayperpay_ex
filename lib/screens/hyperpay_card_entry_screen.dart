import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hyperpay_platform_channel.dart';

class HyperPayCardEntryScreen extends StatefulWidget {
  const HyperPayCardEntryScreen({super.key});

  @override
  State<HyperPayCardEntryScreen> createState() => _HyperPayCardEntryScreenState();
}

class _HyperPayCardEntryScreenState extends State<HyperPayCardEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();

  final _hyperPayChannel = HyperPayPlatformChannel();
  bool _isLoading = false;
  bool _isInitialized = false;
  String _currentStatus = '';
  String _cardBrand = '';
  bool _isCardValid = false;
  bool _isExpiryValid = false;
  bool _isCvvValid = false;

  // Pre-filled values for testing
  final String _checkoutId = "CHECKOUT_123";
  final String _currency = "USD";

  @override
  void initState() {
    super.initState();
    _initializeHyperPay();
    _setupCardValidation();
  }

  Future<void> _initializeHyperPay() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _hyperPayChannel.initialize(
        merchantId: 'your_merchant_id_here',
        accessToken: 'your_access_token_here',
        isProduction: false,
        brand: 'VISA',
        configuration: {
          'enable3DSecure': true,
          'challengeWindowSize': 'FULL_SCREEN',
          'deviceChannel': 'APP',
        },
      );
      
      setState(() {
        _isInitialized = success;
        _isLoading = false;
      });
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('HyperPay SDK initialized successfully')),
        );
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

  void _setupCardValidation() {
    _cardNumberController.addListener(_validateCardNumber);
    _expiryMonthController.addListener(_validateExpiry);
    _expiryYearController.addListener(_validateExpiry);
    _cvvController.addListener(_validateCvv);
  }

  void _validateCardNumber() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    String brand = '';
    bool isValid = false;

    if (cardNumber.isNotEmpty) {
      if (cardNumber.startsWith('4')) {
        brand = 'VISA';
        isValid = cardNumber.length >= 13 && cardNumber.length <= 19;
      } else if (cardNumber.startsWith('5')) {
        brand = 'MASTERCARD';
        isValid = cardNumber.length == 16;
      } else if (cardNumber.startsWith('3')) {
        brand = 'AMEX';
        isValid = cardNumber.length == 15;
      } else if (cardNumber.startsWith('6')) {
        brand = 'DISCOVER';
        isValid = cardNumber.length == 16;
      }
    }

    setState(() {
      _cardBrand = brand;
      _isCardValid = isValid;
    });
  }

  void _validateExpiry() {
    final month = _expiryMonthController.text;
    final year = _expiryYearController.text;
    
    bool isValid = false;
    if (month.isNotEmpty && year.isNotEmpty) {
      final monthInt = int.tryParse(month);
      final yearInt = int.tryParse(year);
      
      if (monthInt != null && yearInt != null) {
        final now = DateTime.now();
        final currentYear = now.year % 100; // Get last 2 digits
        final currentMonth = now.month;
        
        isValid = monthInt >= 1 && monthInt <= 12 && 
                  yearInt >= currentYear && 
                  (yearInt > currentYear || monthInt >= currentMonth);
      }
    }
    
    setState(() {
      _isExpiryValid = isValid;
    });
  }

  void _validateCvv() {
    final cvv = _cvvController.text;
    bool isValid = false;
    
    if (cvv.isNotEmpty) {
      if (_cardBrand == 'AMEX') {
        isValid = cvv.length == 4;
      } else {
        isValid = cvv.length == 3;
      }
    }
    
    setState(() {
      _isCvvValid = isValid;
    });
  }

  String _formatCardNumber(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    
    return buffer.toString();
  }

  IconData _getCardBrandIcon() {
    switch (_cardBrand) {
      case 'VISA':
        return Icons.credit_card;
      case 'MASTERCARD':
        return Icons.credit_card;
      case 'AMEX':
        return Icons.credit_card;
      case 'DISCOVER':
        return Icons.credit_card;
      default:
        return Icons.credit_card_outlined;
    }
  }

  Color _getCardBrandColor() {
    switch (_cardBrand) {
      case 'VISA':
        return Colors.blue;
      case 'MASTERCARD':
        return Colors.orange;
      case 'AMEX':
        return Colors.green;
      case 'DISCOVER':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
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
      final amount = double.parse(_amountController.text);
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final holderName = _holderNameController.text;
      final expiryMonth = _expiryMonthController.text;
      final expiryYear = _expiryYearController.text;
      final cvv = _cvvController.text;
      final email = _emailController.text;

      setState(() => _currentStatus = 'Processing payment...');

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
        amount: amount,
        currency: _currency,
        brand: _cardBrand,
        holderName: holderName,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        customerEmail: email,
        description: 'Payment via HyperPay Card Entry',
        metadata: {
          'source': 'flutter_app',
          'platform': 'mobile',
          'integration': 'card_entry_screen',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Entry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
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
                            if (_currentStatus.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Status: $_currentStatus'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Amount
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Amount',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount (\$)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid amount';
                                }
                                if (double.parse(value) <= 0) {
                                  return 'Amount must be greater than 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Details
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Card Details',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Spacer(),
                                if (_cardBrand.isNotEmpty)
                                  Icon(
                                    _getCardBrandIcon(),
                                    color: _getCardBrandColor(),
                                    size: 24,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Card Number
                            TextFormField(
                              controller: _cardNumberController,
                              decoration: InputDecoration(
                                labelText: 'Card Number',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.credit_card),
                                suffixIcon: _isCardValid
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : _cardNumberController.text.isNotEmpty
                                        ? const Icon(Icons.error, color: Colors.red)
                                        : null,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(19),
                              ],
                              onChanged: (value) {
                                final formatted = _formatCardNumber(value);
                                if (formatted != value) {
                                  _cardNumberController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(offset: formatted.length),
                                  );
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter card number';
                                }
                                final cardNumber = value.replaceAll(' ', '');
                                if (cardNumber.length < 13) {
                                  return 'Card number is too short';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Card Holder Name
                            TextFormField(
                              controller: _holderNameController,
                              decoration: const InputDecoration(
                                labelText: 'Card Holder Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter card holder name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Expiry Date and CVV Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _expiryMonthController,
                                    decoration: InputDecoration(
                                      labelText: 'MM',
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.calendar_today),
                                      suffixIcon: _isExpiryValid
                                          ? const Icon(Icons.check_circle, color: Colors.green)
                                          : _expiryMonthController.text.isNotEmpty
                                              ? const Icon(Icons.error, color: Colors.red)
                                              : null,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'MM';
                                      }
                                      final month = int.tryParse(value);
                                      if (month == null || month < 1 || month > 12) {
                                        return 'Invalid month';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _expiryYearController,
                                    decoration: InputDecoration(
                                      labelText: 'YY',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: _isExpiryValid
                                          ? const Icon(Icons.check_circle, color: Colors.green)
                                          : _expiryYearController.text.isNotEmpty
                                              ? const Icon(Icons.error, color: Colors.red)
                                              : null,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'YY';
                                      }
                                      final year = int.tryParse(value);
                                      if (year == null) {
                                        return 'Invalid year';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cvvController,
                                    decoration: InputDecoration(
                                      labelText: 'CVV',
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.security),
                                      suffixIcon: _isCvvValid
                                          ? const Icon(Icons.check_circle, color: Colors.green)
                                          : _cvvController.text.isNotEmpty
                                              ? const Icon(Icons.error, color: Colors.red)
                                              : null,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'CVV';
                                      }
                                      if (_cardBrand == 'AMEX' && value.length != 4) {
                                        return '4 digits for AMEX';
                                      }
                                      if (_cardBrand != 'AMEX' && value.length != 3) {
                                        return '3 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _processPayment,
                      icon: const Icon(Icons.payment),
                      label: const Text('Pay Now'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Test Card Info
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Test Cards',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text('VISA: 4111111111111111'),
                            const Text('Mastercard: 5555555555554444'),
                            const Text('AMEX: 378282246310005'),
                            const Text('Expiry: Any future date'),
                            const Text('CVV: Any 3 digits (4 for AMEX)'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
