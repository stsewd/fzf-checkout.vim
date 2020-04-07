# fzf-checkout.vim

Checkout branches and tags with [fzf](https://github.com/junegunn/fzf).

![gcheckouttag](https://user-images.githubusercontent.com/4975310/76155099-68186e00-60b5-11ea-84fa-b61cfe7a3e02.png)
![gcheckout](https://user-images.githubusercontent.com/4975310/76155101-72d30300-60b5-11ea-8941-9171f5b8e08c.png)

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
- Press `alt-enter` to checkout a remote branch locally (`origin/foo` becomes `foo`)

# Configuration

If you have [fzf.vim](https://github.com/junegunn/fzf.vim) installed,
this plugin will respect your `g:fzf_command_prefix` setting.

## let g:fzf_checkout_git_bin

Name of the `git` binary.

```vim
let g:fzf_checkout_git_bin = 'git'
```

## g:fzf_checkout_git_options

Additional options to pass to the `git` command.

```vim
let g:fzf_checkout_git_options = ''
```
