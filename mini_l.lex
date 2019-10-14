/*
 *Kathryn Fukuda
 *861276798
 *Amanda Cao
 *861270188
 *
 *CS 152 - Phase 1
 */

DIGIT		[0-9]

%{
        int num_ops = 0, num_parens = 0, num_equals = 0, nums = 0;
        int curPos = 1, curLn = 1;
%}

%%

"+"             {printf("PLUS\n"); curPos += yyleng; ++num_ops;}
"-"             {printf("MINUS\n"); curPos += yyleng; ++num_ops;}
"*"             {printf("MULT\n"); curPos += yyleng; ++num_ops;}
"/"             {printf("DIV\n"); curPos += yyleng; ++num_ops;}
"("             {printf("L_PAREN\n"); curPos += yyleng; ++num_parens;}
")"             {printf("R_PAREN\n"); curPos += yyleng; ++num_parens;}
"="             {printf("EQUAL\n"); curPos += yyleng; ++num_equals;}
{DIGIT}+        {printf("NUMBER %s\n", yytext); curPos += yyleng; ++nums;}
\n              {curPos = 1; ++curLn;}
.               {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%
main () {
  yylex();
}

