" Global settings
let g:fzf_checkout_git_bin = get(g:, 'fzf_checkout_git_bin', 'git')
let g:fzf_checkout_git_options = get(g:, 'fzf_checkout_git_options', '')
let g:fzf_checkout_previous_ref_first = get(g:, 'fzf_checkout_previous_ref_first', v:true)
let g:fzf_checkout_merge_settings = get(g:, 'fzf_checkout_merge_settings', v:true)
let g:fzf_checkout_use_current_buf_cwd = get(g:, 'fzf_checkout_use_current_buf_cwd', v:false)

let s:branch_actions = {
      \ 'checkout': {
      \   'prompt': 'Checkout> ',
      \   'execute': 'echo system("{git} -C {cwd} checkout {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'enter',
      \   'required': ['branch'],
      \   'confirm': v:false,
      \ },
      \ 'track': {
      \   'prompt': 'Track> ',
      \   'execute': 'echo system("{git} -C {cwd} checkout --track {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'alt-enter',
      \   'required': ['branch'],
      \   'confirm': v:false,
      \ },
      \ 'create': {
      \   'prompt': 'Create> ',
      \   'execute': 'echo system("{git} -C {cwd} checkout -b {input}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-b',
      \   'required': ['input'],
      \   'confirm': v:false,
      \ },
      \ 'delete': {
      \   'prompt': 'Delete> ',
      \   'execute': 'echo system("{git} -C {cwd} branch -D {branch}")',
      \   'multiple': v:true,
      \   'keymap': 'ctrl-d',
      \   'required': ['branch'],
      \   'confirm': v:true,
      \ },
      \ 'merge':{
      \   'prompt': 'Merge> ',
      \   'execute': 'echo system("{git} -C {cwd} merge {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-e',
      \   'required': ['branch'],
      \   'confirm': v:true,
      \ },
      \ 'rebase':{
      \   'prompt': 'Rebase> ',
      \   'execute': 'echo system("{git} -C {cwd} rebase {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-r',
      \   'required': ['branch'],
      \   'confirm': v:true,
      \ },
      \}

let s:tag_actions = {
      \ 'checkout': {
      \   'prompt': 'Checkout> ',
      \   'execute': 'echo system("{git} -C {cwd} checkout {tag}")',
      \   'multiple': v:false,
      \   'keymap': 'enter',
      \   'required': ['tag'],
      \   'confirm': v:false,
      \ },
      \ 'create': {
      \   'prompt': 'Create> ',
      \   'execute': 'echo system("{git} -C {cwd} tag {input}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-b',
      \   'required': ['input'],
      \   'confirm': v:false,
      \ },
      \ 'delete': {
      \   'prompt': 'Delete> ',
      \   'execute': 'echo system("{git} -C {cwd} tag -d {tag}")',
      \   'multiple': v:true,
      \   'keymap': 'ctrl-d',
      \   'required': ['tag'],
      \   'confirm': v:true,
      \ },
      \}

if g:fzf_checkout_merge_settings
  for [s:action, s:value] in items(get(g:, 'fzf_branch_actions', {}))
    if has_key(s:branch_actions, s:action)
      call extend(s:branch_actions[s:action], s:value)
    else
      let s:branch_actions[s:action] = s:value
    endif
  endfor

  for [s:action, s:value] in items(get(g:, 'fzf_tag_actions', {}))
    if has_key(s:tag_actions, s:action)
      call extend(s:tag_actions[s:action], s:value)
    else
      let s:tag_actions[s:action] = s:value
    endif
  endfor

  let g:fzf_branch_actions = s:branch_actions
  let g:fzf_tag_actions = s:tag_actions
else
  let g:fzf_branch_actions = get(g:, 'fzf_branch_actions', s:branch_actions)
  let g:fzf_tag_actions = get(g:, 'fzf_tag_actions', s:tag_actions)
endif


let s:prefix = get(g:, 'fzf_command_prefix', '')
let s:branch_command = s:prefix . 'GBranches'
let s:tag_command = s:prefix . 'GTags'
execute 'command! -bang -nargs=* -complete=custom,fzf_checkout#complete_branches ' . s:branch_command . ' call fzf_checkout#list(<bang>0, "branch", <q-args>)'
execute 'command! -bang -nargs=? -complete=custom,fzf_checkout#complete_tags ' . s:tag_command . ' call fzf_checkout#list(<bang>0, "tag", <q-args>)'
