# vim-project

Manages projects, like emacs. Only three functions:

- *ProjectAdd* (`<leader>pa`) adds the current directory* to the list of
    projects.
- *ProjectRemove* (`<leader>pr`) remove the current directory* from the list of
    projects.
- *ProjectOpen* (`<leader>po`) opens a selection list so you can choose a
    project. Vim will cd to it, delete all buffers, and run `Files` if fzf is
    installed or `Explore` otherwise.

\* current directory means parent git directory, if one is found, and cwd
    otherwise.

## Installation

vim-plug:
Add `Plug 'acristoffers/vim-project'` to your .vimrc and run `PlugInstall`

## License

The MIT License (MIT)

Copyright (c) 2020 Álan Crístoffer e Sousa

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
