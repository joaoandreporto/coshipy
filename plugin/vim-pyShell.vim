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

function! StartPyShell()
  call VimuxRunCommand("conda activate boschen-dsp-ctrl-plx; vipython")
endfunction

function! StopPyShell()
  call PyShellExitPasteEnv()
  call VimuxRunCommand("exit")
endfunction

function! PyShellEnterPateEnv()
  if !g:inPasteMode && !g:pysparkMode
    let g:inPasteMode = 1
    call VimuxRunCommand(":paste\r")
  endif
endfunction

function! PyShellExitPasteEnv()
  if g:inPasteMode && !g:pysparkMode
    call VimuxRunCommand("C-d")
    let g:inPasteMode = 0
  endif
endfunction

function! PyShellSendMultiLine() range
  call PyShellEnterPasteEnv()
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
  call PyShellExitPasteEnv()
endfunction

function! PyShellSendLine()
  let line = substitute(substitute(escape(escape(getline('.'),'\'),'`'),"\t","  ",'g')," *$","",'g')
    call VimuxRunCommand(line)
endfunction

function! PyShellSendKey(key)
	call VimuxRunCommand(a:key)
endfunction
