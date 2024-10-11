.PHONY: run run-repl

FILE := lab2.lsp
CMD := rlwrap sbcl

print:
	@printf "> "

run: print
	$(CMD) --noinform --load $(FILE) --quit

run-repl: print
	$(CMD) --noinform --load $(FILE)