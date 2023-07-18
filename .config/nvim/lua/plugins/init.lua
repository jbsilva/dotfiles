local packer_bootstrap = require('plugins.bootstrap').ensure_packer()

return require('packer').startup(function(use)
  ----------------------------------------------------------
  --> Packer: the package manager
  -- Packer can manage itself
  ----------------------------------------------------------
  use 'wbthomason/packer.nvim'

  ----------------------------------------------------------
  --> Neoformat: A (Neo)vim plugin for formatting code
  -- :Neoformat
  -- :Neoformat! python yapf
  ----------------------------------------------------------
  use 'sbdchd/neoformat'

  ----------------------------------------------------------
  --> Neogit: Git interface
  -- :Neogit " uses tab
  -- :Neogit kind=<kind> " override kind
  -- :Neogit cwd=<cwd> " override cwd
  -- :Neogit commit" open commit popup
  ----------------------------------------------------------
  use {
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim'
  }

  ----------------------------------------------------------
  --> WhichKey: Show possible keybindings of the command you started typing
  -- :WhichKey
  ----------------------------------------------------------
  use 'folke/which-key.nvim'

  ----------------------------------------------------------
  --> Undotree: The undo history visualizer for VIM
  --  :UndotreeToggle
  ----------------------------------------------------------
  use {
    'mbbill/undotree',
    setup = function()
      require('plugins.config.undotree').setup()
    end,
  }

  ----------------------------------------------------------
  --> Popup: An implementation of the Popup API from vim in Neovim
  ----------------------------------------------------------
  -- use 'nvim-lua/popup.nvim'

  ----------------------------------------------------------
  --> Nvim-web-devicons: Adds file type icons to plugins
  --  Requires nerdfonts.com
  ----------------------------------------------------------
  use {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup()
    end,
  }

  ----------------------------------------------------------
  --> Nvim-tree: A file explorer for Neovim written in Lua
  -- See also: telescope-file-browser
  ----------------------------------------------------------
  use {
    'nvim-tree/nvim-tree.lua',
    requires = 'nvim-tree/nvim-web-devicons',
    tag = 'nightly',
    event = 'CursorHold',
    config = function()
      require('plugins.config.nvim-tree').config()
    end,
  }

  ----------------------------------------------------------
  --> Telescope: Highly extendable fuzzy finder over lists
  -- Install sharkdp/fd and BurntSushi/ripgrep before
  ----------------------------------------------------------
  use {
    {
      'nvim-telescope/telescope.nvim',
      requires = 'nvim-lua/plenary.nvim',
      event = 'CursorHold',
      config = function()
        require('plugins.config.telescope').config()
      end,
    },
    -- FZF
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      after = 'telescope.nvim',
      run = 'make',
      config = function()
        require('telescope').load_extension('fzf')
      end,
    },
    -- Symbols
    {
      'nvim-telescope/telescope-symbols.nvim',
      after = 'telescope.nvim',
    },
    -- File browser extension
    {
      'nvim-telescope/telescope-file-browser.nvim',
      after = 'telescope.nvim',
      config = function()
        require('telescope').load_extension('file_browser')
      end,
    },
  }

  ----------------------------------------------------------
  --> Colorschemes
  ----------------------------------------------------------
  -- Gruvbox
  use 'gruvbox-community/gruvbox'

  -- Tokyo Night: A dark and light theme ported from VSCode
  use 'folke/tokyonight.nvim'

  -- GitHub's Neovim themes
  use({
    'projekt0n/github-nvim-theme',
    config = function()
      require('github-theme').setup({
      })
      vim.cmd('colorscheme github_dark')
    end
  })

  ----------------------------------------------------------
  --> Lualine: A blazing fast and easy to configure Neovim statusline
  --  Uses:
  --    Git blame: A git blame plugin for Neovim written in Lua
  --    fidget.nvim: Standalone UI for nvim-lsp progress
  ----------------------------------------------------------
  use {
    {
      'nvim-lualine/lualine.nvim',
      after = 'tokyonight.nvim',
      requires = 'f-person/git-blame.nvim',
      event = 'BufEnter',
      config = function()
        require('plugins.config.lualine').config()
      end
    },
    -- Fidget
    {
      'j-hui/fidget.nvim', tag = 'legacy',
      after = 'lualine.nvim',
      config = function()
        require('fidget').setup()
      end
    }
  }

  ----------------------------------------------------------
  --> Bufferline: A snazzy bufferline for Neovim
  ----------------------------------------------------------
  use {
    'akinsho/bufferline.nvim', tag = '*',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('bufferline').setup()
    end
  }

  ----------------------------------------------------------
  --> Neotest: A framework for interacting with tests within NeoVim
  ----------------------------------------------------------
  use {
    'nvim-neotest/neotest',
    cmd = { 'Neotest', 'NeotestRun' },
    module = 'neotest',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'rouge8/neotest-rust',
      'antoinemadec/FixCursorHold.nvim'
    },
    setup = function()
      require('plugins.config.neotest').setup()
    end,
    config = function()
      require('plugins.config.neotest').config()
    end,
  }

  ----------------------------------------------------------
  --> Nvim-lspconfig: Configs for Neovim's built-in language server client
  -- Install the language servers:
  --    https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#pyright
  --    :LspInfo
  ----------------------------------------------------------
  -- use {
  --   'neovim/nvim-lspconfig',
  --   requires = {
  --     -- Automatically install LSPs to stdpath for neovim
  --     'williamboman/mason.nvim',
  --     'williamboman/mason-lspconfig.nvim',
  --     -- Useful status updates for LSP
  --     'j-hui/fidget.nvim',
  --   },
  --   setup = function()
  --     require('mason').setup()
  --   end,
  -- }

  ----------------------------------------------------------
  --> LSP Zero: A starting point to setup some lsp related features
  --> Null-ls: Inject LSP diagnostics, code actions, and more via Lua
  --> Debug Adapter Protocol client implementation for Neovim
  ----------------------------------------------------------
  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      --> Null-ls
      { 'jose-elias-alvarez/null-ls.nvim' },
      { 'jayp0521/mason-null-ls.nvim' },

      --> Debugging
      { "mfussenegger/nvim-dap" },
      { "jayp0521/mason-nvim-dap.nvim" },

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      -- Alternatives: LuaSnip, Vsnip, Ultisnips, Snippy
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
      {'saadparwaiz1/cmp_luasnip'},
    },
    config = function()
      require('plugins.config.lsp_zero').config()
    end,
    event = "InsertEnter",
  }

  ----------------------------------------------------------
  --> Vim-Polyglot: A collection of language packs for Vim
  ----------------------------------------------------------
  use 'sheerun/vim-polyglot'

  ----------------------------------------------------------
  --> Treesitter: A parser generator tool and an incremental parsing library
  -- :TSInstallInfo
  ----------------------------------------------------------
  use {
    {
      'nvim-treesitter/nvim-treesitter',
      event = 'CursorHold',
      run = ':TSUpdate',
      config = function()
        require('plugins.config.treesitter').config()
      end,
    },
    { 'nvim-treesitter/playground', after = 'nvim-treesitter' },
    { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' },
    { 'nvim-treesitter/nvim-treesitter-refactor', after = 'nvim-treesitter' },
    { 'windwp/nvim-ts-autotag', after = 'nvim-treesitter' },
    { 'JoosepAlviste/nvim-ts-context-commentstring', after = 'nvim-treesitter' },
  }

  ----------------------------------------------------------
  --> Easymotion: Simpler way to use some motions in Vim
  --  Instead of <number>w, type <Leader><Leader>w and then a highlighted letter
  --  To paste into search use Ctrl+R+", Ctrl+R+'+', Ctrl+R+0 or Ctrl+R+w
  ----------------------------------------------------------
  use {
    'easymotion/vim-easymotion',
    setup = function()
      require('plugins.config.easymotion').setup()
    end,
    config = function()
      require('plugins.config.easymotion').config()
    end,
  }

  ----------------------------------------------------------
  --> CamelCaseMotion: CamelCase/snake_case motion through words
  --  <leader>w, <leader>b, <leader>e, ci<leader>w (inner motion)
  ----------------------------------------------------------
  use {
    'bkad/CamelCaseMotion',
    setup = function()
      vim.g.camelcasemotion_key = '<leader>'
    end,
  }

  ----------------------------------------------------------
  --> Vim-Repeat: Enable repeating supported plugin maps with "."
  ----------------------------------------------------------
  use 'tpope/vim-repeat'

  ----------------------------------------------------------
  --> Vim-Speeddating: CTRL-A/CTRL-X increment dates, times, and more
  ----------------------------------------------------------
  use 'tpope/vim-speeddating'

  ----------------------------------------------------------
  --> Vim-Surround: Manipulate surroundings
  --
  --  (*) denotes the cursor position:
  --  Old text                  Command     New text
  --  "Hello *world!"           ds"         Hello world!
  --  [123+4*56]/2              cs])        (123+456)/2
  --  <div>Yo!*</div>           cst<p>      <p>Yo!</p>
  --  if *x>3 {                 ysW(        if ( x>3 ) {
  --  my $str = *whee!;         vllllS'     my $str = 'whee!';
  ----------------------------------------------------------
  use 'tpope/vim-surround'

  ----------------------------------------------------------
  --> Vim-visual-multi
  --  Multiple cursors plugin for Vim
  --  https://github.com/mg979/vim-visual-multi/wiki/Quick-start
  ----------------------------------------------------------
  use 'mg979/vim-visual-multi'

  ----------------------------------------------------------
  --> NERD Commenter: Vim plugin for intensely nerdy commenting powers
  --    Has more functions than tpope/vim-commentary.
  --    <leader>cc: comment
  --    <leader>cl: aligned comment
  --    <leader>cu: uncomment
  ----------------------------------------------------------
  -- use {
  --   'preservim/nerdcommenter',
  --   config = function()
  --     require('plugins.config.nerdcommenter').config()
  --   end,
  -- }

  ----------------------------------------------------------
  --> Comment.nvim: Smart and powerful comment plugin for neovim
  --  Supports treesitter, dot repeat, left-right/up-down motions, hooks, etc.
  --
  -- Normal mode: [count]gcc, [count]gbc, gc[count]{motion}, gb[count]{motion}
  -- Visual mode: gc, gb
  ----------------------------------------------------------
  use {
    'numToStr/Comment.nvim',
    event = 'BufRead',
    config = function()
      require('plugins.config.comment').config()
    end,
  }

  ----------------------------------------------------------
  --> GitHub Copilot: uses OpenAI Codex to suggest code in real-time
  -- :Copilot setup
  ----------------------------------------------------------
  use("github/copilot.vim")

  ----------------------------------------------------------
  --> Zen Mode: Distraction-free coding for Neovim
  -- :ZenMode
  ----------------------------------------------------------
  use {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup()
    end
  }

  ----------------------------------------------------------
  --> Automatically set up your configuration after cloning packer.nvim
  ----------------------------------------------------------
  if packer_bootstrap then
    require('packer').sync()
  end

end)
