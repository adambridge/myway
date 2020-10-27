set tabstop=4                                                       " MYWAY-AUTO-INSTALL
set softtabstop=4                                                   " MYWAY-AUTO-INSTALL
set shiftwidth=4                                                    " MYWAY-AUTO-INSTALL
set expandtab                                                       " MYWAY-AUTO-INSTALL
syntax on                                                           " MYWAY-AUTO-INSTALL
colorscheme slate                                                   " MYWAY-AUTO-INSTALL
set guifont=Consolas:h12:cANSI:qDRAFT                               " MYWAY-AUTO-INSTALL
set visualbell                                                      " MYWAY-AUTO-INSTALL
set number                                                          " MYWAY-AUTO-INSTALL
set laststatus=2                                                    " MYWAY-AUTO-INSTALL
                                                                    " MYWAY-AUTO-INSTALL
python3 from powerline.vim import setup as powerline_setup          # MYWAY-AUTO-INSTALL
python3 powerline_setup()                                           # MYWAY-AUTO-INSTALL
python3 del powerline_setup                                         # MYWAY-AUTO-INSTALL
