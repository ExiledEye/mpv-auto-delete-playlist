# mpv-auto-delete-playlist

![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat&logo=lua&logoColor=white)
![MPV](https://img.shields.io/badge/MPV-703e79?style=flat&logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPCEtLSBMaWNlbnNlOiBBcGFjaGUuIE1hZGUgYnkgbGF3bmNoYWlybGF1bmNoZXI6IGh0dHBzOi8vZ2l0aHViLmNvbS9sYXduY2hhaXJsYXVuY2hlci9sYXduaWNvbnMgLS0+Cjxzdmcgd2lkdGg9IjgwMHB4IiBoZWlnaHQ9IjgwMHB4IiB2aWV3Qm94PSIwIDAgMTkyIDE5MiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWw6c3BhY2U9InByZXNlcnZlIiBpZD0iTGF5ZXJfMSIgeD0iMCIgeT0iMCIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMTkyIDE5MiIgdmVyc2lvbj0iMS4xIj48c3R5bGU+LnN0MCwuc3Qxe2ZpbGw6bm9uZTtzdHJva2U6IzAwMDAwMDtzdHJva2Utd2lkdGg6MTI7c3Ryb2tlLW1pdGVybGltaXQ6MTB9LnN0MXtzdHJva2Utd2lkdGg6Nn08L3N0eWxlPjxjaXJjbGUgY3g9Ijk2IiBjeT0iOTYiIHI9Ijc0IiBjbGFzcz0ic3QwIi8+PHBhdGggZD0iTTExMi44IDk0LjEgODUuNSA3OC40Yy0xLjQtLjktMy40LjItMy40IDEuOXYzMS41YzAgMS42IDEuOSAyLjggMy40IDEuOUwxMTIuNyA5OGMxLjUtMSAxLjUtMy4xLjEtMy45eiIgY2xhc3M9InN0MCIvPjxjaXJjbGUgY3g9Ijk2IiBjeT0iOTYiIHI9IjM5IiBjbGFzcz0ic3QxIi8+PGNpcmNsZSBjeD0iOTgiIGN5PSI5Mi40IiByPSI1Mi41IiBjbGFzcz0ic3QxIi8+PC9zdmc+)

A Lua script for **MPV** that automatically deletes the playlist file used to launch MPV, either when playback starts or when MPV closes.

Useful for setups that generate temporary `.m3u` playlist files and need them cleaned up automatically after use.

## Features

*   **Toggleable Trigger**: Delete the playlist on MPV startup or on shutdown, configurable via `.conf`.
*   **Smart Path Detection**: Uses MPV's native `playlist-path` property.
*   **Cross-Platform**: Works on Windows, macOS, and Linux (hopefully).

## Requirements

1.  [**MPV**](https://mpv.io/): The media player itself.
2.  Playlist file to delete.

## Installation

1.  **Git**: Navigate to the scripts directory and run `git clone https://github.com/ExiledEye/mpv-auto-delete-playlist`.  
    **Manual**: Download and place the script folder in your MPV scripts directory.
2.  Launch MPV once. The config file will be installed automatically, thanks to [confhelper.lua](https://github.com/ExiledEye/mpv-helpers#confhelperlua).
3.  Configure 'mpv-auto-delete-playlist.conf' as your liking, found in your script-opts directory.

Usual script directory paths:
*   **Windows**: `...\mpv\scripts\`
*   **Linux/macOS**: `~/.config/mpv/scripts/`

**File structure after installation:**
```text
mpv/
├── scripts/
│   └── mpv-auto-delete-playlist/
│       ├── main.lua                      # Main script
│       ├── confhelper.lua                # Config file installer and loader helper
│       ├── mpv-auto-delete-playlist.conf # Default config file (keep as it is)
│       ├── LICENSE                       # License file
│       └── README.md                     # The file you are reading
└── script-opts/
    └── mpv-auto-delete-playlist.conf     # Configuration file to edit as desired
```

## How It Works

1.  **Detection**: The script reads MPV's `playlist-path` property to find the playlist file that was used to launch MPV.
2.  **Trigger**: Depending on `delete_on`, the deletion runs either when the first file starts playing or when MPV shuts down.
3.  **Deletion**:
    - On **Windows**: uses PowerShell's `Microsoft.VisualBasic.FileIO.FileSystem::DeleteFile` to send files to the Recycle Bin.
    - On **Linux**: uses `os.remove()` for single file deletion or `find -delete` for directory-wide cleanup.
4.  **Keybinds** *(optional, only with `delete_on=end` and `keybinds=yes`)*:
    - `q` — quit and delete as normal.
    - `Ctrl+Q` / `Shift+Q` — quit without deleting.

## Notes

*   The script only works when MPV is launched with a playlist file (e.g. `mpv --playlist=file.m3u`). If no playlist is loaded, the script will skip deletion.
*   On Linux, deletion is permanent only (no trash support).
*   The `keybinds` option overrides MPV's selected quit bindings within the script. Your `input.conf` is not modified.

## Support

If you encounter any problems or have suggestions, please [open an issue](https://github.com/ExiledEye/mpv-auto-delete-playlist/issues).

## License

Copyright (c) 2026 Exiled Eye  
This project is licensed under the MPL-2.0 License.  
Refer to the [LICENSE](LICENSE) file for details.
