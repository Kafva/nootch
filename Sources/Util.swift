import Foundation
import SystemConfiguration

public func sysctlGet(_ key: String) -> String? {
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
