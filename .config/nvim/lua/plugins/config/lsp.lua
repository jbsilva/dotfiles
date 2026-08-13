-------------------------------------------------------------------------------
--> LSP, completion and debugging
--
-- Uses Neovim's native vim.lsp.config/vim.lsp.enable; Mason only installs the
-- servers.
--
-- Keymaps (buffer-local, set on LspAttach):
--   K       hover documentation        <F2>    rename symbol
--   gd      definition                 gD      declaration
--   gi      implementation             go      type definition
--   gr      references                 gs      signature help
--   gl      show diagnostic in a float  <leader>ca  code action
--   [d ]d   previous/next diagnostic
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
  -- blink.cmp advertises the completion capabilities (snippet support,
  -- resolve support, ...). It is lazy-loaded on InsertEnter, so this is
  -- guarded: if blink has not loaded yet it registers its own defaults when
  -- it does, and we fall back to core capabilities here.
  ---------------------------------------------------------------------------
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities(nil, true) })
  end

  ---------------------------------------------------------------------------
  --> Per-server overrides
  ---------------------------------------------------------------------------
  -- Types for the Neovim API and for plugins come from lazydev, which loads
  -- them on demand. Listing the whole runtimepath as `workspace.library`
  -- instead makes lua_ls index every plugin on every start.
  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  })

  -------------------------------------------------------------------------
  --> JSON and YAML schemas
  --
  -- Without a schema catalogue these two servers only check syntax. With one
  -- they validate and complete package.json, tsconfig.json, GitHub workflow
  -- files, docker-compose and the rest against their published schemas.
  -------------------------------------------------------------------------
  local ok_schemas, schemastore = pcall(require, 'schemastore')
  if ok_schemas then
    vim.lsp.config('jsonls', {
      settings = {
        json = {
          schemas = schemastore.json.schemas(),
          validate = { enable = true },
        },
      },
    })

    vim.lsp.config('yamlls', {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = '' }, -- use SchemaStore.nvim's copy
          schemas = schemastore.yaml.schemas(),
        },
      },
    })
  end

  -------------------------------------------------------------------------
  --> Python
  --
  -- pyright does types and navigation; ruff does linting, so pyright's own
  -- diagnostics are turned off to avoid two servers reporting the same
  -- unused import twice.
  --
  -- pythonPath is resolved per project so pyright reads the project
  -- virtualenv (uv/poetry `.venv`, or $VIRTUAL_ENV); without it every
  -- third-party import shows as unresolved.
  -------------------------------------------------------------------------
  local function python_path(root)
    if vim.env.VIRTUAL_ENV then
      return vim.fs.joinpath(vim.env.VIRTUAL_ENV, 'bin', 'python')
    end
    for _, dir in ipairs({ '.venv', 'venv', '.direnv' }) do
      local candidate = vim.fs.joinpath(root or vim.uv.cwd(), dir, 'bin', 'python')
      if vim.uv.fs_stat(candidate) then
        return candidate
      end
    end
    return vim.fn.exepath('python3')
  end

  vim.lsp.config('pyright', {
    before_init = function(_, config)
      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = python_path(config.root_dir)
    end,
    settings = {
      pyright = {
        -- Let ruff own import organisation.
        disableOrganizeImports = true,
      },
      python = {
        analysis = {
          -- ruff reports the lint diagnostics; keep pyright on types only.
          ignore = { '*' },
          typeCheckingMode = 'basic',
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  })

  vim.lsp.config('ruff', {
    init_options = {
      settings = {
        -- Prefer the project's own pyproject.toml/ruff.toml configuration.
        lineLength = 88,
      },
    },
  })

  -------------------------------------------------------------------------
  --> JavaScript / TypeScript
  --
  -- Inlay hints for parameter names and types; toggle them at runtime with
  -- :lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  -------------------------------------------------------------------------
  local ts_inlay_hints = {
    parameterNames = { enabled = 'literals' },
    parameterTypes = { enabled = true },
    variableTypes = { enabled = false },
    propertyDeclarationTypes = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    enumMemberValues = { enabled = true },
  }

  vim.lsp.config('vtsls', {
    settings = {
      typescript = { inlayHints = ts_inlay_hints, updateImportsOnFileMove = { enabled = 'always' } },
      javascript = { inlayHints = ts_inlay_hints },
      vtsls = {
        -- Surface the full error text rather than truncating long TS unions.
        experimental = { completion = { enableServerSideFuzzyMatch = true } },
      },
    },
  })

  -- eslint can fix on save; wired up per-buffer below so it only applies where
  -- the server actually attached.
  vim.lsp.config('eslint', {
    settings = { workingDirectories = { mode = 'auto' } },
  })

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
  --> Buffer-local keymaps
  ---------------------------------------------------------------------------
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspKeymaps', { clear = true }),
    callback = function(args)
      local function map(keys, fn, desc)
        vim.keymap.set('n', keys, fn, { buffer = args.buf, desc = 'LSP: ' .. desc })
      end

      local buf = vim.lsp.buf

      -- Inlay hints: parameter names and inferred types shown inline. Servers
      -- advertise them, but nothing displays them until this is switched on.
      local client = vim.lsp.get_client_by_id(args.data.client_id)
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
