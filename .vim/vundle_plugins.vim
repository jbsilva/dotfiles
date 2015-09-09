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

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" original repos on github
Plugin 'Lokaltog/vim-easymotion'
Plugin 'alfredodeza/pytest.vim'

"Tab autocompletion
"Plugin 'ervandew/supertab'

"Python Documentation (ctrl+k)
Plugin 'fs111/pydoc.vim'

"betterthangrep.com
Plugin 'mileszs/ack.vim'

"Check Python code on the fly
Plugin 'mitechie/pyflakes-pathogen'

"TextMate snippets
Plugin 'msanders/snipmate.vim'

"Write HTML in CSS-like syntax
Plugin 'rstacruz/sparkup'

"Explore filesystem
Plugin 'scrooloose/nerdtree'

"Visualize your Vim undo tree.
":GundoToggle || <leader>g
Plugin 'sjl/gundo.vim'

"Comment multiple lines --> gc{motion}, gcc
Plugin 'tomtom/tcomment_vim'

"Git wrapper. --> :Gedit :Gsplit :Gstatus :Gbrowse :Gblame :Gdiff, etc
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-git'

" Enable repeating supported plugin maps with "."
Plugin 'tpope/vim-repeat'

"CTRL-A/CTRL-X increment dates, times, and more
Plugin 'tpope/vim-speeddating'

"Manipulate surroundings. (*) denotes the cursor position:
"Doc: https://github.com/tpope/vim-surround/blob/master/doc/surround.txt
"  Old text                  Command     New text
"  "Hello *world!"           ds"         Hello world!
"  [123+4*56]/2              cs])        (123+456)/2
"  <div>Yo!*</div>           cst<p>      <p>Yo!</p>
"  if *x>3 {                 ysW(        if ( x>3 ) {
"  my $str = *whee!;         vllllS'     my $str = 'whee!';
Plugin 'tpope/vim-surround'

"List FIXME, TODO and XXX. <leader>tl
Plugin 'vim-scripts/TaskList.vim'

":colorscheme zenburn
Plugin 'jnurmine/Zenburn'

"Defines text objects based on indent levels. Useful in Python
"  Key Mapping   Description
"  <count>ai     (A)n (I)ndentation level and line above.
"  <count>ii     (I)nner (I)ndentation level (no line above).
"  <count>aI     (A)n (I)ndentation level and lines above/below.
"  <count>iI     (I)nner (I)ndentation level (no lines above/below).
Plugin 'michaeljsmith/vim-indent-object'

"Instalar antes: `pip install pep8`
"http://www.python.org/dev/peps/pep-0008/
Plugin 'vim-scripts/pep8'

"Finds buffers/files/commands/bookmarks/tags fast
":FufFile || :FufBuffer
Plugin 'vim-scripts/FuzzyFinder'
Plugin 'vim-scripts/L9'

"Ruby on rails
Plugin 'vim-scripts/rails.vim'

"vim + gnu screen
Plugin 'ervandew/screen'

" non github repos
"Plugin 'git://git.wincent.com/command-t.git'
Plugin 'git://vim-latex.git.sourceforge.net/gitroot/vim-latex/vim-latex'

"C and C++
Plugin 'wincent/Command-T'
Plugin 'vim-scripts/c.vim'

"" Edite o plugin c.vim:
"   -> c-support/templates/Templates: Coloque seus dados
"   -> c-support/templates/cpp.comments.template: Diminua === para 79 colunas
"           e adicione alguns includes e `int main(){ return 0}`
"   -> plugin/c.vim: Mude o formado usado para datas:
"           s:C_FormatDate = '%d/%b/%Y' e s:C_FormatTime = '%T'

" Rust language
Plugin 'rust-lang/rust.vim'

"YouCompleteMe
"Plugin 'Valloric/YouCompleteMe'

"Plugin 'sontek/minibufexpl.vim'
"Plugin 'sontek/rope-vim'

" Edit gpg encrypted files
Plugin 'https://github.com/jamessan/vim-gnupg'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
