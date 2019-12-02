all: my_compiler

mini_l.tab.c mini_l.tab.h:	mini_l.y
	bison -d mini_l.y

lex.yy.c: mini_l.lex mini_l.tab.h
	flex mini_l.lex

my_compiler: lex.yy.c mini_l.tab.c mini_l.tab.h
	g++ -g -O0 -std=c++11 -Werror=return-type -o my_compiler mini_l.tab.c lex.yy.c -l fl

clean:
	rm my_compiler mini_l.tab.c lex.yy.c mini_l.tab.h
