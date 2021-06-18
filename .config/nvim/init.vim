" Plugins
" vim-plug {{{
" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')
    " Lint
    Plug 'w0rp/ale'

    " UI
    Plug 'Yggdroot/indentLine'
    Plug 'itchyny/lightline.vim'
    Plug 'maximbaz/lightline-ale'
    Plug 'junegunn/limelight.vim'
    Plug 'mhinz/vim-signify'
    Plug 'sheerun/vim-polyglot'
    Plug 'simeji/winresizer'
    Plug 'lfv89/vim-interestingwords'
    Plug 'ap/vim-css-color'
    Plug 'scrooloose/nerdtree'
    Plug 'lambdalisue/vim-manpager'

    " Editing
    Plug 'junegunn/vim-easy-align'
    Plug 'sbdchd/neoformat'
    Plug 'tpope/vim-surround'
    Plug 'Shougo/denite.nvim'
        Plug 'Shougo/neomru.vim' " for 'file_mru'
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
        Plug 'Shougo/neco-syntax'

    " Colorscheme
    Plug 'jacoborus/tender.vim'

    " UI
    Plug 'ryanoasis/vim-devicons' " Nerd Fonts required. Load after all supported plugins. 

call plug#end()
" }}} vim-plug

" Colorscheme
if (has("termguicolors"))
    set termguicolors
endif
set background=dark
colorscheme tender
let g:lightline = { 'colorscheme': 'tender' }

" UI
set ruler
set hidden
set number
"set guifont=RictyDiscord\ Nerd\ Font\ 11
set mouse=a

" Search
set incsearch
set hlsearch
set ignorecase
set smartcase

" File
set nobackup
set autochdir

" Indent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Fold
set foldmethod=marker
set foldlevel=99 " unfold everything

" Edit
let mapleader = "\<Space>"
set nrformats=alpha,octal,hex,bin
set virtualedit=block
set clipboard+=unnamedplus
noremap <F4> :tabnew<CR>
noremap <F5> :e!<CR>
noremap <F9> :NERDTreeToggle<CR>
noremap <F12> :split<CR>
noremap <S-F12> :vsplit<CR>
noremap <C-Left> :bprev<CR>
noremap <C-Right> :bnext<CR>
nnoremap <ESC><ESC> :nohlsearch<CR>
nnoremap S diw"0P

" ale {{{
let g:ale_fixers = {
            \   'javascript': ['prettier'],
            \   'python': ['flake8'],
            \}
let g:ale_completion_enabled = 1
let g:ale_open_list = 1
autocmd QuitPre * if empty(&bt) | lclose | endif
" }}}

" deoplete.vim
let g:deoplete#enable_at_startup = 1

" denite.vim {{{
nnoremap <C-p> :Denite file/rec buffer file_mru<CR>
let g:neomru#follow_links = 1
"   Change file/rec command.
call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])
"   Change mappings.
call denite#custom#map('insert', '<C-j>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert', '<C-k>', '<denite:move_to_previous_line>', 'noremap')
call denite#custom#map('insert', '<Down>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert', '<Up>', '<denite:move_to_previous_line>', 'noremap')
"   Ripgrep command on grep source
call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts', ['--vimgrep', '--no-heading'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])
"   Change ignore_globs
call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
      \ [ '.git/', '.ropeproject/', '__pycache__/',
      \   'venv/', 'images/', '*.min.*', 'img/', 'fonts/'])
" }}}

" vim-easy-align
"   Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
"   Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" lightline.vim {{{
set noshowmode
" lightline-ale
let g:lightline = {}
let g:lightline.component_expand = {
      \  'linter_checking': 'lightline#ale#checking',
      \  'linter_warnings': 'lightline#ale#warnings',
      \  'linter_errors': 'lightline#ale#errors',
      \  'linter_ok': 'lightline#ale#ok',
      \ }
let g:lightline.component_type = {
      \     'linter_checking': 'left',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'left',
      \ }
let g:lightline.active = { 'right': [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ]] }
let g:lightline#ale#indicator_checking = "\uf110 "
let g:lightline#ale#indicator_warnings = "\uf071 "
let g:lightline#ale#indicator_errors = "\uf05e "
let g:lightline#ale#indicator_ok = "\uf00c "
" }}}

" vim-signify
let g:signify_realtime = 1
let g:signify_vcs_list = [ 'git', 'hg' ]

" NERDTree
let NERDTreeShowHidden = 1
