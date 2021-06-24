# xplr plugin template

Use this template to [write your own xplr plugin](https://arijitbasu.in/xplr/en/writing-plugins.html).

> **NOTE:** The `src` directory is a symlink to `.` for compatibility reasons.
> It may be removed in the future.

## Requirements

- Some tool

## Installation

### Install manually

- Add the following line in `~/.config/xplr/init.lua`

  ```lua
  local home = os.getenv("HOME")
  package.path = home
    .. "/.config/xplr/plugins/?/src/init.lua;"
    .. home
    .. "/.config/xplr/plugins/?.lua;"
    .. package.path
  ```

- Clone the plugin

  ```bash
  mkdir -p ~/.config/xplr/plugins

  git clone https://github.com/{username}/{plugin}.xplr ~/.config/xplr/plugins/{plugin}
  ```

- Require the module in `~/.config/xplr/init.lua`

  ```lua
  require("{plugin}").setup()

  -- Or

  require("{plugin}").setup{
    mode = "action",
    key = ":",
  }

  -- Type `::` and enjoy.
  ```

## Features

- Some cool feature
