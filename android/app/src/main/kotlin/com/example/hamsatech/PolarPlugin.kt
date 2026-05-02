package com.example.hamsatech

import com.polar.androidcommunications.api.ble.model.DisInfo
import com.polar.sdk.api.PolarBleApi
import com.polar.sdk.api.PolarBleApiCallback
import com.polar.sdk.api.PolarBleApiDefaultImpl
import com.polar.sdk.api.errors.PolarInvalidArgument
import com.polar.sdk.api.model.PolarDeviceInfo
import com.polar.sdk.api.model.PolarHealthThermometerData
import com.polar.sdk.api.model.PolarHrData
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class PolarPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {
        private const val METHOD_CHANNEL = "com.hamsatech/polar"
        private const val HR_EVENT_CHANNEL = "com.hamsatech/polar_hr_stream"
    }

    private lateinit var methodChannel: MethodChannel
    private lateinit var hrEventChannel: EventChannel
    private lateinit var api: PolarBleApi

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var hrJob: Job? = null
    private var hrSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext

        api = PolarBleApiDefaultImpl.defaultImplementation(
            context,
            setOf(
                PolarBleApi.PolarBleSdkFeature.FEATURE_HR,
                PolarBleApi.PolarBleSdkFeature.FEATURE_BATTERY_INFO,
                PolarBleApi.PolarBleSdkFeature.FEATURE_DEVICE_INFO,
                PolarBleApi.PolarBleSdkFeature.FEATURE_POLAR_ONLINE_STREAMING,
            )
        )

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        hrEventChannel = EventChannel(binding.binaryMessenger, HR_EVENT_CHANNEL)
        hrEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                hrSink = events
            }
            override fun onCancel(arguments: Any?) {
                hrSink = null
                hrJob?.cancel()
                hrJob = null
            }
        })

        api.setApiCallback(object : PolarBleApiCallback() {
            override fun deviceConnected(polarDeviceInfo: PolarDeviceInfo) {
                methodChannel.invokeMethod("deviceConnected", polarDeviceInfo.deviceId)
            }
            override fun deviceConnecting(polarDeviceInfo: PolarDeviceInfo) {
                methodChannel.invokeMethod("deviceConnecting", polarDeviceInfo.deviceId)
            }
            override fun deviceDisconnected(polarDeviceInfo: PolarDeviceInfo) {
                methodChannel.invokeMethod("deviceDisconnected", polarDeviceInfo.deviceId)
            }
            override fun blePowerStateChanged(powered: Boolean) {
                methodChannel.invokeMethod("blePowerStateChanged", powered)
            }
            override fun disInformationReceived(identifier: String, disInfo: DisInfo) {}
            override fun htsNotificationReceived(identifier: String, data: PolarHealthThermometerData) {}
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> {
                val deviceId = call.argument<String>("deviceId")
                    ?: return result.error("INVALID_ARG", "deviceId required", null)
                try {
                    api.connectToDevice(deviceId)
                    result.success(null)
                } catch (e: PolarInvalidArgument) {
                    result.error("CONNECTION_ERROR", e.message, null)
                }
            }
            "disconnect" -> {
                val deviceId = call.argument<String>("deviceId")
                    ?: return result.error("INVALID_ARG", "deviceId required", null)
                try {
                    api.disconnectFromDevice(deviceId)
                    result.success(null)
                } catch (e: PolarInvalidArgument) {
                    result.error("DISCONNECT_ERROR", e.message, null)
                }
            }
            "startHrStream" -> {
                val deviceId = call.argument<String>("deviceId")
                    ?: return result.error("INVALID_ARG", "deviceId required", null)
                hrJob?.cancel()
                hrJob = scope.launch {
                    try {
                        api.startHrStreaming(deviceId).collect { hrData ->
                            val sample = hrData.samples.firstOrNull() ?: return@collect
                            hrSink?.success(
                                mapOf(
                                    "hr" to sample.hr,
                                    "rrs" to sample.rrsMs,
                                    "contact" to sample.contactStatus,
                                )
                            )
                        }
                    } catch (e: CancellationException) {
                        throw e
                    } catch (e: Exception) {
                        hrSink?.error("HR_ERROR", e.message ?: "Unknown error", null)
                    }
                }
                result.success(null)
            }
            "stopHrStream" -> {
                hrJob?.cancel()
                hrJob = null
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        scope.cancel()
        try { api.shutDown() } catch (_: Exception) {}
    }
}
