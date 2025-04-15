import Cocoa
import FlutterMacOS
import Foundation

public class MemoryInfoPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "memory_info",
            binaryMessenger: registrar.messenger
        )
        let instance = MemoryInfoPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getMemoryInfo":
            result(getMemoryInfo())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getMemoryInfo() -> [String: Any] {
        var result = [String: Any]()
        
        // 1. Obtener memoria total (nunca falla)
        let totalMemory = Int64(ProcessInfo.processInfo.physicalMemory)
        result["total"] = totalMemory
        
        // 2. Obtener estadísticas de memoria
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let ret = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if ret == KERN_SUCCESS {
            let pageSize = Int64(vm_kernel_page_size)
            
            result["free"] = Int64(stats.free_count) * pageSize
            result["active"] = Int64(stats.active_count) * pageSize
            result["inactive"] = Int64(stats.inactive_count) * pageSize
            result["wired"] = Int64(stats.wire_count) * pageSize
            result["used"] = totalMemory - (Int64(stats.free_count) * pageSize)
        } else {
            // Fallback si host_statistics64 falla
            result["free"] = totalMemory / 2 // Estimación
            result["used"] = totalMemory / 2
            result["error"] = "vm_stats_failed"
        }
        
        return result
    }
}

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
    MemoryInfoPlugin.register(with: flutterViewController.registrar(forPlugin: "MemoryInfoPlugin"))


    super.awakeFromNib()
  }
}
