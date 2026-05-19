--[[
    This file is part of mpv-lua-helpers
    https://github.com/ExiledEye/mpv-lua-helpers
    
    This file is part of mpv-auto-delete-playlist
    https://github.com/ExiledEye/mpv-auto-delete-playlist

    confhelper.lua
    Author: Exiled Eye
    Version: 1.0
    Description: Config file installer and loader helper.

    Copyright (c) 2026 Exiled Eye
    Licensed under the MPL-2.0 License.
    Refer to the LICENSE file for details.
]]

local M = {}

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() end
    return f ~= nil
end

local function install_conf(script_name, base)
    local source = base .. "/" .. script_name .. ".conf"

    local f = io.open(source, "r")
    if not f then
        source = base .. "/script-opts/" .. script_name .. ".conf"
        f = io.open(source, "r")
        if not f then
            mp.msg.error("Could not find source config file in " .. base)
            return nil
        end
    end
    f:close()

    local clean_base = base:gsub("\\", "/")
    local mpv_root = clean_base:match("^(.*)/scripts/")

    local dest_folder
    if mpv_root then
        dest_folder = mpv_root .. "/script-opts"
    else
        local up_one = clean_base:match("^(.*)/[^/]+$")
        local up_two = up_one and up_one:match("^(.*)/[^/]+$")
        if up_two then
            dest_folder = up_two .. "/script-opts"
        else
            dest_folder = mp.command_native({"expand-path", "~~/script-opts"}):gsub("\\", "/")
        end
    end

    local dest_path = dest_folder .. "/" .. script_name .. ".conf"

    mp.msg.info("Conf file source: " .. source)
    mp.msg.info("Conf file target folder: " .. dest_folder)

    local is_windows = package.config:sub(1,1) == "\\"
    if is_windows then
        os.execute('mkdir "' .. dest_folder:gsub("/", "\\") .. '" 2>nul')
    else
        os.execute('mkdir -p "' .. dest_folder .. '"')
    end

    local r = io.open(source, "rb")
    if not r then
        mp.msg.error("Conf file failed to open source: " .. source)
        return nil
    end

    local w = io.open(dest_path, "wb")
    if not w then
        r:close()
        mp.msg.error("Conf file failed to open destination: " .. dest_path)
        return nil
    end

    w:write(r:read("*a"))
    r:close()
    w:close()
    mp.msg.info("Conf file installed successfully to: " .. dest_path)
    return dest_path
end

function M.run(script_name, opts)
    opts = opts or {}
    local base = mp.get_script_directory()
    local options = require("mp.options")

    local options_path = mp.command_native({"expand-path", "~~/script-opts"}):gsub("\\", "/")
        .. "/" .. script_name .. ".conf"

    if not file_exists(options_path) then
        mp.msg.error("Missing " .. script_name .. ".conf in script-opts directory")
        local installed_path = install_conf(script_name, base)
        if installed_path then
            options.read_options(opts, script_name)
            mp.osd_message(script_name .. ".conf automatically installed. Configure the script and restart mpv.", 10)
        else
            mp.osd_message("Failed to install " .. script_name .. ".conf. Check console for more information.", 10)
            mp.msg.error("Failed to install " .. script_name .. ".conf. Consider installing it manually. Running with defaults for this session.")
        end
    else
        options.read_options(opts, script_name)
    end

    return opts
end

return M