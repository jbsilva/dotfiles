local M = {}

function M.config()
  local actions = require('telescope.actions')
  local finders = require('telescope.builtin')

  -- Finders
  local Telescope = setmetatable({}, {
    __index = function(_, k)
      if vim.bo.filetype == 'NvimTree' then
        vim.cmd.wincmd('l')
      end
      return finders[k]
    end,
  })

  ---------------------------------------------------------------------------
  --> Keymaps
  ---------------------------------------------------------------------------
  local remap = require("keymap")
  local nnoremap = remap.nnoremap

  -- Ctrl-p = fuzzy finder
  nnoremap('<C-p>',
    function()
      local ok = pcall(Telescope.git_files, { show_untracked = true })
      if not ok then
        Telescope.find_files()
      end
    end
  )

  -- Get :help
  nnoremap('<leader>H', Telescope.help_tags)

  -- Fuzzy find active buffers
  nnoremap("'b", Telescope.buffers)

  -- Search for string
  nnoremap("'r", Telescope.live_grep)

  -- Fuzzy find changed files in git
  nnoremap("'c", Telescope.git_status)

  -- Open file browser
  nnoremap('<leader>fb', ':Telescope file_browser<cr>')

  ---------------------------------------------------------------------------
  --> Setup
  ---------------------------------------------------------------------------
  require('telescope').setup {
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
        theme = "ivy",
        hijack_netrw = false,
      }
    },
  }
end

return M
