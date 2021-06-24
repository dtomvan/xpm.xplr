---@diagnostic disable
local xplr = xplr
---@diagnostic enable

local util = require("plugin-template1.lib.util")

local function setup(args)
  print(util.dump(args))
  print(util.dump(xplr))
  io.read()
end

return { setup = setup }
