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

let g:quicktag = {}
let s:quicktag_default_opt = {
            \ 'basedir': "~/.vim/quicktag",
            \ 'debug': 0,
            \ }

function! s:setup()
    call extend(g:quicktag, s:quicktag_default_opt, "keep")
    let g:quicktag.statusfile = g:quicktag.basedir . "/status"
endfunction
call s:setup()

" Utils: module
"==================================================================
let s:utils = {}
function! s:utils.normalize(file)
    return fnamemodify(a:file, ":p:~")
endfunction
function! s:utils.uniq(list)
  let dic = {}
  for e in a:list | let dic[e] = 1 | endfor
  return keys(dic)
endfunction

" Environment: "{{{
"=================================================================
let s:env = {}
function! s:env.new()
    let env =  {
                \ 'path': expand("%:p"),
                \ 'tagfile': expand(g:quicktag.basedir ."/".&filetype . ".tags")
                \ }
    return env
endfunction
"}}}
"==================================================================
" Object:
"==================================================================
let s:object = {}
function! s:object.debug(msg)
    if !g:quicktag.debug | return | endif
    echo "[".self.name."] " . string(a:msg)
endfunction

function! s:object.new(name)
    let instance = {}
    let instance.name = a:name
    call extend(instance, self, 'keep')
    call remove(instance, 'new')
    return instance
endfunction

" Status: "{{{
"==================================================================
let s:status =  s:object.new("status")
let s:status = { 'path': g:quicktag.statusfile }

function! s:status.init()"{{{
    let self.files = self.load()
    " call self.debug("load finish")
    " call self.debug(self.files)
endfunction"}}}

function! s:status.dump()"{{{
    call writefile([string(self.files)], expand(self.path))
endfunction"}}}

function! s:status.load()"{{{
    try
        return eval(readfile(expand(self.path))[0])
    catch
        return {}
    endtry
endfunction"}}}

function! s:status.update(file)"{{{
    " call self.debug(a:file)
    let self.files[a:file] = getftime(expand(a:file))
    call self.debug(self.files)
endfunction"}}}

function! s:status.get(file)"{{{
    return get(self.files, a:file, 0)
endfunction"}}}

function! s:status.is_updated(file)"{{{
    return getftime(a:file) != self.get(a:file)
endfunction"}}}
" }}}

" Quicktag: "{{{
"=================================================================
let g:quicktag.debug = 1
let s:quicktag = s:object.new("quicktag")

function! s:quicktag.main()"{{{
    let self.env = s:env.new()
    call self.debug(self.env)
    " call s:status.update(self.env.path)
    " call s:status.get(self.env.path)
    " echo s:status.is_updated(self.env.path)
endfunction"}}}

function! s:quicktag.generate()"{{{
    let cmd = self.ctags_command()
    call self.debug(cmd)
    call system(cmd)
endfunction"}}}

function! s:quicktag.finish()"{{{
    call s:status.dump()
endfunction"}}}

function! s:quicktag.ctags_command()"{{{
    return 'ctags -f ' . self.env.tagfile . " -a " . self.env.path
endfunction"}}}

function! s:quicktag.update()"{{{
    if s:status.is_updated(self.env.path)
        call self.cleanup()
        call self.generate()
        echo "Updated"
    else
        echo "No updated"
    endif
    " if exists('g:underlinetag_autoupdate') && g:underlinetag_autoupdate
        " call underlinetag#do(1)
    " endif
endfunction"}}}

function! s:quicktag.cleanup(...)"{{{
  if a:0 == 0
    return
  endif
  if filereadable(self.env.tagfile)
    let lines = readfile(self.tagfile)
    for file in a:000
      call filter(lines, 'split(v:val, "\t")[1] !=# file')
    endfor
  else
    let lines = []
  endif
  call writefile(lines, self.env.tagfile)
endfunction"}}}

function! s:tag_filelist()"{{{
  return s:uniq(map(taglist('.'), 'v:val.filename'))
endfunction"}}}

" }}}
finish
call s:quicktag.init()
call s:status.init()
call s:quicktag.main()
let g:QuickTag = s:quicktag

function! s:set_tag()
  if empty(&ft) || filereadable('tags')
    return
  endif
  exe 'setlocal tags+='.s:tagfile_name()
endfunction

finish
" Main: "{{{1
augroup QuickTag
    autocmd!
    " autocmd CursorHold,CursorHoldI *.pl,*.rb,*.py,*.lua,*.sh,*.vim silent QuickTagUpdate
    " autocmd VimLeave * call <SID>quicktag.finish()
    " autocmd BufNewFile,BufReadPost * call <SID>set_tag()
augroup END
call s:quicktag_init()

" Command: "{{{1
command! QuickTagUpdate  :call g:QuickTag.update(expand('%:p'))
command! QuickTagCleanUp :call g:QuickTag.cleanup_missing()
"reset &cpo back to users setting

let &cpo = s:old_cpo
nnoremap <Space>R :<C-u>QuickTagUpdate<CR>
" vim: foldmethod=marker
