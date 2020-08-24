" Highlights {{{1

    hi! NtTag ctermfg=242 ctermbg=NONE guifg=#1E1E1E guibg=NONE cterm=NONE

    hi! NtNow ctermfg=255 ctermbg=NONE guifg=#F0F0F0 guibg=NONE cterm=NONE
    hi! NtSoon ctermfg=246 ctermbg=NONE guifg=#939393 guibg=NONE cterm=NONE
    hi! NtLater ctermfg=242 ctermbg=NONE guifg=#686868 guibg=NONE cterm=NONE

" Syntax {{{1

    syntax match NtNow     "\v\[\~\]"
    syntax match NtSoon    "\v\[-\]"
    syntax match NtLater   "\v\[ \]"

    syntax match NtTag     "\v\+([^ ]*)"
