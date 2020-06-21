" project.vim - Manages projects
" Maintainer:   Álan Crístoffer <http://acristoffers.me>
" Version:      1.0.0

if has("win32") || has ("win64")
    let $VIMHOME = $VIM."/vimfiles"
else
    let $VIMHOME = $HOME."/.vim"
endif

function! s:FindCVS()
    let cwd = getcwd()
    let git = system('git rev-parse --show-toplevel')
    if git =~ "fatal:"
        return cwd
    else
        return git
    end
endfun

function! s:ProjectSave()
    execute 'redir! > ' . $VIMHOME . "/projects.paths"
    for path in s:projects
        silent echo path
    endfor
    execute 'redir END'
endfun

function! s:ProjectLoad()
    let lines = readfile($VIMHOME . "/projects.paths")
    let paths = []
    for line in lines
        if strlen(line) > 0
            call add(paths, line)
        end
    endfor
    return paths
endfun

function! s:ProjectAdd()
    let cwd = s:FindCVS()

    let found = 0
    for path in s:projects
        if path == cwd
            let found = 1
        end
    endfor

    if found == 0
        call add(s:projects, cwd)
    end

    call s:ProjectSave()
endfun

function! s:ProjectRemove()
    let cwd = s:FindCVS()

    let projects = []
    for path in s:projects
        if path != cwd
            call add(projects, path)
        end
    endfor

    let s:projects = projects
    call s:ProjectSave()
endfun

function! s:ProjectList()
    let options = []
    let c = 1
    for path in s:projects
        call add(options, c . '. ' . path)
        let c += 1
    endfor

    let option = inputlist(options)
    if option != 0
        let path = get(s:projects, option-1, '')
        if strlen(path) > 0
            call s:ProjectOpen(path)
        end
    end
endfun

function! s:ProjectOpen(path)
    execute 'cd' fnameescape(a:path)
    execute '%bd'
    if &rtp =~ 'fzf'
        execute 'Files'
    else
        execute 'Explore'
    endif
endfun

let s:projects = s:ProjectLoad()

nnoremap <leader>pa :ProjectAdd<CR>
nnoremap <leader>pr :ProjectRemove<CR>
nnoremap <leader>po :ProjectOpen<CR>

command! -bar ProjectAdd    :call s:ProjectAdd()
command! -bar ProjectRemove :call s:ProjectRemove()
command! -bar ProjectOpen   :call s:ProjectList()
