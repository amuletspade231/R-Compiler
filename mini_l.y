/* calculator. */
%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int curLn;
 extern int curPos;
 FILE * yyin;
%}

%union{
  double dval;
  int ival;
  char** sval;
}

%error-verbose
%start input
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN END IDENTIFIER
%type <dval> exp
%token <dval> NUMBER
%left ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left PLUS MINUS
%left MULT DIV MOD
%right UMINUS
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left L_PAREN R_PAREN


%% 
input:	
			| input line
			;

line:		exp EQ END         { printf("\t%f\n", $1);}
			;

exp:		NUMBER                { $$ = $1; }
			| exp PLUS exp        { $$ = $1 + $3; }
			| exp MINUS exp       { $$ = $1 - $3; }
			| exp MULT exp        { $$ = $1 * $3; }
			| exp DIV exp         { if ($3==0) yyerror("divide by zero"); else $$ = $1 / $3; }
			| MINUS exp %prec UMINUS { $$ = -$2; }
			| L_PAREN exp R_PAREN { $$ = $2; }
			;

comp:		EQ | NEQ | GT | GTE | LT | LTE
		;

/*AMANDA:program*/
/*AMANDA:function*/
/*AMANDA:declaration*/
/*KATIE:statement*/
Statements	Statement SEMICOLON Statements
		{printf("Statements -> Statement  SEMICOLON Statements\n");}
		| Statement SEMICOLON
		{printf("Statments -> Statement SEMICOLON\n");}
		;

Statement:	Var ASSIGN Expression
		{printf("Statement -> Var ASSIGN Expression\n");}
		| IF BoolExpr THEN Statements ENDIF
		{printf("Statement -> IF BoolExpr THEN Statements ENDIF\n");}
		| IF BoolExpr THEN Statements ELSE Statements ENDIF
		{printf("Statement -> IF BoolExpr THEN Statements ELSE Statements ENDIF\n");}
		| WHILE BoolExpr BEGINLOOP Statements ENDLOOP
		{printf("Statement -> WHILE BoolExpr BEGINLOOP Statements ENDLOOP\n");}
		| DO BEGINLOOP Statements ENDLOOP WHILE BoolExpr
		{printf("Statement -> DO BEGINLOOP Statements ENDLOOP WHILE BoolExpr\n");}
		| READ Vars
		{printf("Statement -> READ Vars\n");}
		| WRITE Vars
		{printf("Statement -> WRITE Vars\n");}
		| CONTINUE
		{printf("Statement -> CONTINUE\n");}
		| RETURN Expression
		{printf("Statement -> RETURN Expression\n");}
		;
/*AMANDA:bool-expr*/
/*AMANDA:relation and expr*/
/*AMANDA:relation expr*/
/*AMANDA:comp*/
/*KATIE:expression*/
Expressions: 	Expression COMMA Expressions
		{printf("Expressions -> Expression COMMA Expressions\n");}
		| Expression
		{printf("Expressions -> Expression\n");}
		;

Expression:	MultExpr
		{printf("Expression -> MultExpr\n");}
		| MultExpr PLUS Expression
		{printf("Expression -> MultExpr PLUS Expression\n");}
		| MultExpr MINUS Expression
		{printf("Expression -> MultExpr MINUS Expression\n");}
		;
/*KATIE:mult expr*/
MultExpr:	Term
		{printf("MultExpr -> Term\n");}
		| Term MULT MultExpr
		{printf("MultExpr -> Term MULT MultExpr\n");}
		| Term DIV MultExpr
		{printf("MultExpr -> Term DIV MultExpr\n");}
		| Term MOD MultExpr
		{printf("MultExpr -> Term MOD MultExpr\n");}
		;
/*KATIE:term*/
Term:		Var
		{printf("Term -> Var\n");}
		| MINUS var
		{printf("Term -> MINUS Var\n");}
		| NUMBER
		{printf("Term -> NUMBER\n");}
		| MINUS NUMBER
		{printf("Term -> MINUS NUMBER\n");}
		| L_PAREN exp R_PAREN
		{printf("Term -> L_PAREN Expression R_PAREN\n");}
		| MINUS L_PARAM Expression R_PARAM
		{printf("Term -> MINUS L_PAREN Expression R_PAREN\n");}
		| IDENTIFIER L_PAREN Expressions R_PAREN
		{printf("Term -> IDENTIFIER L_PAREN Expressions R_PAREN\n");}
		;
/*KATIE:var*/
Vars		Var COMMA Vars
		{printf("Vars -> Var COMMA Vars\n");}
		| Var
		{printf("Vars -> Var\n");}
		;

Var:		IDENTIFIER	
		{printf("Var -> IDENTIFIER\n");}
		| IDENTIFIER L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
		{printf("Var -> IDENTIFIER L_SQUARE_BRACKET Expression R_SQUARE_BRACKET\n");}
		;

%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", curLn, curPos, msg);
}
