" Status: "{{{
"==================================================================
let s:status = quicktag#object#new("status")
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

function! quicktag#status#instance()
    call s:status.init()
    return s:status
endfunction
