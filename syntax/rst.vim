" Vim reST syntax file
" Language: reStructuredText documentation format
" Maintainer: Marshall Ward <marshall.ward@gmail.com>
" Previous Maintainer: Nikolai Weibull <now@bitwi.se>
" Website: https://github.com/marshallward/vim-restructuredtext
" Latest Revision: 2020-03-31

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" reStructuredText is case-insensitive
syntax case ignore

syn match   rstTransition  /^[=`:.'"~^_*+#-]\{4,}\s*$/

"syn cluster rstCruft                contains=rstEmphasis,rstStrongEmphasis,
"      \ rstInterpretedTextOrHyperlinkReference,rstInlineLiteral,
"      \ rstSubstitutionReference, rstInlineInternalTargets,rstFootnoteReference,
"      \ rstHyperlinkReference

syn cluster rstCruft                contains=
      \ rstInterpretedTextOrHyperlinkReference,rstInlineLiteral,
      \ rstSubstitutionReference, rstInlineInternalTargets,rstFootnoteReference,
      \ rstHyperlinkReference

syn region  rstLiteralBlock         matchgroup=rstDelimiter
      \ start='\(^\z(\s*\).*\)\@<=::\n\s*\n' skip='^\s*$' end='^\(\z1\s\+\)\@!'
      \ contains=@NoSpell

syn region  rstQuotedLiteralBlock   matchgroup=rstDelimiter
      \ start="::\_s*\n\ze\z([!\"#$%&'()*+,-./:;<=>?@[\]^_`{|}~]\)"
      \ end='^\z1\@!' contains=@NoSpell

syn region  rstDoctestBlock         matchgroup=rstDoctestBlockPrompt
      \ start='^>>>\s' end='^$'
      \ contains=rstDoctestBlockPrompt

syn match   rstDoctestBlockPrompt   contained '^>>>\s'

syn region  rstTable                transparent start='^\n\s*+[-=+]\+' end='^$'
      \ contains=rstTableLines,@rstCruft
syn match   rstTableLines           contained display '|\|+\%(=\+\|-\+\)\='

syn region  rstSimpleTable          transparent
      \ start='^\n\%(\s*\)\@>\%(\%(=\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(=\+\)\@>\%(\s*\)\@>\)\+\)\@>$'
      \ end='^$'
      \ contains=rstSimpleTableLines,@rstCruft
syn match   rstSimpleTableLines     contained display
      \ '^\%(\s*\)\@>\%(\%(=\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(=\+\)\@>\%(\s*\)\@>\)\+\)\@>$'
syn match   rstSimpleTableLines     contained display
      \ '^\%(\s*\)\@>\%(\%(-\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(-\+\)\@>\%(\s*\)\@>\)\+\)\@>$'

"syn cluster rstDirectives           contains=rstFootnote,rstCitation,
"      \ rstHyperlinkTarget, rstExDirective
syn cluster rstDirectives           contains=rstFootnote,rstCitation,
      \ rstHyperlinkTarget

"syn match   rstExplicitMarkup       '^\s*\.\.\_s'
"      \ nextgroup=@rstDirectives,rstSubstitutionDefinition
"      \ contains=rstComment

" Explicit blocks "

" Denotes the beginning of an explicit block
syntax match rstExplicitBlockMarker '\.\. '
    \ nextgroup=rstDirectiveType, rstFootnoteLabel
    \ contained

" There are six types of explicit blocks:
"   - Footnotes
"   - Citations
"   - Hyperlink targets
"   - Directives
"   - Substitution definitions
"   - Comments

""" Footnotes

" A footnote label can be:
"  - a whole decimal number consisting of one or more digits,
"  - a single # (denoting auto-numbered footnotes),
"  - a # followed by a simple reference name (an autonumber label), or
"  - a single * (denoting auto-symbol footnotes).

syntax match rstFootnoteLabel
    \ '\%(\d\+\|#\%([[:alnum:]]\%([-_+:.]\?[[:alnum:]]\+\)*\)\=\|\*\)'

" Not in the standard, but it prevents footnote label highlights in the body.
syntax match rstFootnoteMarker
    \ '\.\. \[\%(\d\+\|#\%([[:alnum:]]\%([-_+:.]\?[[:alnum:]]\+\)*\)\=\|\*\)\]'
    \ contains=rstExplicitBlockMarker, rstFootnoteLabel

syntax region rstFootnoteNew
    \ start='^\z\(\s*\)\.\. \[\%(\d\+\|#\%([[:alnum:]]\%([-_+:.]\?[[:alnum:]]\+\)*\)\=\|\*\)\]'
    \ skip='^$'
    \ end='^\(\z1 \)\@!'
    \ contains=rstFootnoteMarker


""" Directives

" Directive types are case-insensitive single words (alphanumerics plus
" isolated internal hyphens, underscores, plus signs, colons, and periods; no
" whitespace).
syntax match rstDirectiveType
    \ '[[:alnum:]]\%([-_+:.]\?[[:alnum:]]\+\)*'
    \ contained

" Directives are indicated by an explicit markup start (.. ) followed by the
" directive type, two colons, and whitespace (together called the *directive
" marker*).
syntax match rstDirectiveMarker
    \ '\.\. [[:alnum:]]\%([-_+:.]\?[[:alnum:]]\+\)*::'
    \ contains=rstExplicitBlockMarker,rstDirectiveType
    \ contained

" TODO: Match directive block (arguments, options, content)

syntax region rstDirectiveNew
    \ start='^\z\(\s*\)\.\. [[:alnum:]]\%([-_+:.]\?[[:alnum:]]\+\)*::'
    \ skip='^$'
    \ end='^\(\z1 \)\@!'
    \ contains=rstDirectiveMarker

" "Simple reference names are single words consisting of alphanumerics plus
" isolated (no two adjacent) internal hyphens, underscores, periods, colons
" and plus signs."
let s:ReferenceName = '[[:alnum:]]\%([-_.:+]\?[[:alnum:]]\+\)*'

"syn match rstDirectiveType '[[:alnum:]]\%([-_.:+]\?[[:alnum:]]\+\)*'
"    \ contained

syn keyword rstTodo contained FIXME TODO XXX NOTE

syn region rstComment
      \ start='\v^\z(\s*)\.\.(\_s+[\[|_]|\_s+.*::)@!' skip=+^$+ end=/^\(\z1   \)\@!/
      \ contains=@Spell,rstTodo

" Note: Order matters for rstCitation and rstFootnote as the regex for
" citations also matches numeric only patterns, e.g. [1], which are footnotes.
" Since we define rstFootnote after rstCitation, it takes precedence, see
" |:syn-define|.
execute 'syn region rstCitation contained matchgroup=rstDirective' .
      \ ' start=+\[' . s:ReferenceName . '\]\_s+' .
      \ ' skip=+^$+' .
      \ ' end=+^\s\@!+ contains=@Spell,@rstCruft'

"execute 'syn region rstFootnote contained matchgroup=rstDirective' .
"      \ ' start=+\[\%(\d\+\|#\%(' . s:ReferenceName . '\)\=\|\*\)\]\_s+' .
"      \ ' skip=+^$+' .
"      \ ' end=+^\s\@!+ contains=@Spell,@rstCruft'

syn region rstHyperlinkTarget contained matchgroup=rstDirective
      \ start='_\%(_\|[^:\\]*\%(\\.[^:\\]*\)*\):\_s' skip=+^$+ end=+^\s\@!+

syn region rstHyperlinkTarget contained matchgroup=rstDirective
      \ start='_`[^`\\]*\%(\\.[^`\\]*\)*`:\_s' skip=+^$+ end=+^\s\@!+

syn region rstHyperlinkTarget matchgroup=rstDirective
      \ start=+^__\_s+ skip=+^$+ end=+^\s\@!+

"execute 'syn region rstExDirective contained matchgroup=rstDirective' .
"      \ ' start=+' . s:ReferenceName . '::\_s+' .
"      \ ' skip=+^$+' .
"      \ ' end=+^\s\@!+ contains=@Spell,@rstCruft,rstLiteralBlock,rstExplicitMarkup'

"syn region rstExDirective
"      \ start=+^\z(\s*\)\.\. [[:alnum:]]\%([-_.:+]\?[[:alnum:]]\+\)*::\_s+
"      \ skip=+^$+
"      \ end=+^\(\z1 \)\@!+
"      \ contains=@Spell,@rstCruft,rstExplcitMarkup,rstDirectiveName

execute 'syn match rstSubstitutionDefinition contained' .
      \ ' /|.*|\_s\+/ nextgroup=@rstDirectives'


"" Inline Markup ""

function! s:DefineOneInlineMarkup(name, start, middle, end, char_left, char_right)
  " Only escape the first char of a multichar delimiter (e.g. \* inside **)
  if a:start[0] == '\'
    let first = a:start[0:1]
  else
    let first = a:start[0]
  endif

  if a:start != '``'
    let rst_contains=' contains=@Spell,rstEscape' . a:name
    execute 'syn match rstEscape'.a:name.' +\\\\\|\\'.first.'+'.' contained'
  else
    let rst_contains=' contains=@Spell'
  endif

  execute 'syn region rst' . a:name .
        \ ' start=+' . a:char_left . '\zs' . a:start .
        \ '\ze[^[:space:]' . a:char_right . a:start[strlen(a:start) - 1] . ']+' .
        \ a:middle .
        \ ' end=+' . a:end . '\ze\%($\|\s\|[''"’)\]}>/:.,;!?\\-]\)+' .
        \ rst_contains

  if a:start != '``'
    execute 'hi def link rstEscape'.a:name.' Special'
  endif
endfunction

" TODO: The "middle" argument may no longer be useful here.
function! s:DefineInlineMarkup(name, start, middle, end)
  if a:middle == '`'
    let middle = ' skip=+\s'.a:middle.'+'
  else
    let middle = ' skip=+\\\\\|\\' . a:middle . '\|\s' . a:middle . '+'
  endif

  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, "'", "'")
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '"', '"')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '(', ')')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '\[', '\]')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '{', '}')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '<', '>')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '’', '’')

  " TODO: Additional whitespace Unicode characters: Pd, Po, Pi, Pf, Ps
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '\%(^\|\s\|\%ua0\|[/:]\)', '')

  execute 'syn match rst' . a:name .
        \ ' +\%(^\|\s\|\%ua0\|[''"([{</:]\)\zs' . a:start .
        \ '[^[:space:]' . a:start[strlen(a:start) - 1] . ']'
        \ a:end . '\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)+'

  execute 'hi def link rst' . a:name . 'Delimiter' . ' rst' . a:name
endfunction

call s:DefineInlineMarkup('Emphasis', '\*', '\*', '\*')
call s:DefineInlineMarkup('StrongEmphasis', '\*\*', '\*', '\*\*')
call s:DefineInlineMarkup('InterpretedTextOrHyperlinkReference', '`', '`', '`_\{0,2}')
call s:DefineInlineMarkup('InlineLiteral', '``', '`', '``')
call s:DefineInlineMarkup('SubstitutionReference', '|', '|', '|_\{0,2}')
call s:DefineInlineMarkup('InlineInternalTargets', '_`', '`', '`')

" Sections are identified through their titles, which are marked up with
" adornment: "underlines" below the title text, or underlines and matching
" "overlines" above the title. An underline/overline is a single repeated
" punctuation character that begins in column 1 and forms a line extending at
" least as far as the right edge of the title text.
"
" It is difficult to count characters in a regex, but we at least special-case
" the case where the title has at least three characters to require the
" adornment to have at least three characters as well, in order to handle
" properly the case of a literal block:
"
"    this is the end of a paragraph
"    ::
"       this is a literal block
syn match   rstSections "\v^%(([=`:.'"~^_*+#-])\1+\n)?.{1,2}\n([=`:.'"~^_*+#-])\2+$"
    \ contains=@Spell
syn match   rstSections "\v^%(([=`:.'"~^_*+#-])\1{2,}\n)?.{3,}\n([=`:.'"~^_*+#-])\2{2,}$"
    \ contains=@Spell

" TODO: Can’t remember why these two can’t be defined like the ones above.
execute 'syn match rstFootnoteReference contains=@NoSpell' .
      \ ' +\%(\s\|^\)\[\%(\d\+\|#\%(' . s:ReferenceName . '\)\=\|\*\)\]_+'

execute 'syn match rstCitationReference contains=@NoSpell' .
      \ ' +\%(\s\|^\)\[' . s:ReferenceName . '\]_\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)+'

execute 'syn match rstHyperlinkReference' .
      \ ' /\<' . s:ReferenceName . '__\=\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)/'

syn match   rstStandaloneHyperlink  contains=@NoSpell
      \ "\<\%(\%(\%(https\=\|file\|ftp\|gopher\)://\|\%(mailto\|news\):\)[^[:space:]'\"<>]\+\|www[[:alnum:]_-]*\.[[:alnum:]_-]\+\.[^[:space:]'\"<>]\+\)[[:alnum:]/]"

" `code` is the standard reST directive for source code.
" `code-block` is a nearly identical directive in Sphinx.
" `sourcecode` used to be supported, but I could not determine its origin so
" it was removed.

"syn region rstCodeBlock contained matchgroup=rstDirective
"      \ start=+\%(code\%(-block\)\=\)::\s*\(\S*\)\?\s*\n\%(\s*:.*:\s*.*\s*\n\)*\n\ze\z(\s\+\)+
"      \ skip=+^$+
"      \ end=+^\z1\@!+
"      \ contains=@NoSpell
"syn cluster rstDirectives add=rstCodeBlock

syn region rstCodeBlock contained matchgroup=rstDirective
      \ start='\%(code\%(-block\)\=\)::'
      \ skip='^$'
      \ end='^\z1\@!'
      \ contains=@NoSpell,rstDirectiveMarker

if !exists('g:rst_syntax_code_list')
    " A mapping from a Vim filetype to a list of alias patterns (pattern
    " branches to be specific, see ':help /pattern'). E.g. given:
    "
    "   let g:rst_syntax_code_list = {
    "       \ 'cpp': ['cpp', 'c++'],
    "       \ }
    "
    " then the respective contents of the following two rST directives:
    "
    "   .. code:: cpp
    "
    "       auto i = 42;
    "
    "   .. code:: C++
    "
    "       auto i = 42;
    "
    " will both be highlighted as C++ code. As shown by the latter block
    " pattern matching will be case-insensitive.
    let g:rst_syntax_code_list = {
        \ 'vim': ['vim'],
        \ 'java': ['java'],
        \ 'cpp': ['cpp', 'c++'],
        \ 'lisp': ['lisp'],
        \ 'php': ['php'],
        \ 'python': ['python'],
        \ 'perl': ['perl'],
        \ 'sh': ['sh'],
        \ }
elseif type(g:rst_syntax_code_list) == type([])
    " backward compatibility with former list format
    let s:old_spec = g:rst_syntax_code_list
    let g:rst_syntax_code_list = {}
    for s:elem in s:old_spec
        let g:rst_syntax_code_list[s:elem] = [s:elem]
    endfor
endif

for s:filetype in keys(g:rst_syntax_code_list)
    unlet! b:current_syntax
    " guard against setting 'isk' option which might cause problems (issue #108)
    let prior_isk = &l:iskeyword
    let s:alias_pattern = ''
                \.'\%('
                \.join(g:rst_syntax_code_list[s:filetype], '\|')
                \.'\)'

    syntax sync clear
    exe 'syn include @rst'.s:filetype.' syntax/'.s:filetype.'.vim'
    "exe 'syn region rstDirective'.s:filetype
    "            \.' matchgroup=rstDirective fold'
    "            \.' start="\c\%(sourcecode\|code\%(-block\)\=\)::\s\+'.s:alias_pattern.'\_s*\n\ze\z(\s\+\)"'
    "            \.' skip=#^$#'
    "            \.' end=#^\z1\@!#'
    "            \.' contains=@NoSpell,@rst'.s:filetype
    exe 'syn region rstDirective'.s:filetype
                \.' matchgroup=rstDirective fold'
                \.' start=#^\z(\s*\)\.\. \%(sourcecode\|code\%(-block\)\=\)::\s\+'.s:alias_pattern.'\_s*\n\ze\z(\s\+\)#'
                \.' skip=#^$#'
                \.' end=#^\(\z1 \)\@!#'
                \.' contains=@NoSpell,@rst'.s:filetype
    exe 'syn cluster rstDirectives add=rstDirective'.s:filetype

    " reset 'isk' setting, if it has been changed
    if &l:iskeyword !=# prior_isk
        let &l:iskeyword = prior_isk
    endif
    unlet! prior_isk
endfor


" Enable top level spell checking
syntax spell toplevel

" TODO: Use better syncing.
syn sync minlines=50 linebreaks=2

hi def link rstTodo                         Todo
hi def link rstComment                      Comment
hi def link rstSections                     Title
hi def link rstTransition                   rstSections
hi def link rstLiteralBlock                 String
hi def link rstQuotedLiteralBlock           String
hi def link rstExDirective                  String
hi def link rstDoctestBlock                 PreProc
hi def link rstDoctestBlockPrompt           rstDelimiter
hi def link rstTableLines                   rstDelimiter
hi def link rstSimpleTableLines             rstTableLines
hi def link rstExplicitMarkup               rstDirective
hi def link rstDirective                    Keyword
hi def link rstFootnote                     String
hi def link rstCitation                     String
hi def link rstHyperlinkTarget              String
hi def link rstExDirective                  String
hi def link rstSubstitutionDefinition       rstDirective
hi def link rstDelimiter                    Delimiter
hi def link rstInterpretedTextOrHyperlinkReference  Identifier
hi def link rstInlineLiteral                String
hi def link rstSubstitutionReference        PreProc
hi def link rstInlineInternalTargets        Identifier
hi def link rstFootnoteReference            Identifier
hi def link rstCitationReference            Identifier
hi def link rstHyperLinkReference           Identifier
hi def link rstStandaloneHyperlink          Identifier
hi def link rstCodeBlock                    String
if exists('g:rst_use_emphasis_colors')
    " TODO: Less arbitrary color selection
    hi def rstEmphasis          ctermfg=13 term=italic cterm=italic gui=italic
    hi def rstStrongEmphasis    ctermfg=1 term=bold cterm=bold gui=bold
else
    hi def rstEmphasis          term=italic cterm=italic gui=italic
    hi def rstStrongEmphasis    term=bold cterm=bold gui=bold
endif

" Syntax rewrite...
highlight default link rstExplicitBlockMarker Operator
highlight default link rstFootnoteLabel Identifier
highlight default link rstFootnoteMarker Constant
highlight default link rstFootnoteNew Constant
highlight default link rstDirectiveType Identifier
highlight default link rstDirectiveMarker Statement
highlight default link rstDirectiveNew Constant

let b:current_syntax = "rst"

let &cpo = s:cpo_save
unlet s:cpo_save
