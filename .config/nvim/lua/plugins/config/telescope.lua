local M = {}

---------------------------------------------------------------------------
--> Pickers
--
-- These are called from the `keys` table in the plugin spec rather than
-- mapped here, so telescope stays lazy: lazy.nvim binds a stub and only
-- loads the plugin on the first press. Mapping inside config() is what
-- forced `event = 'VeryLazy'`, which loaded telescope, plenary,
-- fzf-native, file-browser and devicons during every startup.
--
-- Stepping out of the tree first: a picker opened while the cursor is in
-- NvimTree would otherwise open the file in the tree's own window.
---------------------------------------------------------------------------
local function leave_tree()
  if vim.bo.filetype == 'NvimTree' then
    vim.cmd.wincmd('l')
  end
end

function M.pick(name, opts)
  leave_tree()
  require('telescope.builtin')[name](opts)
end

-- Ctrl-p: tracked + untracked files in a repo, every file outside one.
function M.project_files()
  leave_tree()
  local builtin = require('telescope.builtin')
  if not pcall(builtin.git_files, { show_untracked = true }) then
    builtin.find_files()
  end
end

function M.config()
  local actions = require('telescope.actions')

  require('telescope').setup({
    defaults = {
      prompt_prefix = ' ❯ ',
      initial_mode = 'insert',
      sorting_strategy = 'ascending',
      layout_config = {
        prompt_position = 'top',
      },
      mappings = {
        i = {
          ['<ESC>'] = actions.close,
          ['<C-j>'] = actions.move_selection_next,
          ['<C-k>'] = actions.move_selection_previous,
          ['<TAB>'] = actions.toggle_selection + actions.move_selection_next,
          ['<C-s>'] = actions.send_selected_to_qflist,
          ['<C-q>'] = actions.send_to_qflist,
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = 'smart_case',
      },
      file_browser = {
        theme = 'ivy',
        hijack_netrw = false,
      },
    },
  })
end

return M
