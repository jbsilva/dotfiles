"==============================================================================
"                      ( O O )
"               ====oOO==(_)==OOo=====
"
" File:         ~/.config/nvim/vscode.vim
" Description:  VSCode Neovim extension configuration
" Author:       Julio Batista Silva
" Created:      2021
" Last Change:  Mon, 22 Nov 2021 21:30:00 -0300
"==============================================================================
"
"------------------------------------------------------------------------------
" => Leader key
"------------------------------------------------------------------------------
let mapleader=','

"------------------------------------------------------------------------------
" => Search
"------------------------------------------------------------------------------
set ignorecase              " Ignore case in search patterns...
set smartcase               " ...except if search pattern contains upper case

"------------------------------------------------------------------------------
" => Movements
"------------------------------------------------------------------------------
set whichwrap=h,l,<,>,[,]   " Allow move to next line

" Fast scroll using arrow keys
noremap <Left> 5h
noremap <Down> 5j
noremap <Up> 5k
noremap <Right> 5l

"------------------------------------------------------------------------------
" => Clean search highlight with <leader><space>
"------------------------------------------------------------------------------
nnoremap <silent> <leader><space> :noh<cr>

"------------------------------------------------------------------------------
" => Copy/Paste/Cut
"------------------------------------------------------------------------------

" Delete without overwriting last yank (delete to the black hole register "_)
nnoremap x "_x
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d
vnoremap x "_x

" Normal delete using the <leader> key
" Use <leader>x to cut to system clipboard
nnoremap <leader>d ""d
nnoremap <leader>D ""D
vnoremap <leader>d ""d

" Y copy from cursor to last-non-blank-char
nnoremap Y yg_

" Copy to system clipboard
nnoremap <leader>y "+y
nnoremap <leader>Y "+yg_
vnoremap <leader>y "+y

" Cut to system clipboard
vnoremap <leader>x "+x
nnoremap <leader>x "+x
nnoremap <leader>X "+X

" Paste from system clipboard
vnoremap <leader>p "+p
vnoremap <leader>P "+P
nnoremap <leader>p "+p
nnoremap <leader>P "+P

" Make p paste from "0 (what was yanked without specifiying a register)
" instead of from the unnamed register ("").
" The unnamed register ("") points to the last used register ("+ in the
" commands above), except when using the black hole register ("_).
" The loop is necessary to recover the hability to use p with other registers.
noremap p "0p
noremap P "0P
for s:i in ['"','*','+','-','.',':','%','/','=','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
    execute 'noremap "'.s:i.'p "'.s:i.'p'
    execute 'noremap "'.s:i.'P "'.s:i.'P'
endfor

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

