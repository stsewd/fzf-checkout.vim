function! s:checkout(line)
  " Get first column
  let l:branch = substitute(a:line, '^\(.\+\)\s\@=.*', '\1', '')
  execute 'split | terminal git checkout ' . shellescape(l:branch)
  " Auto insert, so you only need to press enter to close the terminal window.
  call feedkeys('i', 'n')
endfunction


function! fzf_checkout#list(bang, type)
  " Try to get the branch name or fallback to get the commit
  let l:current = system('git symbolic-ref --short -q HEAD || git rev-parse --short HEAD')
  let l:current = substitute(l:current, '\n', '', 'g')
  let l:current_escaped = escape(l:current, '/')

  " See valid atoms in
  " https://github.com/git/git/blob/076cbdcd739aeb33c1be87b73aebae5e43d7bcc5/ref-filter.c#L474
  let l:format = '
        \%(color:yellow bold)%(refname:short)  
        \%(color:reset)%(color:green)%(subject) 
        \%(color:reset)%(color:green dim italic)%(committerdate:relative) 
        \%(color:reset)%(color:blue)-> %(objectname:short)
        \'
  if a:type ==# 'branch'
    let l:subcommand = 'branch --all'
  else
    let l:subcommand = 'tag'
  endif
  let l:git_cmd = 'git ' . l:subcommand . ' --color=always --sort=-refname:short --format=' . shellescape(l:format)

  " Filter to delete current branch and HEAD
  let l:filter = 'sed -r -e "/' . l:current_escaped . '\s.*$/d" -e "/(origin\/HEAD)|(\(HEAD)/d"'
  call fzf#vim#grep(
    \ l:git_cmd . ' | ' . l:filter . ' | sort -u', 0,
    \ { 'sink': function('s:checkout'), 'options': ['--no-multi', '--header='.l:current] }, a:bang)
endfunction
