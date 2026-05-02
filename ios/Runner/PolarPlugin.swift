import Flutter
import PolarBleSdk
import RxSwift

@objc class PolarPlugin: NSObject, FlutterPlugin {
    private var api: PolarBleApi!
    private var methodChannel: FlutterMethodChannel?
    private var hrSink: FlutterEventSink?
    private var hrDisposable: Disposable?

    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.hamsatech/polar",
            binaryMessenger: registrar.messenger()
        )
        let hrEventChannel = FlutterEventChannel(
            name: "com.hamsatech/polar_hr_stream",
            binaryMessenger: registrar.messenger()
        )
        let instance = PolarPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        hrEventChannel.setStreamHandler(instance)
        instance.methodChannel = methodChannel
    }

    override init() {
        super.init()
        api = PolarBleApiDefaultImpl.polarImplementation(
            self,
            features: [.hrStreaming]
        )
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "connect":
            guard let deviceId = args?["deviceId"] as? String else {
                return result(FlutterError(code: "INVALID_ARG", message: "deviceId required", details: nil))
            }
            do {
                try api.connectToDevice(deviceId)
                result(nil)
            } catch {
                result(FlutterError(code: "CONNECTION_ERROR", message: error.localizedDescription, details: nil))
            }
        case "disconnect":
            guard let deviceId = args?["deviceId"] as? String else {
                return result(FlutterError(code: "INVALID_ARG", message: "deviceId required", details: nil))
            }
            do {
                try api.disconnectFromDevice(deviceId)
                result(nil)
            } catch {
                result(FlutterError(code: "DISCONNECT_ERROR", message: error.localizedDescription, details: nil))
            }
        case "startHrStream":
            guard let deviceId = args?["deviceId"] as? String else {
                return result(FlutterError(code: "INVALID_ARG", message: "deviceId required", details: nil))
            }
            hrDisposable?.dispose()
            hrDisposable = api.startHrStreaming(deviceId)
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onNext: { [weak self] hrData in
                        if let sample = hrData.samples.first {
                            self?.hrSink?([
                                "hr": sample.hr,
                                "rrs": sample.rrsMs,
                                "contact": sample.contactStatus,
                            ] as [String: Any])
                        }
                    },
                    onError: { [weak self] error in
                        self?.hrSink?(FlutterError(
                            code: "HR_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                )
            result(nil)
        case "stopHrStream":
            hrDisposable?.dispose()
            hrDisposable = nil
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension PolarPlugin: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        hrSink = events
        return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        hrDisposable?.dispose()
        hrDisposable = nil
        hrSink = nil
        return nil
    }
}

// PolarBleApiDelegate conformance for device connection callbacks
extension PolarPlugin: PolarBleApiDelegate {
    func deviceConnected(_ polarDeviceInfo: PolarDeviceInfo) {
        methodChannel?.invokeMethod("deviceConnected", arguments: polarDeviceInfo.deviceId)
    }
    func deviceConnecting(_ polarDeviceInfo: PolarDeviceInfo) {
        methodChannel?.invokeMethod("deviceConnecting", arguments: polarDeviceInfo.deviceId)
    }
    func deviceDisconnected(_ polarDeviceInfo: PolarDeviceInfo) {
        methodChannel?.invokeMethod("deviceDisconnected", arguments: polarDeviceInfo.deviceId)
    }
    func blePowerOn() {
        methodChannel?.invokeMethod("blePowerStateChanged", arguments: true)
    }
    func blePowerOff() {
        methodChannel?.invokeMethod("blePowerStateChanged", arguments: false)
    }
    func streamingFeaturesReady(_ identifier: String, dataTypes: Set<PolarDeviceDataType>) {}
    func hrFeatureReady(_ identifier: String) {}
    func message(_ str: String) {}
    func coreOpticsFeaturesReady(_ identifier: String) {}
    func disInformationReceived(_ identifier: String, uuid: CBUUID, value: String) {}
    func batteryLevelReceived(_ identifier: String, batteryLevel: UInt) {}
    func hrValueReceived(_ identifier: String, data: PolarHrData) {}
}
