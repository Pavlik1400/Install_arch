" Plugins
call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'junegunn/goyo.vim'

Plug 'https://github.com/preservim/nerdtree'
Plug 'https://github.com/preservim/nerdcommenter'
Plug 'https://github.com/airblade/vim-gitgutter'

Plug 'https://github.com/ycm-core/YouCompleteMe'
"Plug 'maralla/completor.vim'
"Plug 'maralla/completor-neosnippet'
"Plug 'https://github.com/Shougo/neoinclude.vim'
"Plug 'SirVer/ultisnips'
"Plug 'honza/vim-snippets'
call plug#end()

" lightline config
set laststatus=2
set noshowmode

" goyo shortcut
"map :G :Goyo

" numbers on the left
"set number relativenumber
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
" <leader>d -> get more details about syntax error
" :lopen - open list of all syntax errors (:lclose)
let g:completor_python_binary = '/usr/bin/python'
let g:completor_clang_binary = '/usr/bin/clang'
let g:ycm_auto_trigger = 1
let  g:ycm_always_populate_location_list = 1

nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>
nnoremap <S-y> :YcmRestartServer<CR>

" CTRL-O - back from goto place (CTRL-I forward)
nnoremap <leader>g :YcmCompleter GoTo<CR>
nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
nnoremap <leader>gd :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gf :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
nnoremap <leader>gtp :YcmCompleter GoToType<CR>
nnoremap <leader>typ :YcmCompleter GetType<CR>
nnoremap <leader>doc :YcmCompleter GetDoc<CR>
nnoremap <leader>rr :YcmCompleter RefactorRename 

