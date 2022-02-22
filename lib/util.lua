local M = {}

local xpm = require 'xpm'

M.data_path = os.getenv 'XDG_DATA_HOME' or os.getenv 'HOME' .. '/.local/share'
M.install_path = M.data_path .. '/xplr/'

function M.subst_home(path)
    local home = os.getenv 'HOME'
    return string.gsub(path, '~', home)
end
function M.plugin_path(plugin)
    return M.install_path .. '/' .. plugin .. '/'
end

function M.path_exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

function M.cmd(cmd)
    local handle = io.popen(cmd, 'r')
    local s = handle:read '*a'
    return s or ''
end

function M.lines(str)
    local lines = {}
    for s in str:gmatch '[^\r\n]+' do
        table.insert(lines, s)
    end
    return lines
end

function M.repos()
    local existing = M.cmd 'find ' .. M.install_path .. " -name .git -type d -prune | sed 's/\\/\\.git$//'"
    return M.lines(existing)
end

function M.removable_plugins()
    local existing = M.repos()
    local removable = {}
    for _, plugin in ipairs(existing) do
        for _, needed_plugin in ipairs(xpm._plugins) do
            if plugin == needed_plugin._path then
                goto skip
            end
        end
        table.insert(removable, plugin)
        ::skip::
    end
    return removable
end

function M.parse_url(url)
    url = string.gsub(url, '^github:', 'https://github.com/')
    url = string.gsub(url, '^gitlab:', 'https://gitlab.com/')
    if not string.find(url, 'https://') then
        url = 'https://github.com/' .. url
    end
    if not string.find(url, '.git$') then
        url = url .. '.git'
    end
    return url
end

function M.sanitize_plugin_name(name)
    name = name:gsub('https://', '')
    name = name:gsub('http://', '')
    return name
end

function M.author_name(name)
    name = string.match(name, '([A-Za-z0-9%-]+)/')
    return name
end

function M.plug_modname(plugin)
    return plugin:gsub('.+/([A-Za-z0-9%-]+).xplr', '%1')
end

function M.git_clone(url, target)
    local cmd = string.format('git clone %s %s', url, target)
    return M.cmd(cmd)
end

return M
