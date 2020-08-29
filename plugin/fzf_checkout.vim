" Global settings
let g:fzf_checkout_git_bin = get(g:, 'fzf_checkout_git_bin', 'git')
let g:fzf_checkout_git_options = get(g:, 'fzf_checkout_git_options', '')
let g:fzf_checkout_previous_ref_first = get(g:, 'fzf_checkout_previous_ref_first', v:true)

let s:branch_actions = {
      \ 'checkout': {
      \   'prompt': 'Checkout> ',
      \   'execute': 'echo system("{git} checkout {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'enter',
      \   'required': ['branch'],
      \   'confirm': v:false,
      \ },
      \ 'track': {
      \   'prompt': 'Track> ',
      \   'execute': 'echo system("{git} checkout --track {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'alt-enter',
      \   'required': ['branch'],
      \   'confirm': v:false,
      \ },
      \ 'create': {
      \   'prompt': 'Create> ',
      \   'execute': 'echo system("{git} checkout -b {input}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-n',
      \   'required': ['input'],
      \   'confirm': v:false,
      \ },
      \ 'delete': {
      \   'prompt': 'Delete> ',
      \   'execute': 'echo system("{git} branch -D {branch}")',
      \   'multiple': v:true,
      \   'keymap': 'ctrl-d',
      \   'required': ['branch'],
      \   'confirm': v:true,
      \ },
      \}

let s:tag_actions = {
      \ 'checkout': {
      \   'prompt': 'Checkout> ',
      \   'execute': 'echo system("{git} checkout {tag}")',
      \   'multiple': v:false,
      \   'keymap': 'enter',
      \   'required': ['tag'],
      \   'confirm': v:false,
      \ },
      \ 'create': {
      \   'prompt': 'Create> ',
      \   'execute': 'echo system("{git} tag {input}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-n',
      \   'required': ['input'],
      \   'confirm': v:false,
      \ },
      \ 'delete': {
      \   'prompt': 'Delete> ',
      \   'execute': 'echo system("{git} branch -D {tag}")',
      \   'multiple': v:true,
      \   'keymap': 'ctrl-d',
      \   'required': ['tag'],
      \   'confirm': v:true,
      \ },
      \}

let g:fzf_branch_actions = get(g:, 'fzf_branch_actions', s:branch_actions)
let g:fzf_tag_actions = get(g:, 'fzf_tag_actions', s:tag_actions)

" TODO: show a warning for old settings
let g:fzf_checkout_execute = get(g:, 'fzf_checkout_execute', 'system')
let g:fzf_checkout_track_execute = get(g:, 'fzf_checkout_track_execute', 'system')
let g:fzf_checkout_track_key = get(g:, 'fzf_checkout_track_key', 'alt-enter')
let g:fzf_checkout_create_execute = get(g:, 'fzf_checkout_create_execute', 'system')
let g:fzf_checkout_create_tag_execute = get(g:, 'fzf_checkout_create_tag_execute', 'system')
let g:fzf_checkout_create_key = get(g:, 'fzf_checkout_create_key', 'ctrl-n')
let g:fzf_checkout_delete_execute = get(g:, 'fzf_checkout_delete_execute', 'system')
let g:fzf_checkout_delete_tag_execute = get(g:, 'fzf_checkout_delete_tag_execute', 'system')
let g:fzf_checkout_delete_key = get(g:, 'fzf_checkout_delete_key', 'ctrl-d')


let s:prefix = get(g:, 'fzf_command_prefix', '')

" TODO: show a warning for old commands
let s:branch_checkout_command = s:prefix . 'GCheckout'
let s:tag_checkout_command = s:prefix . 'GCheckoutTag'
execute 'command! -bang -nargs=0 ' . s:branch_checkout_command . ' call fzf_checkout#list(<bang>0, "branch", "")'
execute 'command! -bang -nargs=0 ' . s:tag_checkout_command . ' call fzf_checkout#list(<bang>0, "tag", "")'

let s:branch_command = s:prefix . 'GBranches'
let s:tag_command = s:prefix . 'GTags'
execute 'command! -bang -nargs=? -complete=customlist,fzf_checkout#complete_branches ' . s:branch_command . ' call fzf_checkout#list(<bang>0, "branch", <q-args>)'
execute 'command! -bang -nargs=? -complete=customlist,fzf_checkout#complete_tags ' . s:tag_command . ' call fzf_checkout#list(<bang>0, "tag", <q-args>)'
