syntax on
filetype plugin indent on

set number

" indent / tabs (matches Zed: 2 spaces)
set tabstop=2 shiftwidth=2 expandtab

" search
set hlsearch incsearch
set ignorecase smartcase

" usability
set backspace=indent,eol,start
set mouse=a
set clipboard=unnamed
set noswapfile

" persistent undo — trailing // keeps undo files separate for same-named files
if !isdirectory($HOME . "/.vim/undo")
  silent! call mkdir($HOME . "/.vim/undo", "p")
endif
set undofile
set undodir=$HOME/.vim/undo//

" Esc clears search highlighting
nnoremap <silent> <Esc> :nohlsearch<CR>
