" Status:
"==================================================================
let s:Status = quicktag#object#new("Status")
let s:Status.path = g:quicktag.statusfile

function! s:Status.init()"{{{
    let self.files = self.load()
endfunction"}}}

function! s:Status.dump()"{{{
    call writefile([string(self.files)], expand(self.path))
endfunction"}}}

function! s:Status.load()"{{{
    try
        let status = eval(readfile(expand(self.path))[0])
        call filter(status, 'filereadable(v:key)')
        return status
    catch
        return {}
    endtry
endfunction"}}}

function! s:Status.update(file)"{{{
    " call self.debug(a:file)
    let self.files[a:file] = getftime(expand(a:file))
    " call self.debug(self.files)
endfunction"}}}

function! s:Status.get(file)"{{{
    return get(self.files, a:file, 0)
endfunction"}}}

function! s:Status.is_updated(file)"{{{
    return getftime(a:file) != self.get(a:file)
endfunction"}}}

function! quicktag#status#instance()"{{{
    call s:Status.init()
    return s:Status
endfunction"}}}
" vim: foldmethod=marker
