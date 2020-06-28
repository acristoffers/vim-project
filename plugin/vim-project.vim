" project.vim - Manages projects
" Plugin:       https://github.com/acristoffers/vim-project
" Maintainer:   Álan Crístoffer <http://acristoffers.me>
" Version:      1.0.3

" The MIT License (MIT)
"
" Copyright (c) 2020 Álan Crístoffer
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the 'Software'), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

if exists('g:loaded_vim_project') | finish | endif

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
    if has('nvim')
        let g:vim_project_paths = projects
        lua require'vim-project'.open_floating_window()
    else
        let options = map(copy(projects), "(v:key+1) . ') ' . v:val")
        let option = inputlist(options)
        if option != 0
            let path = get(projects, option-1, '')
            if strlen(path) > 0
                call s:ProjectOpen(path)
            end
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

nnoremap <silent> <leader>pa :ProjectAdd<CR>
nnoremap <silent> <leader>pr :ProjectRemove<CR>
nnoremap <silent> <leader>po :ProjectOpen<CR>

command! -bar ProjectAdd    :call s:ProjectAdd()
command! -bar ProjectRemove :call s:ProjectRemove()
command! -bar ProjectOpen   :call s:ProjectList()

let g:loaded_vim_project = 1
