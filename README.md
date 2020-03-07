# fzf-checkout.vim

Checkout branches and tags with [fzf.vim](https://github.com/junegunn/fzf.vim).

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

# Configuration

This plugin respects your `g:fzf_command_prefix` setting.
