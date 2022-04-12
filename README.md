# xplr plugin manager

## Requirements

- Bash
- Git

## Installation

- Add the following line in `~/.config/xplr/init.lua`

```lua
local home = os.getenv("HOME")
local xpm_path = home .. "/.local/share/xplr/xpm.xplr"
local xpm_url = "https://github.com/dtomvan/xpm.xplr"

package.path = package.path
  .. ";"
  .. xpm_path
  .. "/?.lua;"
  .. xpm_path
  .. "/?/init.lua"

os.execute(
  string.format(
    "[ -e '%s' ] || git clone '%s' '%s'",
    xpm_path,
    xpm_url,
    xpm_path
  )
)
```

- Require the module in `~/.config/xplr/init.lua`

```lua

require("xpm").setup({

    -- This works
    'sayanarijit/command-mode.xplr',

    -- Or this
    'github:sayanarijit/command-mode.xplr',

    -- Or this
    'https://github.com/sayanarijit/command-mode.xplr',

    -- You can also use a field
    { name = "sayanarijit/command-mode.xplr" },
})

-- Or

require("xpm").setup({
  plugins = {
    'sayanarijit/command-mode.xplr',
    { name = 'sayanarijit/fzf.xplr' },
  },
  auto_install = true,
  auto_cleanup = true,
})
```

- (optional) Setup key binding for manually managing plugins

```lua
xplr.config.modes.builtin.default.key_bindings.on_key.x = {
  help = "xpm",
  messages = {
    "PopMode",
    { SwitchModeCustom = "xpm" },
  },
}
```

WARNING: a current limitation is that any repo not ending in .xplr isn't picked
up correctly, but by convention the repo's name should end in .xplr


## Features
- Automatically downloads and installs plugins
- Pre/post load hooks
- Automatically calls `setup()` if possible
- Grabs from any git repository

## Setup arguments

```lua
{
  -- Default: {}
  plugins = { "sayanarijit/fzf.xplr" },

  -- Default: true
  auto_install = true

  -- Default: false
  auto_cleanup = false
}
```


## Plugin arguments
All available arguments for a plugin are:
```lua
-- <in xpm.setup>
{
    -- Default: Skip if empty
    "<name>",

    -- Default: Skip if empty
    name = "<name>",

    -- Branch, commit or tag to pin
    -- Default: "origin"
    rev = "<revision>"

    -- Default: empty
    after = function() end,

    -- Default: empty
    before = function() end,

    -- Default: require("<name>").setup()
    setup = function() end,

    -- Default: empty
    -- WARNING: if any of the dependencies fail to download, the plugin won't
    -- load to prevent from any damage being done
    deps = { "sayanarijit/command-mode.xplr" }
}
```
