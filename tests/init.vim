set rtp+=$TEST_CWD
set rtp+=$TEST_CWD/vader.vim

" Non interactive mode
let g:fzf_branch_actions = {
      \ 'delete': {'confirm': v:false},
      \ 'merge': {'confirm': v:false},
      \}
let g:fzf_tag_actions = {
      \ 'delete': {'confirm': v:false},
      \}
