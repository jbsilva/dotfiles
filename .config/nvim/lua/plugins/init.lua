-------------------------------------------------------------------------------
--> Plugin specification (lazy.nvim)
--
-- Cheat sheet:
--   :Lazy          open the UI          :Lazy sync     install + clean + update
--   :Lazy update   update plugins       :Lazy profile  startup cost per plugin
--   :Lazy health   check for problems   :Lazy clean    remove unused plugins
--
-- Commenting (gc/gcc/gbc) is built into Neovim, so no plugin provides it.
-------------------------------------------------------------------------------
require('plugins.bootstrap').ensure_lazy()

require('lazy').setup({

  ----------------------------------------------------------
  --> Colorschemes
  --
  -- tokyonight loads eagerly and early so the colorscheme is applied before
  -- anything draws, and so lualine can resolve its matching theme.
  -- The others stay lazy; `:colorscheme` switches to them on demand.
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
  -- These three are never selected -- tokyonight-night is set above and
  -- nothing switches away from it. They are lazy, so they cost nothing at
  -- startup, but they are still cloned and updated. Drop them if `:colorscheme`
  -- really never gets used.
  { 'projekt0n/github-nvim-theme', lazy = true },
  { 'ellisonleao/gruvbox.nvim', lazy = true },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = true },

  ----------------------------------------------------------
  --> Icons
  -- Required by lualine, bufferline, nvim-tree and telescope.
  --
  -- Alternative to consider: mini.icons  https://github.com/echasnovski/mini.icons
  -- Lighter and faster, and can stand in for this one via
  -- require('mini.icons').mock_nvim_web_devicons().
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
    dependencies = { 'lewis6991/gitsigns.nvim', 'nvim-tree/nvim-web-devicons' },
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
  --
  --  Alternative to consider: mini.tabline
  --  https://github.com/echasnovski/mini.tabline
  --  Much smaller, if the extra bufferline features go unused.
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
      -- Populates b:gitsigns_blame_line for the lualine section. virt_text is
      -- off so the blame shows in the statusline only, not as inline text.
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = false,
        delay = 300,
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Inside a diff ]c/[c stay the built-in diff motions, everywhere else
        -- they walk gitsigns hunks. These are not `expr` mappings, so the diff
        -- branch runs the motion itself instead of returning it.
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk('next')
          end
        end, 'Next git hunk')

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk('prev')
          end
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
  --
  --  Alternative to consider: oil.nvim  https://github.com/stevearc/oil.nvim
  --  Edits the filesystem as a normal buffer -- rename/move/delete with the
  --  usual editing commands, then :w. Both are healthy; pure preference.
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
  --
  --  Alternative to consider: fzf-lua  https://github.com/ibhagwan/fzf-lua
  --  Faster, more actively developed, and drives the same fzf binary already
  --  in packages.nix. Telescope keeps the larger extension ecosystem.
  ----------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    -- Declared here rather than mapped inside config(), so lazy.nvim can bind
    -- a stub and defer the plugin (plus plenary, fzf-native, file-browser and
    -- devicons) until the first press. Mapping in config() is why this used to
    -- carry `event = 'VeryLazy'` and load on every startup.
    keys = {
      {
        '<C-p>',
        function()
          require('plugins.config.telescope').project_files()
        end,
        desc = 'Find files (git-aware)',
      },
      {
        "'b",
        function()
          require('plugins.config.telescope').pick('buffers')
        end,
        desc = 'Find buffers',
      },
      {
        "'r",
        function()
          require('plugins.config.telescope').pick('live_grep')
        end,
        desc = 'Live grep',
      },
      {
        "'c",
        function()
          require('plugins.config.telescope').pick('git_status')
        end,
        desc = 'Changed files (git)',
      },
      {
        '<leader>H',
        function()
          require('plugins.config.telescope').pick('help_tags')
        end,
        desc = 'Help tags',
      },
      { '<leader>fb', '<cmd>Telescope file_browser<cr>', desc = 'File browser' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
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
  --  On the `main` branch: parsers install via :TSInstall / install() and
  --  highlighting starts per buffer through vim.treesitter.start().
  --  Requires the tree-sitter CLI to build parsers.
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
      -- Schemas for jsonls and yamlls: package.json, tsconfig, GitHub
      -- workflows, docker-compose and friends get validation and completion.
      'b0o/SchemaStore.nvim',
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
  --
  --  Debugging is on the function keys, the same ones every other debugger
  --  uses. It cannot live under <leader>d: that is the "delete, but keep the
  --  text" operator from keybinds.lua, and a <leader>d? mapping swallows the
  --  motion after it -- <leader>diw and <leader>dt) could never fire while
  --  <leader>di and <leader>dt were step-into and UI-toggle.
  --
  --  <F5> continue    <F9>  breakpoint   <F6> UI toggle
  --  <F10> step over  <F11> step into
  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<F9>',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'DAP breakpoint',
      },
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'DAP continue',
      },
      {
        '<F10>',
        function()
          require('dap').step_over()
        end,
        desc = 'DAP step over',
      },
      {
        '<F11>',
        function()
          require('dap').step_into()
        end,
        desc = 'DAP step into',
      },
      {
        '<F6>',
        function()
          require('dapui').toggle()
        end,
        desc = 'DAP UI toggle',
      },
      -- Python: debug just the test/class/method under the cursor. Grouped
      -- with the other <leader>t test mappings rather than with the F keys.
      {
        '<leader>tm',
        function()
          require('dap-python').test_method()
        end,
        desc = 'DAP python test method',
      },
    },
    dependencies = {
      -- Repository moved from jayp0521/ to jay-babu/.
      { 'jay-babu/mason-nvim-dap.nvim', dependencies = 'mason-org/mason.nvim' },
      -- Debugger UI: scopes, breakpoints, stacks, watches, REPL.
      { 'rcarriga/nvim-dap-ui', dependencies = 'nvim-neotest/nvim-nio', opts = {} },
      -- Shows each variable's current value inline next to its declaration
      -- while stopped, instead of only in the scopes pane.
      { 'theHamsta/nvim-dap-virtual-text', opts = {} },
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
      'nvim-treesitter/nvim-treesitter',
      -- Language adapters, matching what is actually written here.
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-jest',
    },
    keys = {
      {
        '<leader>tt',
        function()
          require('neotest').run.run(vim.fn.expand('%'))
        end,
        desc = 'Test file',
      },
      {
        '<leader>tn',
        function()
          require('neotest').run.run()
        end,
        desc = 'Test nearest',
      },
      {
        '<leader>td',
        function()
          require('neotest').run.run({ strategy = 'dap' })
        end,
        desc = 'Debug nearest test',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = 'Test summary',
      },
      {
        '<leader>to',
        function()
          require('neotest').output.open({ enter = true })
        end,
        desc = 'Test output',
      },
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
    ft = {
      'html',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'vue',
      'svelte',
      'markdown',
    },
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
      {
        '<leader>ns',
        function()
          require('package-info').show()
        end,
        desc = 'Show package versions',
      },
      {
        '<leader>nu',
        function()
          require('package-info').update()
        end,
        desc = 'Update package',
      },
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
        rust = { 'rustfmt' },
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
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash jump',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote flash',
      },
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
  --> lazydev: Neovim API types for lua_ls, loaded on demand
  --
  --  Only for Lua that is editing Neovim itself, which here means this config.
  --  Gives completion and signatures for vim.* and for plugin modules without
  --  lua_ls indexing every installed plugin at startup.
  ----------------------------------------------------------
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  ----------------------------------------------------------
  --> Treesitter context: keeps the enclosing function/class header pinned
  --  to the top of the window while scrolling through a long body.
  ----------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      max_lines = 3,
      multiline_threshold = 1,
    },
    keys = {
      {
        -- Not [c: gitsigns already uses ]c/[c for hunks.
        '[x',
        function()
          require('treesitter-context').go_to_context(vim.v.count1)
        end,
        desc = 'Jump to enclosing context',
      },
    },
  },

  ----------------------------------------------------------
  --> Trouble: diagnostics, references and quickfix in one list
  --  <leader>xx  diagnostics for the buffer   <leader>xX  for the workspace
  --  <leader>xs  document symbols             <leader>xl  LSP references
  --  <leader>xq  quickfix list
  ----------------------------------------------------------
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Diagnostics (buffer)',
      },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (workspace)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols' },
      { '<leader>xl', '<cmd>Trouble lsp toggle<cr>', desc = 'LSP references/definitions' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix list' },
    },
  },

  ----------------------------------------------------------
  --> Todo-comments: highlight TODO/FIXME/HACK and search them
  --  <leader>xt lists them, ]t / [t jump between them
  ----------------------------------------------------------
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = 'nvim-lua/plenary.nvim',
    opts = { signs = false },
    keys = {
      { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo list' },
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next todo',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous todo',
      },
    },
  },

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
      {
        '<leader>w',
        function()
          require('spider').motion('w')
        end,
        mode = { 'n', 'o', 'x' },
        desc = 'Subword forward',
      },
      {
        '<leader>e',
        function()
          require('spider').motion('e')
        end,
        mode = { 'n', 'o', 'x' },
        desc = 'Subword end',
      },
      {
        '<leader>b',
        function()
          require('spider').motion('b')
        end,
        mode = { 'n', 'o', 'x' },
        desc = 'Subword back',
      },
    },
    opts = {},
  },

  ----------------------------------------------------------
  --> Vim-visual-multi: multiple cursors
  --  https://github.com/mg979/vim-visual-multi/wiki/Quick-start
  --
  --  Alternative to consider: multicursor.nvim
  --  https://github.com/jake-stewart/multicursor.nvim
  --  Lua-native rather than VimL, which avoids visual-multi's long-standing
  --  interaction quirks with other plugins.
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
  -- 'NeogitOrg/neogit'       -- Fork is the git UI here; gitsigns covers hunks
  -- 'antoinemadec/FixCursorHold.nvim' -- its README: not needed after neovim#20198 (0.9)
  -- 'f-person/git-blame.nvim' -- gitsigns' b:gitsigns_blame_line feeds lualine
}, {
  ----------------------------------------------------------
  --> lazy.nvim options
  ----------------------------------------------------------
  install = { colorscheme = { 'tokyonight-night', 'habamax' } },
  -- No plugin here needs luarocks, and leaving it on makes :checkhealth
  -- complain about a missing hererocks install.
  rocks = { enabled = false },
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
