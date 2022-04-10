local M = {}

function M.dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. M.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local util = require('xpm.lib.util')
M._authors = {}

function M.add_plugin(plugin)
    local name = util.sanitize_plugin_name(plugin)
    local path = util.plugin_path(name)
    local author = util.author_name(name)

    if not M._authors[author] then
        package.path = package.path
            .. ';'
            .. util.install_path
            .. author
            .. '/?.xplr/?.lua;'
            .. util.install_path
            .. author
            .. '/?.xplr/init.lua;'
            .. util.install_path
            .. author
            .. '/?.xplr/src/init.lua;'

        M._authors[author] = true
    end

    if not util.path_exists(path) then
        -- Install plugin
        local url = util.parse_url(plugin)
        local output = util.git_clone(url, path)

        if not output then
            return false, 'Got empty output from git'
        elseif output:gmatch('^fatal:') or output:gmatch('^error:') then
            return false, output
        else
            return true, 'Successfully installed ' .. name
        end
    end
    return true, 'Skipping as the plugin has already been installed.'
end

function M.remove_plugin(plugin)
    return util.cmd(string.format("rm -rf '{}'", plugin))
end

function M.remove_unneeded()
    local unneeded = util.removable_plugins()
    for _, plugin in ipairs(unneeded) do
        M.remove_plugin(plugin)
    end
end

return M
