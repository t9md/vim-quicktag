"=============================================================================
" File: quicktag.vim
" Author: t9md <taqumd@gmail.com>
" WebPage: http://github.com/t9md/quicktag.vim
" License: BSD
" Version: 0.1

" GUARD: {{{
"============================================================
" if exists('g:loaded_quicktag')
  " finish
" endif
let g:loaded_quicktag = 1

"for line continuation - i.e dont want C in &cpo
let s:old_cpo = &cpo
set cpo&vim
"}}}

" Setup:"{{{
"==================================================================
if !exists('g:quicktag_debug')
    let g:quicktag_debug = 0
endif

let g:quicktag = {}
let s:quicktag_default_opt = { 
            \ 'basedir': "~/.vim/quicktag",
            \ } 

let g:quicktag.exclude_patterns = [
            \ '\.svn/',
            \ '\.git/',
            \ ]

function! s:setup()"{{{
    call extend(g:quicktag, s:quicktag_default_opt, "keep")
    let g:quicktag.statusfile = g:quicktag.basedir . "/status"
endfunction"}}}

call s:setup()
"}}}

function! s:tagfile_path()
    return expand(g:quicktag.basedir ."/". &filetype . ".tags")
endfunction

function! s:set_tags()
  if empty(&ft) || filereadable('tags')
    return
  endif
  exe 'setlocal tags+='.s:tagfile_path()
endfunction


" Main:
augroup QuickTag
    autocmd!
    autocmd CursorHold,CursorHoldI *.pl,*.rb,*.py,*.lua,*.sh,*.vim silent QuickTagUpdate
    autocmd VimLeave * call quicktag#finish()
    autocmd BufNewFile,BufReadPost * call <SID>set_tags()
augroup END

" Command:
command! QuickTagUpdate  :call quicktag#update()

"reset &cpo back to users setting
let &cpo = s:old_cpo
" vim: foldmethod=marker
