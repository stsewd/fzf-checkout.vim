# fzf-checkout.vim

Checkout branches and tags with [fzf](https://github.com/junegunn/fzf).

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

Call `:GCheckout` or `GCheckoutTag` to checkout to a branch or tag.

## Features

- The current branch or commit will be show at the bottom
- The first item on the list will be the previous branch
- Press `alt-enter` to track a remote branch locally (`origin/foo` becomes `foo`)
- Press `ctrl-n` to create branch locally with the current query as name

# Configuration

If you have [fzf.vim](https://github.com/junegunn/fzf.vim) installed,
this plugin will respect your `g:fzf_command_prefix` setting.

## g:fzf_checkout_git_bin

Name of the `git` binary.

```vim
let g:fzf_checkout_git_bin = 'git'
```

## g:fzf_checkout_git_options

Additional options to pass to the `git` command.

```vim
let g:fzf_checkout_git_options = ''
```

## g:fzf_checkout_track_key

Key used to track the remote branch locally (`git checkout --track branch`).

```vim
let g:fzf_checkout_track_key = 'alt-enter'
```

## g:fzf_checkout_create_key

Key used to create a branch locally (`git checkout -b branch`).

```vim
let g:fzf_checkout_track_key = 'ctrl-n'
```

## g:fzf_checkout_execute

Command used to execute the checkout, options are:

- system: Uses the `system()` function (default).
- terminal: Uses the `terminal` command (it works on Neovim only).
- bang: Makes use of `!command`.

```vim
let g:fzf_checkout_execute = 'system'
```

If you provide a different string as the option,
it will be executed to checkout the branch or tag.
`{git}` and `{branch}` are replaced with the `g:fzf_checkout_git_bin` and the branch or tag to checkout.

```vim
let g:fzf_checkout_execute = 'echo system("{git} checkout {branch}")'
```

## g:fzf_checkout_track_execute

Same as `g:fzf_checkout_execute`, but it's used when tracking a branch.

```vim
let g:fzf_checkout_track_execute = 'system'
```

This is the same as:

```vim
let g:fzf_checkout_track_execute = 'echo system("{git} checkout --track {branch}")'
```

## g:fzf_checkout_create_execute

Same as `g:fzf_checkout_execute`, but it's used when creating a branch.

```vim
let g:fzf_checkout_create_execute = 'system'
```

This is the same as:

```vim
let g:fzf_checkout_create_execute = 'echo system("{git} checkout -b {branch}")'
```

# Examples

Prefix commands with `Fzf`, i.e, `FzfGCheckout` and `FzfGCheckoutTag`.

```vim
let g:fzf_command_prefix = 'Fzf'
```

Sort branches/tags by committer date.

```vim
let g:fzf_checkout_git_options = '--sort=committerdate'
```
