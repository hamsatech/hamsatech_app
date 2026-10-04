package com.example.hamsatech

import android.Manifest
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.polar.androidcommunications.api.ble.model.DisInfo
import com.polar.sdk.api.PolarBleApi
import com.polar.sdk.api.PolarBleApiCallback
import com.polar.sdk.api.PolarBleApiDefaultImpl
import com.polar.sdk.api.errors.PolarInvalidArgument
import com.polar.sdk.api.model.PolarDeviceInfo
import com.polar.sdk.api.model.PolarHealthThermometerData
import com.polar.sdk.api.model.PolarHrData
import android.util.Log
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
        private const val TAG = "PolarScan"
    }

    private lateinit var methodChannel: MethodChannel
    private lateinit var hrEventChannel: EventChannel
    private lateinit var api: PolarBleApi
    private lateinit var appContext: Context

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var hrJob: Job? = null
    private var searchJob: Job? = null
    private var hrSink: EventChannel.EventSink? = null

    // DIAGNOSTIC ONLY — a raw, unfiltered Android BLE scan run alongside the
    // Polar SDK's own searchForDevice(), added to answer one question when the
    // SDK scan reports zero devices: is *anything* advertising nearby at all,
    // or is the SDK's built-in Polar-name-prefix filter (PolarBleApiImpl.
    // setPolarFilter / withDeviceNameFilterPrefix — confirmed present by
    // decompiling polar-ble-sdk 7.1.0) excluding a device that IS in range?
    // Never used for actual discovery/connect — the SDK scan remains the only
    // source of devices offered to Dart, so demo-vs-real UI/connect behavior
    // is unaffected. Logs each address once per scan.
    private var rawScanner: BluetoothLeScanner? = null
    private var rawScanCallback: ScanCallback? = null
    private val rawSeenAddresses = mutableSetOf<String>()

    private fun startRawDiagnosticScan() {
        val manager = appContext.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        val adapter = manager?.adapter
        if (adapter == null || !adapter.isEnabled) {
            Log.w(TAG, "[RAW] skipped — Bluetooth adapter unavailable or off")
            return
        }
        val scanner = adapter.bluetoothLeScanner
        if (scanner == null) {
            Log.w(TAG, "[RAW] skipped — BluetoothLeScanner unavailable")
            return
        }
        rawSeenAddresses.clear()
        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                val address = result.device.address ?: "unknown"
                if (!rawSeenAddresses.add(address)) return // log each address once per scan
                val name = result.scanRecord?.deviceName ?: result.device.name
                Log.d(
                    TAG,
                    "[RAW] BLE device seen: address=$address name=$name rssi=${result.rssi} " +
                        "connectable=${result.isConnectable} serviceUuids=${result.scanRecord?.serviceUuids}"
                )
            }
            override fun onScanFailed(errorCode: Int) {
                Log.e(TAG, "[RAW] scan failed: errorCode=$errorCode")
            }
        }
        rawScanCallback = callback
        rawScanner = scanner
        val settings = ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build()
        try {
            scanner.startScan(null, settings, callback)
            Log.d(TAG, "[RAW] diagnostic scan started (no filter — logs every nearby BLE advertisement)")
        } catch (e: Exception) {
            Log.e(TAG, "[RAW] startScan threw: ${e.javaClass.simpleName}: ${e.message}", e)
        }
    }

    private fun stopRawDiagnosticScan() {
        try {
            rawScanCallback?.let { rawScanner?.stopScan(it) }
        } catch (_: Exception) {}
        Log.d(TAG, "[RAW] diagnostic scan stopped — saw ${rawSeenAddresses.size} distinct BLE address(es) total")
        rawScanner = null
        rawScanCallback = null
    }

    // minSdk is 33 (Android 13), so every device this app runs on is on the
    // S+ (API 31+) runtime-permission model — BLUETOOTH_SCAN/BLUETOOTH_CONNECT,
    // not the legacy ACCESS_FINE_LOCATION-gated scan. No SDK_INT branching needed.
    private fun hasPermission(permission: String): Boolean =
        ContextCompat.checkSelfPermission(appContext, permission) == PackageManager.PERMISSION_GRANTED

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        appContext = context

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
                // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
                Log.d("PolarDebug", "deviceConnected fired on thread=${Thread.currentThread().name}")
                methodChannel.invokeMethod("deviceConnected", polarDeviceInfo.deviceId)
            }
            override fun deviceConnecting(polarDeviceInfo: PolarDeviceInfo) {
                methodChannel.invokeMethod("deviceConnecting", polarDeviceInfo.deviceId)
            }
            override fun deviceDisconnected(polarDeviceInfo: PolarDeviceInfo) {
                methodChannel.invokeMethod("deviceDisconnected", polarDeviceInfo.deviceId)
            }
            override fun blePowerStateChanged(powered: Boolean) {
                // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
                Log.d(
                    "PolarDebug",
                    "[1] blePowerStateChanged callback entered: powered=$powered thread=${Thread.currentThread().name}"
                )
                try {
                    Log.d("PolarDebug", "[2] blePowerStateChanged: before invokeMethod")
                    methodChannel.invokeMethod("blePowerStateChanged", powered)
                    Log.d("PolarDebug", "[3] blePowerStateChanged: after invokeMethod (completed without throwing)")
                } catch (e: Exception) {
                    Log.e("PolarDebug", "blePowerStateChanged: invokeMethod THREW: ${e.javaClass.simpleName}: ${e.message}", e)
                }
            }
            override fun disInformationReceived(identifier: String, disInfo: DisInfo) {}
            override fun htsNotificationReceived(identifier: String, data: PolarHealthThermometerData) {}
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "scan" -> {
                Log.d(TAG, "scan requested")
                val missing = listOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT)
                    .filterNot(::hasPermission)
                if (missing.isNotEmpty()) {
                    val msg = "missing permissions: $missing"
                    Log.e(TAG, "scan aborted — $msg")
                    result.error("PERMISSION_DENIED", msg, null)
                    return
                }
                stopRawDiagnosticScan()
                startRawDiagnosticScan()
                searchJob?.cancel()
                searchJob = scope.launch {
                    var deviceCount = 0
                    try {
                        api.searchForDevice(null).collect { info ->
                            deviceCount++
                            Log.d(
                                TAG,
                                "device found (post Polar-name-filter): id=${info.deviceId} name=${info.name} rssi=${info.rssi} isConnectable=${info.isConnectable}"
                            )
                            methodChannel.invokeMethod(
                                "deviceFound",
                                mapOf(
                                    "deviceId" to info.deviceId,
                                    "name" to info.name.ifEmpty { info.deviceId },
                                    "type" to deviceTypeFor(info.name),
                                )
                            )
                        }
                    } catch (e: CancellationException) {
                        Log.d(
                            TAG,
                            "scan cancelled after finding $deviceCount Polar device(s); " +
                                "compare against [RAW] lines above for everything actually nearby"
                        )
                        throw e
                    } catch (e: Exception) {
                        // Previously swallowed silently — the UI would just time out
                        // with zero devices and no indication anything went wrong.
                        Log.e(TAG, "searchForDevice failed: ${e.javaClass.simpleName}: ${e.message}", e)
                        methodChannel.invokeMethod(
                            "scanError",
                            "${e.javaClass.simpleName}: ${e.message ?: "unknown BLE scan error"}"
                        )
                    }
                }
                result.success(null)
            }
            "stopScan" -> {
                Log.d(TAG, "stopScan requested")
                searchJob?.cancel()
                searchJob = null
                stopRawDiagnosticScan()
                result.success(null)
            }
            "connect" -> {
                val deviceId = call.argument<String>("deviceId")
                    ?: return result.error("INVALID_ARG", "deviceId required", null)
                Log.d(TAG, "connect requested: deviceId=$deviceId")
                if (!hasPermission(Manifest.permission.BLUETOOTH_CONNECT)) {
                    Log.e(TAG, "connect aborted — missing BLUETOOTH_CONNECT permission")
                    return result.error("PERMISSION_DENIED", "missing BLUETOOTH_CONNECT permission", null)
                }
                try {
                    api.connectToDevice(deviceId)
                    result.success(null)
                } catch (e: PolarInvalidArgument) {
                    Log.e(TAG, "connect failed: deviceId=$deviceId error=${e.message}", e)
                    result.error("CONNECTION_ERROR", e.message, null)
                }
            }
            "disconnect" -> {
                val deviceId = call.argument<String>("deviceId")
                    ?: return result.error("INVALID_ARG", "deviceId required", null)
                Log.d(TAG, "disconnect requested: deviceId=$deviceId")
                try {
                    api.disconnectFromDevice(deviceId)
                    result.success(null)
                } catch (e: PolarInvalidArgument) {
                    Log.e(TAG, "disconnect failed: deviceId=$deviceId error=${e.message}", e)
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
        stopRawDiagnosticScan()
        try { api.shutDown() } catch (_: Exception) {}
    }

    private fun deviceTypeFor(name: String): String = when {
        name.contains("H10", ignoreCase = true) || name.contains("H9", ignoreCase = true) -> "Chest strap"
        name.contains("Verity Sense", ignoreCase = true) || name.contains("OH1", ignoreCase = true) -> "Optical sensor"
        else -> "Polar device"
    }
}
