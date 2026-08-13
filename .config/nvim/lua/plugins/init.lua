-------------------------------------------------------------------------------
--> Plugin specification (lazy.nvim)
--
-- Migrated from packer.nvim (archived Aug 2023) to lazy.nvim.
--
-- Cheat sheet:
--   :Lazy          open the UI          :Lazy sync     install + clean + update
--   :Lazy update   update plugins       :Lazy profile  startup cost per plugin
--   :Lazy health   check for problems   :Lazy clean    remove unused plugins
--
-- Notable changes from the packer config, all because upstream moved on:
--   * vim-polyglot        -> nvim-treesitter (polyglot is unmaintained and
--                           actively fights treesitter highlighting)
--   * Comment.nvim        -> dropped; Neovim 0.10+ has gc/gcc built in
--   * lsp-zero.nvim       -> dropped; Neovim 0.11+ has vim.lsp.config/enable,
--                           which is what lsp-zero existed to paper over
--   * nvim-cmp + cmp-*    -> blink.cmp (one plugin, native fuzzy matching)
--   * vim-easymotion      -> flash.nvim (treesitter-aware, no <Plug> mappings)
--   * vim-surround        -> nvim-surround (maintained Lua rewrite)
--   * neoformat           -> conform.nvim (async, format-on-save)
--   * TimUntersberger/... -> NeogitOrg/neogit (repository moved)
--   * williamboman/mason  -> mason-org/mason (repository moved)
--   * gruvbox-community   -> ellisonleao/gruvbox.nvim (Lua rewrite)
-------------------------------------------------------------------------------
require('plugins.bootstrap').ensure_lazy()

require('lazy').setup({

  ----------------------------------------------------------
  --> Colorschemes
  --
  -- tokyonight is the active theme; lualine's matching theme is selected in
  -- plugins/config/lualine.lua. It must load eagerly (lazy = false) and early
  -- (priority) so that the colorscheme is applied before anything draws, and
  -- so lualine can find the theme module. Leaving it lazy is what produced
  -- "theme 'tokyonight' not found, falling back to 'auto'".
  --
  -- The others stay lazy so `:colorscheme` can still switch to them on demand.
  ----------------------------------------------------------
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      style = 'night', -- night | storm | moon | day
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight-night')
    end,
  },
  { 'projekt0n/github-nvim-theme', lazy = true },
  { 'ellisonleao/gruvbox.nvim', lazy = true },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = true },

  ----------------------------------------------------------
  --> Icons
  -- Required by lualine, bufferline, nvim-tree and telescope.
  ----------------------------------------------------------
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    opts = {},
  },

  ----------------------------------------------------------
  --> Lualine: statusline, with inline git blame
  ----------------------------------------------------------
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'f-person/git-blame.nvim', 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('plugins.config.lualine').config()
    end,
  },

  ----------------------------------------------------------
  --> Fidget: LSP progress notifications in the corner
  ----------------------------------------------------------
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {},
  },

  ----------------------------------------------------------
  --> Bufferline: buffer tabs
  ----------------------------------------------------------
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {},
  },

  ----------------------------------------------------------
  --> WhichKey: shows the possible completions of a started mapping
  ----------------------------------------------------------
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  ----------------------------------------------------------
  --> Gitsigns: signs in the gutter, hunk staging, inline blame
  --  ]c / [c   next/previous hunk
  --  <leader>hs stage hunk      <leader>hr reset hunk
  --  <leader>hp preview hunk    <leader>hb blame line
  ----------------------------------------------------------
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation: fall through to plain ]c/[c inside a diff.
        map('n', ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(gs.next_hunk)
          return '<Ignore>'
        end, 'Next git hunk')

        map('n', '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(gs.prev_hunk)
          return '<Ignore>'
        end, 'Previous git hunk')

        map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
        map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>hb', function()
          gs.blame_line({ full = true })
        end, 'Blame line')
        map('n', '<leader>hd', gs.diffthis, 'Diff this')
      end,
    },
  },

  ----------------------------------------------------------
  --> Neogit: magit-style git interface
  --  :Neogit, :Neogit commit, :Neogit kind=<kind>, :Neogit cwd=<cwd>
  ----------------------------------------------------------
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    opts = {},
  },

  ----------------------------------------------------------
  --> Suda: read/write files with sudo
  --  :SudaWrite, :SudaRead
  ----------------------------------------------------------
  {
    'lambdalisue/suda.vim',
    cmd = { 'SudaRead', 'SudaWrite' },
  },

  ----------------------------------------------------------
  --> Undotree: visualise the undo history
  --  <leader>u toggles
  ----------------------------------------------------------
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle', 'UndotreeShow' },
    keys = {
      { '<leader>u', vim.cmd.UndotreeToggle, desc = 'Toggle undotree' },
    },
  },

  ----------------------------------------------------------
  --> Nvim-tree: file explorer
  --  ,e toggles. netrw is disabled in options.lua, so this is the explorer.
  ----------------------------------------------------------
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile' },
    keys = {
      { ',e', '<CMD>NvimTreeToggle<CR>', desc = 'Toggle file explorer' },
    },
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('plugins.config.nvim-tree').config()
    end,
  },

  ----------------------------------------------------------
  --> Telescope: fuzzy finder over lists
  --  Needs fd and ripgrep, both declared in nix-darwin/modules/packages.nix.
  --  <C-p> files, 'b buffers, 'r live grep, 'c git status, <leader>H help
  ----------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'nvim-telescope/telescope-symbols.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      {
        -- Native C sorter: a large speedup on big repositories.
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    config = function()
      require('plugins.config.telescope').config()
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('file_browser')
    end,
  },

  ----------------------------------------------------------
  --> Treesitter: incremental parsing for highlighting and text objects
  --
  --  Uses the `main` branch. The old `master` branch (and the
  --  `nvim-treesitter.configs` module the previous config called) is
  --  deprecated: parsers are now installed with :TSInstall / install() and
  --  highlighting is started per-buffer via vim.treesitter.start().
  ----------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('plugins.config.treesitter').config()
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('plugins.config.treesitter').textobjects()
    end,
  },

  ----------------------------------------------------------
  --> LSP, completion and debugging
  --  See lua/plugins/config/lsp.lua
  ----------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
    },
    config = function()
      require('plugins.config.lsp').config()
    end,
  },
  {
    -- blink.cmp replaces nvim-cmp and all the cmp-* sources with one plugin.
    'saghen/blink.cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    version = '*', -- use a release tag, which ships a prebuilt fuzzy binary
    dependencies = {
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      require('plugins.config.lsp').completion()
    end,
  },
  {
    'mfussenegger/nvim-dap',
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'DAP continue' },
      { '<leader>do', function() require('dap').step_over() end, desc = 'DAP step over' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'DAP step into' },
      { '<leader>dt', function() require('dapui').toggle() end, desc = 'DAP UI toggle' },
      -- Python: debug just the test/class/method under the cursor
      { '<leader>dm', function() require('dap-python').test_method() end, desc = 'DAP python test method' },
    },
    dependencies = {
      -- Repository moved from jayp0521/ to jay-babu/.
      { 'jay-babu/mason-nvim-dap.nvim', dependencies = 'mason-org/mason.nvim' },
      -- Debugger UI: scopes, breakpoints, stacks, watches, REPL.
      { 'rcarriga/nvim-dap-ui', dependencies = 'nvim-neotest/nvim-nio', opts = {} },
      -- Python adapter (debugpy), installed by mason-nvim-dap above.
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      require('plugins.config.lsp').dap()
    end,
  },

  ----------------------------------------------------------
  --> Neotest: run and debug tests from the editor
  --  <leader>tt file      <leader>tn nearest     <leader>ts summary
  --  <leader>td debug nearest test
  ----------------------------------------------------------
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neotest/nvim-nio',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- Language adapters, matching what is actually written here.
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-jest',
    },
    keys = {
      { '<leader>tt', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Test file' },
      { '<leader>tn', function() require('neotest').run.run() end, desc = 'Test nearest' },
      { '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Debug nearest test' },
      { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Test summary' },
      { '<leader>to', function() require('neotest').output.open({ enter = true }) end, desc = 'Test output' },
    },
    config = function()
      require('plugins.config.neotest').config()
    end,
  },

  ----------------------------------------------------------
  --> nvim-ts-autotag: close and rename HTML/JSX tags automatically
  --  Was a nvim-treesitter module on the master branch; now standalone.
  ----------------------------------------------------------
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte', 'markdown' },
    opts = {},
  },

  ----------------------------------------------------------
  --> Package info: show outdated deps inline in package.json
  --  <leader>ns show versions, <leader>nu update package on the line
  ----------------------------------------------------------
  {
    'vuki656/package-info.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    event = { 'BufRead package.json' },
    opts = {},
    keys = {
      { '<leader>ns', function() require('package-info').show() end, desc = 'Show package versions' },
      { '<leader>nu', function() require('package-info').update() end, desc = 'Update package' },
    },
  },

  ----------------------------------------------------------
  --> Conform: async formatting, replaces neoformat
  --  <leader>F formats the buffer or the visual selection.
  ----------------------------------------------------------
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>F',
        function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end,
        mode = { 'n', 'v' },
        desc = 'Format buffer/selection',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        nix = { 'nixfmt' },
        python = { 'ruff_format' },
        sh = { 'shfmt' },
        zsh = { 'shfmt' },
        terraform = { 'terraform_fmt' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        html = { 'prettier' },
        css = { 'prettier' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
      },
      -- Not format-on-save: this config has deliberate hand-formatting in
      -- places. Use <leader>F or :Format.
      format_on_save = false,
    },
  },

  ----------------------------------------------------------
  --> Flash: jump anywhere on screen, replaces vim-easymotion
  --  s  jump by label      S  treesitter-node select
  --  Also enhances f/F/t/T with labels.
  ----------------------------------------------------------
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      modes = {
        -- Off by default: `/` search stays vanilla, as easymotion left it.
        search = { enabled = false },
      },
    },
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash jump' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote flash' },
    },
  },

  ----------------------------------------------------------
  --> nvim-surround: manipulate surroundings (maintained vim-surround)
  --
  --  (*) is the cursor:
  --  Old text                  Command     New text
  --  "Hello *world!"           ds"         Hello world!
  --  [123+4*56]/2              cs])        (123+456)/2
  --  <div>Yo!*</div>           cst<p>      <p>Yo!</p>
  --  if *x>3 {                 ysW(        if ( x>3 ) {
  ----------------------------------------------------------
  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    opts = {},
  },

  ----------------------------------------------------------
  --> Autopairs: close brackets and quotes as you type
  ----------------------------------------------------------
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true, -- use treesitter to avoid pairing inside strings
    },
  },

  ----------------------------------------------------------
  --> Vim-repeat: make "." work with plugin maps
  ----------------------------------------------------------
  { 'tpope/vim-repeat', event = 'VeryLazy' },

  ----------------------------------------------------------
  --> Vim-speeddating: CTRL-A/CTRL-X on dates and times
  ----------------------------------------------------------
  { 'tpope/vim-speeddating', event = 'VeryLazy' },

  ----------------------------------------------------------
  --> nvim-spider: subword motions, replaces bkad/CamelCaseMotion
  --
  --  Moves by camelCase and snake_case segments, which is most of the value
  --  when reading Python and JavaScript. Bound to the same <leader>w/e/b as
  --  CamelCaseMotion used, so plain w/e/b keep their normal meaning.
  --  Works in operator-pending mode too: d<leader>w, ci<leader>w, ...
  ----------------------------------------------------------
  {
    'chrisgrieser/nvim-spider',
    keys = {
      { '<leader>w', function() require('spider').motion('w') end, mode = { 'n', 'o', 'x' }, desc = 'Subword forward' },
      { '<leader>e', function() require('spider').motion('e') end, mode = { 'n', 'o', 'x' }, desc = 'Subword end' },
      { '<leader>b', function() require('spider').motion('b') end, mode = { 'n', 'o', 'x' }, desc = 'Subword back' },
    },
    opts = {},
  },

  ----------------------------------------------------------
  --> Vim-visual-multi: multiple cursors
  --  https://github.com/mg979/vim-visual-multi/wiki/Quick-start
  ----------------------------------------------------------
  {
    'mg979/vim-visual-multi',
    event = 'VeryLazy',
    init = function()
      vim.g.VM_mouse_mappings = 1
    end,
  },

  ----------------------------------------------------------
  --> Removed, kept here as a record of why
  ----------------------------------------------------------
  -- 'numToStr/Comment.nvim'   -- archived; Neovim 0.10+ has built-in gc/gcc/gbc
  -- 'preservim/nerdcommenter' -- superseded by the built-in commenting
  -- 'sheerun/vim-polyglot'    -- unmaintained; conflicts with treesitter
  -- 'VonHeikemen/lsp-zero'    -- superseded by native vim.lsp.config/enable
  -- 'bkad/CamelCaseMotion'    -- unmaintained; replaced by nvim-spider
  -- 'easymotion/vim-easymotion' -- replaced by flash.nvim
  -- 'tpope/vim-surround'      -- replaced by kylechui/nvim-surround
  -- 'sbdchd/neoformat'        -- replaced by stevearc/conform.nvim

}, {
  ----------------------------------------------------------
  --> lazy.nvim options
  ----------------------------------------------------------
  install = { colorscheme = { 'github_dark', 'habamax' } },
  checker = {
    -- Check for updates in the background, but never install automatically.
    enabled = true,
    notify = false,
  },
  change_detection = { notify = false },
  performance = {
    rtp = {
      -- Disable unused built-in plugins to shave startup time.
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        'netrwPlugin',
      },
    },
  },
})
