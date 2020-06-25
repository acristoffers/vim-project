" project.vim - Manages projects
" Maintainer:   Álan Crístoffer <http://acristoffers.me>
" Version:      1.0.2

function! s:vimhome()
    return (has("win32") || has ("win64")) ? $VIM."/vimfiles" : $HOME."/.vim"
endfun

function! s:pfile()
    return s:vimhome() . "/projects.paths"
endfun

function! s:FindCVS()
    let git = system('git rev-parse --show-toplevel')
    return trim(git =~ "fatal:" ? getcwd() : git)
endfun

function! s:ProjectSave(projects)
    call writefile(a:projects, s:pfile())
endfun

function! s:ProjectLoad()
    let file = s:pfile()
    if filereadable(file)
        return filter(map(readfile(file), 'trim(v:val)'), 'strlen(v:val) > 0')
    else
        return []
    endif
endfun

function! s:ProjectAdd()
    let projects = s:ProjectLoad()
    call add(projects, s:FindCVS())
    call s:ProjectSave(uniq(sort(projects)))
endfun

function! s:ProjectRemove()
    let cwd = s:FindCVS()
    call s:ProjectSave(filter(s:ProjectLoad(), 'v:val != cwd'))
endfun

function! s:ProjectClean()
    let projects = copy(s:ProjectLoad())
    call filter(projects, 'isdirectory(v:val) > 0')
    call s:ProjectSave(projects)
endfun

function! s:ProjectList()
    call s:ProjectClean()
    let projects = s:ProjectLoad()
    let options = map(copy(projects), "(v:key+1) . ') ' . v:val")
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
