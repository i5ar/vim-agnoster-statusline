" Filename: plugin/agnoster.vim
" Author: https://github.com/i5ar
" Version: 0.0.2
" License: MIT License
" Last Change: 2017/12/01.


" Statusline inspired by Agnoster Zsh theme
" Ignore *.swp file and prevent conflict with branch status on write
if &swapfile =~# 1
  set noswapfile
endif

" Symbols for Powerline terminals
let g:powerline_left_sep="\ue0b0"
" let g:powerline_left_alt_sep="\ue0b1"
let g:powerline_right_sep="\ue0b2"
let g:powerline_right_alt_sep="\ue0b3"
" let g:powerline_readonly="\ue0a2"
" let g:powerline_line_num="\ue0a1"
let g:powerline_branch="\ue0a0"
" let g:powerline_column_num="\ue0a3"
let g:plusminus= "\u00b1"
let g:detached="\u27a6"
" let g:cross="\u2718"
" let g:lightning="\u26a1"
" let g:gear="\u2699"
" let g:circle="\u25cf"
" let g:plus="\u271a"
let g:opencentre="\u271c"

" Determine server name or terminal color
function! GetTerminal()
  if (strlen(v:servername)>0)
    if v:servername =~ 'nvim'
        let l:terminal_session = 'neovim'
    else
      let l:terminal_session = v:servername
    endif
  elseif !has('gui_running')
    let l:terminal_session = exists("$COLORTERM") ? $COLORTERM : $TERM
  else
    let l:terminal_session = 'agnoster'
  endif
  return l:terminal_session
endfunction

function! IsInsideWorkTreeGit()
  let l:work_tree=system("git rev-parse --is-inside-work-tree 2>/dev/null | tr -d '\n'")
  return strlen(l:work_tree) > 0?1:0
endfunction

function! IsDetachedGit()
  let l:ref_symbolic=system("git symbolic-ref HEAD 2>/dev/null | tr -d '\n'")  " symbolic (refs/heads/master)
  return strlen(l:ref_symbolic) == 0?1:0
endfunction

" TODO: Replace generic dirty git with BISECT_LOG, MERGE_HEAD and rebase
function! IsDirtyGit()
  let l:git_status=system("git status --porcelain --ignore-submodules")
  return strlen(l:git_status) > 0?1:0
endfunction

" Get branch name
function! BranchGit()
  if IsInsideWorkTreeGit()
    let l:repo_path=system("git rev-parse --git-dir 2>/dev/null")  " path of the .git directory
    " let l:ref=system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")  " abbrev (HEAD)
    " let l:ref=system("echo -n $vcs_info_msg_0_")  " require vcs_info package
    let l:ref_short=system("git rev-parse --short HEAD 2> /dev/null | tr -d '\n'")  " short (f32e741)
    let l:ref_symbolic=system("git symbolic-ref HEAD 2>/dev/null | tr -d '\n'")  " symbolic (refs/heads/master)

    if IsDetachedGit()
      let l:ref=l:ref_short  " short (f32e741)
      let l:branchname=g:detached."\ ".l:ref
    else
      let l:ref=substitute(l:ref_symbolic, 'refs\/heads\/', '', '')  " branch name (master)
      let l:branchname=g:powerline_branch."\ ".l:ref
    endif
    " execute 'echo "'.l:ref_symbolic.'"'

    if IsDirtyGit()
      let l:branchname=l:branchname."\ ".g:opencentre
    else
      let l:branchname=l:branchname
    endif

    return strlen(l:ref) > 0?l:branchname:''
  endif
endfunction

" Syntax highlighting
" https://superuser.com/questions/844004/
" https://stackoverflow.com/questions/9065941/
function! SetStatuslineHighlight()
  highlight DirBlue guibg=Blue ctermfg=0 guifg=Black ctermbg=4
  highlight BarBlack guibg=Black ctermfg=9 guifg=Orange ctermbg=0
  highlight BarBlackWhite guibg=Black ctermfg=12 guifg=White ctermbg=0
  highlight BarWhiteBlackPowerline guibg=Black ctermfg=12 guifg=White ctermbg=0
  highlight BarWhiteBlack guibg=White ctermfg=0 guifg=Black ctermbg=12
  highlight BarMagentaPowerline guibg=White ctermfg=5 guifg=Magenta ctermbg=12
  highlight BarMagenta guibg=Magenta ctermfg=0 guifg=Black ctermbg=5
  " highlight VimModePowerline guibg=Magenta ctermfg=2 guifg=Green ctermbg=5
  highlight VimModePowerline guibg=White ctermfg=2 guifg=Green ctermbg=12
  highlight VimMode guibg=Yellow ctermfg=12 guifg=White ctermbg=3
  if strlen(BranchGit()) > 0 && IsDirtyGit()
    highlight DirStatusPowerline guibg=Yellow ctermfg=4 guifg=Blue ctermbg=3
    highlight GitStatus guibg=Yellow ctermfg=0 guifg=Black ctermbg=3
    highlight GitStatusPowerline guibg=Black ctermfg=3 guifg=Yellow ctermbg=0
  elseif strlen(BranchGit()) > 0 && !IsDirtyGit()
    highlight DirStatusPowerline guibg=Green ctermfg=4 guifg=Blue ctermbg=2
    highlight GitStatus guibg=Green ctermfg=0 guifg=Black ctermbg=2
    highlight GitStatusPowerline guibg=Black ctermfg=2 guifg=Green ctermbg=0
  else
    highlight DirStatusPowerline guibg=Black ctermfg=4 guifg=Blue ctermbg=0
  endif
endfunction

call SetStatuslineHighlight()

" Update Vim mode
function! Mode()
  redraw
  let l:mode = mode()
  if mode ==# "n"
    " Update segment color
    exec 'highlight VimModePowerline guibg=White ctermfg=2 guifg=Green ctermbg=12'
    exec 'highlight VimMode guibg=Green ctermfg=0 guifg=Black ctermbg=2'
    " Convert status notifier to words
    return "NORMAL"
  elseif mode ==# "i"
    exec 'highlight VimModePowerline guibg=White ctermfg=4 guifg=Blue ctermbg=12'
    exec 'highlight VimMode guibg=Blue ctermfg=0 guifg=Black ctermbg=4'
    return "INSERT"
  elseif mode ==# "R"
    exec 'highlight VimModePowerline guibg=White ctermfg=1 guifg=Red ctermbg=12'
    exec 'highlight VimMode guibg=Red ctermfg=0 guifg=Black ctermbg=1'
    return "REPLACE"
  elseif mode ==# "v"
    exec 'highlight VimModePowerline guibg=White ctermfg=9 guifg=Orange ctermbg=12'
    exec 'highlight VimMode guibg=Orange ctermfg=0 guifg=Black ctermbg=9'
    return "VISUAL"
  elseif mode ==# "V"
    exec 'highlight VimModePowerline guibg=White ctermfg=9 guifg=Orange ctermbg=12'
    exec 'highlight VimMode guibg=Orange ctermfg=0 guifg=Black ctermbg=9'
    return "VISUAL LINE"
  " FIXME: Enter Visual Block mode
  elseif mode ==# ""
    exec 'highlight VimModePowerline guibg=White ctermfg=9 guifg=Orange ctermbg=12'
    exec 'highlight VimMode guibg=Orange ctermfg=0 guifg=Black ctermbg=9'
    return "VISUAL BLOCK"
  " TODO: Add Select mode
  else
    return l:mode
  endif
endfunction

function! UpdateStatusline()
  set statusline=
  set statusline+=%#DirBlue#
  " set statusline+=\ %{getcwd()}\  " full path working directory
  " set statusline+=\ %{expand('%:~:h')}\  " file directory containing head
  set statusline+=\ %{fnamemodify(getcwd(),':~:.')}\  " working directory

  set statusline+=%#DirStatusPowerline#
  set statusline+=%{g:powerline_left_sep}

  if strlen(BranchGit()) > 0
    set statusline+=%#GitStatus#
    set statusline+=\ %{BranchGit()}\  " branch
    set statusline+=%#GitStatusPowerline#
    set statusline+=%{g:powerline_left_sep}
  endif

  set statusline+=%#BarBlack#
  " set statusline+=\ %{expand('%:t')}\  " file name
  set statusline+=\ %.32f\  " relative path
  set statusline+=%=  " align right

  " Datatime
  set statusline+=%#BarBlackWhite#
  set statusline+=%{g:powerline_right_alt_sep}
  set statusline+=\ %{&filetype}\  " programming language
  set statusline+=%{g:powerline_right_alt_sep}
  set statusline+=\ %{&fileencoding?&fileencoding:&encoding}\  " encoding
  set statusline+=%{g:powerline_right_alt_sep}
  set statusline+=\ %{&fileformat}\  " unix
  set statusline+=%#BarWhiteBlackPowerline#
  set statusline+=%{g:powerline_right_sep}
  set statusline+=%#BarWhiteBlack#
  set statusline+=\ %p%%\  " mouse position in percentage
  set statusline+=%{g:powerline_right_alt_sep}
  set statusline+=\ %l:%c\  " line:column

  " Terminal
  " set statusline+=%#BarMagentaPowerline#
  " set statusline+=%{g:powerline_right_sep}
  " set statusline+=%#BarMagenta#
  " set statusline+=\ %{GetTerminal()}\  " terminal

  " Mode
  " set statusline+=%#VimModePowerline#
  " set statusline+=%{g:powerline_right_sep}
  " set statusline+=%#VimMode#
  " set statusline+=\ %{Mode()}\  " mode

endfunction

call UpdateStatusline()

" HACK: Fix the vte bug on GNOME Terminal
" https://askubuntu.com/questions/855080/
" if has("unix")
"   au VimEnter * silent execute '!echo -ne "\e[ q"'  " cursor
" endif

" Update Statusline
au BufWritePost * call SetStatuslineHighlight()
au BufWritePost * call UpdateStatusline()
