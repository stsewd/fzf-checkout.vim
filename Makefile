EXTRA_OPTIONS?=
VIM_BIN?=nvim

lint:
	vint autoload/*.vim plugin/*.vim

test: 
	TEST_CWD=`pwd` \
	$(VIM_BIN) $(EXTRA_OPTIONS) -u tests/init.vim -c "Vader! tests/**" > /dev/null

setup:
	git clone --depth=1 https://github.com/junegunn/vader.vim.git

.PHONY: lint test setup
