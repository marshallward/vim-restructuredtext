function s:CacheRstFold()
python3 <<EOF
import vim
cb = vim.current.buffer
cache = {}
curlevel = maxlevel = 0
new = False
levels = []
for i in range(len(cb) - 1):
  chars = "".join(set(cb[i + 1]))
  if len(cb[i + 1]) >= len(cb[i]) and chars in list("=-`:.'\"~^_*+#"):
    new = True
    if chars not in cache:
      cache[chars] = maxlevel = maxlevel + 1
    curlevel = cache[chars]
  else:
    new = False
  levels.append("{}{}".format(">" if new else "", curlevel))
levels.append("{}".format(curlevel))
cb.vars["RstFoldCache"] = levels
EOF
endfunction

function RstFold#GetRstFold()
  if !has_key(b:, 'RstFoldCache')
    call s:CacheRstFold()
  endif
  return b:RstFoldCache[v:lnum - 1]
endfunction
