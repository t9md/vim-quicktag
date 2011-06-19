" Controller: "{{{
"=================================================================
let s:controller = quicktag#object#new("controller")

function! s:controller.generate()"{{{
    let cmd = self.ctags_command()
    call self.debug(cmd)
    call system(cmd)
endfunction"}}}

function! s:controller.init()"{{{
    let self.status = quicktag#status#instance()
endfunction"}}}

function! s:controller.finish()"{{{
    call self.status.dump()
endfunction"}}}

function! s:controller.ctags_command()"{{{
    return 'ctags -f ' . self.env.tagfile . " -a " . self.env.path
endfunction"}}}

function! s:controller.update()"{{{
    if empty(&filetype) | return | endif

    let self.env = quicktag#environment#new()

    for pattern in g:quicktag.exclude_patterns
        if match(self.env.path, pattern) != -1
            return
        endif
    endfor

    call self.debug(self.env.path)

    if self.status.is_updated(self.env.path)
        call self.clean()
        call self.generate()
        call self.status.update(self.env.path)
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

function! quicktag#controller#update()
    call s:controller.update()
endfunction

function! quicktag#controller#finish()
    call s:controller.finish()
endfunction

call s:controller.init()
