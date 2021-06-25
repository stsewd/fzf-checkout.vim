# fzf-checkout.vim

[![CI](https://github.com/stsewd/fzf-checkout.vim/workflows/CI/badge.svg)](https://github.com/stsewd/fzf-checkout.vim/actions?query=workflow%3ACI+branch%3Amaster)
[![Linter](https://github.com/stsewd/fzf-checkout.vim/workflows/linter/badge.svg)](https://github.com/stsewd/fzf-checkout.vim/actions?query=workflow%3Alinter+branch%3Amaster)

Manage branches and tags with [fzf](https://github.com/junegunn/fzf).

![fzf-checkout](https://user-images.githubusercontent.com/4975310/105560618-4da5ae00-5ce2-11eb-9cf3-24c9729d4e80.gif)

# Requirements

- `fzf`, see <https://github.com/junegunn/fzf/blob/master/README-VIM.md#installation>
- `git >=2.13.7`

# Installation

Install using [vim-plug](https://github.com/junegunn/vim-plug).
Put this in your `init.vim`.

```vim
Plug 'stsewd/fzf-checkout.vim'
```

## Features

- The current branch or commit will be show at the bottom
- The first item on the list will be the previous branch/tag
- Press `alt-enter` to track a remote branch locally (`origin/foo` becomes `foo`)
- Press `ctrl-b` to create a branch or tag with the current query as name
- Press `ctrl-d` to delete a branch or tag
- Press `ctrl-e` to merge a branch
- Press `ctrl-r` to rebase a branch
- Ask for confirmation for irreversible actions like delete
- Define your own actions

# Usage

Call `:GBranches [action] [filter]` or `:GTags [action]` to execute an action over a branch or tag.
If no action is given, you can make use of defined keymaps to execute an action.

# Commands and settings

See [`:h fzf-checkout`](doc/fzf-checkout.txt) for a list of all available commands and settings.

If you have [fzf.vim](https://github.com/junegunn/fzf.vim) installed,
this plugin will respect your `g:fzf_command_prefix` setting.

# Examples

Prefix commands with `Fzf`, i.e, `FzfGBranches` and `FzfGTags`:

```vim
let g:fzf_command_prefix = 'Fzf'
```

Sort branches/tags by committer date. Minus sign to show in reverse order (recent first):

```vim
let g:fzf_checkout_git_options = '--sort=-committerdate'
```

Override the mapping to delete a branch with `ctrl-r`:

```vim
let g:fzf_branch_actions = {
      \ 'delete': {'keymap': 'ctrl-r'},
      \}
```

Use the bang command to checkout a tag:

```vim
let g:fzf_tag_actions = {
      \ 'checkout': {'execute': '!{git} -C {cwd} checkout {branch}'},
      \}
```

Define a _diff_ action using [fugitive](https://github.com/tpope/vim-fugitive).
You can use it with `:GBranches diff` or with `:GBranches` and pressing `ctrl-f`:

```vim
let g:fzf_branch_actions = {
      \ 'diff': {
      \   'prompt': 'Diff> ',
      \   'execute': 'Git diff {branch}',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-f',
      \   'required': ['branch'],
      \   'confirm': v:false,
      \ },
      \}
```

Define checkout as the only action for branches:

```vim
let g:fzf_checkout_merge_settings = v:false
let g:fzf_branch_actions = {
      \ 'checkout': {
      \   'prompt': 'Checkout> ',
      \   'execute': 'echo system("{git} -C {cwd} checkout {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'enter',
      \   'required': ['branch'],
      \   'confirm': v:false,
      \ },
      \}
```
