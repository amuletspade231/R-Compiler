%{
 #include <stdio.h>
 #include <stdlib.h>
 #include "generator.hpp"

 void yyerror(const char *msg);
 extern int curLn;
 extern int curPos;
 extern ASTNode* root
 extern FILE * yyin;
 extern int yylex();
%}

%union{
  double dval;
  int ival;
  char* sval;
}

%error-verbose
%start Program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN MINUS PLUS MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN END NUMBER
%token <sval> IDENTIFIER
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
/*AMANDA:program*/
Program:	Functions
		{ $$ = $1; root = $$; }

Functions:	Function
		{ $$ = new FunctionList(); $$->append($1); }
		Function Functions 
		{ $$ = $2; $2->append($1); /*this append will be a "push front"*/ }
		| 
		{}
/*AMANDA:function*/
Function:	FUNCTION IDENTIFIER SEMICOLON BEGIN_PARAMS Declarations END_PARAMS BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY
		{ $$ = new Function($2, $5, $8, $11); }
/*AMANDA:declaration*/
Declarations:	Declaration SEMICOLON
		{printf("Declarations -> Declaration SEMICOLON\n");}
		| Declaration SEMICOLON Declarations
		{printf("Declarations -> Declaration SEMICOLON Declarations\n");}
		|
		{printf("Declarations -> Epsilon\n");}

Declaration:	IDENTIFIER COMMA Declaration
		{printf("Declaration -> IDENTIFIER COMMA Declaration\n");}
		| IDENTIFIER COLON INTEGER
		{printf("Declaration -> IDENTIFIER COLON INTEGER\n");}
		| IDENTIFIER COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
		{printf("Declaration -> IDENTIFIER COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
/*KATIE:statement*/
Statements:	Statement SEMICOLON Statements
		{$$ = $3; $3->append($1); /*append by push_front*/ }
		| Statement SEMICOLON
		{$$ = new StatementList(); $$->append($1);}
		;

Statement:	Var ASSIGN Expression
		{$$ = new DefineStatement($1, $3);}
		| IF BoolExpr THEN Statements ENDIF
		{printf("Statement -> IF BoolExpr THEN Statements ENDIF\n");}
		| IF BoolExpr THEN Statements ELSE Statements ENDIF
		{$$ = new IfElseStatement($2, $4, $6);}
		| WHILE BoolExpr BEGINLOOP Statements ENDLOOP
		{$$ = new WhileStatement($2, $4);}
		| DO BEGINLOOP Statements ENDLOOP WHILE BoolExpr
		{$$ = new DoWhileStatement($3, $6);}
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
BoolExpr:	RelationAndExpr
		{ $$ = $1; }
		| RelationAndExpr OR RelationAndExpr
		{ $$ = new Expr($1, "||", $3); }
/*AMANDA:relation and expr*/
RelationAndExpr: RelationExpr
		 { $$ = $1; }
		 | RelationExpr AND RelationExpr
		 { $$ = new Expr($1, "&&", $3); }
/*AMANDA:relation expr*/
RelationExpr:	NOT RelationExpr
		{ $$ = new Expr(NULL, "!", $2); }
		| Expression Comp Expression
		{ $$ = new Expr($1, $2, $3); }
		| TRUE
		{ $$ = new ExprBool(true); }
		| FALSE
		{ $$ = new ExprBool(false); }
		| L_PAREN BoolExpr R_PAREN
		{ $$ = $2; }
/*AMANDA:comp*/
Comp:		EQ 
		{ $$ = "=="; }
		| NEQ
		{ $$ = "!="; }
		| GT 
		{ $$ = ">"; }
		| GTE 
		{ $$ = ">="; }
		| LT 
		{ $$ = "<"; }
		| LTE
		{ $$ = "<="; }
		;
/*KATIE:expression*/
Expressions: 	Expression COMMA Expressions
		{$$ = $3; $3->append($1);}
		| Expression
		{$$ = new ExpreList(); $$->append($1);}
		;

Expression:	MultExpr
		{$$ = $1;}
		| MultExpr PLUS Expression
		{$$ = new Expr($1, "+", $3)}
		| MultExpr MINUS Expression
		{$$ = new Expr($1, "-", $3);}
		;
/*KATIE:mult expr*/
MultExpr:	Term
		{$$ = $1;}
		| Term MULT MultExpr
		{$$ = new Expr($1, "*", $3);}
		| Term DIV MultExpr
		{$$ = new Expr($1, "/", $3);}
		| Term MOD MultExpr
		{$$ = new Expr($1, "%", $3);}
		;
/*KATIE:term*/
Term:		Var
		{$$ = $1;}
		| MINUS Var
		{$$ = new Expr(NULL, "-", $2);}
		| NUMBER
		{$$ = new ExprNum($1);}
		| MINUS NUMBER
		{$$ = new Expr(NULL, "-", new ExprNum($2));}
		| L_PAREN Expression R_PAREN
		{$$ = $2;}
		| MINUS L_PAREN Expression R_PAREN
		{$$ = new Expr(NULL, "-", $3);}
		| IDENTIFIER L_PAREN Expressions R_PAREN
		{$$ = new FunctionCall($1, $2);}
		;
/*KATIE:var*/
Vars:		Var COMMA Vars
		{$$ = $3; $3->append($1);}
		| Var
		{$$ = new VarList(); $$->append($1);}
		;

Var:		IDENTIFIER	
		{$$ = new IdVar($1);}
		| IDENTIFIER L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
		{$$ = new ArrayVar($1, $3);}
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
