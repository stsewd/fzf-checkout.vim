function! fzf_checkout#get_ref(line)
  " Get first column.
  return split(a:line)[0]
endfunction


function! s:checkout(lines)
  if len(a:lines) < 2
    return
  endif

  let l:query = a:lines[0]
  let l:key = a:lines[1]

  if l:key ==# g:fzf_checkout_create_key
    let l:branch = l:query
  elseif len(a:lines) > 2
    let l:branch = fzf_checkout#get_ref(a:lines[2])
  else
    return
  endif

  let l:branch = shellescape(l:branch)

  if l:key ==# g:fzf_checkout_track_key
    " Track remote branch
    let l:execute_options = {
          \ 'terminal': 'split | terminal {git} checkout --track {branch}',
          \ 'system': 'echo system("{git} checkout --track {branch}")',
          \ 'bang': '!{git} checkout --track {branch}',
          \}
    let l:execute_command = get(
          \ l:execute_options,
          \ g:fzf_checkout_track_execute,
          \ g:fzf_checkout_track_execute,
          \)
  elseif l:key ==# g:fzf_checkout_create_key
    " Create branch
    let l:execute_options = {
          \ 'terminal': 'split | terminal {git} checkout -b {branch}',
          \ 'system': 'echo system("{git} checkout -b {branch}")',
          \ 'bang': '!{git} checkout -b {branch}',
          \}
    let l:execute_command = get(
          \ l:execute_options,
          \ g:fzf_checkout_create_execute,
          \ g:fzf_checkout_create_execute,
          \)
  else
    " Normal checkout
    let l:execute_options = {
          \ 'terminal': 'split | terminal {git} checkout {branch}',
          \ 'system': 'echo system("{git} checkout {branch}")',
          \ 'bang': '!{git} checkout {branch}',
          \}
    let l:execute_command = get(
          \ l:execute_options,
          \ g:fzf_checkout_execute,
          \ g:fzf_checkout_execute,
          \)
  endif

  let l:execute_command = substitute(l:execute_command, '{git}', g:fzf_checkout_git_bin, 'g')
  let l:execute_command = substitute(l:execute_command, '{branch}', l:branch, 'g')
  execute l:execute_command
endfunction


function! s:get_current_ref()
  " Try to get the branch name or fallback to get the commit.
  let l:current = system('git symbolic-ref --short -q HEAD || git rev-parse --short HEAD')
  let l:current = substitute(l:current, '\n', '', 'g')
  return l:current
endfunction


function s:remove_duplicated_branches(branches) abort
    let l:filtered_branches = []

    for branch in a:branches
      let l:branch_name = strcharpart(branch, 0, stridx(branch, ' '))
      let l:found = v:false

      for added_branch in l:filtered_branches
        if strcharpart(added_branch, 0, stridx(added_branch, ' ')) ==# l:branch_name
          let l:found = v:true
          break
        endif
      endfor

      if l:found != v:true
        call add(l:filtered_branches, branch)
      endif

    endfor

    return l:filtered_branches
endfunction


" See valid atoms in
" https://github.com/git/git/blob/076cbdcd739aeb33c1be87b73aebae5e43d7bcc5/ref-filter.c#L474
const s:format = shellescape(
      \ '%(color:yellow bold)%(refname:short)  ' ..
      \ '%(color:reset)%(color:green)%(subject) ' ..
      \ '%(color:reset)%(color:green dim italic)%(committerdate:relative) ' ..
      \ '%(color:reset)%(color:blue)-> %(objectname:short)'
      \)


function! fzf_checkout#list(bang, type)
  let l:current = s:get_current_ref()

  let l:valid_keys = join([g:fzf_checkout_track_key, g:fzf_checkout_create_key], ',')

  if a:type ==# 'branch'
    let l:subcommand = 'branch --all'
    let l:name = 'GCheckout'
  else
    let l:subcommand = 'tag'
    let l:name = 'GCheckoutTag'
  endif
  let l:git_cmd = printf('%s %s --color=always --format=%s %s', g:fzf_checkout_git_bin, l:subcommand, s:format, g:fzf_checkout_git_options)

  let l:git_output = split(system(l:git_cmd), '\n')

  if g:fzf_checkout_hide_remote && a:type ==# 'branch'
    let l:formatted_output = map(l:git_output, 'substitute(v:val, "\\e\\[\[0-9;\]\\+m\\zs\\S*", {m -> fnamemodify(m[0], ":t")}, "")')
    let l:git_output = s:remove_duplicated_branches(l:formatted_output)
  endif

  " Filter to delete the current ref, and HEAD from the list.
  let l:git_output = filter(l:git_output, printf('v:val !~# "^\\S*%s" && v:val !~# "^\\S*HEAD"', escape(l:current, '/')))

  let l:options = [
        \ '--prompt', 'Checkout> ',
        \ '--header', l:current,
        \ '--nth', '1',
        \ '--expect', l:valid_keys,
        \ '--ansi',
        \ '--print-query',
        \]
  call fzf#run(fzf#wrap(
        \ l:name,
        \ {
        \   'source': l:git_output,
        \   'sink*': function('s:checkout'),
        \   'options': l:options,
        \ },
        \ a:bang,
        \))
endfunction
