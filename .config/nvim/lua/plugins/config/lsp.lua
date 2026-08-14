-------------------------------------------------------------------------------
--> LSP, completion and debugging
--
-- Uses Neovim's native vim.lsp.config/vim.lsp.enable; Mason only installs the
-- servers.
--
-- Per-server settings live one file each in after/lsp/<name>.lua. It has to be
-- after/: all lsp/<name>.lua files on the runtimepath merge into a single tier
-- in runtimepath order, and plugin directories come after the config
-- directory, so a plain lsp/pyright.lua here would lose to the one
-- nvim-lspconfig ships. after/lsp/ is a strictly higher tier and extends it
-- instead. See :h lsp-config-merge.
--
-- This file keeps what is not per-server: diagnostics, which servers to
-- install and enable, and the buffer-local behaviour set on LspAttach.
--
-- Keymaps (buffer-local, set on LspAttach):
--   K       hover documentation        <F2>    rename symbol
--   gd      definition                 gD      declaration
--   gi      implementation             go      type definition
--   gr      references                 gs      signature help
--   gl      show diagnostic in a float  <leader>ca  code action
--   [d ]d   previous/next diagnostic    <leader>th  toggle inlay hints
--   [e ]e   previous/next error only
--
-- Neovim 0.11 also ships its own defaults (grn rename, gra code action,
-- grr references, gri implementation, gO symbols); those still work.
--
-- Servers: :Mason to install/remove, :LspInfo to inspect what attached.
-------------------------------------------------------------------------------
local M = {}

-- Servers installed automatically. Names are mason-lspconfig's, which match
-- nvim-lspconfig's lsp/<name>.lua files.
local servers = {
  -- Python: pyright for types/navigation, ruff for lint + import sorting.
  -- They are complementary; pyright's own linting is left off below.
  'pyright',
  'ruff',

  -- JavaScript / TypeScript. vtsls wraps the official TypeScript language
  -- server and is better maintained than the old tsserver integration.
  'vtsls',
  'eslint',

  -- Web
  'html',
  'cssls',
  'jsonls',

  -- Everything else in regular use here
  'bashls',
  'lua_ls',
  'terraformls',
  'yamlls',
}

-- Servers already installed outside Mason, mapped to the binary that proves
-- it. Mason has no prebuilt release for some of these and would build them
-- from source; these are enabled directly instead.
local system_servers = {
  nil_ls = 'nil', -- Nix, from nixpkgs
  -- From the rustup toolchain (`just rust-setup`), so it stays matched to
  -- rustc and has rust-src for std-library navigation.
  rust_analyzer = 'rust-analyzer',
}

function M.config()
  ---------------------------------------------------------------------------
  --> Diagnostics
  ---------------------------------------------------------------------------
  vim.diagnostic.config({
    -- Compact markers on every line with a diagnostic, and the full message
    -- rendered underneath the line the cursor is on. virtual_lines landed in
    -- 0.11 and is the fix for long TypeScript union errors and Rust borrow
    -- messages, which virtual_text truncates at the window edge.
    virtual_text = { spacing = 2, prefix = '●', current_line = false },
    virtual_lines = { current_line = true },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = true },
  })

  ---------------------------------------------------------------------------
  --> Capabilities shared by every server
  --
  -- Nothing to do here. blink.cmp advertises the completion capabilities
  -- (snippet support, resolve support, ...) from its own plugin/blink-cmp.lua,
  -- which calls vim.lsp.config('*', { capabilities = ... }) as it loads. It is
  -- listed as a dependency of nvim-lspconfig so that runs before any server
  -- starts; doing it again here only duplicated it.
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  --> eslint fix on save
  --
  -- Per buffer, so it only applies where eslint actually attached. The
  -- server's own settings are in after/lsp/eslint.lua.
  ---------------------------------------------------------------------------
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserEslintFix', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name ~= 'eslint' then
        return
      end
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = args.buf,
        command = 'LspEslintFixAll',
      })
    end,
  })

  ---------------------------------------------------------------------------
  --> Install and enable servers
  --
  -- mason-lspconfig v2 calls vim.lsp.enable() for every installed server,
  -- so no per-server setup() loop is needed.
  ---------------------------------------------------------------------------
  require('mason-lspconfig').setup({
    ensure_installed = servers,
    automatic_enable = true,
  })

  -- Enable the servers that are already on $PATH.
  for server, binary in pairs(system_servers) do
    if vim.fn.executable(binary) == 1 then
      vim.lsp.enable(server)
    end
  end

  ---------------------------------------------------------------------------
  --> Buffer-local keymaps and per-buffer behaviour
  ---------------------------------------------------------------------------
  -- clear = false: this group holds one set of autocommands per buffer, so
  -- clearing it on every LspAttach would drop the other buffers' entries.
  -- They are cleared per buffer instead, on attach and again on detach.
  local highlight_group = vim.api.nvim_create_augroup('UserLspDocumentHighlight', { clear = false })

  vim.api.nvim_create_autocmd('LspDetach', {
    group = vim.api.nvim_create_augroup('UserLspDetach', { clear = true }),
    callback = function(args)
      vim.lsp.buf.clear_references()
      vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = args.buf })
    end,
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspKeymaps', { clear = true }),
    callback = function(args)
      local function map(keys, fn, desc)
        vim.keymap.set('n', keys, fn, { buffer = args.buf, desc = 'LSP: ' .. desc })
      end

      local buf = vim.lsp.buf

      -- Highlight every other reference to the symbol under the cursor once
      -- the cursor has rested for 'updatetime' (300ms in options.lua), and
      -- clear them again on the next move. Servers advertise this, but nothing
      -- asks for it by default.
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight') then
        vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = args.buf })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          group = highlight_group,
          buffer = args.buf,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          group = highlight_group,
          buffer = args.buf,
          callback = vim.lsp.buf.clear_references,
        })
      end

      -- Inlay hints: parameter names and inferred types shown inline. Servers
      -- advertise them, but nothing displays them until this is switched on.
      if client and client:supports_method('textDocument/inlayHint') then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }),
            { bufnr = args.buf }
          )
        end, 'Toggle inlay hints')
      end

      map('K', buf.hover, 'Hover documentation')
      map('gd', buf.definition, 'Go to definition')
      map('gD', buf.declaration, 'Go to declaration')
      map('gi', buf.implementation, 'List implementations')
      map('go', buf.type_definition, 'Go to type definition')
      map('gr', buf.references, 'List references')
      map('gs', buf.signature_help, 'Signature help')
      map('<F2>', buf.rename, 'Rename symbol')
      map('<leader>ca', buf.code_action, 'Code action')

      map('gl', vim.diagnostic.open_float, 'Show diagnostic')
      map('[d', function()
        vim.diagnostic.jump({ count = -1, float = true })
      end, 'Previous diagnostic')
      map(']d', function()
        vim.diagnostic.jump({ count = 1, float = true })
      end, 'Next diagnostic')

      -- The same jumps restricted to errors, for a file noisy with warnings
      -- and hints where ]d would stop at every one of them.
      map('[e', function()
        vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
      end, 'Previous error')
      map(']e', function()
        vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
      end, 'Next error')
    end,
  })
end

-------------------------------------------------------------------------------
--> Completion (blink.cmp)
--
-- Replaces nvim-cmp plus cmp-buffer/path/nvim-lsp/nvim-lua/cmp_luasnip.
-- blink ships its own fuzzy matcher and sources in one plugin.
--
-- The old config deliberately unmapped <Tab>/<S-Tab>/<CR> and accepted with
-- <Right>; that preference is preserved below.
-------------------------------------------------------------------------------
function M.completion()
  require('luasnip.loaders.from_vscode').lazy_load()

  require('blink.cmp').setup({
    snippets = { preset = 'luasnip' },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    keymap = {
      preset = 'none',

      -- Accept with Right arrow, as before.
      ['<Right>'] = { 'accept', 'fallback' },

      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

      -- Tab/S-Tab only move through snippet placeholders, never the menu.
      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
    },

    completion = {
      -- Do not preselect, so <CR> keeps inserting a newline.
      list = { selection = { preselect = false, auto_insert = true } },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { border = 'rounded' },
    },

    signature = { enabled = true, window = { border = 'rounded' } },

    appearance = { nerd_font_variant = 'mono' },
  })
end

-------------------------------------------------------------------------------
--> Debug Adapter Protocol
-------------------------------------------------------------------------------
function M.dap()
  require('mason-nvim-dap').setup({
    -- debugpy for Python, js-debug-adapter for Node/browser JS and TS.
    ensure_installed = { 'python', 'js' },
    -- Set explicitly because the type marks it required, so leaving it out is
    -- a lua_ls warning. Off: ensure_installed above is the only thing that
    -- should pull an adapter in.
    automatic_installation = false,
    -- Empty handlers table = apply mason-nvim-dap's default adapter setup for
    -- everything installed. Replaces the old `automatic_setup = true`.
    handlers = {},
  })

  ---------------------------------------------------------------------------
  --> Python
  --
  -- Point dap-python at debugpy's own interpreter (the one Mason installed),
  -- not the project interpreter. debugpy then launches the project's python
  -- itself, so this works regardless of which virtualenv is active.
  ---------------------------------------------------------------------------
  local ok, dap_python = pcall(require, 'dap-python')
  if ok then
    local debugpy = vim.fn.exepath('debugpy-adapter')
    if debugpy ~= '' then
      dap_python.setup(debugpy)
    else
      -- Mason's default install location.
      dap_python.setup(vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python')
    end
  end

  ---------------------------------------------------------------------------
  --> Open and close the debugger UI with the session
  ---------------------------------------------------------------------------
  local dap = require('dap')
  local ui_ok, dapui = pcall(require, 'dapui')
  if not ui_ok then
    return
  end

  dap.listeners.after.event_initialized['dapui'] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated['dapui'] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited['dapui'] = function()
    dapui.close()
  end
end

return M
