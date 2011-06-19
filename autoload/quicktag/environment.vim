function! s:tagfile_path()
    return expand(g:quicktag.basedir ."/". &filetype . ".tags")
endfunction

let s:env = {}
function! s:env.new()
    let env =  {
                \ 'path': expand("%:p"),
                \ 'tagfile': s:tagfile_path()
                \ }
    return env
endfunction

function! quicktag#environment#new()
    return s:env.new()
endfunction
