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

let s:exclude_patterns = [
            \ '\.svn/',
            \ '\.git/',
            \ ]

function! s:setup()"{{{
    call extend(g:quicktag, s:quicktag_default_opt, "keep")
    let g:quicktag.statusfile = g:quicktag.basedir . "/status"
endfunction"}}}
call s:setup()
"}}}
" Utils: module"{{{
"==================================================================
let s:utils = {}
function! s:utils.normalize(file)"{{{
    return fnamemodify(a:file, ":p:~")
endfunction"}}}
function! s:utils.uniq(list)"{{{
  let dic = {}
  for e in a:list | let dic[e] = 1 | endfor
  return keys(dic)
endfunction"}}}
"}}}
" Environment: "{{{
"=================================================================
let s:env = {}
function! s:env.new()
    let env =  {
                \ 'path': expand("%:p"),
                \ 'tagfile': s:tagfile_path()
                \ }
    return env
endfunction
"}}}
" Object:"{{{
"==================================================================
let s:object = {}
function! s:object.debug(msg)"{{{
    if !g:quicktag_debug | return | endif
    echo "[".self.name."] " . string(a:msg)
endfunction"}}}

function! s:object.new(name)"{{{
    let instance = {}
    let instance.name = a:name
    call extend(instance, self, 'keep')
    call remove(instance, 'new')
    return instance
endfunction"}}}

"}}}
" Status: "{{{
"==================================================================
let s:status = s:object.new("status")
let s:status.path = g:quicktag.statusfile

function! s:status.init()"{{{
    let self.files = self.load()
endfunction"}}}
function! s:status.dump()"{{{
    call writefile([string(self.files)], expand(self.path))
endfunction"}}}
function! s:status.load()"{{{
    try
        let status = eval(readfile(expand(self.path))[0])
        call filter(status, 'filereadable(v:key)')
        return status
    catch
        return {}
    endtry
endfunction"}}}
function! s:status.update(file)"{{{
    " call self.debug(a:file)
    let self.files[a:file] = getftime(expand(a:file))
    " call self.debug(self.files)
endfunction"}}}
function! s:status.get(file)"{{{
    return get(self.files, a:file, 0)
endfunction"}}}

function! s:status.is_updated(file)"{{{
    return getftime(a:file) != self.get(a:file)
endfunction"}}}
" }}}
" Controller: "{{{
"=================================================================
let s:controller = s:object.new("controller")

function! s:controller.generate()"{{{
    let cmd = self.ctags_command()
    call self.debug(cmd)
    call system(cmd)
endfunction"}}}

function! s:controller.finish()"{{{
    call s:status.dump()
endfunction"}}}

function! s:controller.ctags_command()"{{{
    return 'ctags -f ' . self.env.tagfile . " -a " . self.env.path
endfunction"}}}

function! s:controller.setenv()"{{{
    let self.env = s:env.new()
endfunction"}}}

function! s:controller.update()"{{{
    if empty(&filetype) | return | endif

    call self.setenv()

    for pattern in s:exclude_patterns
        if match(self.env.path, pattern) != -1
            return
        endif
    endfor

    call self.debug(self.env.path)

    if s:status.is_updated(self.env.path)
        call self.clean()
        call self.generate()
        call s:status.update(self.env.path)
        echo "Updated"
    else
        echo "No updated"
    endif
endfunction"}}}

function! s:controller.clean()"{{{
    let tagfile = self.env.tagfile
    let cfile   = self.env.path

    if !filereadable(tagfile) | return | endif
    let lines = readfile(tagfile)

    " remove lines for current file
    call filter(lines, 'split(v:val, "\t")[1] !=# cfile')

    " remove unreadable files from tagfile
    call filter(lines, 'filereadable(split(v:val, "\t")[1])')
    call writefile(lines, self.env.tagfile)
endfunction"}}}

" function! s:controller.clean(...)"{{{
    " let files = len(a:0) == 0 ? [self.env.path] : a:000

    " if filereadable(self.env.tagfile)
        " let lines = readfile(self.env.tagfile)
        " for file in files
            " call filter(lines, 'split(v:val, "\t")[1] !=# file')
        " endfor
    " else
        " let lines = []
    " endif
    " call writefile(lines, self.env.tagfile)
" endfunction"}}}

" function! s:controller.clean_missing()
    " call self.setenv()
    " let  missing = readfile(self.env.tagfile)
    " call filter(missing, "v:val !~# '^!_TAG_' ")
    " call map(missing, 'split(v:val, "\t")[1]')
    " call filter(missing, '!filereadable(v:val)')
    " if len(missing) > 0
        " echo "cleaning missingfile:"
        " echo join(missing, "\n")
        " call call(self.clean, missing, self)
    " endif
" endfunction
" }}}

function! s:tagfile_path()
    return expand(g:quicktag.basedir ."/". &filetype . ".tags")
endfunction

function! s:set_tag()
  if empty(&ft) || filereadable('tags')
    return
  endif
  exe 'setlocal tags+='.s:tagfile_path()
endfunction

let g:QuickTag = s:controller

" Main: "{{{1
call s:status.init()
augroup QuickTag
    autocmd!
    autocmd CursorHold,CursorHoldI *.pl,*.rb,*.py,*.lua,*.sh,*.vim silent QuickTagUpdate
    autocmd VimLeave * call QuickTag.finish()
    autocmd BufNewFile,BufReadPost * call <SID>set_tag()
augroup END

" Command: "{{{1
command! QuickTagUpdate  :call g:QuickTag.update()

"reset &cpo back to users setting
let &cpo = s:old_cpo
" vim: foldmethod=marker
