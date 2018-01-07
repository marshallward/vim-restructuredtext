" reStructuredText filetype plugin file
" Language: reStructuredText documentation format
" Maintainer: Marshall Ward <marshall.ward@gmail.com>
" Original Maintainer: Nikolai Weibull <now@bitwi.se>
" Website: https://github.com/marshallward/vim-restructuredtext
" Latest Revision: 2016-10-07

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

let b:undo_ftplugin = "setl com< cms< et< fo<"

setlocal comments=fb:.. commentstring=..\ %s expandtab
setlocal formatoptions+=tcroql

" reStructuredText standard recommends that tabs be expanded to 8 spaces
" The choice of 3-space indentation is to provide slightly better support for
" directives (..) and ordered lists (1.), although it can cause problems for
" many other cases.
"
" More sophisticated indentation rules should be revisted in the future.

if !exists("g:rst_style") || g:rst_style != 0
    setlocal expandtab shiftwidth=3 softtabstop=3 tabstop=8
endif

set foldmethod=expr
set foldexpr=RstFold#GetRstFold()

augroup RstFold
  autocmd TextChanged,InsertLeave <buffer> unlet! b:RstFoldCache
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
