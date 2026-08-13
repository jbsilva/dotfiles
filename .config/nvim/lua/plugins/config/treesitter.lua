-------------------------------------------------------------------------------
--> Treesitter
--
-- Rewritten for the nvim-treesitter `main` branch. The previous config used
-- `require('nvim-treesitter.configs').setup{...}`, which only exists on the old
-- `master` branch. On main:
--
--   * parsers are installed with require('nvim-treesitter').install(...)
--     or :TSInstall, and updated with :TSUpdate
--   * highlighting is started per buffer with vim.treesitter.start()
--     instead of a `highlight = { enable = true }` table
--   * the bundled `playground`, `refactor` and `autotag` modules are gone
--     (:InspectTree and :EditQuery are in core now; nvim-ts-autotag is a
--     separate plugin if HTML tag renaming is wanted again)
--   * textobjects moved to its own setup call, see M.textobjects() below
--
-- Neovim ships parsers for c, lua, markdown, query, vim and vimdoc, so those
-- work with no install.
-------------------------------------------------------------------------------
local M = {}

-- Parsers to keep installed.
local ensure_installed = {
  'bash',
  'c',
  'css',
  'diff',
  'dockerfile',
  'git_config',
  'gitcommit',
  'gitignore',
  'go',
  'hcl',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'nix',
  'python',
  'query',
  'regex',
  'rust',
  'terraform',
  'toml',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

function M.config()
  require('nvim-treesitter').setup({})

  -- install() is async and a no-op for parsers already present.
  require('nvim-treesitter').install(ensure_installed)

  ---------------------------------------------------------------------------
  --> Enable highlighting and treesitter indentation per buffer
  --
  -- vim.treesitter.start() throws when no parser is available for the
  -- language, which is normal for filetypes not in the list above, so it is
  -- wrapped in pcall rather than guarded by a pattern list.
  ---------------------------------------------------------------------------
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('TreesitterStart', { clear = true }),
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(args.match)
      if not lang then
        return
      end

      if pcall(vim.treesitter.start, args.buf, lang) then
        -- Use treesitter for the `=` operator.
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })
end

-------------------------------------------------------------------------------
--> Text objects
--
-- On main, nvim-treesitter-textobjects exposes Lua functions instead of
-- generating mappings from a config table, so the keymaps from the old
-- `textobjects = { select/swap/move }` blocks are declared explicitly here.
-------------------------------------------------------------------------------
function M.textobjects()
  require('nvim-treesitter-textobjects').setup({
    select = {
      -- Jump forward to the text object if the cursor is not inside one.
      lookahead = true,
    },
    move = {
      set_jumps = true,
    },
  })

  local select = require('nvim-treesitter-textobjects.select')
  local swap = require('nvim-treesitter-textobjects.swap')
  local move = require('nvim-treesitter-textobjects.move')

  ---------------------------------------------------------------------------
  --> Select: af/if function, ac/ic class, al/il loop, aa/ia parameter
  ---------------------------------------------------------------------------
  local selections = {
    ['af'] = '@function.outer',
    ['if'] = '@function.inner',
    ['ac'] = '@class.outer',
    ['ic'] = '@class.inner',
    ['al'] = '@loop.outer',
    ['il'] = '@loop.inner',
    ['aa'] = '@parameter.outer',
    ['ia'] = '@parameter.inner',
    ['uc'] = '@comment.outer',
  }

  for keys, query in pairs(selections) do
    vim.keymap.set({ 'x', 'o' }, keys, function()
      select.select_textobject(query, 'textobjects')
    end, { desc = 'Select ' .. query })
  end

  ---------------------------------------------------------------------------
  --> Swap the parameter under the cursor with the next/previous one
  ---------------------------------------------------------------------------
  vim.keymap.set('n', '<leader>a', function()
    swap.swap_next('@parameter.inner')
  end, { desc = 'Swap parameter with next' })

  vim.keymap.set('n', '<leader>A', function()
    swap.swap_previous('@parameter.inner')
  end, { desc = 'Swap parameter with previous' })

  ---------------------------------------------------------------------------
  --> Move between functions, classes and blocks
  ---------------------------------------------------------------------------
  local moves = {
    goto_next_start = {
      [']f'] = '@function.outer',
      [']]'] = '@class.outer',
      [']b'] = '@block.outer',
    },
    goto_next_end = { [']F'] = '@function.outer', [']['] = '@class.outer', [']B'] = '@block.outer' },
    goto_previous_start = {
      ['[f'] = '@function.outer',
      ['[['] = '@class.outer',
      ['[b'] = '@block.outer',
    },
    goto_previous_end = {
      ['[F'] = '@function.outer',
      ['[]'] = '@class.outer',
      ['[B'] = '@block.outer',
    },
  }

  for fn, keymaps in pairs(moves) do
    for keys, query in pairs(keymaps) do
      vim.keymap.set({ 'n', 'x', 'o' }, keys, function()
        move[fn](query, 'textobjects')
      end, { desc = fn .. ' ' .. query })
    end
  end
end

return M
