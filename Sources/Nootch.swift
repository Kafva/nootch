import AppKit
import SystemConfiguration

struct ModelConfig {
    let width: Int
    let height: Int
    let notchlessHeight: Int
    let refreshRate: Double

    init?() {
        guard let model = ModelConfig.sysctlGet("hw.model") else {
            return nil
        }
        switch (model) {
        case "Mac15,6":  // M3
            self.width = 1512
            self.height = 982
            self.notchlessHeight = 945
            self.refreshRate = 120.0
        default:
            print("Unsupported model: '\(model)'")
            return nil
        }
    }

    func isDefaultMode(displayMode: CGDisplayMode) -> Bool {
        return self.width == displayMode.width &&
               self.height == displayMode.height &&
               self.refreshRate == displayMode.refreshRate
    }

    func defaultMode(displayModes: [CGDisplayMode]) -> CGDisplayMode? {
        return displayModes.first {
            self.width == $0.width &&
            self.height == $0.height &&
            self.refreshRate == $0.refreshRate
        }
    }

    func notchlessMode(displayModes: [CGDisplayMode]) -> CGDisplayMode? {
        return displayModes.first {
            self.width == $0.width &&
            self.notchlessHeight == $0.height &&
            self.refreshRate == $0.refreshRate
        }
    }

    static private func sysctlGet(_ key: String) -> String? {
        var size = 0
        if sysctlbyname(key, nil, &size, nil, 0) != 0 {
            print("Failed to retrieve size of '\(key)'")
            return nil
        }

        var machine = [CChar](repeating: 0,  count: size)
        if sysctlbyname(key, &machine, &size, nil, 0) != 0 {
            print("Failed to retrieve value of '\(key)'")
            return nil
        }

        return String(utf8String: machine)
    }
}

class Nootch {
    private let mainDisplayID = CGMainDisplayID()
    private let cfg: ModelConfig
    private var displayModes: [CGDisplayMode] = []

    init?(cfg: ModelConfig) {
        self.cfg = cfg

        let option = [kCGDisplayShowDuplicateLowResolutionModes: kCFBooleanTrue] as
                     CFDictionary

        guard let modes = CGDisplayCopyAllDisplayModes(mainDisplayID, option) as?
                          [CGDisplayMode] else {
            print("Failed to get display modes")
            return
        }

        displayModes = modes.filter { $0.isUsableForDesktopGUI() }
    }

    func toggleNotch() -> Bool {
        guard let mode = CGDisplayCopyDisplayMode(mainDisplayID) else {
            print("Failed to get current display mode")
            return false
        }

        if cfg.isDefaultMode(displayMode: mode) {
            guard let displayMode = cfg.notchlessMode(displayModes: displayModes) else {
                print("Failed to retrieve notchless display mode")
                return false
            }
            return setResolution(displayMode: displayMode, notchless: true)
        }
        else {
            guard let displayMode = cfg.defaultMode(displayModes: displayModes) else {
                print("Failed to retrieve default display mode")
                return false
            }

            return setResolution(displayMode: displayMode, notchless: false)
        }
    }

    private func setResolution(displayMode: CGDisplayMode, notchless: Bool) -> Bool {
        var config: CGDisplayConfigRef?
        let dims = "\(displayMode.width)x\(displayMode.height)"
        let modeStr = notchless ? "no notch" : "default"
        print(
            "Setting resolution to: \(dims) [\(modeStr)]"
        )

        guard CGBeginDisplayConfiguration(&config) == .success else {
            print("Failed to begin display configuration")
            return false
        }

        CGConfigureDisplayWithDisplayMode(config, mainDisplayID, displayMode, nil)

        guard CGCompleteDisplayConfiguration(config, .forSession) == .success  else {
            print("Failed to complete display configuration")
            return false
        }

        return true
    }
}
