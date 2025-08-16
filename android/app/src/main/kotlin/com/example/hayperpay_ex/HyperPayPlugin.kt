package com.example.hayperpay_ex

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import android.content.Context
import android.util.Log
import kotlinx.coroutines.*
import org.json.JSONObject
import java.util.*

class HyperPayPlugin: FlutterPlugin, MethodCallHandler, StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null
    private var isInitialized = false
    private var merchantId: String? = null
    private var accessToken: String? = null
    private var isProduction = false
    private var brand: String? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "hyperpay_sdk")
        eventChannel = EventChannel(binding.binaryMessenger, "hyperpay_events")
        channel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        Log.d("HyperPayPlugin", "Plugin attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        Log.d("HyperPayPlugin", "Plugin detached from engine")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "getCheckoutId" -> handleGetCheckoutId(call, result)
            "processPayment" -> handleProcessPayment(call, result)
            "processPaymentWithUI" -> handleProcessPaymentWithUI(call, result)
            "getPaymentStatus" -> handleGetPaymentStatus(call, result)
            "tokenizePaymentMethod" -> handleTokenizePaymentMethod(call, result)
            "processPaymentWithToken" -> handleProcessPaymentWithToken(call, result)
            "getSDKVersion" -> handleGetSDKVersion(call, result)
            "isInitialized" -> handleIsInitialized(call, result)
            "setLogLevel" -> handleSetLogLevel(call, result)
            "dispose" -> handleDispose(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        try {
            val merchantId = call.argument<String>("merchantId")
            val accessToken = call.argument<String>("accessToken")
            val isProduction = call.argument<Boolean>("isProduction") ?: false
            val brand = call.argument<String>("brand")
            val configuration = call.argument<Map<String, Any>>("configuration")

            Log.d("HyperPayPlugin", "Initializing SDK with merchantId: $merchantId, isProduction: $isProduction")

            // Store configuration
            this.merchantId = merchantId
            this.accessToken = accessToken
            this.isProduction = isProduction
            this.brand = brand
            this.isInitialized = true

            // Simulate initialization delay
            CoroutineScope(Dispatchers.IO).launch {
                delay(1000)
                withContext(Dispatchers.Main) {
                    result.success(mapOf("success" to true))
                    Log.d("HyperPayPlugin", "SDK initialized successfully")
                }
            }
        } catch (e: Exception) {
            Log.e("HyperPayPlugin", "Initialization failed", e)
            result.error("INITIALIZATION_FAILED", e.message, null)
        }
    }

    private fun handleGetCheckoutId(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
        }

        try {
            val amount = call.argument<Double>("amount")
            val currency = call.argument<String>("currency")
            val customerEmail = call.argument<String>("customerEmail")
            val threeDSecureData = call.argument<Map<String, Any>>("threeDSecureData")

            Log.d("HyperPayPlugin", "Getting checkout ID for amount: $amount $currency")

            // Simulate server communication
            CoroutineScope(Dispatchers.IO).launch {
                delay(1500)
                val checkoutId = "CHECKOUT_${System.currentTimeMillis()}"
                
                withContext(Dispatchers.Main) {
                    result.success(mapOf("checkoutId" to checkoutId))
                    Log.d("HyperPayPlugin", "Checkout ID generated: $checkoutId")
                }
            }
        } catch (e: Exception) {
            Log.e("HyperPayPlugin", "Failed to get checkout ID", e)
            result.error("CHECKOUT_ID_ERROR", e.message, null)
        }
    }

    private fun handleProcessPayment(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
        }

        try {
            val checkoutId = call.argument<String>("checkoutId")
            val amount = call.argument<Double>("amount")
            val currency = call.argument<String>("currency")
            val brand = call.argument<String>("brand")
            val holderName = call.argument<String>("holderName")
            val cardNumber = call.argument<String>("cardNumber")
            val expiryMonth = call.argument<String>("expiryMonth")
            val expiryYear = call.argument<String>("expiryYear")
            val cvv = call.argument<String>("cvv")
            val enable3DSecure = call.argument<Boolean>("enable3DSecure") ?: true
            val threeDSecureData = call.argument<Map<String, Any>>("threeDSecureData")

            Log.d("HyperPayPlugin", "Processing payment: $amount $currency for $holderName")
            Log.d("HyperPayPlugin", "3D Secure enabled: $enable3DSecure")

            // Simulate payment processing with 3D Secure
            CoroutineScope(Dispatchers.IO).launch {
                delay(2000)

                // Simulate 3D Secure challenge if enabled
                if (enable3DSecure && shouldTrigger3DChallenge(cardNumber)) {
                    Log.d("HyperPayPlugin", "Triggering 3D Secure challenge")
                    
                    // Send 3D Secure event
                    withContext(Dispatchers.Main) {
                        eventSink?.success(mapOf(
                            "type" to "3DS_CHALLENGE",
                            "checkoutId" to checkoutId,
                            "data" to mapOf(
                                "acsUrl" to "https://acs.example.com",
                                "paReq" to "PA_REQ_${System.currentTimeMillis()}",
                                "md" to "MD_${System.currentTimeMillis()}"
                            ),
                            "timestamp" to Date().time
                        ))
                    }
                    
                    delay(3000) // Simulate challenge completion
                }

                val isSuccess = System.currentTimeMillis() % 3 != 0L
                
                withContext(Dispatchers.Main) {
                    if (isSuccess) {
                        val paymentResult = mapOf(
                            "checkoutId" to checkoutId,
                            "transactionId" to "TXN_${System.currentTimeMillis()}",
                            "status" to "completed",
                            "amount" to amount,
                            "currency" to currency,
                            "brand" to brand,
                            "holderName" to holderName,
                            "cardNumber" to maskCardNumber(cardNumber),
                            "message" to "Payment processed successfully",
                            "timestamp" to Date().time,
                            "threeDSecureResult" to mapOf(
                                "authenticationValue" to "AUTH_${System.currentTimeMillis()}",
                                "eci" to "05",
                                "cavv" to "CAVV_${System.currentTimeMillis()}"
                            )
                        )
                        
                        result.success(paymentResult)
                        Log.d("HyperPayPlugin", "Payment successful")
                        
                        // Send payment event
                        eventSink?.success(mapOf(
                            "type" to "PAYMENT_SUCCESS",
                            "checkoutId" to checkoutId,
                            "data" to paymentResult,
                            "timestamp" to Date().time
                        ))
                    } else {
                        result.error("PAYMENT_FAILED", "Payment processing failed", null)
                        Log.d("HyperPayPlugin", "Payment failed")
                        
                        // Send payment event
                        eventSink?.success(mapOf(
                            "type" to "PAYMENT_FAILED",
                            "checkoutId" to checkoutId,
                            "data" to mapOf("error" to "Payment processing failed"),
                            "timestamp" to Date().time
                        ))
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("HyperPayPlugin", "Payment processing failed", e)
            result.error("PAYMENT_ERROR", e.message, null)
        }
    }

    private fun handleProcessPaymentWithUI(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
        }

        try {
            Log.d("HyperPayPlugin", "Launching HyperPay ready-to-use UI")

            // Simulate UI presentation and payment processing
            CoroutineScope(Dispatchers.IO).launch {
                delay(1000) // Simulate UI loading
                
                // Call the regular payment processing
                handleProcessPayment(call, result)
            }
        } catch (e: Exception) {
            Log.e("HyperPayPlugin", "Payment with UI failed", e)
            result.error("UI_PAYMENT_ERROR", e.message, null)
        }
    }

    private fun handleGetPaymentStatus(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
        }

        try {
            val checkoutId = call.argument<String>("checkoutId")
            Log.d("HyperPayPlugin", "Getting payment status for: $checkoutId")

            // Simulate status check
            CoroutineScope(Dispatchers.IO).launch {
                delay(500)
                withContext(Dispatchers.Main) {
                    result.success(mapOf("status" to "completed"))
                }
            }
        } catch (e: Exception) {
            Log.e("HyperPayPlugin", "Failed to get payment status", e)
            result.error("STATUS_ERROR", e.message, null)
        }
    }

    private fun handleTokenizePaymentMethod(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
        }

        try {
            val checkoutId = call.argument<String>("checkoutId")
            val brand = call.argument<String>("brand")
            val holderName = call.argument<String>("holderName")
            val cardNumber = call.argument<String>("cardNumber")

            Log.d("HyperPayPlugin", "Tokenizing payment method for $holderName")

            // Simulate tokenization
            CoroutineScope(Dispatchers.IO).launch {
                delay(1000)
                val token = "TOKEN_${System.currentTimeMillis()}"
                
                withContext(Dispatchers.Main) {
                    result.success(mapOf("token" to token))
                    Log.d("HyperPayPlugin", "Payment method tokenized: $token")
                }
            }
        } catch (e: Exception) {
            Log.e("HyperPayPlugin", "Tokenization failed", e)
            result.error("TOKENIZATION_ERROR", e.message, null)
        }
    }

    private fun handleProcessPaymentWithToken(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
            return
        }

        try {
            val checkoutId = call.argument<String>("checkoutId")
            val token = call.argument<String>("token")
            val amount = call.argument<Double>("amount")
            val currency = call.argument<String>("currency")

            Log.d("HyperPayPlugin", "Processing payment with token: $token")

            // Simulate token payment
            CoroutineScope(Dispatchers.IO).launch {
                delay(1500)
                val isSuccess = System.currentTimeMillis() % 3 != 0L
                
                withContext(Dispatchers.Main) {
                    if (isSuccess) {
                        val paymentResult = mapOf(
                            "checkoutId" to checkoutId,
                            "transactionId" to "TXN_${System.currentTimeMillis()}",
                            "status" to "completed",
                            "amount" to amount,
                            "currency" to currency,
                            "brand" to "TOKENIZED",
                            "holderName" to "Tokenized Payment",
                            "cardNumber" to "**** **** **** ****",
                            "message" to "Payment processed successfully with token",
                            "timestamp" to Date().time
                        )
                        
                        result.success(paymentResult)
                    } else {
                        result.error("TOKEN_PAYMENT_FAILED", "Token payment failed", null)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("HyperPayPlugin", "Token payment failed", e)
            result.error("TOKEN_PAYMENT_ERROR", e.message, null)
        }
    }

    private fun handleGetSDKVersion(call: MethodCall, result: Result) {
        result.success(mapOf("version" to "1.0.0"))
    }

    private fun handleIsInitialized(call: MethodCall, result: Result) {
        result.success(mapOf("initialized" to isInitialized))
    }

    private fun handleSetLogLevel(call: MethodCall, result: Result) {
        val level = call.argument<String>("level")
        Log.d("HyperPayPlugin", "Setting log level to: $level")
        result.success(null)
    }

    private fun handleDispose(call: MethodCall, result: Result) {
        isInitialized = false
        merchantId = null
        accessToken = null
        brand = null
        Log.d("HyperPayPlugin", "SDK disposed")
        result.success(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d("HyperPayPlugin", "Event stream listener attached")
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        Log.d("HyperPayPlugin", "Event stream listener detached")
    }

    private fun shouldTrigger3DChallenge(cardNumber: String?): Boolean {
        // Simulate 3D Secure challenge for certain card numbers
        return cardNumber?.startsWith("4000") == true || 
               System.currentTimeMillis() % 4 == 0L
    }

    private fun maskCardNumber(cardNumber: String?): String {
        if (cardNumber.isNullOrEmpty() || cardNumber.length < 4) {
            return cardNumber ?: ""
        }
        return "*".repeat(cardNumber.length - 4) + cardNumber.substring(cardNumber.length - 4)
    }
}
