
#include <vector>
#include <string>
#include <iostream>
#include <sstream>

class Generator
{
  public:
    static int counter_label;
    static int counter_var;

    static void init()
    {
        counter_label = 0;
        counter_var = 0;
    }

    static std::string make_label()
    {
        std::string temp = "__label__";
        temp += std::to_string(counter_label++);
        return temp;
    }

    static std::string make_var()
    {
        std::string temp = "__temp__";
        temp += std::to_string(counter_var++);
        return temp;
    }
};

class ASTNode
{
  public:
    virtual std::string gencode() = 0;
};


class Expr : public ASTNode
{
  public:
    Expr(Expr *p1, std::string op, Expr *p2) : p1(p1), op(op), p2(p2) {}
    virtual ~Expr()
    {
        delete p1;
        delete p2;
    }

    virtual std::string gencode()
    {
        std::stringstream ss;
	if(p1 != NULL) {
            ss << p1->gencode() << p2->gencode();
            std::string temp = Generator::make_var();
            ss << op << ' ' << temp << ", " << p1->ret_var << ", " << p2->ret_var << '\n';
            ret_var = temp;
	} else {
	//if p1 is null, that means expr has a unary op (- or !)
	    ss << p2->gencode();
	    if (op == "-") {
	    	std::string temp0 = Generator::make_var();
	    	ss << "= " << temp0 << ", 0" << '\n';
	    	std::string temp1 = Generator::make_var();
	    	ss << op << ' ' << temp1 << ", " << temp0 << ", " << p2->ret_var << '\n';
	    	ret_var = temp1;
	    } else { //op == "!"
		std::string temp = Generator::make_var();
		ss << op << ' ' << temp << ", " << p2->ret_var << '\n';
		ret_var = temp;
	    }
	}
        return ss.str();
    }

    std::string ret_var;

  protected:
    Expr() {}
    Expr *p1 = nullptr, *p2 = nullptr;
    std::string op;
};


class Variable : public Expr
{
  public:
    std::string ret_var = "";
};

class VarList : public Variable
{
  public:
    VarList() {}
    virtual ~VarList()
    {
	for (auto v : var_vec)
	{
		delete v;
	}
    }
    void append(Variable *v) { var_vec.insert(var_vec.begin(), v);}

    virtual std::string gencode() {
	std::stringstream ss;
	for (auto v : var_vec) {
	    ss << v->gencode();
	}
	return ss.str();
    }

  protected: 
    std::vector<Variable *> var_vec;
};

class IdVar : public Variable
{
  public:
    IdVar(std::string name) : name(name) {}

    virtual std::string gencode()
    {
	ret_var = name;
	return "";	
    }

    std::string ret_var;

  protected:
    std::string name;
};

class ArrayVar : public Variable
{
  public:
    ArrayVar(std::string name, Expr* exprIndex) : name(name), exprIndex(exprIndex) {}

    virtual std::string gencode()
    {
	std::string temp = Generator::make_var();
	ret_var = name + ", " + temp;
	std::stringstream ss;
	ss << exprIndex->gencode();
	return ss.str();	
    }

    std::string ret_var;


  protected:
    std::string name;
    Expr* exprIndex;
};



class ExprList : Expr
{
  public:
    ExprList() {}
    virtual ~ExprList()
    {
	for(auto e : expr_vec) { delete e; }
    }
    void append(Expr *e) { expr_vec.insert(expr_vec.begin(), e); }

    virtual std::string gencode()
    {
	std::stringstream ss;
	for(auto e : expr_vec) { 
	    ss << e->gencode();
	}
	return ss.str();
    }

    std::vector<Expr *> expr_vec;

  protected:
};

class ExprID : public Expr
{
  public:
    ExprID(std::string name) : name(name) {}
    virtual std::string gencode()
    {
        ret_var = name;
        return "";
    }

  protected:
    std::string name;
};

class ExprNumber : public Expr
{
  public:
    ExprNumber(int number) : number(number) {}
    virtual std::string gencode()
    {
        std::string temp = Generator::make_var();
        ret_var = temp;
        std::stringstream ss;
        ss << "= " << temp << ", " << std::to_string(number) << '\n';
        return ss.str();
    }

  protected:
    int number;
};

class ExprBool : public Expr
{
  public:
    ExprBool(std::string bval) : bval(bval) {}
    virtual std::string gencode()
    {
        std::string temp = Generator::make_var();
        ret_var = temp;
        std::stringstream ss;
        ss << "= " << temp << ", " << bval << '\n';
        return ss.str();
    }

  protected:
    std::string bval;
};

class ExprArray : public Expr
{
  public:
    ExprArray(ArrayVar* arr) : arr(arr) {}
    virtual std::string gencode()
    {
	std::string temp = Generator::make_var();
	ret_var = temp;
	std::stringstream ss;
	ss << "=[] " << temp << ", " << arr->ret_var << '\n';
	return ss.str();	
    }

  protected:
    ArrayVar* arr;
};

class Statement : public ASTNode
{};

class StatementList : public ASTNode
{
  public:
    StatementList() {}
    virtual ~StatementList()
    {
        for (auto s : stat_vec)
        {
            delete s;
        }
    }
    void append(Statement *s) { stat_vec.insert(stat_vec.begin(), s); }

    std::string backpatch(std::string label) {
        std::string code = gencode();
        int index = code.find("FAKE_LABEL");

        code.replace(index, 10, label); //"FAKE_LABEL" has length 10
        return code;
    }

    virtual std::string gencode() {
        std::stringstream ss;
        for (auto s : stat_vec) {
            ss << s->gencode();
        }
        return ss.str();
    }

  protected:
    std::vector<Statement *> stat_vec;
};

class ReturnStatement : public Statement
{
  public :
    ReturnStatement(Expr *expr) : expr(expr) {}
    virtual std::string gencode() {
	std::stringstream ss;
	expr->gencode();
	ss << "ret " << expr->ret_var << '\n';
	return ss.str();
    }

  protected:
    Expr *expr;
};

class WhileStatement : public Statement
{
  public:
    WhileStatement(Expr *bool_expr, StatementList *while_block)
	: bool_expr(bool_expr), while_block(while_block) {}
    virtual std::string gencode() {
	std::stringstream ss;
	std::string condition, begin_loop, end_loop;
	begin_loop = Generator::make_label(); //l0
	end_loop = Generator::make_label(); //l1
	condition = Generator::make_label(); //l2
	
	ss << ": " << condition << '\n';
	ss << bool_expr->gencode();
	ss << "?:= " << begin_loop << ", " << bool_expr->ret_var << '\n';
	ss << ":= " << end_loop << '\n';
	ss << ": " << begin_loop << '\n';
	ss << while_block->backpatch(condition);
	ss << ":= " << condition << '\n';
	ss << ": " << end_loop << '\n';

	return ss.str();
    }

  protected:
    Expr *bool_expr;
    StatementList *while_block;
};

class DoWhileStatement : public Statement
{
  public: 
    DoWhileStatement(StatementList *loop_block, Expr *bool_expr)
	: loop_block(loop_block), bool_expr(bool_expr) {}

    virtual std::string gencode() {
	std::stringstream ss;
	std::string begin_loop, end_loop, condition;
	begin_loop = Generator::make_label();
	end_loop = Generator::make_label();
	condition = Generator::make_label();

	ss << ": " << begin_loop << '\n';
	ss << loop_block->backpatch(condition);
	ss << ": " << condition << '\n';
	ss << bool_expr->gencode();
	ss << "?:= " << begin_loop << ", " << bool_expr->ret_var << '\n';
	ss << ":= " << end_loop << '\n';
	ss << ": " << end_loop << '\n';

	return ss.str();
    }

  protected:
    Expr *bool_expr;
    StatementList *loop_block;
};

class ContinueStatement : public Statement
{
    public:
	ContinueStatement() {}

	virtual std::string gencode() {
	    std::stringstream ss;
	    ss << "goto FAKE_LABEL\n";

	    return ss.str();
	}
};

class IfStatement : public Statement
{
  public:
    IfStatement(Expr *bool_expr, StatementList *block) : bool_expr(bool_expr), block(block) {}
    virtual std::string gencode() {
	std::stringstream ss;
	std::string l0, l1;
	l0 = Generator::make_label();
	l1 = Generator::make_label();
	
	ss << "?:=" << l0 << ", " << bool_expr->ret_var << '\n';
	ss << ":= " << l1 << '\n';
	ss << ": " << l0 << '\n';
	ss << block->gencode();
	ss << ": " << l1;

	return ss.str();
    }

  protected:
    Expr *bool_expr;
    StatementList *block;
};

class IfElseStatement : public Statement
{
  public:
    IfElseStatement(Expr *bool_expr, StatementList *then_block, StatementList *else_block)
        : bool_expr(bool_expr), then_block(then_block), else_block(else_block) {}

    virtual std::string gencode() {
        std::stringstream ss;
        ss << bool_expr->gencode();
        std::string l0, l1, l2;
        l0 = Generator::make_label();
        l1 = Generator::make_label();
        l2 = Generator::make_label();

        ss << "?:= " << l0 << ", " << bool_expr->ret_var << '\n';
        ss << ":= " << l1 << '\n';
        ss << ": " << l0 << '\n';
        ss << then_block->gencode();
        ss << ":= " << l2 << '\n';
        ss << ": " << l1 << '\n';
        ss << else_block->gencode();
        ss << ": " << l2 << '\n';
        return ss.str();
    }


  protected:
    Expr *bool_expr;
    StatementList *then_block;
    StatementList *else_block;
};

class ExprStatement : public Statement
{
  public:
    ExprStatement(Expr *expr) : expr(expr) {}
    virtual ~ExprStatement() { delete expr; }

    virtual std::string gencode() {
        return expr->gencode();
    }

  protected:
    Expr *expr;
};

class AssignStatement : public Statement
{
  public:
    AssignStatement(Variable *var, Expr *expr) : var(var), expr(expr) {}
    virtual ~AssignStatement() { delete expr; }

    virtual std::string gencode()
    {
        std::stringstream ss;
	ss << var->gencode();
        ss << expr->gencode();
	if (var->ret_var.find(',') == std::string::npos) { // assign to a variable
            ss << "= " << var->ret_var << ", " << expr->ret_var << '\n';
	} else { // assign to an array
	    ss << "[]= " << var->ret_var << ", " << expr->ret_var << '\n';
	}
        return ss.str();
    }

  protected:
    Variable *var;
    Expr *expr;
};

class Declaration : public Statement
{
  public:
    Declaration(std::string name) { id_list.push_back(name); }
    Declaration(std::string name, int arr_size) : arr_size(arr_size) { id_list.push_back(name); }

    virtual std::string gencode()
    {
        std::stringstream ss;
	for (auto name : id_list) {
	    if (arr_size < 0) { // not an array
            	ss << ". " << name << '\n';
	    } else { // is an array
	    	ss << ".[] " << name << ", " << arr_size << '\n';
	    }
	}
        return ss.str();
    }

    void append(std::string name) { id_list.insert(id_list.begin(), name);}

  protected:
    std::vector<std::string> id_list;
    int arr_size = -1;
};

class ReadStatement : public Statement
{
  public: 
    ReadStatement(VarList *var) : var(var) {}

    virtual std::string gencode()
    {
	std::stringstream ss;
	size_t id = var->ret_var.find(",");
	if (id == std::string::npos) {
	    //not an arr
	    ss << ".< " << var->ret_var << '\n';
	} else {
	    //is an array
	    ss << ".[]< " << var->ret_var << '\n';
	}
	return ss.str();
    }

  protected:
    Variable *var;
};

class WriteStatement : public Statement
{
  public:
    WriteStatement(VarList *var) : var(var) {}

    virtual std::string gencode()
    {
	std::stringstream ss;
	size_t id = var->ret_var.find(",");
	if (id == std::string::npos) {
	    ss << ".> " << var->ret_var << '\n';
	} else {
	    ss << ".[]> " << var->ret_var << '\n';
	}
	return ss.str();
    }

  protected:
    Variable *var;
};


class Function : public ASTNode
{
  public:
    Function(char *func, StatementList *params, StatementList *locals, StatementList *body) : func(func), params(params), locals(locals), body(body) {}
    virtual std::string gencode() 
    {
	std::stringstream ss;
 	ss << "func " << func << '\n';
	ss << params->gencode();
	ss << locals->gencode();
	ss << body->gencode();
	ss << "endfunc\n";

	return ss.str();
    }

  protected:
    char *func;
    StatementList *params;
    StatementList *locals;
    StatementList *body;
};

class FunctionList : public ASTNode
{
  public:
    FunctionList() {}
    virtual ~FunctionList()
    {
        for (auto f : func_vec)
        {
            delete f;
        }
    }
    void append(Function *f) { func_vec.insert(func_vec.begin(), f); }

    virtual std::string gencode() {
        std::stringstream ss;
        for (auto f : func_vec) {
            ss << f->gencode();
        }
        return ss.str();
    }

  protected:
    std::vector<Function *> func_vec;
};

class FunctionCall : public Variable
{
  public:
    FunctionCall(std::string func, ExprList *param) : func(func), param(param) {}
    virtual std::string gencode()
    {
	std::stringstream ss;
	std::string temp = Generator::make_var();
	param->gencode();
	for( auto p : param->expr_vec ) {
		ss << "param " << p->ret_var << '\n';
	} 
	ss << "call " << func << ", " << temp << '\n';
	ret_var = temp;
	return ss.str();
    }

    std::string ret_var;

  protected:
    //FunctionCall() {}
    std::string func;
    ExprList *param;
};
