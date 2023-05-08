let g:tmuxcnf   = '-f \"' . $HOME . "/.tmux.conf" . '\"'
let g:inPasteMode = 0

if !exists("g:inTmux")
  let g:inTmux = 0
endif

function! WarningMsg(wmsg)
  echohl WarningMsg
  echomsg a:wmsg
  echohl Normal
endfunction

function! StartCondaShell()
  call VimuxRunCommand("if [[ $CONDAENVSEL ]]; then source $CONDAENVSEL; elif [ -x ~/.vim/bundle/coshipy/plugin/conda_env_sel.sh ]; then source ~/.vim/bundle/coshipy/plugin/conda_env_sel.sh; else echo \"conda_env_sel.sh was not found or doesn\'t have execution privileges and \$CONDAENVSEL is unset.\"; fi")
endfunction

function! StopCondaShell()
  call CondaShellExitPasteEnv()
  call VimuxRunCommand("exit")
  call VimuxRunCommand("conda deactivate")
endfunction

function! CondaShellEnterPasteEnv()
  if !g:inPasteMode && !g:pysparkMode
    let g:inPasteMode = 1
    call VimuxRunCommand(":paste\r")
  endif
endfunction

function! CondaShellExitPasteEnv()
  if g:inPasteMode && !g:pysparkMode
    call VimuxRunCommand("C-d")
    let g:inPasteMode = 0
  endif
endfunction

function! CondaShellSendMultiLine() range
  call CondaShellEnterPasteEnv()
  for ind in range(a:firstline,a:lastline)
    let line = substitute(substitute(escape(escape(getline(ind),'\'),'`'),"\t","  ",'g')," *$","",'g')
    let sline = split(line)
    if g:pysparkMode
      let sline = sline + ['']
    endif
    if len(sline) > 0
      " stupid way of getting first non-white space character of the line
      if sline[0][0] !~ '/\|*\|#'
        call VimuxRunCommand(line)
      endif
    endif
  endfor
  call CondaShellExitPasteEnv()
endfunction

function! CondaShellSendLine()
  let line = substitute(substitute(escape(escape(getline('.'),'\'),'`'),"\t","  ",'g')," *$","",'g')
    call VimuxRunCommand(line)
endfunction

function! CondaShellSendKey(key)
	call VimuxRunCommand(a:key)
endfunction
