" Plugins
" vim-plug {{{
" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin(stdpath('data') . '/plugged')
    " LSP
    Plug 'prabirshrestha/vim-lsp'
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'mattn/vim-lsp-settings'

    " Telescope (fuzzy finder)
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    " UI
    Plug 'mhinz/vim-startify'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'airblade/vim-gitgutter'
    Plug 'sheerun/vim-polyglot'
    Plug 'lfv89/vim-interestingwords'
    Plug 'norcalli/nvim-colorizer.lua'
    Plug 'ojroques/nvim-hardline'

    " Editing
    Plug 'junegunn/vim-easy-align'
    Plug 'tpope/vim-surround'

    " Colorscheme
    Plug 'jacoborus/tender.vim'
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
"noremap <F9> :NERDTreeToggle<CR>
noremap <F12> :split<CR>
noremap <S-F12> :vsplit<CR>
noremap <C-Left> :bprev<CR>
noremap <C-Right> :bnext<CR>
nnoremap <ESC><ESC> :nohlsearch<CR>
nnoremap S diw"0P

" vim-easy-align
"   Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
"   Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" NERDTree
"let NERDTreeShowHidden = 1

" vim-lsp
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    inoremap <buffer> <expr><c-f> lsp#scroll(+4)
    inoremap <buffer> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" asyncomplete.vim
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fr <cmd>Telescope oldfiles<cr>

" nvim-hardline
lua require('hardline').setup {}

" nvim-colorizer.lua
lua require('colorizer').setup {}

if has('win32')
    " from `:help shell-powershell`
    let &shell = has('win32') ? 'powershell' : 'pwsh'
    let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=
endif
