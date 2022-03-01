---@diagnostic disable
local xplr = xplr
_xpm_plugins = {}
---@diagnostic enable

local M = {}

local lib = require 'xpm.lib'
local util = require 'xpm.lib.util'

function M.use_plugin(plugin)
    local name = plugin[1]
    if type(plugin) == 'string' then
        name = plugin
    end
    if not name then
        return true
    end

    local before = plugin.before
    if type(before) == 'function' then
        before()
    end

    local deps = plugin.deps
    if type(deps) == 'table' then
        for _, dep in ipairs(deps) do
            local status = M.use_plugin(dep)
            if not status then
                return false
            end
        end
    end

    local status, _ = lib.add_plugin(name)
    if status then
        local config = plugin.setup
        if type(config) ~= 'function' then
            config = function()
                local ok, mod = pcall(require, util.plug_modname(name))
                if ok then
                    pcall(mod.setup)
                end
            end
        end
        config()
        local after = plugin.after
        if type(after) == 'function' then
            after()
        end
        local sanitized = util.sanitize_plugin_name(name);
        if type(plugin) == "string" then
            plugin = { plugin }
        end
        plugin._path = util.plugin_path(sanitized);
        table.insert(_xpm_plugins, plugin)
        return true
    end
end

function M.setup(args)
    args = args or {}
    for _, plugin in ipairs(args) do
        M.use_plugin(plugin)
    end
end

return M
