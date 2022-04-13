local M = {}

local util = require("xpm.lib.util")

M._authors = {}

M._xpm_plugins = {}

function M.use_plugin(plugin)
  local name = plugin.name or plugin[1]
  if type(plugin) == "string" then
    name = plugin
  end
  if not name then
    return true
  end

  local sanitized = util.sanitize_plugin_name(name)
  if type(plugin) == "string" then
    plugin = { plugin }
  end

  plugin._path = util.plugin_path(sanitized)
  M._xpm_plugins[sanitized] = plugin

  local before = plugin.before
  if type(before) == "function" then
    before()
  end

  local deps = plugin.deps
  if type(deps) == "table" then
    for _, dep in ipairs(deps) do
      local status = M.use_plugin(dep)
      if not status then
        return false
      end
    end
  end

  local rev = plugin.rev or "origin"

  local status, _ = M.add_plugin(name, rev)

  if status then
    local config = plugin.setup
    if type(config) ~= "function" then
      config = function()
        local ok, mod = pcall(require, util.plug_modname(name))
        if ok then
          pcall(mod.setup)
        end
      end
    end

    config()

    local after = plugin.after
    if type(after) == "function" then
      after()
    end

    return true
  end
end

function M.add_plugin(plugin, rev)
  local name = util.sanitize_plugin_name(plugin)
  local path = util.plugin_path(name)
  local author = util.author_name(name)

  if not M._authors[author] then
    package.path = package.path
      .. ";"
      .. util.install_path
      .. "/"
      .. author
      .. "/?.xplr/?.lua;"
      .. util.install_path
      .. "/"
      .. author
      .. "/?.xplr/init.lua;"
      .. util.install_path
      .. author
      .. "/?.xplr/src/init.lua;"

    M._authors[author] = true
  end

  if not util.path_exists(path) then
    -- Install plugin
    local url = util.parse_url(plugin)
    print(string.format("xpm install: %s -> %s", url, path))
    local output = util.git_clone(url, path)

    if not util.is_err(output) then
      output = util.git_checkout(path, rev)
    end

    if not output then
      return false, "Got empty output from git"
    elseif util.is_err(output) then
      return false, output
    else
      return true, "Successfully installed " .. name
    end
  end
  return true, "Skipping as the plugin has already been installed."
end

function M.removable_plugins()
  local existing = util.repos()
  local removable = {}

  for _, path in ipairs(existing) do
    local is_needed = false
    for _, needed_plugin in pairs(M._xpm_plugins) do
      if path == needed_plugin._path then
        is_needed = true
        break
      end
    end

    if not is_needed then
      table.insert(removable, { _path = path })
    end
  end
  return removable
end

function M.remove_plugin(plugin)
  -- Scary stuff

  local path = plugin._path

  assert(path ~= nil and path:find(util.install_path) ~= nil)

  print(string.format("xpm remove: '%s'", path))
  io.write("[press ENTER to delete]")
  io.flush()
  local _ = io.read()
  print()

  return util.cmd(string.format("rm -rf '%s'", path))
end

function M.update_plugins()
  for _, plugin in pairs(M._xpm_plugins) do
    print(string.format("xpm update: '%s'", plugin._path))
    local rev = plugin.rev or "origin"
    util.git_fetch(plugin._path)
    util.git_checkout(plugin._path, rev)
  end
end

function M.remove_plugins()
  for _, plugin in pairs(M._xpm_plugins) do
    M.remove_plugin(plugin)
  end
end

return M
