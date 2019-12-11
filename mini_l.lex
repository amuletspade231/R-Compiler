/*
 *Kathryn Fukuda
 *861276798
 *Amanda Cao
 *861270188
 *
 *CS 152 - Phase 2
 */

%{
	#include "model.hpp"
	#include "mini_l.tab.h"
	int curPos = 1, curLn = 1;
%}

DIGIT		[0-9]
LETTER 		[a-zA-Z]
IDENTIFIER	{LETTER}|({LETTER}({LETTER}|{DIGIT}|_)*({LETTER}|{DIGIT}))
NONIDENT_1	({DIGIT}|_)+{IDENTIFIER}
NONIDENT_2	{IDENTIFIER}_+
COMMENT		[#][#].*\n

%%
"function"	{curPos += yyleng; return FUNCTION;}
"beginparams"	{curPos += yyleng; return BEGIN_PARAMS;}
"endparams"	{curPos += yyleng; return END_PARAMS;}
"beginlocals"	{curPos += yyleng; return BEGIN_LOCALS;}
"endlocals"	{curPos += yyleng; return END_LOCALS;}
"beginbody"	{curPos += yyleng; return BEGIN_BODY;}
"endbody"	{curPos += yyleng; return END_BODY;}
"integer"	{curPos += yyleng; return INTEGER;}
"array"		{curPos += yyleng; return ARRAY;}
"of"		{curPos += yyleng; return OF;}
"if"		{curPos += yyleng; return IF;}
"then"		{curPos += yyleng; return THEN;}
"endif"		{curPos += yyleng; return ENDIF;}
"else"		{curPos += yyleng; return ELSE;}
"while"		{curPos += yyleng; return WHILE;}
"do"		{curPos += yyleng; return DO;}
"beginloop"	{curPos += yyleng; return BEGINLOOP;}
"endloop"	{curPos += yyleng; return ENDLOOP;}
"continue"	{curPos += yyleng; return CONTINUE;}
"read"		{curPos += yyleng; return READ;}
"write"		{curPos += yyleng; return WRITE;}
"and"		{curPos += yyleng; return AND;}
"or"		{curPos += yyleng; return OR;}
"not"		{curPos += yyleng; return NOT;}
"true"		{curPos += yyleng; return TRUE;}
"false"		{curPos += yyleng; return FALSE;}
"return"	{curPos += yyleng; return RETURN;}

"-"             {curPos += yyleng; return MINUS;}
"+"             {curPos += yyleng; return PLUS;}
"*"             {curPos += yyleng; return MULT;}
"/"             {curPos += yyleng; return DIV;}
"%"             {curPos += yyleng; return MOD;}

"=="            {curPos += yyleng; return EQ;}
"<>"            {curPos += yyleng; return NEQ;}
"<"             {curPos += yyleng; return LT;}
">"             {curPos += yyleng;return GT;}
"<="            {curPos += yyleng;return LTE;}
">="            {curPos += yyleng; return GTE;}

";"            {curPos += yyleng; return SEMICOLON;}
":"            {curPos += yyleng; return COLON;}
","            {curPos += yyleng; return COMMA;}
"("            {curPos += yyleng; return L_PAREN;}
")"            {curPos += yyleng; return R_PAREN;}
"["            {curPos += yyleng; return L_SQUARE_BRACKET;}
"]"            {curPos += yyleng; return R_SQUARE_BRACKET;}
":="           {curPos += yyleng; return ASSIGN;}

{IDENTIFIER}	{curPos += yyleng; yylval.sval = yytext; /*printf("ident: %s\n", yytext);*/ return IDENTIFIER;}
{NONIDENT_1}	{printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", curLn, curPos, yytext); exit(0);}
{NONIDENT_2}	{printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", curLn, curPos, yytext); exit(0);}
{DIGIT}+	{curPos += yyleng; yylval.ival = atof(yytext); return NUMBER;}

" "		{}
"	"	{curPos += yyleng;}
{COMMENT}	{curPos = 1; ++curLn;}
\n		{curPos = 1; ++curLn;}
.               {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", curLn, curPos, yytext); exit(0);}

%%
