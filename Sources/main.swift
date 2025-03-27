#!/usr/bin/env swift
import AppKit
import System

if (CommandLine.arguments.contains { $0 == "--help" || $0 == "-h" }) {
    let program = FilePath(CommandLine.arguments[0]).lastComponent
    print("""
    Toggle between the default resolution and a smaller resolution that hides
    the black 'notch' on MacBook displays.

    Usage: \(program ?? "") [-h]
    """)
    exit(1)
}

if NSScreen.screens.count > 1 {
    print("More than one screen attached")
    exit(1)
}

let model = sysctlGet("hw.model") ?? ""
let cfg = ModelConfig(model: model)

guard let cfg else {
    print("Unsupported model: '\(model)'")
    exit(1)
}

guard let nootch = Nootch(cfg: cfg) else {
    exit(1)
}

let r = nootch.toggleNotch()
exit(r ? 1 : 0)
