/*
 *Kathryn Fukuda
 *861276798
 *Amanda Cao
 *861270188
 *
 *CS 152 - Phase 1
 */

DIGIT		[0-9]
LETTER 		[a-zA-Z]
IDENTIFIER	{LETTER}{LETTER|DIGIT}*
%{
        int num_ops = 0, num_parens = 0, num_equals = 0, nums = 0;
        int curPos = 1, curLine = 1;
%}

%%
"function"	{printf("FUNCTION\n"); curPos += yyleng;}
"beginparams"	{printf("BEGIN_PARAMS\n"); curPos += yyleng;}
"endparams"	{printf("END_PARAMS\n"); curPos += yyleng;}
"beginlocals"	{printf("BEGIN_LOCALS\n"); curPos += yyleng;}
"endlocals"	{printf("END_LOCALS\n"); curPos += yyleng;}
"beginbody"	{printf("BEGIN_BODY\n"); curPos += yyleng;}
"endbody"	{printf("END_BODY\n"); curPos += yyleng;}
"integer"	{printf("INTEGER\n"); curPos += yyleng;}
"array"		{printf("ARRAY\n"); curPos += yyleng;}
"of"		{printf("OF\n"); curPos += yyleng;}
"if"		{printf("IF\n"); curPos += yyleng;}
"then"		{printf("THEN\n"); curPos += yyleng;}
"endif"		{printf("ENDIF\n"); curPos += yyleng;}
"else"		{printf("ELSE\n"); curPos += yyleng;}
"while"		{printf("WHILE\n"); curPos += yyleng;}
"do"		{printf("DO\n"); curPos += yyleng;}
"beginloop"	{printf("BEGINLOOP\n"); curPos += yyleng;}
"endloop"	{printf("ENDLOOP\n"); curPos += yyleng;}
"continue"	{printf("CONTINUE\n"); curPos += yyleng;}
"read"		{printf("READ\n"); curPos += yyleng;}
"write"		{printf("WRITE\n"); curPos += yyleng;}
"and"		{printf("AND\n"); curPos += yyleng;}
"or"		{printf("OR\n"); curPos += yyleng;}
"not"		{printf("NOT\n"); curPos += yyleng;}
"true"		{printf("TRUE\n"); curPos += yyleng;}
"false"		{printf("FALSE\n"); curPos += yyleng;}
"return"	{printf("RETURN\n"); curPos += yyleng;}


"+"             {printf("PLUS\n"); curPos += yyleng;}
"-"             {printf("MINUS\n"); curPos += yyleng;}
"*"             {printf("MULT\n"); curPos += yyleng;}
"/"             {printf("DIV\n"); curPos += yyleng;}
"("             {printf("L_PAREN\n"); curPos += yyleng;}
")"             {printf("R_PAREN\n"); curPos += yyleng;}
"="             {printf("EQUAL\n"); curPos += yyleng;}
{DIGIT}+        {printf("NUMBER %s\n", yytext); curPos += yyleng;}
\n              {curPos = 1; ++curLn;}
.               {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", curLn, curPos, yytext); exit(0);}

%%
main () {
  yylex();
}

