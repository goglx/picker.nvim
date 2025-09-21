# picker.nvim
Command select picker that can be customised. 

# Initial command 
this is just a set of commands to verify that plugin is working.

<img width="1756" height="724" alt="image" src="https://github.com/user-attachments/assets/efc5db33-5058-47af-9402-71d111ffadd8" />

# Requirements

1. Telescope must be installed

# Use case

There are set of commands that I don't want to map to `<leader>something` but in the same time I want
quickly to be able to select them from a given prompt.

Such as `Telescope find_files no_ignore=true hidden=true`.

# Features

*   A fuzzy-find command picker built on top of `telescope.nvim`.
*   Execute either Vim commands or Lua functions.
*   Default set of useful commands.
*   Extensible configuration to add your own commands.
*   Group commands for better organization.

# Installation

Using your favorite plugin manager.

```lua
-- Packer
use { "thegoglx/picker.nvim" }

-- lazy.nvim
{ "thegoglx/picker.nvim" }
```

# Usage

Press `<leader>k` in normal mode to open the command picker.

# Configuration

You can add your own commands to the picker by using the `add` function.

```lua
require("thegoglx.picker").add({
  id = "my_command",
  desc = "My custom command",
  action = ":echo 'Hello from my custom command!'<CR>",
  group = "Custom"
})
```

You can also add a Lua function as an action:

```lua
require("thegoglx.picker").add({
  id = "my_lua_function",
  desc = "My custom Lua function",
  action = function()
    print("Hello from my custom Lua function!")
  end,
  group = "Custom"
})
```

# Default Commands

The plugin comes with a set of default commands:

*   **File**:
    *   `write`: Save current buffer.
    *   `quit`: Quit.
    *   `writequit`: Write and quit.
*   **Telescope**:
    *   `buffers`: List buffers.
    *   `find_files`: Find files.
*   **Dev**:
    *   `reload_config`: Reload `init.lua`.
*   **View**:
    *   `toggle_number`: Toggle line numbers.