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

function! quicktag#object#new(name)
    return s:object.new(a:name)
endfunction
