-- lua/thegoglx/init.lua
-- wiring the plugins

local picker = require("thegoglx.picker")

-- Map <leader>K> in normal mode to open the picker
vim.keymap.set("n", "<leader>k", function()
	picker.open()
end, { desc = "Fuzzy command picker" })
