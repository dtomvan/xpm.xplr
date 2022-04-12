---@diagnostic disable
local xplr = xplr
---@diagnostic enable

local M = {}

local lib = require("xpm.lib")

function M.setup(args)
  args = args or {}

  M.plugins = args.plugins or args

  local auto_install, auto_cleanup = true, false

  if args.auto_install ~= nil then
    auto_install = args.auto_install
  end

  if args.auto_cleanup ~= nil then
    auto_cleanup = args.auto_cleanup
  end

  if auto_install then
    M.install_plugins()
  end

  if auto_cleanup then
    M.cleanup_plugins()
  end

  xplr.fn.custom.xpm = {
    install_plugins = M.install_plugins,
    cleanup_plugins = M.cleanup_plugins,
    update_plugins = M.update_plugins,
    remove_plugins = M.remove_plugins,

    render_plugins = function(_)
      local ui = { " " }
      for name, plugin in pairs(lib._xpm_plugins) do
        table.insert(ui, string.format("%s (%s)", name, plugin.rev or "origin"))
      end
      return ui
    end,
  }

  xplr.config.modes.custom.xpm = {
    name = "xpm",

    layout = {
      Horizontal = {
        config = {
          constraints = {
            { Percentage = 50 },
            { Percentage = 50 },
          },
        },
        splits = {
          {
            CustomContent = {
              title = "plugins",
              body = {
                DynamicList = { render = "custom.xpm.render_plugins" },
              },
            },
          },
          "HelpMenu",
        },
      },
    },

    key_bindings = {
      on_key = {
        i = {
          help = "install plugins",
          messages = {
            { CallLua = "custom.xpm.install_plugins" },
          },
        },
        c = {
          help = "cleanup plugins",
          messages = {
            { CallLua = "custom.xpm.cleanup_plugins" },
          },
        },
        u = {
          help = "update plugins",
          messages = {
            { CallLua = "custom.xpm.update_plugins" },
          },
        },
        r = {
          help = "remove plugins",
          messages = {
            { CallLua = "custom.xpm.remove_plugins" },
          },
        },
        esc = {
          messages = {
            "PopMode",
          },
        },
        ["ctrl-c"] = {
          messages = {
            "Terminate",
          },
        },
      },
    },
  }
end

M.use_plugin = lib.use_plugin

function M.install_plugins(_)
  for _, plugin in ipairs(M.plugins) do
    M.use_plugin(plugin)
  end
end

function M.update_plugins(_)
  lib.update_plugins()
end

function M.cleanup_plugins(_)
  local removable = lib.removable_plugins()
  for _, plugin in ipairs(removable) do
    lib.remove_plugin(plugin)
  end
end

function M.remove_plugins(_)
  lib.remove_plugins()
end

return M
