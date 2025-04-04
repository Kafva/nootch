# nootch
Some Macbook models (e.g. Macbook Pro M3) have a black 'notch' at the top of
the screen, this is annoying. This simple program changes to a lower supported
resolution, hiding the notch (but also reducing the screen space).

```bash
swift build -c release
./.build/arm64-apple-macosx/release/nootch
```

Example keyboard shortcut with Karabiner to toggle the resolution:
```json
{
    "description": "Toggle notch",
    "manipulators": [
        {
            "from": {
                "key_code": "f",
                "modifiers": {
                    "mandatory": ["left_command", "left_shift"],
                    "optional": ["any"]
                }
            },
            "to": [{ "shell_command": "~/.local/bin/nootch > /tmp/.nootch.log" }],
            "type": "basic"
        }
    ]
}
```

Related/similar programs:
* [ByeNotch](https://github.com/ignaciojuarez/ByeNotch)
* [Lunar](https://github.com/alin23/Lunar)
