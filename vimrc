set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
syntax on
colorscheme slate
set guifont=Consolas:h12:cANSI:qDRAFT
set visualbell
set number
set laststatus=2

python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
