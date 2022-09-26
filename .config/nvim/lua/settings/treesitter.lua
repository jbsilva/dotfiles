local M = {}

function M.config()
  require 'nvim-treesitter.configs'.setup {
    ---------------------------------------------------------------------------
    --> nvim-treesitter/nvim-treesitter
    ---------------------------------------------------------------------------
  
    -- A list of parser names, or "all"
    ensure_installed = {
      'bash',
      'c',
      'css',
      'html',
      'json',
      'lua',
      'markdown',
      'python',
      'rust',
    },
  
    -- Automatically install missing parsers when entering buffer
    auto_install = true,
  
    highlight = {
      enable = true,
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },
  
    -- Indentation based on treesitter for the = operator
    indent = {
      enable = true,
    },
  
    -- Incremental selection based on the named nodes from the grammar
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
      },
    },
  
    ---------------------------------------------------------------------------
    --> nvim-treesitter/nvim-treesitter-textobjects
    -- Syntax aware text-objects, select, move, swap, and peek support
    ---------------------------------------------------------------------------
    textobjects = {
      select = {
        enable = true,
  
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
  
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
          ['al'] = '@loop.outer',
          ['il'] = '@loop.inner',
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['uc'] = '@comment.outer',
        },
      },
  
      -- Define your own mappings to swap the node under the cursor with the next
      -- or previous one, like function parameters or arguments
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
          ['<leader>f'] = '@function.outer',
          ['<leader>e'] = '@element',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
          ['<leader>F'] = '@function.outer',
          ['<leader>E'] = '@element',
        },
      },
  
      -- Define your own mappings to jump to the next or previous text object
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']f'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
  
      -- peek_definition_code: show textobject surrounding definition as determined
      -- using Neovim's built-in LSP in a floating window. Press the shortcut twice
      -- to enter the floating window
      lsp_interop = {
        enable = true,
        border = 'none',
        peek_definition_code = {
          ["<leader>df"] = "@function.outer",
          ["<leader>dF"] = "@class.outer",
        },
      },
  
    },  -- End textobjects
  
    ---------------------------------------------------------------------------
    --> windwp/nvim-ts-autotag
    -- Use treesitter to auto close and auto rename html tag
    ---------------------------------------------------------------------------
    autotag = {
      enable = true,
    },
  
    ---------------------------------------------------------------------------
    --> nvim-treesitter/playground
    -- View treesitter information directly in Neovim!
    ---------------------------------------------------------------------------
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
    },
  
    ---------------------------------------------------------------------------
    --> nvim-treesitter/nvim-treesitter-refactor
    -- Refactor modules for nvim-treesitter
    ---------------------------------------------------------------------------
    refactor = {
      -- Highlights definition and usages of the current symbol under the cursor
      highlight_definitions = {
        enable = true
      },
  
      -- Renames the symbol under the cursor within the current scope (and current file)
      smart_rename = {
        enable = true,
        keymaps = {
          smart_rename = "grr",
        },
      },
    },
  
    ---------------------------------------------------------------------------
    --> JoosepAlviste/nvim-ts-context-commentstring
    -- Set the commentstring option based on the cursor location in the file
    ---------------------------------------------------------------------------
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
  }
end

return M
