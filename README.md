# fzf-checkout.vim

Manage branches and tags with [fzf](https://github.com/junegunn/fzf).

![gcheckout](https://user-images.githubusercontent.com/4975310/82736850-2d0bfb00-9cf2-11ea-8eec-8b84e903e805.png)
![gcheckouttag](https://user-images.githubusercontent.com/4975310/82736909-a3106200-9cf2-11ea-8974-dc64d8011f6c.png)

# Installation

Install using [vim-plug](https://github.com/junegunn/vim-plug).
Put this in your `init.vim`.

```vim
Plug 'stsewd/fzf-checkout.vim'
```

**Note:** You need to have `fzf` installed in addition to use this plugin.
See <https://github.com/junegunn/fzf/blob/master/README-VIM.md#installation>.

# Usage

Call `:GBranches [action]` or `GTags [action]` to execute an action over a branch or tag.
If no action is given, you can make use of defined keymaps to execute an action.

## Features

- The current branch or commit will be show at the bottom
- The first item on the list will be the previous branch
- Type `:GBranches <tab>` or `GTags <tab>` to see all available actions
- Press `alt-enter` to track a remote branch locally (`origin/foo` becomes `foo`)
- Press `ctrl-n` to create a branch or tag with the current query as name
- Press `ctrl-d` to delete a branch or tag

# Configuration

If you have [fzf.vim](https://github.com/junegunn/fzf.vim) installed,
this plugin will respect your `g:fzf_command_prefix` setting.

## g:fzf_checkout_git_bin

Name of the `git` binary.

```vim
let g:fzf_checkout_git_bin = 'git'
```

## g:fzf_checkout_git_options

Additional options to pass to the `git` command. It is not recommended to change the
`--color` and `--format` parameters, as they are used by the plugin and changing them
may break something.

```vim
let g:fzf_checkout_git_options = ''
```

## g:fzf_checkout_previous_ref_first

Display previously used branch first independent of specified sorting.

```vim
let g:fzf_checkout_previous_ref_first = v:true
```

## g:fzf_branch_actions

A dictionary of actions for branches.
The keys are the name of the action,
and the value is a dictionary with the following keys:

- `prompt`: A string to use it as prompt when executing this action
- `execute`: A string to be executed when performing this action.
  You can make use of the following placeholders:
  - `{git}`: Replaced with the value from `g:fzf_checkout_git_bin``{branch}`
  - `{branch}`: Replaced with the branches selected
  - `{tag}`: Replaced with the tags selected
  - `{input}`: Replaced with the input from the user
- `multiple`: The actions supports multiple selections?
- `keymap`: The keymap used to execute this action (it can be empty)
- `required`: A list of required elements (`['branch', 'tag', 'input']`) to perform this action
- `confirm`: Ask for confirmation before executing this action?

```vim
let g:fzf_branch_actions = {
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
```

## g:fzf_tag_actions

Same as `g:fzf_branch_actions` but used to define tag actions.

```vim
let g:fzf_tag_actions = {
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
```

# Examples

Prefix commands with `Fzf`, i.e, `FzfGCheckout` and `FzfGCheckoutTag`.

```vim
let g:fzf_command_prefix = 'Fzf'
```

Sort branches/tags by committer date. Minus sign to show in reverse order (recent first).

```vim
let g:fzf_checkout_git_options = '--sort=-committerdate'
```

# TODO

- docs
- rename plugin?
- rename files?
- Allow to easily override or add new settings by merging the settings from the
  user with the default settings
