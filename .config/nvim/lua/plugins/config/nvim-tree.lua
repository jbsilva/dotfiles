local M = {}

function M.config()
  require('nvim-tree').setup({
    diagnostics = {
      enable = true,
    },
    update_focused_file = {
      enable = true,
    },
    view = {
      width = 35,
      side = 'left',
    },
    filters = {
      custom = { '.git$', 'node_modules$', '^target$' },
    },
    git = {
      ignore = false,
    },
    actions = {
      open_file = {
        window_picker = {
          enable = false,
        },
      },
    },
    renderer = {
      icons = {
        show = {
          git = true,
          folder = true,
          file = true,
          folder_arrow = false,
        },
        glyphs = {
          default = '',
        },
      },
      indent_markers = {
        enable = true,
      },
    },
  })

  ---------------------------------------------------------------------------
  --> Never wrap lines in the tree window
  --
  -- The ,e keymap lives in the lazy.nvim spec (lua/plugins/init.lua) so the
  -- plugin can stay lazy-loaded until the key is pressed.
  ---------------------------------------------------------------------------
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('NVIM_TREE', { clear = true }),
    pattern = 'NvimTree',
    callback = function()
      -- nvim_win_set_option is deprecated since 0.10; vim.wo is the
      -- supported way to set a window-local option.
      vim.wo[0].wrap = false
    end,
  })
end

return M
