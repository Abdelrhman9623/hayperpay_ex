import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register HyperPay plugin manually
    let registrar = self.registrar(forPlugin: "HyperPayPlugin")!
    let channel = FlutterMethodChannel(name: "hyperpay_sdk", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "hyperpay_events", binaryMessenger: registrar.messenger())

    let hyperPayPlugin = HyperPayPlugin()
    registrar.addMethodCallDelegate(hyperPayPlugin, channel: channel)
    eventChannel.setStreamHandler(hyperPayPlugin)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// HyperPay Plugin Implementation with 3D Secure 2 Support
class HyperPayPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var isInitialized = false
    private var merchantId: String?
    private var accessToken: String?
    private var isProduction = false
    private var brand: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        // This method is not used since we register manually
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call: call, result: result)
        case "getCheckoutId":
            handleGetCheckoutId(call: call, result: result)
        case "processPayment":
            handleProcessPayment(call: call, result: result)
        case "processPaymentWithUI":
            handleProcessPaymentWithUI(call: call, result: result)
        case "getPaymentStatus":
            handleGetPaymentStatus(call: call, result: result)
        case "tokenizePaymentMethod":
            handleTokenizePaymentMethod(call: call, result: result)
        case "processPaymentWithToken":
            handleProcessPaymentWithToken(call: call, result: result)
        case "getSDKVersion":
            handleGetSDKVersion(call: call, result: result)
        case "isInitialized":
            handleIsInitialized(call: call, result: result)
        case "setLogLevel":
            handleSetLogLevel(call: call, result: result)
        case "dispose":
            handleDispose(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let merchantId = args["merchantId"] as? String,
              let accessToken = args["accessToken"] as? String,
              let isProduction = args["isProduction"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let brand = args["brand"] as? String
        let configuration = args["configuration"] as? [String: Any]
        
        print("HyperPayPlugin: Initializing SDK with merchantId: \(merchantId), isProduction: \(isProduction)")
        
        // Store configuration
        self.merchantId = merchantId
        self.accessToken = accessToken
        self.isProduction = isProduction
        self.brand = brand
        self.isInitialized = true
        
        // Simulate initialization delay
        DispatchQueue.global(qos: .background).async { [weak self] in
            Thread.sleep(forTimeInterval: 1.0)
            self?.isInitialized = true
            print("HyperPayPlugin: SDK initialized successfully")
            
            DispatchQueue.main.async {
                result(["success": true])
            }
        }
    }
    
    private func handleGetCheckoutId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let amount = args["amount"] as? Double,
              let currency = args["currency"] as? String,
              let customerEmail = args["customerEmail"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let threeDSecureData = args["threeDSecureData"] as? [String: Any]
        
        print("HyperPayPlugin: Getting checkout ID for amount: \(amount) \(currency)")
        
        // Simulate server communication
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 1.5)
            let checkoutId = "CHECKOUT_\(Int(Date().timeIntervalSince1970 * 1000))"
            
            DispatchQueue.main.async {
                result(["checkoutId": checkoutId])
                print("HyperPayPlugin: Checkout ID generated: \(checkoutId)")
            }
        }
    }
    
    private func handleProcessPayment(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let checkoutId = args["checkoutId"] as? String,
              let amount = args["amount"] as? Double,
              let currency = args["currency"] as? String,
              let brand = args["brand"] as? String,
              let holderName = args["holderName"] as? String,
              let cardNumber = args["cardNumber"] as? String,
              let expiryMonth = args["expiryMonth"] as? String,
              let expiryYear = args["expiryYear"] as? String,
              let cvv = args["cvv"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid payment arguments", details: nil))
            return
        }
        
        let enable3DSecure = args["enable3DSecure"] as? Bool ?? true
        let threeDSecureData = args["threeDSecureData"] as? [String: Any]
        
        print("HyperPayPlugin: Processing payment: \(amount) \(currency) for \(holderName)")
        print("HyperPayPlugin: 3D Secure enabled: \(enable3DSecure)")
        
        // Simulate payment processing with 3D Secure
        DispatchQueue.global(qos: .background).async { [weak self] in
            Thread.sleep(forTimeInterval: 2.0)
            
            // Simulate 3D Secure challenge if enabled
            if enable3DSecure && self?.shouldTrigger3DChallenge(cardNumber: cardNumber) == true {
                print("HyperPayPlugin: Triggering 3D Secure challenge")
                
                // Send 3D Secure event
                DispatchQueue.main.async {
                    self?.eventSink?([
                        "type": "3DS_CHALLENGE",
                        "checkoutId": checkoutId,
                        "data": [
                            "acsUrl": "https://acs.example.com",
                            "paReq": "PA_REQ_\(Int(Date().timeIntervalSince1970 * 1000))",
                            "md": "MD_\(Int(Date().timeIntervalSince1970 * 1000))"
                        ],
                        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                    ])
                }
                
                Thread.sleep(forTimeInterval: 3.0) // Simulate challenge completion
            }
            
            let isSuccess = Int(Date().timeIntervalSince1970 * 1000) % 3 != 0
            
            DispatchQueue.main.async {
                if isSuccess {
                    let paymentResult: [String: Any] = [
                        "checkoutId": checkoutId,
                        "transactionId": "TXN_\(Int(Date().timeIntervalSince1970 * 1000))",
                        "status": "completed",
                        "amount": amount,
                        "currency": currency,
                        "brand": brand,
                        "holderName": holderName,
                        "cardNumber": self?.maskCardNumber(cardNumber: cardNumber) ?? "",
                        "message": "Payment processed successfully",
                        "timestamp": Int(Date().timeIntervalSince1970 * 1000),
                        "threeDSecureResult": [
                            "authenticationValue": "AUTH_\(Int(Date().timeIntervalSince1970 * 1000))",
                            "eci": "05",
                            "cavv": "CAVV_\(Int(Date().timeIntervalSince1970 * 1000))"
                        ]
                    ]
                    
                    result(paymentResult)
                    print("HyperPayPlugin: Payment successful")
                    
                    // Send payment event
                    self?.eventSink?([
                        "type": "PAYMENT_SUCCESS",
                        "checkoutId": checkoutId,
                        "data": paymentResult,
                        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                    ])
                } else {
                    result(FlutterError(code: "PAYMENT_FAILED", message: "Payment processing failed", details: nil))
                    print("HyperPayPlugin: Payment failed")
                    
                    // Send payment event
                    self?.eventSink?([
                        "type": "PAYMENT_FAILED",
                        "checkoutId": checkoutId,
                        "data": ["error": "Payment processing failed"],
                        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                    ])
                }
            }
        }
    }
    
    private func handleProcessPaymentWithUI(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        print("HyperPayPlugin: Launching HyperPay ready-to-use UI")
        
        // Simulate UI presentation and payment processing
        DispatchQueue.global(qos: .background).async { [weak self] in
            Thread.sleep(forTimeInterval: 1.0) // Simulate UI loading
            
            // Call the regular payment processing
            self?.handleProcessPayment(call: call, result: result)
        }
    }
    
    private func handleGetPaymentStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let checkoutId = args["checkoutId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid checkout ID", details: nil))
            return
        }
        
        print("HyperPayPlugin: Getting payment status for: \(checkoutId)")
        
        // Simulate status check
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 0.5)
            
            DispatchQueue.main.async {
                result(["status": "completed"])
            }
        }
    }
    
    private func handleTokenizePaymentMethod(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let checkoutId = args["checkoutId"] as? String,
              let brand = args["brand"] as? String,
              let holderName = args["holderName"] as? String,
              let cardNumber = args["cardNumber"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid tokenization arguments", details: nil))
            return
        }
        
        print("HyperPayPlugin: Tokenizing payment method for \(holderName)")
        
        // Simulate tokenization
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 1.0)
            let token = "TOKEN_\(Int(Date().timeIntervalSince1970 * 1000))"
            
            DispatchQueue.main.async {
                result(["token": token])
                print("HyperPayPlugin: Payment method tokenized: \(token)")
            }
        }
    }
    
    private func handleProcessPaymentWithToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let checkoutId = args["checkoutId"] as? String,
              let token = args["token"] as? String,
              let amount = args["amount"] as? Double,
              let currency = args["currency"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid token payment arguments", details: nil))
            return
        }
        
        print("HyperPayPlugin: Processing payment with token: \(token)")
        
        // Simulate token payment
        DispatchQueue.global(qos: .background).async { [weak self] in
            Thread.sleep(forTimeInterval: 1.5)
            let isSuccess = Int(Date().timeIntervalSince1970 * 1000) % 3 != 0
            
            DispatchQueue.main.async {
                if isSuccess {
                    let paymentResult: [String: Any] = [
                        "checkoutId": checkoutId,
                        "transactionId": "TXN_\(Int(Date().timeIntervalSince1970 * 1000))",
                        "status": "completed",
                        "amount": amount,
                        "currency": currency,
                        "brand": "TOKENIZED",
                        "holderName": "Tokenized Payment",
                        "cardNumber": "**** **** **** ****",
                        "message": "Payment processed successfully with token",
                        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                    ]
                    
                    result(paymentResult)
                } else {
                    result(FlutterError(code: "TOKEN_PAYMENT_FAILED", message: "Token payment failed", details: nil))
                }
            }
        }
    }
    
    private func handleGetSDKVersion(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(["version": "1.0.0"])
    }
    
    private func handleIsInitialized(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(["initialized": isInitialized])
    }
    
    private func handleSetLogLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let level = args["level"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid log level", details: nil))
            return
        }
        
        print("HyperPayPlugin: Setting log level to: \(level)")
        result(nil)
    }
    
    private func handleDispose(call: FlutterMethodCall, result: @escaping FlutterResult) {
        isInitialized = false
        merchantId = nil
        accessToken = nil
        brand = nil
        print("HyperPayPlugin: SDK disposed")
        result(nil)
    }
    
    // MARK: - FlutterStreamHandler
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        print("HyperPayPlugin: Event stream listener attached")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        print("HyperPayPlugin: Event stream listener detached")
        return nil
    }
    
    private func shouldTrigger3DChallenge(cardNumber: String?) -> Bool {
        // Simulate 3D Secure challenge for certain card numbers
        return cardNumber?.hasPrefix("4000") == true || 
               Int(Date().timeIntervalSince1970 * 1000) % 4 == 0
    }
    
    private func maskCardNumber(cardNumber: String?) -> String {
        guard let cardNumber = cardNumber, cardNumber.count >= 4 else {
            return cardNumber ?? ""
        }
        let maskedPart = String(repeating: "*", count: cardNumber.count - 4)
        let lastFour = String(cardNumber.suffix(4))
        return maskedPart + lastFour
    }
}