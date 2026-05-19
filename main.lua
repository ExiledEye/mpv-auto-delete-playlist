--[[
    This file is part of mpv-auto-delete-playlist
    https://github.com/ExiledEye/mpv-auto-delete-playlist

    main.lua
    Author: Exiled Eye
    Version: 1.0
    Description: Main script.

    Copyright (c) 2026 Exiled Eye
    Licensed under the MPL-2.0 License.
    Refer to the LICENSE file for details.
]]

local options = require("confhelper").run("mpv-auto-delete-playlist", {
    delete_on = "end",
    delete_all_in_dir = false,
    permanent = true,
    keybinds = true,
    keybind1 = "ctrl+q",
    keybind2 = "shift+q"
}) -- Options which can be changed in the mpv-auto-delete-playlist.conf file

local skip_deletion = false

local function get_playlist_path()
    return mp.get_property("playlist-path")
end

local function delete_file(filepath)
    local is_windows = package.config:sub(1,1) == "\\"
    if is_windows then
        if options.permanent then
            mp.command_native({
                name = "subprocess",
                playback_only = false,
                detach = true,
                args = { 'powershell', '-NoProfile', '-Command',
                    string.format('Remove-Item -LiteralPath "%s" -Force', filepath)
                },
            })
        else
            local ps_code = [[
                $file = '__filepath__'
                Add-Type -AssemblyName Microsoft.VisualBasic
                [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($file, 'OnlyErrorDialogs', 'SendToRecycleBin')
            ]]
            ps_code = ps_code:gsub("__filepath__", filepath:gsub("\\", "\\\\"))
            mp.command_native({
                name = "subprocess",
                playback_only = false,
                detach = true,
                args = { 'powershell', '-NoProfile', '-Command', ps_code },
            })
        end
    else
        os.remove(filepath)
    end
end

local function delete_all_in_dir(folder)
    local is_windows = package.config:sub(1,1) == "\\"
    if is_windows then
        if options.permanent then
            mp.command_native({
                name = "subprocess",
                playback_only = false,
                detach = true,
                args = { 'powershell', '-NoProfile', '-Command',
                    string.format('Get-ChildItem -Path "%s" -Filter "playlist*.m3u" | Remove-Item -Force', folder)
                },
            })
        else
            local ps_code = [[
                $folder = '__folder__'
                $files = Get-ChildItem -Path $folder -Filter "playlist*.m3u"
                foreach ($file in $files) {
                    Add-Type -AssemblyName Microsoft.VisualBasic
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($file.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                }
            ]]
            ps_code = ps_code:gsub("__folder__", folder:gsub("\\", "\\\\"))
            mp.command_native({
                name = "subprocess",
                playback_only = false,
                detach = true,
                args = { 'powershell', '-NoProfile', '-Command', ps_code },
            })
        end
    else
        mp.command_native({
            name = "subprocess",
            playback_only = false,
            args = { 'sh', '-c', 'find "' .. folder .. '" -type f -name "playlist*.m3u" -delete' }
        })
    end
end

local function get_folder_from_path(filepath)
    local is_windows = package.config:sub(1,1) == "\\"
    if is_windows then
        return filepath:match("^(.*\\)")
    else
        return filepath:match("^(.*/)") 
    end
end

local function run_deletion()
    if skip_deletion then return end

    local playlist_path = get_playlist_path()
    if not playlist_path then
        mp.osd_message("delete_playlist: no playlist path found, skipping.")
        return
    end

    if options.delete_all_in_dir then
        local folder = get_folder_from_path(playlist_path)
        if folder then
            delete_all_in_dir(folder)
            mp.osd_message("Deleted all playlist*.m3u in: " .. folder)
        end
    else
        delete_file(playlist_path)
        mp.osd_message("Deleted playlist file: " .. playlist_path)
    end
end

if options.delete_on == "start" then
    mp.register_event("start-file", run_deletion)
elseif options.delete_on == "end" then
    mp.register_event("shutdown", run_deletion)

    if options.keybinds then
        mp.add_key_binding(options.keybind1, "quit_no_delete", function()
            skip_deletion = true
            mp.command("quit")
        end)

        mp.add_key_binding(options.keybind2, "quit_no_delete_alt", function()
            skip_deletion = true
            mp.command("quit")
        end)
    end
end