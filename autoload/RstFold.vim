function s:CacheRstFold()
  let b:RstFoldCache = {}
  let header_types = {}
  let max_level = 0
  function! Process(match) closure
    let curline = getcurpos()[1]
    if has_key(b:RstFoldCache, curline - 1)
      " For over+under-lined headers, the regex will match both at the
      " overline and at the title itself; in that case, skip the second match.
      return
    endif
    let lines = split(a:match, '\n')
    let key = repeat(lines[-1][0], len(lines))
    if !has_key(header_types, key)
      let max_level += 1
      let header_types[key] = max_level
    endif
    let b:RstFoldCache[curline] = header_types[key]
  endfunction
  let save_cursor = getcurpos()
  silent keeppatterns %s/\v^%(%(([=`:.'"~^_*+#-])\1+\n)?.{1,2}\n([=`:.'"~^_*+#-])\2+)|%(%(([=`:.''"~^_*+#-])\3{2,}\n)?.{3,}\n([=`:.''"~^_*+#-])\4{2,})$/\=Process(submatch(0))/gn
  call setpos('.', save_cursor)
endfunction

function RstFold#GetRstFold()
  if !has_key(b:, 'RstFoldCache')
    call s:CacheRstFold()
  endif
  if has_key(b:RstFoldCache, v:lnum)
    return '>' . b:RstFoldCache[v:lnum]
  else
    return '='
  endif
endfunction

function RstFold#GetRstFoldText()
  if !has_key(b:, 'RstFoldCache')
    call s:CacheRstFold()
  endif
  let indent = repeat('  ', b:RstFoldCache[v:foldstart] - 1)
  let thisline = getline(v:foldstart)
  " For over+under-lined headers, skip the overline.
  let text = thisline =~ '^\([=`:.''"~^_*+#-]\)\1\+$' ? getline(v:foldstart + 1) : thisline
  return indent . text
endfunction
