/*
 *Kathryn Fukuda
 *861276798
 *Amanda Cao
 *
 *CS 152 - Phase 1
 */

DIGIT		[0-9]

%%

.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%
main () {
  yylex();
}
