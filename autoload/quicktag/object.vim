" Object:
"==================================================================
let s:Object = {}

function! s:Object.debug(msg)"{{{
    if !g:quicktag_debug | return | endif
    echo "[".self.name."] " . string(a:msg)
endfunction"}}}

function! s:Object.new(name)"{{{
    let instance = {}
    let instance.name = a:name
    call extend(instance, self, 'keep')
    call remove(instance, 'new')
    return instance
endfunction"}}}

function! quicktag#object#new(name)"{{{
    return s:Object.new(a:name)
endfunction"}}}
" vim: foldmethod=marker
