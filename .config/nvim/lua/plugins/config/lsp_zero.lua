----------------------------------------------------------
--> LSP Zero
--
--  :LspZeroFormat
--  :LspZeroWorkspaceList
--
--  K: display information about symbol
--  gD: jumps to declaration
--  gi: lists all implementations of symbol
--  go: jumps to definition of the type
--  gr: list all references to symbol
--  <F2> renames all references of the symbol
--
--  gl: show diagnostics
--  [d: previous diagnosticvim.lsp.buf.rename().
--  ]d: next diagnostic
--
--  https://github.com/VonHeikemen/lsp-zero.nvim
----------------------------------------------------------
local M = {}

function M.config()
  local lsp = require('lsp-zero')
  lsp.preset('recommended')

  -- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
  lsp.ensure_installed({
    'bashls',                 -- Bash
    'html',                   -- HTML
    -- 'jedi_language_server',   -- Python
    -- 'pylsp',                  -- Python
    'pyright',                -- Python. Requires npm
    'jsonls',                 -- Json
    'marksman',               -- Markdown
    'rust_analyzer',          -- Rust
    'sqlls',                  -- SQL
    'sumneko_lua',            -- Lua
    'terraformls',            -- Terraform
    'tsserver',               -- TypeScript
    'yamlls',                 -- Yaml
  })

  ----------------------------------------------------------
  --> CMP
  ----------------------------------------------------------
  local cmp = require('cmp')
  local cmp_mappings = lsp.defaults.cmp_mappings()

  -- Disable completion with tab
  cmp_mappings['<Tab>'] = nil
  cmp_mappings['<S-Tab>'] = nil

  lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
  })

  lsp.nvim_workspace()

  lsp.setup()

  ----------------------------------------------------------
  --> Null-ls
  --  Sources: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
  ----------------------------------------------------------
  local null_ls = require('null-ls')
  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics

  null_ls.setup({
    sources = {
      -- Stylua: Lua

      -- Prettier: Javascript, TypeScript, CSS, JSON, HTML, Yaml, Markdown
      formatting.prettier.with({
        extra_args = {
          '--no-semi',
          '--single-quote',
          '--jsx-single-quote',
          '--tab-width', '2',
          '--print-width', vim.bo.textwidth,
        },
      }),

      -- Markdownlint: Markdown style checker and lint tool
      diagnostics.markdownlint,

      -- Mdformat: An opinionated Markdown formatter that can be used to enforce a consistent style in Markdown files
      formatting.mdformat,

      -- https://github.com/JohnnyMorganz/StyLua#options
      formatting.stylua.with({
        extra_args = {
          '--indent-type', 'spaces',
          '--indent-width', '2',
          '--column-width', '88',
          '--quote-style', 'AutoPreferSingle',
        },
      }),
      -- Black: Python
      formatting.black.with({
        extra_args = {
          '--line-length', '88',
        }
      }),
      -- Isort: Python
      formatting.isort.with({
        extra_args = {
          '--line-length', '88',
        }
      }),
      -- Flake8: Python
      -- https://pycodestyle.pycqa.org/en/latest/intro.html#error-codes
      diagnostics.flake8.with({
        extra_args = {
          '--max-line-length', '88',
          '--ignore', 'W391',
        },
      }),
    },
  })

  ----------------------------------------------------------
  --> Mason-null-ls
  ----------------------------------------------------------
  require('mason-null-ls').setup({
    -- ensure_installed = {
    --   "stylua",
    --   "jq",
    --   "prettier",
    --   "black",
    --   "isort",
    --   "mypy",
    --   "pylint",
    -- },
    automatic_installation = true,
    automatic_setup = false,
  })

  ----------------------------------------------------------
  --> Mason-dap
  ----------------------------------------------------------
  require('mason-nvim-dap').setup({
    ensure_installed = {
      'python',
    },
    automatic_setup = true,
  })
end

return M
