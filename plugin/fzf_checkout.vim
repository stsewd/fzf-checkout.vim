" Global settings
let g:fzf_checkout_git_bin = get(g:, 'fzf_checkout_git_bin', 'git')
let g:fzf_checkout_git_options = get(g:, 'fzf_checkout_git_options', '')
let g:fzf_checkout_previous_ref_first = get(g:, 'fzf_checkout_previous_ref_first', v:true)
let g:fzf_checkout_merge_settings = get(g:, 'fzf_checkout_merge_settings', v:true)

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
      \ 'merge':{
      \   'prompt': 'Merge> ',
      \   'execute': 'echo system("{git} merge {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-e',
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


let s:deprecated_options = [
      \ 'fzf_checkout_execute',
      \ 'fzf_checkout_track_execute',
      \ 'fzf_checkout_track_key',
      \ 'fzf_checkout_create_execute',
      \ 'fzf_checkout_create_tag_execute',
      \ 'fzf_checkout_create_key',
      \ 'fzf_checkout_delete_execute',
      \ 'fzf_checkout_delete_tag_execute',
      \ 'fzf_checkout_delete_key',
      \]

for s:option in s:deprecated_options
  if has_key(g:, s:option)
    echohl WarningMsg
    echomsg printf(
          \ 'The g:%s option was removed, ' .
          \ 'please use g:fzf_branch_actions and g:fzf_tag_actions instead.',
          \ s:option,
          \)
    echohl None
  endif
endfor


let s:prefix = get(g:, 'fzf_command_prefix', '')

" These commands are going to be removed soon!
" Use GBranches and GTags.
let s:branch_command = s:prefix . 'GCheckout'
let s:tag_command = s:prefix . 'GCheckoutTag'
execute 'command! -bang -nargs=0 ' . s:branch_command . ' call fzf_checkout#list(<bang>0, "branch", "", v:true)'
execute 'command! -bang -nargs=0 ' . s:tag_command . ' call fzf_checkout#list(<bang>0, "tag", "", v:true)'

let s:branch_command = s:prefix . 'GBranches'
let s:tag_command = s:prefix . 'GTags'
execute 'command! -bang -nargs=* -complete=customlist,fzf_checkout#complete_branches ' . s:branch_command . ' call fzf_checkout#list(<bang>0, "branch", <q-args>, v:false)'
execute 'command! -bang -nargs=? -complete=customlist,fzf_checkout#complete_tags ' . s:tag_command . ' call fzf_checkout#list(<bang>0, "tag", <q-args>, v:false)'
