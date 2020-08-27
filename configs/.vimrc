" Plugins
call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'junegunn/goyo.vim'

Plug 'https://github.com/preservim/nerdtree'
Plug 'https://github.com/preservim/nerdcommenter'

Plug 'maralla/completor.vim'
Plug 'maralla/completor-neosnippet'
Plug 'https://github.com/Shougo/neoinclude.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'https://github.com/airblade/vim-gitgutter'
call plug#end()

" lightline config
set laststatus=2
set noshowmode

" goyo shortcut
map :G :Goyo

" numbers on the left
set number relativenumber
" normal split
set splitbelow splitright

syntax enable
colorscheme monokai

" NERDTree config
map <C-n> :NERDTreeToggle<CR>
" autocmd vimenter * NERDTree

" NerdCommenter shortcut
map <C-\> <leader>c<space>

" autocomplition config
let g:completor_python_binary = '/usr/bin/python'
let g:completor_clang_binary = '/usr/bin/clang'
