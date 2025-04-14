import Cocoa
import FlutterMacOS

// Añade esta clase dentro del mismo archivo
@objc class DiskSpacePlugin: NSObject, FlutterPlugin {
    @objc static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "disk_space",
            binaryMessenger: registrar.messenger
        )
        let instance = DiskSpacePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getFreeDiskSpace":
            result(getFreeDiskSpace())
        case "getTotalDiskSpace":
            result(getTotalDiskSpace())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getFreeDiskSpace() -> Int64 {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            return values.volumeAvailableCapacityForImportantUsage ?? -1
        } catch {
            return -1
        }
    }
    
    private func getTotalDiskSpace() -> Int64 {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey])
            return Int64(values.volumeTotalCapacity ?? -1)
        } catch {
            return -1
        }
    }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    DiskSpacePlugin.register(with: flutterViewController.registrar(forPlugin: "DiskSpacePlugin"))

    super.awakeFromNib()
  }
}
