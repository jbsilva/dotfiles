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
  --> Colorscheme
  --
  -- tokyonight loads eagerly and early so the colorscheme is applied before
  -- anything draws, and so lualine can resolve its matching theme.
  --
  -- github-nvim-theme, gruvbox and catppuccin used to sit here as lazy specs
  -- for `:colorscheme` to switch to. Nothing ever selected them, so they were
  -- only ever cloned and updated. Add one back if that changes.
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

  ----------------------------------------------------------
  --> Icons
  -- Required by lualine, mini.tabline, nvim-tree, fzf-lua and mini.files.
  --
  -- mock_nvim_web_devicons() defines the nvim-web-devicons API surface, so the
  -- consumers above keep calling get_icon/get_icon_color unchanged. Stays
  -- lazy: lazy.nvim runs a dependency's config() before the dependent's, so
  -- the mock is installed before anything asks for an icon.
  --
  -- Traded away: per-filetype icon *colours*. mini.icons uses a fixed set of
  -- highlight groups instead, which tokyonight already defines (MiniIconsAzure
  -- ... MiniIconsYellow). Needs Nerd Fonts >= 3.0.0.
  --
  -- Replaced 'nvim-tree/nvim-web-devicons', which was `lazy = true, opts = {}`.
  ----------------------------------------------------------
  {
    'nvim-mini/mini.icons',
    lazy = true,
    opts = {},
    config = function(_, opts)
      -- Through the module table rather than the _G.MiniIcons global the docs
      -- use: same table (mini/icons.lua returns it), and lua_ls can see it.
      local icons = require('mini.icons')
      icons.setup(opts)
      icons.mock_nvim_web_devicons()
    end,
  },

  ----------------------------------------------------------
  --> Lualine: statusline, with inline git blame
  ----------------------------------------------------------
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'lewis6991/gitsigns.nvim', 'nvim-mini/mini.icons' },
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
  --> Buffer tabs
  --
  --  Renders the listed buffers, with the current one centred and duplicate
  --  names disambiguated by directory. Buffer navigation is unaffected: it is
  --  <Tab>/<S-Tab> on :bnext/:bprevious and ,d on :bdelete, all in
  --  keybinds.lua, none of it routed through this plugin.
  --
  --  Replaced 'akinsho/bufferline.nvim' (version = '*', opts = {}), which ran
  --  on defaults. What it offered beyond this and nothing here used: close
  --  icons, :BufferLinePick, buffer reordering, groups, diagnostics, and the
  --  nvim-tree offset.
  ----------------------------------------------------------
  {
    'nvim-mini/mini.tabline',
    event = 'VeryLazy',
    dependencies = 'nvim-mini/mini.icons',
    opts = {},
  },

  ----------------------------------------------------------
  --> WhichKey: shows the possible completions of a started mapping
  ----------------------------------------------------------
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
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

  -- Undotree is no longer a plugin: Neovim 0.12 ships nvim.undotree as an
  -- optional package. <leader>u is mapped in keybinds.lua.

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
    dependencies = 'nvim-mini/mini.icons',
    config = function()
      require('plugins.config.nvim-tree').config()
    end,
  },

  ----------------------------------------------------------
  --> fzf-lua: fuzzy finder over lists
  --  Needs fd, ripgrep and fzf, all declared in nix-darwin/modules/packages.nix.
  --  <C-p> files, 'b buffers, 'r live grep, 'c git status, <leader>H help
  --
  --  Replaced nvim-telescope/telescope.nvim, which needed plenary,
  --  telescope-fzf-native (a `make` build step, to get a sorter as fast as the
  --  fzf binary already on $PATH) and telescope-file-browser. fzf-lua drives
  --  that fzf binary directly and needs none of the three.
  --
  --  Most of the old in-picker mappings were reproduced by fzf itself: esc
  --  aborts, ctrl-j/ctrl-k move, tab toggles and moves down. Only the quickfix
  --  keys are configured, in plugins/config/fzf.lua.
  ----------------------------------------------------------
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    -- Declared here rather than mapped inside config(), so lazy.nvim can bind a
    -- stub and defer the plugin until the first press.
    keys = {
      {
        '<C-p>',
        function()
          require('plugins.config.fzf').project_files()
        end,
        desc = 'Find files (git-aware)',
      },
      {
        "'b",
        function()
          require('plugins.config.fzf').pick('buffers')
        end,
        desc = 'Find buffers',
      },
      {
        "'r",
        function()
          require('plugins.config.fzf').pick('live_grep')
        end,
        desc = 'Live grep',
      },
      {
        "'c",
        function()
          require('plugins.config.fzf').pick('git_status')
        end,
        desc = 'Changed files (git)',
      },
      {
        '<leader>H',
        function()
          require('plugins.config.fzf').pick('helptags')
        end,
        desc = 'Help tags',
      },
    },
    -- fzf-lua reads _G.MiniIcons directly when it is present.
    dependencies = 'nvim-mini/mini.icons',
    config = function()
      require('plugins.config.fzf').config()
    end,
  },

  ----------------------------------------------------------
  --> mini.files: file browser
  --  <leader>fb, replacing telescope-file-browser, which died with telescope.
  --
  --  Deliberately NOT a replacement for nvim-tree: this is a transient float
  --  with no git or diagnostic status, and the tree is configured for both.
  --  Filesystem edits are ordinary text edits, applied on confirmation.
  ----------------------------------------------------------
  {
    'nvim-mini/mini.files',
    keys = {
      {
        '<leader>fb',
        function()
          local buf = vim.api.nvim_buf_get_name(0)
          require('mini.files').open(buf ~= '' and buf or nil, true)
        end,
        desc = 'File browser',
      },
    },
    dependencies = 'nvim-mini/mini.icons',
    opts = {
      windows = { preview = true, width_focus = 35, width_preview = 60 },
      content = {
        filter = function(entry)
          return not vim.tbl_contains({ '.git', 'node_modules', 'target' }, entry.name)
        end,
      },
    },
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
      -- Registers the completion capabilities every server is started with, so
      -- it has to load first. Spec is below, with the rest of completion.
      'saghen/blink.cmp',
    },
    config = function()
      require('plugins.config.lsp').config()
    end,
  },
  {
    -- blink.cmp replaces nvim-cmp and all the cmp-* sources with one plugin.
    --
    -- Also a dependency of nvim-lspconfig above, which is what loads it in
    -- practice: it has to register the LSP capabilities before a server
    -- starts. These events only catch the cases with no file read, such as
    -- typing a command straight into an empty buffer.
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
  --  <leader>td debug nearest test               <leader>to last output
  --  <leader>tm is nvim-dap's Python test-method map, in its spec above.
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
    -- No BufWritePre event: with format_on_save off there is nothing for it to
    -- do, so it only pulled the plugin in on the first write of every session.
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
      -- places. Use <leader>F. There is no :Format command; conform only
      -- creates :ConformInfo.
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
    -- Still VeryLazy, not `keys`: the f/F/t/T labels come from flash's char
    -- mode, which needs the plugin loaded rather than a lazy.nvim stub.
    event = 'VeryLazy',
    opts = {
      modes = {
        -- Off by default: `/` search stays vanilla, as easymotion left it.
        search = { enabled = false },
      },
    },
    keys = {
      -- Jump moved off bare s/S so mini.surround can have the s prefix.
      --
      -- <leader>j rather than gs: gs is LSP signature help (lsp.lua), mapped
      -- per buffer on attach, so a global gs would be shadowed in every buffer
      -- with a server running. gm/gM/gw/gh are all builtins.
      {
        '<leader>j',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash jump',
      },
      {
        '<leader>J',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash treesitter',
      },
      -- Operator-pending only, and mini.surround maps nothing on bare r, so
      -- this one stays where it was.
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
  --> mini.surround: manipulate surroundings
  --
  --  Replaced kylechui/nvim-surround. Different verbs: everything is under an
  --  s prefix rather than ys/cs/ds, which is why flash's jump moved to
  --  <leader>j -- see its spec above.
  --
  --  (*) is the cursor:
  --  Old text                  Command     New text
  --  "Hello *world!"           sd"         Hello world!
  --  [123+4*56]/2              sr])        (123+456)/2
  --  <div>Yo!*</div>           srt<p>      <p>Yo!</p>
  --  if *x>3 {                 saW(        if ( x>3 ) {
  --
  --  Maps sa add, sd delete, sr replace, sf/sF find right/left, sh highlight,
  --  each also with an n/l suffix for the next/previous match (sdn, srl, ...).
  --  b and q are aliases for any bracket and any quote, as in nvim-surround.
  --
  --  mini.surround maps bare s to <Nop> itself, on purpose: without it a slow
  --  s-then-key would fire the built-in substitute. So s alone does nothing,
  --  which is no loss here because flash held s before. Use cl instead.
  --  Bare S is now free again and back to the built-in substitute-line.
  ----------------------------------------------------------
  {
    'nvim-mini/mini.surround',
    event = 'VeryLazy',
    opts = {
      -- nvim-surround searched the whole buffer; mini.surround defaults to 20
      -- lines, which silently fails to find a surrounding in longer functions.
      n_lines = 500,
    },
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
  --  <leader>qd  diagnostics for the buffer   <leader>qD  for the workspace
  --  <leader>qs  document symbols             <leader>ql  LSP references
  --  <leader>qq  quickfix list
  --
  --  Under <leader>q rather than the usual <leader>x, because keybinds.lua
  --  maps <leader>x to "+x. Sharing the prefix left that mapping complete but
  --  ambiguous, so every bare press sat out timeoutlen (500ms) first.
  ----------------------------------------------------------
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
    keys = {
      {
        '<leader>qd',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Diagnostics (buffer)',
      },
      { '<leader>qD', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (workspace)' },
      { '<leader>qs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols' },
      { '<leader>ql', '<cmd>Trouble lsp toggle<cr>', desc = 'LSP references/definitions' },
      { '<leader>qq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix list' },
    },
  },

  ----------------------------------------------------------
  --> Todo-comments: highlight TODO/FIXME/HACK and search them
  --  <leader>qt lists them, ]t / [t jump between them
  ----------------------------------------------------------
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = 'nvim-lua/plenary.nvim',
    opts = { signs = false },
    keys = {
      { '<leader>qt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo list' },
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
  -- 'nvim-tree/nvim-web-devicons' -- replaced by mini.icons + mock_nvim_web_devicons
  -- 'akinsho/bufferline.nvim' -- replaced by mini.tabline; ran on bare defaults
  -- 'kylechui/nvim-surround' -- replaced by mini.surround; flash moved to <leader>j
  -- 'nvim-telescope/telescope.nvim' -- replaced by fzf-lua
  -- 'nvim-telescope/telescope-fzf-native.nvim' -- fzf-lua drives the fzf binary itself
  -- 'nvim-telescope/telescope-file-browser.nvim' -- replaced by mini.files on <leader>fb
  -- 'mbbill/undotree'         -- Neovim 0.12 ships nvim.undotree; mapped in keybinds.lua

  ----------------------------------------------------------
  --> mini.nvim (nvim-mini/mini.nvim), evaluated against every plugin above
  --
  -- Adopted: mini.icons, mini.tabline. Both were already flagged as
  -- alternatives here and neither changes behaviour that anything uses.
  --
  -- Worth revisiting, each with one concrete cost:
  --   mini.notify     replaces fidget, but setup() reassigns vim.notify
  --                   unconditionally, so it takes over every notification
  --                   unless it is restored afterwards. Gains a history.
  --   mini.statusline replaces lualine, but it has no refresh timer, and the
  --                   blame section depends on one: gitsigns sets
  --                   b:gitsigns_blame_line asynchronously without calling
  --                   redrawstatus, so the section would show the previous
  --                   line's blame. It also never sets laststatus, so
  --                   globalstatus has to move to options.lua.
  --
  -- Rejected, with the blocking reason:
  --   mini.pick       no git_status picker exists ('c is bound to it), and
  --                   fzf-lua now fills this role anyway
  --   mini.pairs      no treesitter awareness at all; check_ts = true is the
  --                   only option this config sets on nvim-autopairs
  --   mini.diff       no inline blame anywhere in mini.nvim; only
  --                   minigit_summary_string (branch/HEAD) is exposed
  --   mini.clue       triggers are buffer-local and must be created last, so
  --                   every per-buffer on_attach here would need wiring
  --   mini.jump2d     no treesitter mode (S) and no remote operator (r)
  --   mini.hipatterns highlighting only: no ]t/[t, no project-wide todo list
  --   mini.ai         layers on nvim-treesitter-textobjects rather than
  --                   replacing it, and its defaults claim al/il, already
  --                   mapped to @loop.outer/@loop.inner in treesitter.lua
  --
  -- No mini module exists for: multiple cursors, HTML/JSX tag closing, date
  -- incrementing, undo-tree visualisation, or sudo write -- checked across all
  -- 46 module docs. LSP, DAP, test running, parser management, formatters and
  -- colorschemes are outside mini.nvim's stated scope.
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
