let s:Environment = {}

function! s:Environment.new()"{{{
    let env =  {
                \ 'path': expand("%:p"),
                \ 'tagfile': s:tagfile_path()
                \ }
    return env
endfunction"}}}

function! quicktag#environment#new()"{{{
    return s:Environment.new()
endfunction"}}}

function! s:tagfile_path()"{{{
    return expand(g:quicktag.basedir ."/". &filetype . ".tags")
endfunction"}}}
" vim: foldmethod=marker
