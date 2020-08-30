" See valid atoms in
" https://github.com/git/git/blob/076cbdcd739aeb33c1be87b73aebae5e43d7bcc5/ref-filter.c#L474
let s:format = shellescape(
      \ '%(color:yellow bold)%(refname:short)  ' .
      \ '%(color:reset)%(color:green)%(subject) ' .
      \ '%(color:reset)%(color:green dim italic)%(committerdate:relative) ' .
      \ '%(color:reset)%(color:blue)-> %(objectname:short)'
      \)
let s:color_regex = '\e\[[0-9;]\+m'


let s:branch_keybindings = {}
for [s:action, s:value] in items(g:fzf_branch_actions)
  let s:keymap = s:value['keymap']
  if !empty(s:keymap)
    let s:branch_keybindings[s:keymap] = s:action
  endif
endfor

let s:tag_keybindings = {}
for [s:action, s:value] in items(g:fzf_tag_actions)
  let s:keymap = s:value['keymap']
  if !empty(s:keymap)
    let s:tag_keybindings[s:keymap] = s:action
  endif
endfor

let s:actions = {'tag': g:fzf_tag_actions, 'branch': g:fzf_branch_actions}
let s:keybindings = {'tag': s:tag_keybindings, 'branch': s:branch_keybindings}
let s:branch_filters = {
      \ '--all': '--all',
      \ '--locals': '',
      \ '--remotes': '--remotes',
      \}


function! s:execute(type, action, lines) abort
  if len(a:lines) < 2
    return
  endif

  let l:input = shellescape(a:lines[0])
  let l:key = a:lines[1]
  let l:actions = s:actions[a:type]
  let l:action = a:action

  if empty(l:action)
    let l:action = get(s:keybindings[a:type], l:key)
    if string(l:action) ==# '0'
      return
    endif
  elseif l:key !=# 'enter'
    return
  endif

  let l:branch = ''
  if len(a:lines) > 2
    if l:actions[l:action]['multiple']
      let l:branch = join(map(a:lines[2:], 'shellescape(split(v:val)[0])'), ' ')
    else
      let l:branch = shellescape(split(a:lines[2])[0])
    endif
  endif

  let l:required = l:actions[l:action]['required']

  let l:branch_required = index(l:required, 'branch') >= 0 || index(l:required, 'tag') >= 0
  if l:branch_required && empty(trim(l:branch))
    call s:warning('A ' . a:type . ' is required')
    return
  endif

  let l:input_required = index(l:required, 'input') >= 0
  if l:input_required && empty(trim(l:input))
    call s:warning('An input is required')
    return
  endif

  if l:actions[l:action]['confirm']
    let l:choice = confirm(
          \'Do yo want to ' . l:action . ' ' . l:branch . '?',
          \ "&Yes\n&No", 2
          \)
    if l:choice != 1
      return
    endif
  endif

  let l:execute_command = l:actions[l:action]['execute']
  let l:execute_command = substitute(l:execute_command, '{git}', g:fzf_checkout_git_bin, 'g')
  let l:execute_command = substitute(l:execute_command, '{branch}', l:branch, 'g')
  let l:execute_command = substitute(l:execute_command, '{tag}', l:branch, 'g')
  let l:execute_command = substitute(l:execute_command, '{input}', l:input, 'g')
  execute l:execute_command
endfunction


function! s:warning(msg) abort
    echohl WarningMsg | echomsg a:msg | echohl None
endfunction


function! s:get_current_ref() abort
  " Try to get the branch name or fallback to get the commit.
  let l:current = system('git symbolic-ref --short -q HEAD || git rev-parse --short HEAD')
  let l:current = substitute(l:current, '\n', '', 'g')
  return l:current
endfunction


function! s:get_previous_ref() abort
  " Try to get the branch name or fallback to get the commit.
  let l:previous = system('git rev-parse -q --abbrev-ref --symbolic-full-name "@{-1}"')
  if l:previous =~# '^\s*$' || l:previous =~# "'@{-1}'"
    let l:previous = system('git rev-parse --short -q "@{-1}"')
  endif
  let l:previous = substitute(l:previous, '\n', '', 'g')
  return l:previous
endfunction


function! s:remove_branch(branches, pattern) abort
  " Find first occurrence and remove it
  let l:index = match(a:branches, '^' . s:color_regex . a:pattern)
  if (l:index != -1)
    call remove(a:branches, l:index)
    return v:true
  endif
  return v:false
endfunction


function! fzf_checkout#list(bang, type, options, deprecated) abort
  let l:actions = s:actions[a:type]
  let l:options = split(a:options)
  let l:action = ''
  let l:filter = '--all'

  if len(l:options) > 2
    call s:warning('Maximum two arguments are allowed')
    return
  endif

  if !empty(l:options)
    if has_key(l:actions, l:options[0])
      let l:action = l:options[0]
    elseif a:type ==# 'branch' && has_key(s:branch_filters, l:options[0])
      let l:filter = l:options[0]
    endif
  endif

  if len(l:options) > 1
    if has_key(l:actions, l:options[1])
      let l:action = l:options[1]
    elseif a:type ==# 'branch' && has_key(s:branch_filters, l:options[1])
      let l:filter = l:options[1]
    endif
  endif

  if a:type ==# 'branch'
    let l:name = 'GBranches'
    let l:prompt = 'Branches> '
    let l:subcommand = 'branch ' . s:branch_filters[l:filter]

    if a:deprecated
      call s:warning('The :GCheckout command is deprecated, use :GBranches instead')
    endif
  elseif a:type ==# 'tag'
    let l:name = 'GTags'
    let l:prompt = 'Tags> '
    let l:subcommand = 'tag'

    if a:deprecated
      call s:warning('The :GCheckoutTag command is deprecated, use :GTags instead')
    endif
  else
    return
  endif

  " Allow all keybindings if isn't a specific task.
  if empty(l:action)
    let l:keybindings = keys(get(s:keybindings, a:type))
  else
    let l:keybindings = ['enter']
  endif

  if !empty(l:action)
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


function! fzf_checkout#complete_tags(arglead, cmdline, cursorpos) abort
  let l:cmdlist = split(a:cmdline)
  if len(l:cmdlist) > 2 || len(l:cmdlist) > 1 && empty(a:arglead) 
    return
  endif

  let l:options = keys(g:fzf_tag_actions)
  if empty(a:arglead)
    return l:options
  endif

  let l:candidates = []
  for l:option in l:options
    if l:option[:len(a:arglead) - 1] ==# a:arglead
      call add(l:candidates, l:option)
    endif
  endfor

  return l:options
endfunction


function! fzf_checkout#complete_branches(arglead, cmdline, cursorpos) abort
  let l:cmdlist = split(a:cmdline)
  if len(l:cmdlist) > 3 || len(l:cmdlist) > 2 && empty(a:arglead)
    return
  endif

  let l:options =  keys(g:fzf_branch_actions) + keys(s:branch_filters)
  if len(l:cmdlist) == 2
    if index(keys(g:fzf_branch_actions), l:cmdlist[1]) >= 0
      let l:options =  keys(s:branch_filters)
    elseif index(keys(s:branch_filters), l:cmdlist[1]) >= 0
      let l:options =  keys(g:fzf_branch_actions)
    endif
  endif

  if empty(a:arglead)
    return l:options
  endif

  let l:candidates = []
  for l:option in l:options
    if l:option[:len(a:arglead) - 1] ==# a:arglead
      call add(l:candidates, l:option)
    endif
  endfor

  return l:candidates
endfunction
