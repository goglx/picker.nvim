-- lua/thegoglx/picker.lua
-- Custom Telescope picker that lists commands (and functions) and executes the selected item.
-- Drop this file into: ~/.config/nvim/lua/r/command_picker.lua
-- Requirements: telescope.nvim installed

local M = {}

-- Central list of commands/actions
-- Each entry: { id = "unique", desc = "Description", action = ":write<CR>" or function() ... end, group = "optional" }
local items = {
  { id = "write", desc = "Save current buffer", action = ":w<CR>", group = "File" },
  { id = "quit", desc = "Quit", action = ":q<CR>", group = "File" },
  { id = "writequit", desc = "Write and quit", action = ":wq<CR>", group = "File" },
  { id = "buffers", desc = "List buffers (Telescope)", action = ":Telescope buffers<CR>", group = "Telescope" },
  { id = "find_files", desc = "Find files (Telescope)", action = ":Telescope find_files<CR>", group = "Telescope" },
  { id = "reload_config", desc = "Reload init.lua (source)", action = function()
      -- example of a Lua action: reload most common config path (adjust to your setup)
      local ok, _ = pcall(dofile, vim.fn.stdpath('config') .. '/init.lua')
      if ok then
        vim.notify('Sourced init.lua', vim.log.levels.INFO)
      else
        vim.notify('Failed to source init.lua', vim.log.levels.ERROR)
      end
    end, group = "Dev" },
  { id = "toggle_number", desc = "Toggle line numbers", action = function()
      vim.wo.number = not vim.wo.number
      vim.notify('number: ' .. tostring(vim.wo.number))
    end, group = "View" },
}

-- Utility: transform an item into a display label
local function label_of(item)
  if item.group and item.group ~= '' then
    return string.format("[%s] %s — %s", item.group, item.id, item.desc or "")
  end
  return string.format("%s — %s", item.id, item.desc or "")
end

-- Main picker
function M.open()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    vim.notify('telescope.nvim not found', vim.log.levels.ERROR)
    return
  end

  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local formatted = {}
  for _, it in ipairs(items) do
    table.insert(formatted, { item = it, label = label_of(it) })
  end

  pickers.new({}, {
    prompt_title = 'Commands & Actions',
    finder = finders.new_table {
      results = formatted,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.label,
          ordinal = entry.label,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local run_selected = function()
        local selection = action_state.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)
        if not selection or not selection.value or not selection.value.item then return end

        local sel = selection.value.item
        if type(sel.action) == 'function' then
          local ok, err = pcall(sel.action)
          if not ok then
            vim.schedule(function()
              vim.notify('Error running function: ' .. tostring(err), vim.log.levels.ERROR)
            end)
          end
          return
        end

        if type(sel.action) == 'string' then
          local s = sel.action
          -- If it starts with ":" treat as command
          if s:sub(1,1) == ':' then
            -- strip leading : and optional trailing <CR>
            local cmd = s:sub(2)
            cmd = cmd:gsub('<CR>$', '')
            -- run in command-line context
            vim.cmd(cmd)
            return
          end

          -- Otherwise, feed keys (handle <CR>, <Esc>, etc.)
          local keys = vim.api.nvim_replace_termcodes(s, true, false, true)
          vim.api.nvim_feedkeys(keys, 'n', true)
          return
        end

        vim.notify('Unknown action type for selection', vim.log.levels.WARN)
      end

      -- map Enter in both insert and normal mode of the picker
      map('i', '<CR>', run_selected)
      map('n', '<CR>', run_selected)

      -- optional: map Ctrl-x to run but keep prompt open
      local run_and_keep = function()
        local selection = action_state.get_selected_entry(prompt_bufnr)
        if not selection or not selection.value or not selection.value.item then return end
        local sel = selection.value.item
        if type(sel.action) == 'function' then
          pcall(sel.action)
        elseif type(sel.action) == 'string' then
          local s = sel.action
          if s:sub(1,1) == ':' then
            local cmd = s:sub(2):gsub('<CR>$', '')
            vim.cmd(cmd)
          else
            local keys = vim.api.nvim_replace_termcodes(s, true, false, true)
            vim.api.nvim_feedkeys(keys, 'n', true)
          end
        end
      end
      map('i', '<C-x>', run_and_keep)
      map('n', '<C-x>', run_and_keep)

      return true
    end,
  }):find()
end

-- Helpers to extend items at runtime
function M.add(item)
  -- minimal validation
  if not item or not item.id or not item.action then
    error('item must have id and action')
  end
  table.insert(items, item)
end

function M.list()
  return items
end

return M

