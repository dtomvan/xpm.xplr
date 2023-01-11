local q = xplr.util.shell_quote

local M = {}

M.data_path = os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share"
M.install_path = M.data_path .. "/xplr"

function M.dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

function M.subst_home(path)
  local home = os.getenv("HOME")
  return string.gsub(path, "~", home)
end

function M.plugin_path(plugin)
  return M.install_path .. "/" .. plugin
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
  res = xplr.util.shell_execute("bash", { "-c", cmd })
  return res.stdout .. "\n" .. res.stderr
end

function M.lines(str)
  local lines = {}
  for s in str:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

function M.repos()
  local cmd = string.format(
    "find %s -type d -name .git -prune | sed 's:/.git$::'",
    q(M.install_path)
  )

  local existing = M.cmd(cmd)

  return M.lines(existing)
end

function M.parse_url(url)
  url = string.gsub(url, "^github:", "https://github.com/")
  url = string.gsub(url, "^gitlab:", "https://gitlab.com/")
  if not string.find(url, "https://") then
    url = "https://github.com/" .. url
  end
  if not string.find(url, ".git$") then
    url = url .. ".git"
  end
  return url
end

function M.sanitize_plugin_name(name)
  name = name:gsub("https://", "")
  name = name:gsub("http://", "")
  return name
end

function M.author_name(name)
  name = string.match(name, "([A-Za-z0-9%-]+)/")
  return name
end

function M.plug_modname(plugin)
  return plugin:gsub(".+/([A-Za-z0-9%-]+).xplr", "%1")
end

function M.git_clone(url, target)
  local cmd = string.format("git clone %s %s", q(url), q(target))
  return M.cmd(cmd)
end

function M.git_fetch(path)
  local cmd = string.format("cd %s && git fetch", q(path))
  return M.cmd(cmd)
end

function M.git_checkout(path, rev)
  local cmd = string.format("cd %s && git checkout %s", q(path), q(rev))
  return M.cmd(cmd)
end

function M.is_err(output)
  return output:find("^fatal:") ~= nil or output:find("^error:") ~= nil
end

return M
