# fzf-checkout.vim

Checkout branches and tags with [fzf.vim](https://github.com/junegunn/fzf.vim).

![gcheckouttag](https://user-images.githubusercontent.com/4975310/76155099-68186e00-60b5-11ea-84fa-b61cfe7a3e02.png)
![gcheckout](https://user-images.githubusercontent.com/4975310/76155101-72d30300-60b5-11ea-8941-9171f5b8e08c.png)

# Installation

Install using [vim-plug](https://github.com/junegunn/vim-plug). Put this on your init.vim.

```vim
" You must have installed fzf.vim
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'stsewd/fzf-checkout.vim'
```

# Usage

Call `:GCheckout` or `GCheckoutTag` to checkout to a branch or tag.

## Features

- The current branch or commit will be show at the bottom
- The first item on the list will be the previous branch
- Press `alt-enter` to checkout a remote branch locally (`origin/foo` becomes `foo`)

# Configuration

This plugin respects your `g:fzf_command_prefix` setting.
