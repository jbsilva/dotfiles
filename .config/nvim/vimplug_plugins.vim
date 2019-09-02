"------------------------------------------------------------------------------
"   => Vim-PLug - https://github.com/junegunn/vim-plug/
"
"   Gerencia plugins do Vim.
"
"   Commands:
"       :PlugInstall [name ...] [#threads]  - Install plugins
"       :PlugUpdate [name ...] [#threads]   - Install or update plugins
"       :PlugClean[!]                       - Remove unlisted plugins (bang version will clean without prompt)
"       :PlugUpgrade                        - Upgrade vim-plug itself
"       :PlugStatus                         - Check the status of plugins
"       :PlugDiff                           - Examine changes from the previous update and the pending changes
"       :PlugSnapshot[!] [output path]      - Generate script for restoring the current snapshot of the plugins
"
"   Options:
"       banch/tag/commit    - Branch/tag/commit of the repository to use
"       rtp                 - Subdirectory that contains Vim plugin
"       dir                 - Custom directory for the plugin
"       as                  - Use different name for the plugin
"       do                  - Post-update hook (string or funcref)
"       on                  - On-demand loading: Commands or <Plug>-mappings
"       for                 - On-demand loading: File types
"       frozen              - Do not update unless explicitly specified
"------------------------------------------------------------------------------


"*****************************************************************************
"" Vim-PLug core
"*****************************************************************************
let vimplug_file=expand('$XDG_CONFIG_HOME/nvim/autoload/plug.vim')

let g:vim_bootstrap_langs = "html,javascript,perl,python,ruby"
let g:vim_bootstrap_editor = "nvim"

if !filereadable(vimplug_file)
  if !executable("curl")
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent exec "!\curl -fLo " . vimplug_file . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif

" Required:
call plug#begin(expand('~/.config/nvim/plugged'))


"*****************************************************************************
"" Plug install packages
"*****************************************************************************

"------------------------------------------------------------------------------
" => Devicons - Add filetype glyphs (icons)
"    Install yanoasis/nerd-fonts first
"------------------------------------------------------------------------------
Plug 'ryanoasis/vim-devicons'

"------------------------------------------------------------------------------
" => Easymotion
"------------------------------------------------------------------------------
Plug 'Lokaltog/vim-easymotion'

"------------------------------------------------------------------------------
" => Pytest
"------------------------------------------------------------------------------
Plug 'alfredodeza/pytest.vim'

"------------------------------------------------------------------------------
" => Python Documentation
"    <C-k>
"------------------------------------------------------------------------------
Plug 'fs111/pydoc.vim'

"------------------------------------------------------------------------------
" => ACK - betterthangrep.com
"------------------------------------------------------------------------------
Plug 'mileszs/ack.vim'

"------------------------------------------------------------------------------
" => Check Python code on the fly
"------------------------------------------------------------------------------
Plug 'mitechie/pyflakes-pathogen'

"------------------------------------------------------------------------------
" => UltiSnips - The ultimate snippet solution for Vim
"    Needs python; run `pip install neovim` and check with :echo has("python")
"------------------------------------------------------------------------------
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"

"------------------------------------------------------------------------------
" => Sparkup - Write HTML in CSS-like syntax
"------------------------------------------------------------------------------
Plug 'rstacruz/sparkup'

"------------------------------------------------------------------------------
" => NERDTree - Explore the filesystem.
"    :NERDTree
"------------------------------------------------------------------------------
Plug 'scrooloose/nerdtree'
"nnoremap <leader>d :NERDTreeToggle<CR>
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore=['.git$[[dir]]', '.DS_STORE$[[file]]', '*.swp$[[file]]', 'tmp[[dir]]', '*.pyc$[[file]]', '\.hg','\.svn','\.bzr', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeChDirMode=2
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
nnoremap <silent> <F2> :NERDTreeFind<CR>
nnoremap <silent> <F3> :NERDTreeToggle<CR>


"------------------------------------------------------------------------------
" => NERDTree-Tabs - NERDTree and tabs together in Vim, painlessly
"------------------------------------------------------------------------------
Plug 'jistr/vim-nerdtree-tabs'
map <Leader>n <plug>NERDTreeTabsToggle<CR>

" Start Vim with NERDTreeTabs open
"let g:nerdtree_tabs_open_on_gui_startup = 1
"let g:nerdtree_tabs_open_on_console_startup = 1

"------------------------------------------------------------------------------
" => Nerdcommenter - Vim plugin for intensely orgasmic commenting
"    <leader>cc: comment
"    <leader>cl: aligned comment
"    <leader>cu: uncomment
"------------------------------------------------------------------------------
Plug 'scrooloose/nerdcommenter'

"------------------------------------------------------------------------------
" => Gundu - Visualize your Vim undo tree and display diffs
"    :GundoToggle
"------------------------------------------------------------------------------
Plug 'sjl/gundo.vim'
nnoremap <leader>g :GundoToggle<CR>

"------------------------------------------------------------------------------
" => Fugitive - Git wrapper
"    :Gedit :Gsplit :Gstatus :Gbrowse :Gblame :Gdiff, etc
"------------------------------------------------------------------------------
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb' " required by fugitive to :Gbrowse

"------------------------------------------------------------------------------
" => Vim-Repeat - Enable repeating supported plugin maps with "."
"------------------------------------------------------------------------------
Plug 'tpope/vim-repeat'

"------------------------------------------------------------------------------
" => Vim-Speeddating - CTRL-A/CTRL-X increment dates, times, and more
"------------------------------------------------------------------------------
Plug 'tpope/vim-speeddating'

"------------------------------------------------------------------------------
" => Vim-Surround - Manipulate surroundings
"       (*) denotes the cursor position:
"       Old text                  Command     New text
"       "Hello *world!"           ds"         Hello world!
"       [123+4*56]/2              cs])        (123+456)/2
"       <div>Yo!*</div>           cst<p>      <p>Yo!</p>
"       if *x>3 {                 ysW(        if ( x>3 ) {
"       my $str = *whee!;         vllllS'     my $str = 'whee!';
"------------------------------------------------------------------------------
Plug 'tpope/vim-surround'

"------------------------------------------------------------------------------
" => TaskList - List FIXME, TODO and XXX
"    <leader>tl
"------------------------------------------------------------------------------
Plug 'vim-scripts/TaskList.vim'

"------------------------------------------------------------------------------
" => Zenburn - Colorscheme
"    :colorscheme zenburn
"------------------------------------------------------------------------------
Plug 'jnurmine/Zenburn'

"------------------------------------------------------------------------------
" => Molokai - Colorscheme
"    :colorscheme molokai
"------------------------------------------------------------------------------
Plug 'tomasr/molokai'

"------------------------------------------------------------------------------
" => Indent Object
"    Defines text objects based on indent levels. Useful in Python
"    Key Mapping   Description
"    <count>ai     (A)n (I)ndentation level and line above.
"    <count>ii     (I)nner (I)ndentation level (no line above).
"    <count>aI     (A)n (I)ndentation level and lines above/below.
"    <count>iI     (I)nner (I)ndentation level (no lines above/below).
"------------------------------------------------------------------------------
Plug 'michaeljsmith/vim-indent-object'

"------------------------------------------------------------------------------
" => PEP8 - Python style guide checker
"    Install before: `pip install pep8`
"    http://www.python.org/dev/peps/pep-0008/
"------------------------------------------------------------------------------
Plug 'vim-scripts/pep8'
let g:pep8_map = '<leader>8'

"------------------------------------------------------------------------------
" => L9
"------------------------------------------------------------------------------
Plug 'vim-scripts/L9'

"------------------------------------------------------------------------------
" => LaTeX
"------------------------------------------------------------------------------
Plug 'lervag/vimtex'

"------------------------------------------------------------------------------
" => Command-T - Fast file navigation for VIM
"------------------------------------------------------------------------------
Plug 'wincent/Command-T'

"------------------------------------------------------------------------------
" => C.vim - C and C++
"    Edit first:
"       -> c-support/templates/Templates: Your info
"       -> c-support/templates/cpp.comments.template: customize the template
"       -> plugin/c.vim: Change date format:
"              s:C_FormatDate = '%d/%b/%Y'
"              s:C_FormatTime = '%T'
"------------------------------------------------------------------------------
Plug 'vim-scripts/c.vim'

"------------------------------------------------------------------------------
" => Vim-javascript - JavaScript syntax highlighting and improved indentation
"------------------------------------------------------------------------------
Plug 'pangloss/vim-javascript'
let g:javascript_plugin_jsdoc = 1

"------------------------------------------------------------------------------
" => Deoplete - Asynchronous completion for neovim
"    Replaces YouCompleteMe
"------------------------------------------------------------------------------
Plug 'Shougo/deoplete.nvim'
if has('nvim')
  " Enable deoplete.
  let g:deoplete#enable_at_startup = 1

  if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
  endif

  augroup omnifuncs
    autocmd!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=tern#Complete
  augroup end

  let g:tern_request_timeout = 1
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 0

  " Automatically close preview window after autocompletion
  autocmd CompleteDone * if pumvisible() == 0 | pclose | endif
endif

"------------------------------------------------------------------------------
" => Vim expand region
"    Visually select larger regions of text using the same key combination
"------------------------------------------------------------------------------
Plug 'terryma/vim-expand-region'

"------------------------------------------------------------------------------
" => ALE - Asynchronous Lint Engine
"    Plugin for providing linting in NeoVim. Replaces Syntastic
"    Python: pip install pycodestyle pyflakes flake8 vim-vint proselint yamllint
"    Shell: shellcheck
"------------------------------------------------------------------------------
Plug 'w0rp/ale'
let g:ale_linters = {}
:call extend(g:ale_linters, {
    \'python': ['flake8'], })

"------------------------------------------------------------------------------
" => Vim-airline - Lean & mean status/tabline for vim that's light as air
"    Works better when the terminal font is set to Powerline or Hack Nerd Font
"------------------------------------------------------------------------------
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#branch#displayed_head_limit = 10
let g:airline_powerline_fonts = 1
let g:airline_theme = 'powerlineish'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#virtualenv#enabled = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep          = '▶'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '◀'
  let g:airline_right_alt_sep     = '«'
  let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'
  let g:airline_symbols.linenr    = '␊'
  let g:airline_symbols.branch    = '⎇'
  let g:airline_symbols.paste     = 'ρ'
  let g:airline_symbols.paste     = 'Þ'
  let g:airline_symbols.paste     = '∥'
  let g:airline_symbols.whitespace = 'Ξ'
else
  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''

  " powerline symbols
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif

"------------------------------------------------------------------------------
" => MiniBufExpl - List open buffers as tabs
"------------------------------------------------------------------------------
Plug 'fholgado/minibufexpl.vim'

"------------------------------------------------------------------------------
" => Tern - Tern-based JavaScript editing support
"   Installation: cd bundle/tern_for_vim && npm install
"                 Create a .tern-project file
"   TernDef: Jump to the definition of the thing under the cursor.
"   TernDoc: Look up the documentation of something.
"   TernType: Find the type of the thing under the cursor.
"   TernRefs: Show all references to the variable or property under the cursor.
"   TernRename: Rename the variable under the cursor.
"------------------------------------------------------------------------------
Plug 'ternjs/tern_for_vim'
let g:tern_map_keys=1                       "enable keyboard shortcuts
let g:tern_show_argument_hints='on_hold'    "show argument hints

"------------------------------------------------------------------------------
" => Vim-gnupg - Edit gpg encrypted files
"------------------------------------------------------------------------------
Plug 'https://github.com/jamessan/vim-gnupg'

"------------------------------------------------------------------------------
" => Fuzzy Finder
"    On macOS, can be installed with homebrew.
"    :FZF
"------------------------------------------------------------------------------
"Plugin 'junegunn/fzf'
set rtp+=/usr/local/opt/fzf

if isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
else
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
  Plug 'junegunn/fzf.vim'
endif
let g:make = 'gmake'
if exists('make')
        let g:make = 'make'
endif

set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
let $FZF_DEFAULT_COMMAND =  "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"

" The Silver Searcher
if executable('ag')
  let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
  set grepprg=ag\ --nogroup\ --nocolor
endif

" ripgrep
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>e :FZF -m<CR>
"Recovery commands from history through FZF
nmap <leader>y :History:<CR>

"------------------------------------------------------------------------------
" => FuzzyFinder - Finds buffers/files/commands/bookmarks/tags fast
"    :FufFile :FufBuffer
"------------------------------------------------------------------------------
Plug 'vim-scripts/FuzzyFinder'
nmap ,f :FufFile<CR>
nmap ,e :FufCoverageFile<CR>
nmap ,u :FufTaggedFile<CR>
nmap ,c :FufFileWithCurrentBufferDir<CR>
nmap ,b :FufBuffer<CR>
nmap ,l :FufLine<CR>

"------------------------------------------------------------------------------
" => Taglist
"    Requires 'exuberant ctags'
"------------------------------------------------------------------------------
Plug 'vim-scripts/taglist.vim'

"------------------------------------------------------------------------------
" => Vim-autoformat - Easy code formatting in Vim
"    :Autoformat
"------------------------------------------------------------------------------
Plug 'Chiel92/vim-autoformat'
let g:formatdef_rustfmt = '"rustfmt"'
let g:formatters_rust = ['rustfmt']

"------------------------------------------------------------------------------
" => Rust language
"------------------------------------------------------------------------------
Plug 'rust-lang/rust.vim'

"------------------------------------------------------------------------------
" => Database
" let g:dbext_default_profile_mySQL = 'type=MYSQL:user=root:passwd=pass:dbname=mysql'
"------------------------------------------------------------------------------
Plug 'vim-scripts/dbext.vim'

"------------------------------------------------------------------------------
" => SQL
"------------------------------------------------------------------------------
Plug 'vim-scripts/Align'
Plug 'vim-scripts/SQLUtilities'
vmap <silent>sf         <Plug>SQLU_Formatter<CR>
nmap <silent>scl        <Plug>SQLU_CreateColumnList<CR>
nmap <silent>scd        <Plug>SQLU_GetColumnDef<CR>
nmap <silent>scdt       <Plug>SQLU_GetColumnDataType<CR>
nmap <silent>scp        <Plug>SQLU_CreateProcedure<CR>

"------------------------------------------------------------------------------
" => Instant Markdown previews
"    Install first: `npm -g install instant-markdown-d`
"    If autostart=0, run with :InstantMarkdownPreview
"------------------------------------------------------------------------------
Plug 'suan/vim-instant-markdown'
let g:instant_markdown_slow = 1
"let g:instant_markdown_autostart = 0

"------------------------------------------------------------------------------
" => Vim-commentary
"------------------------------------------------------------------------------
Plug 'tpope/vim-commentary'

"------------------------------------------------------------------------------
" => Vim-Session
"------------------------------------------------------------------------------
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

"------------------------------------------------------------------------------
" => HTML
"------------------------------------------------------------------------------
Plug 'hail2u/vim-css3-syntax'
Plug 'gorodinskiy/vim-coloresque'
Plug 'tpope/vim-haml'
Plug 'mattn/emmet-vim'

"------------------------------------------------------------------------------
" => Javascript
"------------------------------------------------------------------------------
Plug 'jelera/vim-javascript-syntax'

"------------------------------------------------------------------------------
" => Perl
"------------------------------------------------------------------------------
Plug 'vim-perl/vim-perl'
Plug 'c9s/perlomni.vim'

"------------------------------------------------------------------------------
" => Python
"------------------------------------------------------------------------------
Plug 'davidhalter/jedi-vim'
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}

let g:jedi#popup_on_dot = 0
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_definitions_command = "<leader>d"
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<leader>n"
let g:jedi#rename_command = "<leader>r"
let g:jedi#show_call_signatures = "0"
let g:jedi#completions_command = "<C-Space>"
let g:jedi#smart_auto_mappings = 0

"------------------------------------------------------------------------------
" => Ruby
"------------------------------------------------------------------------------
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-projectionist'
Plug 'thoughtbot/vim-rspec'
Plug 'ecomba/vim-ruby-refactoring'

"------------------------------------------------------------------------------
" => Vim-gitgutter - Shows a git diff in the 'gutter' (sign column)
"------------------------------------------------------------------------------
Plug 'airblade/vim-gitgutter'

"------------------------------------------------------------------------------
" => Grep - Grep search tools integration with Vim
"    :Grep :GrepAdd :Rgrep :RgrepAdd :GrepBugger :GrepBufferAdd
"------------------------------------------------------------------------------
Plug 'vim-scripts/grep.vim'
nnoremap <silent> <leader>f :Rgrep<CR>
let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*.log *.db'
let Grep_Skip_Dirs = '.git node_modules'

"------------------------------------------------------------------------------
" => CSApprox - Make gvim-only colorschemes work transparently in terminal vim
"------------------------------------------------------------------------------
Plug 'vim-scripts/CSApprox'

"------------------------------------------------------------------------------
" => DelimitMate - Automatic closing of quotes, parenthesis, brackets, etc.
"------------------------------------------------------------------------------
Plug 'Raimondi/delimitMate'

"------------------------------------------------------------------------------
" => Tagbar - Displays tags in a window, ordered by scope
"------------------------------------------------------------------------------
Plug 'majutsushi/tagbar'

"------------------------------------------------------------------------------
" => IndentLine - Display the indention levels with thin vertical lines 
"------------------------------------------------------------------------------
Plug 'Yggdroot/indentLine'

"------------------------------------------------------------------------------
" => Vim-polyglot - A collection of language packs for Vim
"------------------------------------------------------------------------------
Plug 'sheerun/vim-polyglot'
"let g:polyglot_disabled = ['python']
"let python_highlight_all = 1

"------------------------------------------------------------------------------
" => Vimproc - Asynchronous execution library for Vim.
"------------------------------------------------------------------------------
Plug 'Shougo/vimproc.vim', {'do': g:make}

"------------------------------------------------------------------------------
call plug#end()
filetype plugin indent on
