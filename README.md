# Vim Agnoster statusline

Vim Agnoster (aka Vimster) is a pleasing statusline inspired by Agnoster Zsh
theme.
It was designed to provide a consistent terminal experience around my [Agnoster Zsh theme](https://github.com/i5ar/agnoster-zsh-theme) fork.

![Screenshot](vim-agnoster-statusline.png)

## Quick start

After installing this plugin, please restart the editor.

If the statusline doesn't show up, add the following configuration to your
`~/.vimrc`:

    set laststatus=2

If the statusline is not colored modify `TERM` in your shell *rc* file:

    export TERM=xterm-256color

You also need to add the following configuration to your `~/.vimrc`:

    if !has('gui_running')
      set t_Co=256
    endif

The `showmode` hints are unnecessary because the mode information is displayed
in the statusline.
If you want to get rid of them, add the following configuration to your
`~/.vimrc`:

    set noshowmode
