"===================================================================
"                      ( O O )
"               ====oOO==(_)==OOo=====
"
" File:         ~/.vim/settings.vim
" Description:  Configurações do vim
" Author:       Julio
" Created:      2011
" Last Change:  Wed 09 Sep 2015 19:30
"===================================================================

"------------------------------------------------------------------------------
" => Desativa modelines por segurança [http://www.guninski.com/vim1.html]
"   A primeira linha de um documento executa comandos se iniciada por 'vim:'
"   Isso só é um risco se abrirmos algum documento de alguém mal intencionado
"------------------------------------------------------------------------------
"set modelines=0

"------------------------------------------------------------------------------
" => Constantes
" Existem varias formas de se definir variaveis:
"   let user = 'Julio Batista Silva'                    -- String
"   let user = expand($USER_FULLNAME)                   -- Variavel de ambiente
"   let user = system('git config -z --get user.name')  -- Shell command
"------------------------------------------------------------------------------
let g:DOTFILES = escape(expand('<sfile>:p:h:h'), ' ')  "dotfiles
let g:VIMFILES = escape(expand('<sfile>:p:h'), ' ')    "dotfiles/.vim/
let g:VIMSETTINGS = escape(expand('<sfile>:p'), ' ')   "dotfiles/.vim/settings.vim
let g:VIMCONF = g:DOTFILES . '/.vimrc'                 "dotfiles/.vimrc
let g:TEMPLATES = g:VIMFILES . '/templates'            "dotfiles/.vim/templates

"------------------------------------------------------------------------------
" => Funcoes Uteis
"------------------------------------------------------------------------------

" Copia o conteudo de `file` no inicio do arquivo atual com as variaveis no
" formato `$VARIAVEL` já resolvidas. Uso para templates.
" Atencao: O `expand` trata especialmente linhas iniciadas por '%', '#' ou '<'.
"          Se precisar, inicie com '\' ('\#', por exemplo).
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
" => Esquema de cores (colorscheme)
"------------------------------------------------------------------------------
if has("gui_running")
    colorscheme zenburn
else
    colorscheme zenburn
endif


"------------------------------------------------------------------------------
" => Check Html5
" http://about.validator.nu/html5check.py
"------------------------------------------------------------------------------
map ,h5 :!html5check.py %<CR>

"------------------------------------------------------------------------------
" => Geral
"------------------------------------------------------------------------------
" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Ativa o mouse, se disponivel e esconde-o enquanto digita
set mousehide
if has('mouse')
  set mouse=a
endif

" Ativa highlighting na sintaxe e nas buscas
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
    filetype plugin indent on
    
    " Put these in an autocmd group, so that we can delete them easily.
    augroup vimrcEx
    au!
    
    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    " Also don't do it when the mark is in the first line, that is the default
    " position when opening a file.
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

    augroup END
else
  set autoindent        " always set autoindenting on
endif

" See the changes you made
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

"------------------------------------------------------------------------------
" => Standard stuff.
"------------------------------------------------------------------------------
filetype plugin on

ru macros/matchit.vim       " Enabled extended % matching
set spelllang=pt            " Muda a linguagem do dicionario para portugues
set hi=100                  " Only store past 100 commands
set ul=200                  " Only undo up to 200 times
set lz                      " Don't redraw screen during macros
set tf                      " Improves redrawing for newer computers
set sc                      " Show incomplete command at bottom right
set bs=2                    " Allow backspacing over anything
set ic scs                  " Only be case sensitive when search contains uppercase
set sb                      " Open new split windows below current
set hid                     " Allow hidden buffers
set tm=500                  " Lower timeout for mappings
set cot=menu                " Don't show extra info on completions
set report=0                " Always report when lines are changed
set t_vb=                   " ^
set scrolloff=4             " min. number of lines above/below cursor
set expandtab               " insert spaces instead of tab chars
set tabstop=4               " a n-space tab width
set shiftwidth=4            " allows the use of < and > for VISUAL indenting
set softtabstop=4           " counts n spaces when DELETE or BCKSPCE is used
set incsearch               " increment search
set smartcase               " upper-case sensitive search
set history=100             " 100 lines of command line history
set cmdheight=1             " command line height
set ruler                   " show the cursor position all the time
set showmode                " show mode at bottom of screen
set number                  " show line numbers
set nowritebackup           " ^
set nobackup                " disable backup
set noswapfile              " disable swapfiles
set showmatch               " show matching brackets (),{},[]
set whichwrap=h,l,<,>,[,]
set showcmd
set modeline
set wildmenu
set splitbelow
set formatoptions+=l
set selection=inclusive
set showcmd                 " display incomplete commands
set incsearch               " do incremental searching
set wildmenu                " filesystem surfing - press :e and ^D
set wildchar=<tab>
set nofoldenable

"------------------------------------------------------------------------------
" => Colore a coluna 80
"------------------------------------------------------------------------------
set colorcolumn=80

"------------------------------------------------------------------------------
" => Scroll rapido usando as setas do teclado
"------------------------------------------------------------------------------
noremap <Left> 5h
noremap <Down> 5j
noremap <Up> 5k
noremap <Right> 5l

"------------------------------------------------------------------------------
" => Evita uso acidental do <F1>
"------------------------------------------------------------------------------
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

"------------------------------------------------------------------------------
" => Por que meus teclados não têm aviso de CapsLock?
"------------------------------------------------------------------------------
command! -nargs=* -complete=file Q q <args>
command! -nargs=* -complete=file W w <args>
command! -nargs=* -complete=file Wq wq <args>
command! -nargs=* -complete=file WQ wq <args>
command! -nargs=* -complete=file E e <args>
command! -nargs=* -complete=file Cd cd <args>
command! -nargs=* -complete=file CD cd <args>
command! -nargs=* -complete=option Set set <args>

"------------------------------------------------------------------------------
" => Corrige detecção de filetypes
"------------------------------------------------------------------------------
au BufNewFile,BufRead .htaccess,httpd.conf set filetype=apache
au BufNewFile,BufRead *.inc set filetype=php
au BufNewFile,BufRead *.sys set filetype=php
au BufNewFile,BufRead grub.conf set filetype=grub
au BufNewFile,BufRead *.blog set filetype=blog
au BufNewFile,BufRead *.tex set filetype=tex

"------------------------------------------------------------------------------
" => Keymappings de compilação e execução
"------------------------------------------------------------------------------
au FileType php map <F6> :!php &<CR>
au FileType python map <F6> :!python %<CR>
au FileType perl map <F6> :!perl %<CR>
au FileType ruby map <F6> :!ruby %<CR>
au FileType lua map <F6> :!lua %<CR>
au FileType html,xhtml map <F6> :!chromium %<CR>

"------------------------------------------------------------------------------
" => Templates
"   if &filetype =~ '^\(text\|html\|python|ruby|rust\)$'
"------------------------------------------------------------------------------
autocmd BufNewFile *.html,*.txt,*.py,*.rb,*.rs :call s:Insere(fnameescape(g:TEMPLATES . '/' . &filetype))

if exists('*strftime')
    au BufNewFile *.txt :call append(1, '# Created: '.strftime('%a, %d %b %Y %T %z'))
    au BufNewFile *.py :call append(2, '# Created: '.strftime('%a, %d %b %Y %T %z'))
    au BufNewFile *.rb :call append(2, '# Created: '.strftime('%a, %d %b %Y %T %z'))
    au BufNewFile *.html :call append(1, '<!-- Created: ' . strftime('%a, %d %b %Y %T %z') . ' -->')
endif

"------------------------------------------------------------------------------
" => Text files
"    Corretor ortográfico
"       Linguagem default: PT_BR.
"       Para usar inglês:           `:setlocal spell spelllang=en_us`
"       Para desativar corretor:    `:setlocal nospell`
"       Comandos (`:help spell`):   `[s`, `]s`, `z=`, `zg`, `zw`, `:spellr`
"    Textos com 78 colunas
"------------------------------------------------------------------------------
autocmd FileType text setlocal textwidth=78 spell spelllang=pt_br

"------------------------------------------------------------------------------
" => C e C++
"------------------------------------------------------------------------------
au FileType c,cpp set cindent
au FileType c,cpp set formatoptions+=ro
"au FileType c,cpp set foldmethod=syntax
"au FileType c,cpp set foldlevel=4
let g:C_Styles = { '*.c,*.h' : 'default', '*.cc,*.cpp,*.hh,*.hpp' : 'CPP' }

"------------------------------------------------------------------------------
" => Python
"------------------------------------------------------------------------------
au FileType python set foldmethod=indent
au FileType python set foldlevel=99
au FileType python set omnifunc=pythoncomplete#Complete
let g:SuperTabDefaultCompletionType = "context"

"------------------------------------------------------------------------------
" => Ruby
"------------------------------------------------------------------------------
au FileType ruby,eruby setlocal sts=2 sw=2
au FileType ruby,eruby set omnifunc=rubycomplete#Complete
au FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
au FileType ruby,eruby let g:rubycomplete_rails = 1
au FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

"------------------------------------------------------------------------------
" => HTML
"   Alguns desses snips tambem sao implementados no SnipMate
"------------------------------------------------------------------------------
au FileType html,xhtml,php,eruby imap bbb <br />
au FileType html,xhtml,php,eruby imap aaa <a href=""></a><left><left><left><left><left><left>
au FileType html,xhtml,php,eruby imap iii <img src="" /><left><left><left><left>
au FileType html,xhtml,php,eruby imap ddd <div id=""></div><left><left><left><left><left><left><left><left>

"------------------------------------------------------------------------------
" => TeX e LaTeX
"------------------------------------------------------------------------------
au FileType tex  map! Ç \c{C}
au FileType tex  map! ç \c{c}
au FileType tex  map! Á \'{A}
au FileType tex  map! À \`{A}
au FileType tex  map! Â \^{A}
au FileType tex  map! ã \~{a}
au FileType tex  map! á \'{a}
au FileType tex  map! â \^{a}
au FileType tex  map! ã \~{a}
au FileType tex  map! à \`{a}
au FileType tex  map! É \'{E}
au FileType tex  map! Ê \^{E}
au FileType tex  map! é \'{e}
au FileType tex  map! ê \^{e}
au FileType tex  map! Í \'{I}
au FileType tex  map! í \'{i}
au FileType tex  map! Ó \'{O}
au FileType tex  map! ó \'{o}
au FileType tex  map! Ô \^{O}
au FileType tex  map! ô \^{o}
au FileType tex  map! Õ \~{O}
au FileType tex  map! õ \~{o}
au FileType tex  map! Ú \'{U}
au FileType tex  map! ú \'{u}
au FileType tex  map! Ü \"{U}
au FileType tex  map! ü \"{u}

"------------------------------------------------------------------------------
" => Ler documentos do MS Word
"   Depende do antiword (http://vim.wikia.com/wiki/View_and_diff_MS_Word_files)
"------------------------------------------------------------------------------
if executable('antiword')
    augroup Word
        au!
        au BufReadPre *.doc set ro
        au BufReadPre *.doc set hlsearch!
        au BufReadPost *.doc %!antiword "%"
    augroup END
endif
