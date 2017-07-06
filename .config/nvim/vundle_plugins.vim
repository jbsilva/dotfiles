"------------------------------------------------------------------------------
"   => Vundle - https://github.com/VundleVim/Vundle.vim
"   Gerencia plugins do Vim.
"   Instalação:
"       git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"   Comandos:
"       :PluginList       - lists configured plugins
"       :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
"       :PluginSearch foo - searches for foo; append `!` to refresh local cache
"       :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"------------------------------------------------------------------------------
filetype off                   " required!

set rtp+=$XDG_CONFIG_HOME/nvim/bundle/Vundle.vim
call vundle#begin()

"------------------------------------------------------------------------------
" => Vundle
"    let Vundle manage Vundle, required
"------------------------------------------------------------------------------
Plugin 'VundleVim/Vundle.vim'

"------------------------------------------------------------------------------
" => Devicons - Add filetype glyphs (icons)
"    Install yanoasis/nerd-fonts first
"------------------------------------------------------------------------------
Plugin 'ryanoasis/vim-devicons'

"------------------------------------------------------------------------------
" => Easymotion
"------------------------------------------------------------------------------
Plugin 'Lokaltog/vim-easymotion'

"------------------------------------------------------------------------------
" => Pytest
"------------------------------------------------------------------------------
Plugin 'alfredodeza/pytest.vim'

"------------------------------------------------------------------------------
" => Python Documentation
"    <C-k>
"------------------------------------------------------------------------------
Plugin 'fs111/pydoc.vim'

"------------------------------------------------------------------------------
" => ACK - betterthangrep.com
"------------------------------------------------------------------------------
Plugin 'mileszs/ack.vim'

"------------------------------------------------------------------------------
" => Check Python code on the fly
"------------------------------------------------------------------------------
Plugin 'mitechie/pyflakes-pathogen'

"------------------------------------------------------------------------------
" => UltiSnips - The ultimate snippet solution for Vim
"    Needs python; run `pip install neovim` and check with :echo has("python")
"------------------------------------------------------------------------------
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

"------------------------------------------------------------------------------
" => Sparkup - Write HTML in CSS-like syntax
"------------------------------------------------------------------------------
Plugin 'rstacruz/sparkup'

"------------------------------------------------------------------------------
" => NERDTree - Explore the filesystem.
"    :NERDTree
"------------------------------------------------------------------------------
Plugin 'scrooloose/nerdtree'
"nnoremap <leader>d :NERDTreeToggle<CR>
let NERDTreeShowHidden = 1
let NERDTreeIgnore=['.git$[[dir]]', '.DS_STORE$[[file]]', '*.swp$[[file]]', 'tmp[[dir]]', '*.pyc$[[file]]', '\.hg','\.svn','\.bzr']

"------------------------------------------------------------------------------
" => NERDTree-Tabs - NERDTree and tabs together in Vim, painlessly
"------------------------------------------------------------------------------
Plugin 'jistr/vim-nerdtree-tabs'
map <Leader>n <plug>NERDTreeTabsToggle<CR>

" Start Vim with NERDTreeTabs open
let g:nerdtree_tabs_open_on_gui_startup = 1
let g:nerdtree_tabs_open_on_console_startup = 1
"------------------------------------------------------------------------------
" => Nerdcommenter - Vim plugin for intensely orgasmic commenting
"<leader>cc: comment
"<leader>cl: aligned comment
"<leader>cu: uncomment
"------------------------------------------------------------------------------
Plugin 'scrooloose/nerdcommenter'

"------------------------------------------------------------------------------
" => Gundu - Visualize your Vim undo tree and display diffs
"    :GundoToggle
"------------------------------------------------------------------------------
Plugin 'sjl/gundo.vim'
nnoremap <leader>g :GundoToggle<CR>

"------------------------------------------------------------------------------
" => Fugitive - Git wrapper
"    :Gedit :Gsplit :Gstatus :Gbrowse :Gblame :Gdiff, etc
"------------------------------------------------------------------------------
Plugin 'tpope/vim-fugitive'

"------------------------------------------------------------------------------
" => Vim-Repeat - Enable repeating supported plugin maps with "."
"------------------------------------------------------------------------------
Plugin 'tpope/vim-repeat'

"------------------------------------------------------------------------------
" => Vim-Speeddating - CTRL-A/CTRL-X increment dates, times, and more
"------------------------------------------------------------------------------
Plugin 'tpope/vim-speeddating'

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
Plugin 'tpope/vim-surround'

"------------------------------------------------------------------------------
" => TaskList - List FIXME, TODO and XXX
"    <leader>tl
"------------------------------------------------------------------------------
Plugin 'vim-scripts/TaskList.vim'

"------------------------------------------------------------------------------
" => Zenburn
"    :colorscheme zenburn
"------------------------------------------------------------------------------
Plugin 'jnurmine/Zenburn'

"------------------------------------------------------------------------------
" => Indent Object
"    Defines text objects based on indent levels. Useful in Python
"    Key Mapping   Description
"    <count>ai     (A)n (I)ndentation level and line above.
"    <count>ii     (I)nner (I)ndentation level (no line above).
"    <count>aI     (A)n (I)ndentation level and lines above/below.
"    <count>iI     (I)nner (I)ndentation level (no lines above/below).
"------------------------------------------------------------------------------
Plugin 'michaeljsmith/vim-indent-object'

"------------------------------------------------------------------------------
" => PEP8 - Python style guide checker
"   Install before: `pip install pep8`
"   http://www.python.org/dev/peps/pep-0008/
"------------------------------------------------------------------------------
Plugin 'vim-scripts/pep8'
let g:pep8_map = '<leader>8'

"------------------------------------------------------------------------------
" => FuzzyFinder - Finds buffers/files/commands/bookmarks/tags fast
"    :FufFile :FufBuffer
"------------------------------------------------------------------------------
Plugin 'vim-scripts/FuzzyFinder'
nmap ,f :FufFile<CR>
nmap ,e :FufCoverageFile<CR>
nmap ,u :FufTaggedFile<CR>
nmap ,c :FufFileWithCurrentBufferDir<CR>
nmap ,b :FufBuffer<CR>
nmap ,l :FufLine<CR>

"------------------------------------------------------------------------------
" => L9
"------------------------------------------------------------------------------
Plugin 'vim-scripts/L9'

"------------------------------------------------------------------------------
" => LaTeX
"------------------------------------------------------------------------------
Plugin 'lervag/vimtex'

"------------------------------------------------------------------------------
" => "C and C++
" Edite o plugin c.vim:
"   -> c-support/templates/Templates: Coloque seus dados
"   -> c-support/templates/cpp.comments.template: Diminua === para 79 colunas
"           e adicione alguns includes e `int main(){ return 0}`
"   -> plugin/c.vim: Mude o formado usado para datas:
"           s:C_FormatDate = '%d/%b/%Y' e s:C_FormatTime = '%T'
"------------------------------------------------------------------------------
Plugin 'wincent/Command-T'
Plugin 'vim-scripts/c.vim'

"------------------------------------------------------------------------------
" => Vim-javascript - JavaScript syntax highlighting and improved indentation.
"------------------------------------------------------------------------------
Plugin 'pangloss/vim-javascript'
let g:javascript_plugin_jsdoc = 1

"------------------------------------------------------------------------------
" => Deoplete - Asynchronous completion for neovim
"    Replaces YouCompleteMe
"------------------------------------------------------------------------------
Plugin 'Shougo/deoplete'
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
Plugin 'terryma/vim-expand-region'

"------------------------------------------------------------------------------
" => ALE - Asynchronous Lint Engine
"    Plugin for providing linting in NeoVim. Replaces Syntastic
"    Python: pip install pycodestyle pyflakes flake8 vim-vint proselint yamllint
"    Shell: shellcheck
"------------------------------------------------------------------------------
Plugin 'w0rp/ale'

"------------------------------------------------------------------------------
" => Vim-airline - Lean & mean status/tabline for vim that's light as air
"------------------------------------------------------------------------------
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline#extensions#branch#displayed_head_limit = 10
let g:airline_powerline_fonts = 1

"------------------------------------------------------------------------------
" => MiniBufExpl - List open buffers as tabs
"------------------------------------------------------------------------------
Plugin 'fholgado/minibufexpl.vim'

"------------------------------------------------------------------------------
" => Tern - Tern-based JavaScript editing support
"   Installation: cd ~/.vim/bundle/tern_for_vim && npm install
"                 Create a .tern-project file
"   TernDef: Jump to the definition of the thing under the cursor.
"   TernDoc: Look up the documentation of something.
"   TernType: Find the type of the thing under the cursor.
"   TernRefs: Show all references to the variable or property under the cursor.
"   TernRename: Rename the variable under the cursor.
"------------------------------------------------------------------------------
Plugin 'ternjs/tern_for_vim'
let g:tern_map_keys=1                       "enable keyboard shortcuts
let g:tern_show_argument_hints='on_hold'    "show argument hints

"------------------------------------------------------------------------------
" => Edit gpg encrypted files
"------------------------------------------------------------------------------
Plugin 'https://github.com/jamessan/vim-gnupg'

"------------------------------------------------------------------------------
" => Taglist
"    Requires 'exuberant ctags'
"------------------------------------------------------------------------------
Plugin 'vim-scripts/taglist.vim'

"------------------------------------------------------------------------------
" => Vim-autoformat - Easy code formatting in Vim
"    :Autoformat
"------------------------------------------------------------------------------
Plugin 'Chiel92/vim-autoformat'
let g:formatdef_rustfmt = '"rustfmt"'
let g:formatters_rust = ['rustfmt']

"------------------------------------------------------------------------------
" => Rust language
"------------------------------------------------------------------------------
Plugin 'rust-lang/rust.vim'

"------------------------------------------------------------------------------
" => Database
" let g:dbext_default_profile_mySQL = 'type=MYSQL:user=root:passwd=pass:dbname=mysql'
"------------------------------------------------------------------------------
Plugin 'vim-scripts/dbext.vim'

"------------------------------------------------------------------------------
" => SQL
"------------------------------------------------------------------------------
Plugin 'vim-scripts/Align'
Plugin 'vim-scripts/SQLUtilities'
vmap <silent>sf         <Plug>SQLU_Formatter<CR>
nmap <silent>scl        <Plug>SQLU_CreateColumnList<CR>
nmap <silent>scd        <Plug>SQLU_GetColumnDef<CR>
nmap <silent>scdt       <Plug>SQLU_GetColumnDataType<CR>
nmap <silent>scp        <Plug>SQLU_CreateProcedure<CR>

"------------------------------------------------------------------------------
" => Instant Markdown previews
"    Install first: `npm -g install instant-markdown-d`
"------------------------------------------------------------------------------
Plugin 'suan/vim-instant-markdown'
let g:instant_markdown_slow = 1
"let g:instant_markdown_autostart = 0


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
