import AppKit

struct ModelConfig {
    let width: Int
    let height: Int
    let notchlessHeight: Int
    let refreshRate: Double

    init?(model: String) {
        switch (model) {
        case "Mac15,6":  // M3
            self.width = 1512
            self.height = 982
            self.notchlessHeight = 945
            self.refreshRate = 120.0
        default:
            return nil
        }
    }

    func isDefaultMode(displayMode: CGDisplayMode) -> Bool {
        return self.width == displayMode.width &&
               self.height == displayMode.height &&
               self.refreshRate == displayMode.refreshRate
    }

    func isNotchlessMode(displayMode: CGDisplayMode) -> Bool {
        return self.width == displayMode.width &&
               self.notchlessHeight == displayMode.height &&
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
        let modeStr = notchless ? "notchless" : "default"
        print(
            "Setting resolution to: \(displayMode.width)x\(displayMode.height) [\(modeStr)]"
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

        // Verify the change
        guard let newMode = CGDisplayCopyDisplayMode(mainDisplayID) else {
            print("Unexpected result from display configuration")
            return false
        }

        if notchless {
            return cfg.isDefaultMode(displayMode: newMode)
        }
        else {
            return cfg.isNotchlessMode(displayMode: newMode)
        }
    }
}
