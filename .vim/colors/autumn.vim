" # Autumn
"
" Autumn is a color scheme inspired by the colors you can find in the autumn.
" Originally it was written as a color scheme for Komodo IDE but was ported to
" Vim by Kenneth Love and Chris Jones. Since I moved to Vim I've made several
" changes and improvements to the color scheme, however if it wasn't for Ken and
" Chris I probably wouldn't have any clue where to start.
"
" More information about the color scheme (as well as an up to date version) can
" be found here: https://github.com/YorickPeterse/Autumn.vim
"
" ## Requirements
"
" * Vim 7 or newer (7.3 or newer is recommended)
" * A version of Vim capable of displaying lots of colors. Autumn was designed
"   to be used in combination with Gvim, Macvim or similar implementations of
"   Vim. However, Autumn does offer support for 256 color terminals but the
"   colors will look slightly different.
"
" ## Installation
"
" Assuming you've downloaded this file and placed it somewhere all you have to
" do is move it into your "color" directory:
"
"     $ cp ~/Downloads/autumn.vim ~/.vim/color/
"
" ## Supported Languages & Features
"
" Autumn supports most, if not all features provided by Vim as well as a large
" amount of programming/scripting languages such as Ruby and C. Autumn comes
" with tweaked colors for the following languages:
"
" * Ruby
" * CSS
" * HTML
" * PHP
" * Python
" * Javascript
"
" Other languages such as Java or more obscure ones such as Rust. As long as
" there's a proper syntax highlighting plugin for the language this color scheme
" should be able to handle it just fine. However, if this isn't the case feel
" free to submit patches using Github.
"
" Once installed you can activate it by running ``:color autumn`` in a Vim
" session.
"
" Authors: Yorick Peterse, Kenneth Love and Chris Jones
" License: Creative Commons ShareAlike 3 License
" Website: https://github.com/YorickPeterse/Autumn.vim
"
set background=dark

" Basic "maintenance" before setting our own colors and what not.
hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "autumn"

" Vim >= 7.0 specific colors.
if version >= 700
  hi Pmenu    guifg=#ffffff guibg=#202020 ctermfg=255 ctermbg=238
  hi PmenuSel guifg=#ffffff guibg=#6B6B6B ctermfg=0   ctermbg=148
endif

" ColorColumn is available since Vim 7.3.
if version >= 703
  hi ColorColumn guibg=#444444 ctermbg=238
endif

" General colors
hi Cursor       guifg=NONE    guibg=#626262 ctermbg=241 ctermbg=none gui=none
hi Normal       guifg=#F3F2CC guibg=#292929 ctermfg=230 ctermbg=235  gui=none
hi NonText      guifg=#808080 guibg=#292929 ctermfg=244 ctermbg=235  gui=none
hi LineNr       guifg=#6c6c6c guibg=#292929 ctermfg=242 ctermbg=235  gui=none
hi StatusLine   guifg=#292929 guibg=#6c6c6c ctermfg=235 ctermbg=242  gui=none
hi StatusLineNC guifg=#6c6c6c guibg=#292929 ctermfg=242 ctermbg=235  gui=none
hi VertSplit    guifg=#444444 guibg=#292929 ctermfg=238 ctermbg=235  gui=none
hi Title        guifg=#f6f3e8 guibg=NONE    ctermfg=7   ctermbg=none gui=bold
hi Visual       guifg=#faf4c6 guibg=#3c414c ctermfg=230 ctermbg=238  gui=none
hi SpecialKey   guifg=#808080 guibg=#343434 ctermfg=244 ctermbg=236  gui=none
hi Folded       guifg=#000000 guibg=#4D4D4D ctermfg=0   ctermbg=239  gui=none
hi FoldColumn   guifg=#6c6c6c guibg=#292929 ctermfg=242 ctermbg=235  gui=none
hi SignColumn   guifg=#76443d guibg=#292929 ctermfg=239 ctermbg=235  gui=none
hi MatchParen   guifg=#EB5D49 guibg=NONE    ctermfg=167 ctermbg=none gui=none
hi Visual       guifg=NONE    guibg=#525252 ctermbg=239 ctermbg=none gui=none
hi Search       guifg=#000000 guibg=#FFCC32 ctermfg=0   ctermbg=221  gui=none
hi Question     guifg=#92AF72 guibg=NONE    ctermfg=107 ctermbg=none gui=none
hi ErrorMsg     guifg=#ffffff guibg=#EB5D49 ctermfg=15  ctermbg=167  gui=none
hi Error        guifg=#ffffff guibg=#EB5D49 ctermfg=15  ctermbg=167  gui=none
hi Directory    guifg=#7895B7 guibg=NONE    ctermfg=103 ctermbg=none gui=none

" Commong syntax elements.
hi Comment    guifg=#6B6B6B ctermfg=242 gui=none
hi Todo       guifg=#cccccc ctermfg=252 gui=none
hi Boolean    guifg=#EB5D49 ctermfg=167 gui=none
hi String     guifg=#92AF72 ctermfg=107 gui=none
hi Identifier guifg=#F3F2CC ctermfg=230 gui=none
hi Function   guifg=#CBC983 ctermfg=186 gui=none
hi Type       guifg=#eb5d49 ctermfg=167 gui=none
hi Statement  guifg=#EB5D49 ctermfg=167 gui=none
hi Keyword    guifg=#EB5D49 ctermfg=167 gui=none
hi Constant   guifg=#F3F2CC ctermfg=230 gui=none
hi Number     guifg=#B3EBBF ctermfg=151 gui=none
hi PreProc    guifg=#faf4c6 ctermfg=230 gui=none
hi Operator   guifg=#ffffff ctermfg=15  gui=none
hi Special    guifg=#ffffff ctermfg=15  gui=none

" Ruby
hi rubySymbol           guifg=#E8A75C guibg=NONE ctermfg=179
hi rubyConstant         guifg=#F3F2CC guibg=NONE ctermfg=230
hi rubyInstanceVariable guifg=#7895B7 guibg=NONE ctermfg=103
hi rubyClassVariable    guifg=#7895B7 guibg=NONE ctermfg=103
hi rubyModule           guifg=#EB5D49 guibg=NONE ctermfg=167
hi rubyClass            guifg=#EB5D49 guibg=NONE ctermfg=167
hi rubyFunction         guifg=#CBC983 guibg=NONE ctermfg=186
hi rubyDefine           guifg=#EB5D49 guibg=NONE ctermfg=167
hi rubyRegexp           guifg=#E8A75C guibg=NONE ctermfg=179

" PHP
hi phpVarSelector     guifg=#F3F2CC guibg=NONE ctermfg=230
hi phpSpecialFunction guifg=#CBC983 guibg=NONE ctermfg=186
hi phpIdentifier      guifg=#7895B7 guibg=NONE ctermfg=103
hi phpVarSelector     guifg=#7895B7 guibg=NONE ctermfg=103
hi phpComparison      guifg=#ffffff guibg=NONE ctermfg=15
hi phpMemberSelector  guifg=#ffffff guibg=NONE ctermfg=15
hi phpC1Top           guifg=#ffffff guibg=NONE ctermfg=15

" CSS
hi cssIdentifier guifg=#F3F2CC guibg=NONE ctermfg=230

" The css*Prop rules are used to style the properies for the selector. All
" properties, such as background and display will be set to the same color.
hi cssFontProp             guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssColorProp            guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssTextProp             guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssBoxProp              guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssRenderProp           guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssAuralProp            guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssGeneratedContentProp guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssPagingProp           guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssTableProp            guifg=#F3F2CC guibg=NONE ctermfg=230
hi cssUIProp               guifg=#F3F2CC guibg=NONE ctermfg=230

" Styles for various CSS attributes.
hi cssFontAttr             guifg=#92AF72 guibg=NONE ctermfg=107
hi cssCommonAttr           guifg=#92AF72 guibg=NONE ctermfg=107
hi cssColorAttr            guifg=#92AF72 guibg=NONE ctermfg=107
hi cssTextAttr             guifg=#92AF72 guibg=NONE ctermfg=107
hi cssBoxAttr              guifg=#92AF72 guibg=NONE ctermfg=107
hi cssGeneratedContentAttr guifg=#92AF72 guibg=NONE ctermfg=107
hi cssUIAttr               guifg=#92AF72 guibg=NONE ctermfg=107
hi cssImportant            guifg=#EB5D49 guibg=NONE ctermfg=167
hi cssColor                guifg=#B3EBBF guibg=NONE ctermfg=151
hi cssFunctionName         guifg=#CBC983 guibg=NONE ctermfg=186
hi cssFunction             guifg=#CBC983 guibg=NONE ctermfg=186
hi cssClassName            guifg=#CBC983 guibg=NONE ctermfg=186
hi cssBraces               guifg=#ffffff guibg=NONE ctermfg=15
hi cssTagName              guifg=#CBC983 guibg=NONE ctermfg=186

" Diffs
hi diffAdded     guifg=#ffffff guibg=#7D9662 ctermfg=15  ctermbg=101
hi diffRemoved   guifg=#ffffff guibg=#D65340 ctermfg=15  ctermbg=167
hi diffFile      guifg=#ffffff guibg=NONE    ctermfg=15  ctermbg=none
hi diffLine      guifg=#7895B7 guibg=NONE    ctermfg=103 ctermbg=none
hi diffNoEOL     guifg=#cccccc guibg=NONE    ctermfg=252 ctermbg=none
hi diffComment   guifg=#6B6B6B guibg=NONE    ctermfg=242 ctermbg=none
hi DiffChange    guifg=#000000 guibg=#f5d67a ctermfg=0   ctermbg=222
hi DiffText      guifg=#000000 guibg=#ffedba ctermfg=0   ctermbg=229

hi link DiffAdd    diffAdded
hi link DiffDelete diffRemoved

" HTML
hi htmlString         guifg=#92AF72 guibg=NONE ctermfg=107
hi htmlTag            guifg=#F3F2CC guibg=NONE ctermfg=230
hi htmlSpecialTagName guifg=#F3F2CC guibg=NONE ctermfg=230
hi htmlTagN           guifg=#F3F2CC guibg=NONE ctermfg=230
hi htmlTagName        guifg=#F3F2CC guibg=NONE ctermfg=230
hi htmlLink           guifg=#7895B7 guibg=NONE ctermfg=103
hi htmlArg            guifg=#CBC983 guibg=NONE ctermfg=186

" Python
hi pythonComment      guifg=#6B6B6B guibg=NONE ctermfg=242

" Javascript
hi javascriptNumber   guifg=#B3EBBF ctermfg=151 gui=none ctermfg=208

" Annoy fellow Vim users by enforcing these indentation rules.
" vim: set tw=80 shiftwidth=2 softtabstop=2 tabstop=2 expandtab
