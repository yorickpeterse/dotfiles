" Autumn is a color scheme based on, how original, the colors of the autumn
" (along with some added flavors). The original color scheme was developed
" for Komodo Edit/IDE by Yorick Peterse (that's me!) and ported to Vim by
" the following two chaps:
"
"  * Kenneth Love
"  * Chris Jones
"
" For more information go to this theme's Github page, which can be found here:
" https://github.com/YorickPeterse/Autumn.vim
"
" Author:   Yorick Peterse
" Credits:  Kenneth Love and Chris Jones, they originally ported this theme to Vim.
" License:  Creative Commons ShareAlike 3 License
"
set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "autumn"

" Vim >= 7.0 specific colors
if version >= 700
  hi Pmenu          guifg=#ffffff guibg=#202020 ctermfg=255 ctermbg=238
  hi PmenuSel       guifg=#ffffff guibg=#6B6B6B ctermfg=0 ctermbg=148
  hi ColorColumn    guibg=#444444
endif

" General colors
hi Cursor           guifg=NONE    guibg=#626262 gui=none ctermbg=241
hi Normal           guifg=#F3F2CC guibg=#292929 gui=none ctermfg=253 ctermbg=234
hi NonText          guifg=#808080 guibg=#292929 gui=none ctermfg=244 ctermbg=235
hi LineNr           guifg=#6c6c6c guibg=#292929 gui=none ctermfg=244 ctermbg=232
hi StatusLine       guifg=#292929 guibg=#6c6c6c gui=none ctermfg=253 ctermbg=238
hi StatusLineNC     guifg=#6c6c6c guibg=#292929 gui=none ctermfg=246 ctermbg=238
hi VertSplit        guifg=#444444 guibg=#292929 gui=none ctermfg=238 ctermbg=238
hi Title            guifg=#f6f3e8 guibg=NONE    gui=bold ctermfg=254 cterm=bold
hi Visual           guifg=#faf4c6 guibg=#3c414c gui=none ctermfg=254 ctermbg=4
hi SpecialKey       guifg=#808080 guibg=#343434 gui=none ctermfg=244 ctermbg=236
hi Folded           guifg=#000000 guibg=#4D4D4D gui=none
hi FoldColumn       guifg=#6c6c6c guibg=#292929 gui=none
hi SignColumn       guifg=#76443d guibg=#292929 gui=none
hi MatchParen       guifg=#EB5D49 guibg=NONE    gui=none
hi Visual           guifg=NONE    guibg=#525252 gui=none
hi Search           guifg=#000000 guibg=#FFCC32 gui=none
hi Question         guifg=#92AF72 guibg=NONE    gui=none
hi ErrorMsg         guifg=#ffffff guibg=#EB5D49 gui=none
hi Error            guifg=#ffffff guibg=#EB5D49 gui=none
hi Directory        guifg=#7895B7 guibg=NONE

" Syntax highlighting
hi Comment         guifg=#6B6B6B gui=none ctermfg=244
hi Todo            guifg=#cccccc guibg=NONE ctermfg=245
hi Boolean         guifg=#EB5D49 gui=none ctermfg=148
hi String          guifg=#92AF72 gui=none ctermfg=148
hi Identifier      guifg=#F3F2CC gui=none ctermfg=148
hi Function        guifg=#CBC983 gui=none ctermfg=255
hi Type            guifg=#eb5d49 gui=none ctermfg=103
hi Statement       guifg=#EB5D49 gui=none ctermfg=103
hi Keyword         guifg=#EB5D49 gui=none ctermfg=208
hi Constant        guifg=#F3F2CC gui=none ctermfg=208
hi Number          guifg=#B3EBBF gui=none ctermfg=208
hi PreProc         guifg=#faf4c6 gui=none ctermfg=230
hi Operator        guifg=#ffffff gui=none
hi Special         guifg=#ffffff gui=none

" Custom keywords
hi CommentDocBlock guifg=#BFBFBF guibg=NONE

" Ruby specific colors
hi rubySymbol           guifg=#E8A75C guibg=NONE
hi rubyConstant         guifg=#F3F2CC guibg=NONE
hi rubyInstanceVariable guifg=#7895B7 guibg=NONE
hi rubyClassVariable    guifg=#7895B7 guibg=NONE
hi rubyModule           guifg=#EB5D49 guibg=NONE
hi rubyClass            guifg=#EB5D49 guibg=NONE
hi rubyFunction         guifg=#CBC983 guibg=NONE
hi rubyDefine           guifg=#EB5D49 guibg=NONE
hi rubyRegexp           guifg=#E8A75C guibg=NONE

" PHP specific colors
hi phpVarSelector       guifg=#F3F2CC guibg=NONE
hi phpSpecialFunction   guifg=#CBC983 guibg=NONE
hi phpIdentifier        guifg=#7895B7 guibg=NONE
hi phpVarSelector       guifg=#7895B7 guibg=NONE
hi phpComparison        guifg=#ffffff guibg=NONE
hi phpMemberSelector    guifg=#ffffff guibg=NONE
hi phpC1Top             guifg=#ffffff guibg=NONE

" CSS specific colors
hi cssIdentifier        guifg=#F3F2CC guibg=NONE

" The css*Prop rules are used to style the properies
" for the selector. All properties, such as background
" and display will be set to the same color.
hi cssFontProp              guifg=#F3F2CC guibg=NONE
hi cssColorProp             guifg=#F3F2CC guibg=NONE
hi cssTextProp              guifg=#F3F2CC guibg=NONE
hi cssBoxProp               guifg=#F3F2CC guibg=NONE
hi cssRenderProp            guifg=#F3F2CC guibg=NONE
hi cssAuralProp             guifg=#F3F2CC guibg=NONE
hi cssGeneratedContentProp  guifg=#F3F2CC guibg=NONE
hi cssPagingProp            guifg=#F3F2CC guibg=NONE
hi cssTableProp             guifg=#F3F2CC guibg=NONE
hi cssUIProp                guifg=#F3F2CC guibg=NONE

" Styling for all the attributes. There's gotta be
" an easier way to do this :/
hi cssFontAttr             guifg=#92AF72 guibg=NONE
hi cssCommonAttr           guifg=#92AF72 guibg=NONE
hi cssColorAttr            guifg=#92AF72 guibg=NONE
hi cssTextAttr             guifg=#92AF72 guibg=NONE
hi cssBoxAttr              guifg=#92AF72 guibg=NONE
hi cssGeneratedContentAttr guifg=#92AF72 guibg=NONE
hi cssUIAttr               guifg=#92AF72 guibg=NONE

hi cssImportant            guifg=#EB5D49 guibg=NONE
hi cssColor                guifg=#B3EBBF guibg=NONE

hi cssFunctionName      guifg=#CBC983 guibg=NONE
hi cssFunction          guifg=#CBC983 guibg=NONE
hi cssClassName         guifg=#CBC983 guibg=NONE
hi cssBraces            guifg=#ffffff guibg=NONE
hi cssTagName           guifg=#CBC983 guibg=NONE

" Style rules for Diffs
hi diffAdded     guifg=#ffffff guibg=#7D9662
hi diffRemoved   guifg=#ffffff guibg=#D65340
hi diffFile      guifg=#ffffff guibg=NONE
hi diffLine      guifg=#7895B7 guibg=NONE
hi diffNoEOL     guifg=#cccccc guibg=NONE
hi diffComment   guifg=#6B6B6B guibg=NONE

hi DiffChange    guifg=#ffffff guibg=#FFCC32
hi DiffText      guifg=#ffffff guibg=#E8A75C

hi link DiffAdd    diffAdded
hi link DiffDelete diffRemoved

" HTML colors
hi htmlString         guifg=#92AF72 guibg=NONE
hi htmlTag            guifg=#F3F2CC guibg=NONE
hi htmlSpecialTagName guifg=#F3F2CC guibg=NONE
hi htmlTagN           guifg=#F3F2CC guibg=NONE
hi htmlTagName        guifg=#F3F2CC guibg=NONE
hi htmlLink           guifg=#7895B7 guibg=NONE
hi htmlArg            guifg=#CBC983 guibg=NONE

" Python specific colors
hi pythonComment      guifg=#6B6B6B guibg=NONE

" Javascript specific colors
hi javascriptNumber   guifg=#B3EBBF gui=none ctermfg=208
