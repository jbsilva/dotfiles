"------------------------------------------------------------------------------
" => Vundle - https://github.com/gmarik/vundle
"    Gerencia plugins melhor que Pathogen. Comandos:
"       :BundleInstall for main install
"       :BundleInstall! will install/update all
"       :Bundle "foo" searches for foo.
"       :BundleClean will remove deleted bundles
"------------------------------------------------------------------------------
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
Bundle 'gmarik/vundle'

" original repos on github
Bundle 'Lokaltog/vim-easymotion'
Bundle 'alfredodeza/pytest.vim'

"Tab autocompletion
"Bundle 'ervandew/supertab'

"Python Documentation (ctrl+k)
Bundle 'fs111/pydoc.vim'

"betterthangrep.com
Bundle 'mileszs/ack.vim'

"Check Python code on the fly
Bundle 'mitechie/pyflakes-pathogen'

"TextMate snippets
Bundle 'msanders/snipmate.vim'

"Write HTML in CSS-like syntax
Bundle 'rstacruz/sparkup'

"Explore filesystem
Bundle 'scrooloose/nerdtree'

"Visualize your Vim undo tree.
":GundoToggle || <leader>g
Bundle 'sjl/gundo.vim'

Bundle 'sontek/minibufexpl.vim'
Bundle 'sontek/rope-vim'

"Comment multiple lines --> gc{motion}, gcc
Bundle 'tomtom/tcomment_vim'

"Git wrapper. --> :Gedit :Gsplit :Gstatus :Gbrowse, etc
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-git'

"Manipulate surroundings. (*) denotes the cursor position:
"Doc: https://github.com/tpope/vim-surround/blob/master/doc/surround.txt
"  Old text                  Command     New text
"  "Hello *world!"           ds"         Hello world!
"  [123+4*56]/2              cs])        (123+456)/2
"  <div>Yo!*</div>           cst<p>      <p>Yo!</p>
"  if *x>3 {                 ysW(        if ( x>3 ) {
"  my $str = *whee!;         vllllS'     my $str = 'whee!';
Bundle 'tpope/vim-surround'

"List FIXME, TODO and XXX. <leader>tl
Bundle 'vim-scripts/TaskList.vim'

":colorscheme zenburn
Bundle 'jnurmine/Zenburn'

"Defines text objects based on indent levels. Useful in Python
"  Key Mapping   Description
"  <count>ai     (A)n (I)ndentation level and line above.
"  <count>ii     (I)nner (I)ndentation level (no line above).
"  <count>aI     (A)n (I)ndentation level and lines above/below.
"  <count>iI     (I)nner (I)ndentation level (no lines above/below).
Bundle 'michaeljsmith/vim-indent-object'

"Instalar antes: `sudo easy_install-3.2 pep8`
"http://www.python.org/dev/peps/pep-0008/
Bundle 'vim-scripts/pep8'

"Finds buffers/files/commands/bookmarks/tags fast
":FufFile || :FufBuffer
Bundle 'vim-scripts/FuzzyFinder'
Bundle 'vim-scripts/L9'

"Ruby on rails
Bundle 'vim-scripts/rails.vim'

"vim + gnu screen
Bundle 'ervandew/screen'

" non github repos
"Bundle 'git://git.wincent.com/command-t.git'
Bundle 'git://vim-latex.git.sourceforge.net/gitroot/vim-latex/vim-latex'
Bundle 'git://gitorious.org/vim-gnupg/vim-gnupg.git'

"C and C++
Bundle 'wincent/Command-T'
Bundle 'vim-scripts/c.vim'

"" Edite o plugin c.vim:
"   -> c-support/templates/Templates: Coloque seus dados
"   -> c-support/templates/cpp.comments.template: Diminua === para 79 colunas
"           e adicione alguns includes e `int main(){ return 0}`
"   -> plugin/c.vim: Mude o formado usado para datas:
"           s:C_FormatDate = '%d/%b/%Y' e s:C_FormatTime = '%T'

"YouCompleteMe
Bundle 'Valloric/YouCompleteMe'
