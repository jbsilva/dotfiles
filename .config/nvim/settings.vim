"==============================================================================
"                      ( O O )
"               ====oOO==(_)==OOo=====
"
" File:         ~/.config/nvim/settings.vim
" Description:  Neovim configuration
" Author:       Julio Batista Silva
" Created:      2011
" Last Change:  Sat, 05 Jun 2021 17:20:00 -0300
"==============================================================================

"------------------------------------------------------------------------------
" => Python path
"    Where pynvim is installed
"------------------------------------------------------------------------------
if has('mac') || has('macunix') || has('gui_macvim')
    let g:python_host_prog = '/usr/bin/python2'
    let g:python3_host_prog = '/usr/bin/python3'
elseif has("unix")
    let g:python_host_prog = '/usr/bin/python2'
    let g:python3_host_prog = '/usr/bin/python3'
"elseif has('win32') || has('win64')
"    let g:python_host_prog = '/usr/bin/python2'
"    let g:python3_host_prog = '/usr/bin/python3'
endif

"------------------------------------------------------------------------------
" => Don't show session save message
"------------------------------------------------------------------------------
let g:session_autosave = 'no'

"------------------------------------------------------------------------------
" => Utilities
"------------------------------------------------------------------------------
" For templates: copy `file` content to the beginning of current file with
" expanded variables.
" Attention: escape '%', '#' and '<' with '\' in the beginning of line.
fun! s:Insere(file)
    if filereadable(a:file)
        exe 'silent! 0r ' a:file
        for linenum in range(1, line('$'))
            let line = getline(linenum)
            if line =~ '\$'
                call setline(linenum, expand(line))
            endif
        endfor
    endif
endfun

"------------------------------------------------------------------------------
" => Encoding
"------------------------------------------------------------------------------
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,default,latin1

"------------------------------------------------------------------------------
" => True Color
"    Working in Tmux
"------------------------------------------------------------------------------
if has("termguicolors")
  let &t_8f = "[38;2;%lu;%lu;%lum"
  let &t_8b = "[48;2;%lu;%lu;%lum"
  set termguicolors
endif

"------------------------------------------------------------------------------
" => Colorscheme
"------------------------------------------------------------------------------
if has("gui_running")
    colorscheme gruvbox
else
    colorscheme gruvbox
endif

"------------------------------------------------------------------------------
" => General stuff
"------------------------------------------------------------------------------
" When started as "evim", evim.vim will already have done these settings.
"if v:progname =~? "evim"
"  finish
"endif

" Shell
"if exists('$SHELL')
"    set shell=$SHELL
"else
"    set shell=/bin/sh
"endif

" Don't use Ex mode, use Q for formatting
"map Q gq

" CTRL-U in insert mode deletes a lot. Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Enable mouse if available
set mousehide
if has('mouse')
  set mouse=a
endif

" Enable highlighting
"if &t_Co > 2 || has("gui_running")
"  syntax on
"  set hlsearch
"endif

" Visual
"if has("gui_running")
"  if has("gui_mac") || has("gui_macvim")
"    set guifont=Menlo:h12
"    set transparency=7
"  endif
"else
"  let g:CSApprox_loaded = 1
"  let g:indentLine_enabled = 1
"  let g:indentLine_concealcursor = 0
"  let g:indentLine_char = '┆'
"  let g:indentLine_faster = 1
"endif

" See the changes you made
"if !exists(":DiffOrig")
"    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
"                \ | wincmd p | diffthis
"endif

"------------------------------------------------------------------------------
" => Standard stuff
"------------------------------------------------------------------------------
filetype plugin on

"ru macros/matchit.vim       " Enabled extended % matching
set backspace=2             " Allow backspacing over anything
"set cmdheight=1             " Command line height
"set completeopt=menu        " Don't show extra info on completions
set expandtab               " Insert spaces instead of tab chars
"set formatoptions+=l
set hidden                  " Allow hidden buffers
set ic scs                  " Only be case sensitive when search contains uppercase
set lazyredraw              " Don't redraw screen during macros
set modeline                " Modeline. Warning: possibly insecure
"set nofoldenable
set noswapfile              " Disable swapfiles
"set nobackup                " Disable backup
"set nowritebackup           " Don't make a backup before overwriting a file
set number                  " Show line numbers
set relativenumber          " Relative line numbers
set report=0                " Always report when lines are changed
set ruler                   " Show the cursor position all the time
set scrolloff=4             " Min. number of lines above/below cursor
"set selection=inclusive
set shiftwidth=4            " Allows the use of < and > for VISUAL indenting
set showcmd                 " Display incomplete commands
set showmatch               " Show matching brackets (),{},[]
set showmode                " Show mode at bottom of screen
set tabstop=4               " A n-space tab width
set softtabstop=4           " Counts n spaces when DELETE or BCKSPCE is used
set splitbelow              " Open new split windows below current
set t_vb=                   " ^
set timeoutlen=500          " Lower timeout for mappings
set undolevels=500          " Only undo up to 500 times
set whichwrap=h,l,<,>,[,]   " Allow move to next line

"------------------------------------------------------------------------------
" => Disable relative numbers if not usefull
"------------------------------------------------------------------------------
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

"------------------------------------------------------------------------------
" => Wildmenu - Enables "enhanced mode" of command-line completion
"------------------------------------------------------------------------------
set wildchar=<tab>
set wildmenu                    " Filesystem surfing - press :e and ^D
set wildmode=longest,list,full

"Ignore files
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,solr/**,log/**,*.psd,*.PSD,.git/**,.gitkeep,.gems/**
set wildignore+=*.ico,*.ICO,backup/**,*.sql,*.dump,*.tmp,*.min.js,Gemfile.lock
set wildignore+=*.png,*.PNG,*.JPG,*.jpg,*.JPEG,*.jpeg,*.GIF,*.gif,*.pdf,*.PDF
set wildignore+=vendor/**,coverage/**,tmp/**,rdoc/**,*.BACKUP.*,*.BASE.*,*.LOCAL.*,*.REMOTE.*,.sass-cache/**
set wildignore+=*.pyc

"------------------------------------------------------------------------------
" => Searching
"------------------------------------------------------------------------------
set hlsearch
set incsearch               " Increment search
set ignorecase
set smartcase               " Upper-case sensitive search

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

"------------------------------------------------------------------------------
" => Restore last cursor position
"    restore-cursor last-position-jump
"------------------------------------------------------------------------------
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

"------------------------------------------------------------------------------
" => Window title
"------------------------------------------------------------------------------
set title
set titleold="Terminal"
set titlestring=%F

"------------------------------------------------------------------------------
" => Color column 80
"------------------------------------------------------------------------------
set colorcolumn=80

"------------------------------------------------------------------------------
" => Navigate through buffers
"------------------------------------------------------------------------------
map <C-P> :bp<cr>
map <C-N> :bn<cr>

"------------------------------------------------------------------------------
" => Switching windows
"------------------------------------------------------------------------------
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"------------------------------------------------------------------------------
" => Fast scroll using arrow keys
"------------------------------------------------------------------------------
noremap <Left> 5h
noremap <Down> 5j
noremap <Up> 5k
noremap <Right> 5l

"------------------------------------------------------------------------------
" => Avoids accidental use of <F1>
"------------------------------------------------------------------------------
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

"------------------------------------------------------------------------------
" => Save as root: :Sw
"------------------------------------------------------------------------------
command! -nargs=0 Sw w !sudo tee % > /dev/null

"------------------------------------------------------------------------------
" => Correct commands written with CapsLock on
"------------------------------------------------------------------------------
command! -nargs=* -complete=file Q q <args>
command! -nargs=* -complete=file W w <args>
command! -nargs=* -complete=file Wq wq <args>
command! -nargs=* -complete=file WQ wq <args>
command! -nargs=* -complete=file E e <args>
command! -nargs=* -complete=file Cd cd <args>
command! -nargs=* -complete=file CD cd <args>
command! -nargs=* -complete=option Set set <args>

cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

"------------------------------------------------------------------------------
" => Fix filetype detection
"------------------------------------------------------------------------------
au BufNewFile,BufRead .htaccess,httpd.conf set filetype=apache
au BufNewFile,BufRead *.inc set filetype=php
au BufNewFile,BufRead *.sys set filetype=php
au BufNewFile,BufRead grub.conf set filetype=grub
au BufNewFile,BufRead *.blog set filetype=blog
au BufNewFile,BufRead *.tex set filetype=tex

"------------------------------------------------------------------------------
" => Keymappings for compilation and execution
"------------------------------------------------------------------------------
au FileType php map <F6> :!php &<CR>
au FileType python map <F6> :!python %<CR>
au FileType perl map <F6> :!perl %<CR>
au FileType ruby map <F6> :!ruby %<CR>
au FileType lua map <F6> :!lua %<CR>
au FileType html,xhtml map <F6> :!chromium %<CR>

"------------------------------------------------------------------------------
" => Templates
"   if &filetype =~ '^\(html|text|python|ruby|rust|lua|javascript\)$'
"------------------------------------------------------------------------------
autocmd BufNewFile *.html,*.txt,*.py,*.rb,*.rs,*.lua,*.js :call s:Insere(fnameescape(g:TEMPLATES . '/' . &filetype))

if exists('*strftime')
    au BufNewFile *.txt :call append(1, '# Created: '.strftime('%a, %d %b %Y %T %z'))
    au BufNewFile *.py :call append(2, '# Created: '.strftime('%a, %d %b %Y %T %z'))
    au BufNewFile *.rb :call append(2, '# Created: '.strftime('%a, %d %b %Y %T %z'))
    au BufNewFile *.html :call append(1, '<!-- Created: ' . strftime('%a, %d %b %Y %T %z') . ' -->')
endif

"------------------------------------------------------------------------------
" => Text files
"    Spell checker
"       Default language: PT_BR.
"       For english:                `:setlocal spell spelllang=en_us`
"       Deactivate correction:      `:setlocal nospell`
"       Commands (`:help spell`):   `[s`, `]s`, `z=`, `zg`, `zw`, `:spellr`
"    Text with 80 columns
"------------------------------------------------------------------------------
autocmd FileType text setlocal textwidth=80 spell spelllang=pt_br

"------------------------------------------------------------------------------
" => C e C++
"------------------------------------------------------------------------------
au FileType c,cpp set cindent
au FileType c,cpp set formatoptions+=ro
"au FileType c,cpp set foldmethod=syntax
"au FileType c,cpp set foldlevel=4

"------------------------------------------------------------------------------
" => Python
"------------------------------------------------------------------------------
"au FileType python set foldmethod=indent
"au FileType python set foldlevel=99
"au FileType python set omnifunc=pythoncomplete#Complete
"let g:SuperTabDefaultCompletionType = "context"

"" vim-python
"augroup vimrc-python
"  autocmd!
"  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 colorcolumn=79
"      \ formatoptions+=croq softtabstop=4
"      \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
"augroup END

"------------------------------------------------------------------------------
" => Ruby
"------------------------------------------------------------------------------
"au FileType ruby,eruby setlocal sts=2 sw=2
"au FileType ruby,eruby set omnifunc=rubycomplete#Complete
"au FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
"au FileType ruby,eruby let g:rubycomplete_rails = 1
"au FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

"------------------------------------------------------------------------------
" => HTML
"   Some of these snipets are implemented by another plugin
"------------------------------------------------------------------------------
"au FileType html,xhtml,php,eruby imap bbb <br />
"au FileType html,xhtml,php,eruby imap aaa <a href=""></a><left><left><left><left><left><left>
"au FileType html,xhtml,php,eruby imap iii <img src="" /><left><left><left><left>
"au FileType html,xhtml,php,eruby imap ddd <div id=""></div><left><left><left><left><left><left><left><left>
"autocmd Filetype html setlocal ts=2 sw=2 expandtab " for html files, 2 spaces

"------------------------------------------------------------------------------
" => Javascript
"------------------------------------------------------------------------------
"let g:javascript_enable_domhtmlcss = 1

"------------------------------------------------------------------------------
" => Read MS Word documents
"    Requires antiword (http://vim.wikia.com/wiki/View_and_diff_MS_Word_files)
"------------------------------------------------------------------------------
"if executable('antiword')
"    augroup Word
"        au!
"        au BufReadPre *.doc set ro
"        au BufReadPre *.doc set hlsearch!
"        au BufReadPost *.doc %!antiword "%"
"    augroup END
"endif

"------------------------------------------------------------------------------
" => Terminal emulation
"------------------------------------------------------------------------------
"nnoremap <silent> <leader>sh :terminal<CR>

"------------------------------------------------------------------------------
" => Remove trailing whitespaces
"------------------------------------------------------------------------------
command! FixWhitespace :%s/\s\+$//e

"------------------------------------------------------------------------------
" => Execute selection
"------------------------------------------------------------------------------
vnoremap <Leader>es :<c-u>exec join(getline("'<","'>"),"\n")<CR>

"------------------------------------------------------------------------------
" => Disable visualbell
"------------------------------------------------------------------------------
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"------------------------------------------------------------------------------
" => Copy/Paste/Cut
"------------------------------------------------------------------------------
"if has('unnamedplus')
"  set clipboard=unnamed,unnamedplus
"endif

" Y copy from cursor to last-non-blank-char
nnoremap Y yg_

" Copy to system clipboard
vnoremap <leader>y "+y
nnoremap <leader>y "+y
nnoremap <leader>yy "+yy
nnoremap <leader>Y "+yg_

" Cut to system clipboard
vnoremap <leader>x "+x
nnoremap <leader>x "+x
nnoremap <leader>X "+X

" Paste from system clipboard
vnoremap <leader>p "+p
vnoremap <leader>P "+P
nnoremap <leader>p "+p
nnoremap <leader>P "+P

"noremap YY "+y<CR>
"noremap <leader>p "+gP<CR>
"noremap XX "+x<CR>

"if has('macunix')
"  " pbcopy for OSX copy/paste
"  vmap <C-x> :!pbcopy<CR>
"  vmap <C-c> :w !pbcopy<CR><CR>
"endif

"------------------------------------------------------------------------------
" => Clean search highlight with <leader><space>
"------------------------------------------------------------------------------
nnoremap <silent> <leader><space> :noh<cr>

"------------------------------------------------------------------------------
" => Stay in Visual Mode after indenting with '>' or '<'
"------------------------------------------------------------------------------
vmap < <gv
vmap > >gv

"------------------------------------------------------------------------------
" => Move visual block
"------------------------------------------------------------------------------
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"------------------------------------------------------------------------------
" => Statusline
"    Commented as the status line will be defined by the vim-airline plugin
"------------------------------------------------------------------------------
"set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

"if exists("*fugitive#statusline")
"  set statusline+=%{FugitiveStatusline()}
"endif

"------------------------------------------------------------------------------
" => Check Html5
"    http://about.validator.nu/html5check.py
"------------------------------------------------------------------------------
"map ,h5 :!html5check.py %<CR>

