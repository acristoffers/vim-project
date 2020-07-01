-- The MIT License (MIT)
--
-- Copyright (c) 2020 Álan Crístoffer
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local api = vim.api
local cmd = api.nvim_command

local current_index = 1;

local function go_up()
    current_index = current_index - 1
    if current_index < 1 then
        current_index = 1
    end
    cmd('call cursor(' .. current_index + 4 .. ',6)')
end

local function go_down()
    local paths = api.nvim_get_var("vim_project_paths")
    current_index = current_index + 1
    if current_index >= #paths then
        current_index = #paths
    end
    cmd('call cursor(' .. current_index + 4 .. ',6)')
end

local function close()
    current_index = 1
    cmd('q')
    cmd('set modifiable')
    cmd('set noreadonly')
end

local function open(index)
    if index then
        current_index = index
    end
    local paths = api.nvim_get_var("vim_project_paths")
    local path = paths[current_index]
    close()
    cmd('%bd')
    api.nvim_set_current_dir(path)
    cmd("if &rtp =~ 'fzf' | execute 'Files' | else | execute 'Explore' | endif")
end

local function open_floating_window()
    local lines = api.nvim_get_option("lines") - 2
    local columns = api.nvim_get_option("columns")

    local width = math.ceil(0.9 * columns)
    local height = math.ceil(0.9 * lines)

    local row = math.ceil(lines - height) / 2
    local col = math.ceil(columns - width) / 2

    local border_opts = {
        style = "minimal",
        relative = "editor",
        row = row - 1,
        col = col - 1,
        width = width + 2,
        height = height + 2,
    }

    local opts = {
        style = "minimal",
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
    }

    local border_lines = {'╭' .. string.rep('─', width) .. '╮'}
    local middle_line = '│' .. string.rep(' ', width) .. '│'
    for i = 1, height do
        table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, '╰' .. string.rep('─', width) .. '╯')

    -- create an unlisted scratch buffer for the border
    local border_buffer = api.nvim_create_buf(false, true)

    -- create border window
    local border_window = api.nvim_open_win(border_buffer, true, border_opts)

    -- set border_lines in the border buffer from start 0 to end -1 and strict_indexing false
    cmd('set modifiable')
    api.nvim_buf_set_lines(border_buffer, 0, -1, false, border_lines)

    cmd('set winhl=Normal:Floating')

    -- create an unlisted scratch buffer
    file_buffer = api.nvim_create_buf(false, true)

    -- create file window
    local file_window = api.nvim_open_win(file_buffer, true, opts)

    -- use autocommand to ensure that the border_buffer closes at the same time as the main buffer
    local cmdl = [[autocmd WinLeave <buffer> silent! execute 'silent bdelete! %s %s']]
    cmd(cmdl:format(file_buffer, border_buffer))

    local paths = api.nvim_get_var("vim_project_paths")

    lines = {'', '    Select a project to open:', '', ''}
    for i = 1, #paths do
        table.insert(lines, '    [' .. i .. '] ' .. paths[i])
        cmd('nnoremap <silent><nowait><buffer> ' ..
            i .. ' :lua require"vim-project".open(' .. i .. ')<CR>')
    end
    table.insert(lines, '')
    table.insert(lines, '    [q] Close window')

    api.nvim_buf_set_lines(file_buffer, 0, -1, true, lines)

    cmd('nnoremap <silent><buffer> <esc> :lua require"vim-project".close()<CR>')
    cmd('nnoremap <silent><buffer> q :lua require"vim-project".close()<CR>')
    cmd('nnoremap <silent><buffer> k :lua require"vim-project".go_up()<CR>')
    cmd('nnoremap <silent><buffer> j :lua require"vim-project".go_down()<CR>')
    cmd('nnoremap <silent><buffer> h k')
    cmd('nnoremap <silent><buffer> l j')
    cmd('nnoremap <silent><buffer> <CR> :lua require"vim-project".open()<CR>')
    cmd('setlocal nocursorcolumn')
    cmd('set winblend=0')
    cmd('set nomodifiable')
    cmd('set readonly')
    cmd('set buftype=nofile')
    cmd('set nobuflisted')
    cmd('set bufhidden=wipe')
    cmd('set syntax=vim-project')
    cmd('setlocal textwidth=0')
    cmd('let &l:colorcolumn=0')
    cmd('call cursor(5, 6)')

    cmd('nnoremap <buffer><nowait><silent> i             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> <insert>      <Nop>')
    cmd('nnoremap <buffer><nowait><silent> b             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> g             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> G             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> s             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> t             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> v             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> B             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> S             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> T             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> V             <Nop>')
    cmd('nnoremap <buffer><nowait><silent> <LeftMouse>   <Nop>')
    cmd('nnoremap <buffer><nowait><silent> <2-LeftMouse> <Nop>')
    cmd('nnoremap <buffer><nowait><silent> <MiddleMouse> <Nop>')
end

return {
    open_floating_window = open_floating_window,
    go_up = go_up,
    go_down = go_down,
    close = close,
    open = open
}
