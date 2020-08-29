" See valid atoms in
" https://github.com/git/git/blob/076cbdcd739aeb33c1be87b73aebae5e43d7bcc5/ref-filter.c#L474
let s:format = shellescape(
      \ '%(color:yellow bold)%(refname:short)  ' .
      \ '%(color:reset)%(color:green)%(subject) ' .
      \ '%(color:reset)%(color:green dim italic)%(committerdate:relative) ' .
      \ '%(color:reset)%(color:blue)-> %(objectname:short)'
      \)

let s:color_regex = '\e\[[0-9;]\+m'

" TODO: this should be a setting!
let s:branch_actions = {
      \ 'checkout': {
      \   'prompt': 'Checkout> ',
      \   'execute': 'echo system("{git} checkout {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'enter',
      \ },
      \ 'track': {
      \   'prompt': 'Track> ',
      \   'execute': 'echo system("{git} checkout --track {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'alt-enter',
      \ },
      \ 'create': {
      \   'prompt': 'Create> ',
      \   'execute': 'echo system("{git} checkout -b {input}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-n',
      \ },
      \ 'delete': {
      \   'prompt': 'Delete> ',
      \   'execute': 'echo system("{git} branch -D {branch}")',
      \   'multiple': v:true,
      \   'keymap': 'ctrl-d',
      \ },
      \}

let s:tag_actions = {
      \ 'checkout': {
      \   'prompt': 'Checkout> ',
      \   'execute': 'echo system("{git} checkout {tag}")',
      \   'multiple': v:false,
      \   'keymap': 'enter',
      \ },
      \ 'create': {
      \   'prompt': 'Create> ',
      \   'execute': 'echo system("{git} tag {input}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-n',
      \ },
      \ 'delete': {
      \   'prompt': 'Delete> ',
      \   'execute': 'echo system("{git} branch -D {tag}")',
      \   'multiple': v:true,
      \   'keymap': 'ctrl-d',
      \ },
      \}

let s:branch_keybindings = {}
for s:action in keys(s:branch_actions)
  let s:branch_keybindings[s:branch_actions[s:action]['keymap']] = s:action
endfor

let s:tag_keybindings = {}
for s:action in keys(s:tag_actions)
  let s:tag_keybindings[s:tag_actions[s:action]['keymap']] = s:action
endfor

let s:actions = {'tag': s:tag_actions, 'branch': s:branch_actions}
let s:keybindings = {'tag': s:tag_keybindings, 'branch': s:branch_keybindings}


function! s:execute(type, action, lines)
  if len(a:lines) < 2
    return
  endif

  let l:input = a:lines[0]
  let l:key = a:lines[1]

  let l:branch = l:input
  if len(a:lines) > 2
    " TODO: support multiple branches
    let l:branch = split(a:lines[2])[0]
  endif

  let l:branch = shellescape(l:branch)
  let l:input = shellescape(l:input)

  let l:action = a:action
  if empty(l:action)
    let l:action = get(s:keybindings[a:type], l:key)
    if string(l:action) ==# '0'
      return
    endif
  else
    if l:key !=# 'enter'
      return
    endif
  endif

  let l:execute_command = s:actions[a:type][l:action]['execute']
  let l:execute_command = substitute(l:execute_command, '{git}', g:fzf_checkout_git_bin, 'g')
  let l:execute_command = substitute(l:execute_command, '{branch}', l:branch, 'g')
  let l:execute_command = substitute(l:execute_command, '{tag}', l:branch, 'g')
  let l:execute_command = substitute(l:execute_command, '{input}', l:input, 'g')
  execute l:execute_command
endfunction


function! s:get_current_ref()
  " Try to get the branch name or fallback to get the commit.
  let l:current = system('git symbolic-ref --short -q HEAD || git rev-parse --short HEAD')
  let l:current = substitute(l:current, '\n', '', 'g')
  return l:current
endfunction


function! s:get_previous_ref()
  " Try to get the branch name or fallback to get the commit.
  let l:previous = system('git rev-parse -q --abbrev-ref --symbolic-full-name "@{-1}"')
  if l:previous =~# '^\s*$' || l:previous =~# "'@{-1}'"
    let l:previous = system('git rev-parse --short -q "@{-1}"')
  endif
  let l:previous = substitute(l:previous, '\n', '', 'g')
  return l:previous
endfunction


function! s:remove_branch(branches, pattern)
  " Find first occurrence and remove it
  let l:index = match(a:branches, '^' . s:color_regex . a:pattern)
  if (l:index != -1)
    call remove(a:branches, l:index)
    return v:true
  endif
  return v:false
endfunction


function! fzf_checkout#list(bang, type, options) abort
  if a:type ==# 'branch'
    let l:name = 'GCheckout'
    let l:subcommand = 'branch --all'
  elseif a:type ==# 'tag'
    let l:name = 'GCheckoutTag'
    let l:subcommand = 'tag'
  else
    return
  endif

  let l:action = ''
  let l:actions = s:actions[a:type]
  let l:options = split(a:options)
  if !empty(l:options) && has_key(l:actions, l:options[0])
    let l:action = l:options[0]
  endif

  " Allow all keybindings if isn't a specific task.
  if empty(l:action)
    let l:keybindings = keys(get(s:keybindings, a:type))
  else
    let l:keybindings = ['enter']
  endif

  if empty(l:action)
    let l:prompt = 'Checkout> '
  else
    let l:prompt = l:actions[l:action]['prompt']
  endif

  let l:git_cmd = printf('%s %s --color=always --sort=refname:short --format=%s %s',
        \ g:fzf_checkout_git_bin,
        \ l:subcommand,
        \ s:format,
        \ g:fzf_checkout_git_options
        \)

  let l:git_output = split(system(l:git_cmd), '\n')

  " Delete the current and HEAD from the list.
  let l:current = s:get_current_ref()
  call s:remove_branch(l:git_output, escape(l:current, '/'))
  call s:remove_branch(l:git_output, '\(origin/\)\?HEAD')

  if g:fzf_checkout_previous_ref_first
    " Put previous ref first
    let l:previous = s:get_previous_ref()
    if !empty(l:previous)
      if (s:remove_branch(l:git_output, escape(l:previous, '/')))
        call insert(l:git_output, system(l:git_cmd . ' --list ' . l:previous), 0)
      endif
    endif
  endif

  " TODO: Allow keybindings only if the action supports them.
  let l:valid_keys = join(l:keybindings, ',')

  let l:fzf_options = [
        \ '--prompt', l:prompt,
        \ '--header', l:current,
        \ '--nth', '1',
        \ '--multi',
        \ '--expect', l:valid_keys,
        \ '--ansi',
        \ '--print-query',
        \]
  call fzf#run(fzf#wrap(
        \ l:name,
        \ {
        \   'source': l:git_output,
        \   'sink*': function('s:execute', [a:type, l:action]),
        \   'options': l:fzf_options,
        \ },
        \ a:bang,
        \))
endfunction
