" project.vim - Manages projects
" Maintainer:   Álan Crístoffer <http://acristoffers.me>
" Version:      1.0.1

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

function! s:ProjectSave(projects)
    execute 'redir! > ' . $VIMHOME . "/projects.paths"
    for path in a:projects
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
    let projects = s:ProjectLoad()

    let found = 0
    for path in projects
        if path == cwd
            let found = 1
        end
    endfor

    if found == 0
        call add(projects, cwd)
    end

    call s:ProjectSave(projects)
endfun

function! s:ProjectRemove()
    let cwd = s:FindCVS()

    let projects = []
    for path in s:ProjectLoad()
        if path != cwd
            call add(projects, path)
        end
    endfor

    call s:ProjectSave(projects)
endfun

function! s:ProjectList()
    let projects = s:ProjectLoad()
    let options = []
    let c = 1
    for path in projects
        call add(options, c . '. ' . path)
        let c += 1
    endfor

    let option = inputlist(options)
    if option != 0
        let path = get(projects, option-1, '')
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

nnoremap <leader>pa :ProjectAdd<CR>
nnoremap <leader>pr :ProjectRemove<CR>
nnoremap <leader>po :ProjectOpen<CR>

command! -bar ProjectAdd    :call s:ProjectAdd()
command! -bar ProjectRemove :call s:ProjectRemove()
command! -bar ProjectOpen   :call s:ProjectList()
