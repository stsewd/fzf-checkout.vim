" Global settings
let g:fzf_checkout_git_bin = get(g:, 'fzf_checkout_git_bin', 'git')
let g:fzf_checkout_git_options = get(g:, 'fzf_checkout_git_options', '')
let g:fzf_checkout_previous_ref_first = get(g:, 'fzf_checkout_previous_ref_first', v:true)

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

let s:branch_command = s:prefix . 'GBranches'
let s:tag_command = s:prefix . 'GTags'

execute 'command! -bang -nargs=0 ' . s:branch_checkout_command . ' call fzf_checkout#list(<bang>0, "branch", "")'
execute 'command! -bang -nargs=0 ' . s:tag_checkout_command . ' call fzf_checkout#list(<bang>0, "tag", "")'

" TODO: autocomplete actions
execute 'command! -bang -nargs=? ' . s:branch_command . ' call fzf_checkout#list(<bang>0, "branch", <q-args>)'
execute 'command! -bang -nargs=? ' . s:tag_command . ' call fzf_checkout#list(<bang>0, "tag", <q-args>)'
