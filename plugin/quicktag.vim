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
" let g:loaded_quicktag = 1

"for line continuation - i.e dont want C in &cpo
let s:old_cpo = &cpo
set cpo&vim
"}}}

function! s:set_default(varname, default) "{{{
  if !exists(a:varname)
    let {a:varname} = a:default
  endif
endfunction"}}}

" Setup: variable "{{{
call s:set_default('g:quicktag_basedir', "~/.vim/quicktag")
call s:set_default('g:quicktag_statusfile', g:quicktag_basedir . "/status")
"}}}

function! s:quicktag_status_dump()"{{{
  call writefile([string(g:quicktag_lastupdate)],
        \ expand(g:quicktag_statusfile))
endfunction"}}}

function! s:quicktag_status_load() "{{{
  try
    let g:quicktag_lastupdate = eval(
          \ readfile(expand(g:quicktag_statusfile))[0])
  catch
    call s:set_default('g:quicktag_lastupdate',{})
    if !(type(g:quicktag_lastupdate) == type({}))
      let g:quicktag_lastupdate = {}
    endif
  endtry
endfunction "}}}

function! s:quicktag_init() "{{{
  call s:quicktag_status_load()
endfunction "}}}

function! s:quicktag_finish() "{{{1
  call s:quicktag_status_dump()
endfunction

function! s:uniq(list) "{{{1
  let dic = {}
  for e in a:list | let dic[e] = 1 | endfor
  return keys(dic)
endfunction

function! s:tagfile_name() "{{{1
  return expand(g:quicktag_basedir ."/".&ft . ".tags")
endfunction

function! s:ctags_command(file) "{{{1
  if !filereadable(a:file)
    let cmd_fmt = 'ctags -f %s %s'
  else
    let cmd_fmt = 'ctags -f %s -a %s'
  endif
  return printf(cmd_fmt, s:tagfile_name(), a:file)
endfunction

function! s:update_status(file) "{{{1
  let g:quicktag_lastupdate[a:file] = getftime(a:file)
endfunction

function! s:get_status(file) "{{{1
  return get(g:quicktag_lastupdate, a:file, 0)
endfunction

function! s:is_updated(file) "{{{1
  return getftime(a:file) != s:get_status(a:file)
endfunction

function! s:ctags_execute(file) "{{{1
  call system(s:ctags_command(a:file))
  call s:update_status(a:file)
endfunction

function! s:tag_filelist() "{{{1
  return s:uniq(map(taglist('.'), 'v:val.filename'))
endfunction

let s:o = {}
function! s:o.update(file)
  if s:is_updated(a:file)
    call self.cleanup(a:file)
    call s:ctags_execute(a:file)
    echo " Updated"
  else
    echo " Nothing updated"
  endif
  if exists('g:underlinetag_autoupdate') && g:underlinetag_autoupdate
    call underlinetag#do(1)
  endif
endfunction

function! s:o.cleanup(...) "{{{1
  if a:0 == 0
    return
  endif
  if filereadable(s:tagfile_name())
    let lines = readfile(s:tagfile_name())
    for file in a:000
      call filter(lines, 'split(v:val, "\t")[1] !=# file')
    endfor
  else
    let lines = []
  endif
  call writefile(lines, s:tagfile_name())
endfunction

function! s:o.cleanup_missing() "{{{1
  let missing = copy(s:tag_filelist())
  call filter(missing, '!filereadable(v:val)')
  if len(missing) >0
    call self.cleanup(missing)
  endif
endfunction

let g:QuickTag = s:o
unlet s:o

function! s:set_tag()
  if empty(&ft) || filereadable('tags')
    return
  endif
  exe 'setlocal tags+='.s:tagfile_name()
endfunction

" Main: "{{{1
" This is test
" This is test
" This is test
" This is test
augroup QuickTag
    autocmd!
    autocmd CursorHold,CursorHoldI *.rb,*.py,*.lua,*.sh,*.vim silent QuickTagUpdate
    autocmd VimLeave * call <SID>quicktag_finish()
    autocmd BufNewFile,BufReadPost * call <SID>set_tag()
augroup END
call s:quicktag_init()

" Command: "{{{1
command! QuickTagUpdate  :call g:QuickTag.update(expand('%:p'))
command! QuickTagCleanUp :call g:QuickTag.cleanup_missing()
"reset &cpo back to users setting

let &cpo = s:old_cpo
nnoremap <Space>R :<C-u>QuickTagUpdate<CR>
" vim: foldmethod=marker
