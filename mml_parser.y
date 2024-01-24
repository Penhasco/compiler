%{
//-- don't change *any* of these: if you do, you'll break the compiler.
#include <algorithm>
#include <memory>
#include <cstring>
#include <cdk/compiler.h>
#include <cdk/types/types.h>
#include ".auto/all_nodes.h"
#define LINE                         compiler->scanner()->lineno()
#define yylex()                      compiler->scanner()->scan()
#define yyerror(compiler, s)         compiler->scanner()->error(s)
//-- don't change *any* of these --- END!
%}

%parse-param {std::shared_ptr<cdk::compiler> compiler}

%union {
  //--- don't change *any* of these: if you do, you'll break the compiler.
  YYSTYPE() : type(cdk::primitive_type::create(0, cdk::TYPE_VOID)) {}
  ~YYSTYPE() {}
  YYSTYPE(const YYSTYPE &other) { *this = other; }
  YYSTYPE& operator=(const YYSTYPE &other) { type = other.type; return *this; }

  //-- don't change *any* of these --- END!
  double                d; 
  int                   i;	/* integer value */
  std::string          *s;	/* symbol name or string literal */
  cdk::basic_node      *node;	/* node pointer */
  cdk::sequence_node   *sequence;
  cdk::expression_node *expression; /* expression nodes */
  cdk::lvalue_node     *lvalue;
  std::shared_ptr<cdk::basic_type> type;        /* expression type */
  mml::block_node      *block;
  std::vector< std::shared_ptr<cdk::basic_type>> *functype;
};

%token <i> tINTEGER 
%token <d> tDOUBLE
%token <s> tIDENTIFIER tSTRING
%token tWHILE tIF tPRINTLINE tREAD tBEGIN tEND tRETURN tELIF tELSE
%token tOR tAND tFE tPUBLIC tNEXT tSTOP
%token tFOREIGN tFORWARD tAUTO tINT tTYPE_TEXT tTYPE_DOUBLE tTYPE_VOID tTYPE_AUTO tSIZEOF

%nonassoc tIFX
%nonassoc tELSE tIF tELIF tWHILE
%nonassoc '~'

%right '='
%left tGE tLE tEQ tNE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%left tOR tAND


%nonassoc tUNARY
%nonassoc tUMINUS
%nonassoc '('


%type <node> stmt program iffalse whiledec 
%type <sequence> list exprs 
%type <expression> expr 
%type <lvalue> lval
%type <s> string
%type<sequence> file seqdecl vardecs opt_vardecs func_args 
%type<node> decl vardec func_arg 
%type<type> dtype 
%type<block> block block_stmts
%type<functype> func_type opt_data_type



%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

file         : /* empty */                {$$ = new cdk::sequence_node(LINE); }
             | seqdecl               { $$ = $1; }
             | seqdecl program       {$$ = new cdk::sequence_node(LINE,$2,$1);}
             | program                    { $$ = new cdk::sequence_node(LINE, $1);}
             ;



program	: tBEGIN block_stmts tEND { compiler->ast(new mml::program_node(LINE, $2)); }
	     ;


list : stmt	     { $$ = new cdk::sequence_node(LINE, $1); }
	   | list stmt { $$ = new cdk::sequence_node(LINE, $2, $1); }
	   ;

seqdecl: decl                                                         { $$ = new cdk::sequence_node(LINE, $1);}
       | seqdecl decl                                                 { $$ = new cdk::sequence_node(LINE, $2, $1);}
       ;


decl   : vardec ';'                                                      { $$ = $1;}
     ;


vardec   : dtype tIDENTIFIER                                             { $$ = new mml::declaration_node(LINE, false, false, false, false, $1, *$2, nullptr); delete $2; }
          | dtype tIDENTIFIER '=' expr                                     { $$ = new mml::declaration_node(LINE, false, false, false, false, $1, *$2, $4); delete $2; }
          | tTYPE_AUTO tIDENTIFIER '=' expr         { $$ = new mml::declaration_node(LINE, false, false, false, true, nullptr, *$2, $4); delete $2; }
          | tFORWARD dtype tIDENTIFIER          { $$ = new mml::declaration_node(LINE, true, false, false, false, $2, *$3, nullptr); delete $3; }
          | tPUBLIC dtype tIDENTIFIER          { $$ = new mml::declaration_node(LINE, false, false, true, false, $2, *$3, nullptr); delete $3; }
          | tPUBLIC dtype tIDENTIFIER '=' expr         { $$ = new mml::declaration_node(LINE,  false, false, true, false, $2, *$3, $5); delete $3; }
          | tPUBLIC  tIDENTIFIER '=' expr         { $$ = new mml::declaration_node(LINE,  false, false, true, false, nullptr, *$2, $4); delete $2; }
          | tPUBLIC tTYPE_AUTO tIDENTIFIER '=' expr         { $$ = new mml::declaration_node(LINE,  false, false, true, false, nullptr, *$3, $5); delete $3; }
          | tFOREIGN dtype tIDENTIFIER          { $$ = new mml::declaration_node(LINE, false, true, false, false, $2, *$3, nullptr); delete $3; }
          ;


vardecs      : vardec ';'          { $$ = new cdk::sequence_node(LINE, $1);     }
             | vardecs vardec ';' { $$ = new cdk::sequence_node(LINE, $2, $1); }
             ;
             
opt_vardecs  : /* empty */ { $$ = NULL; }
             | vardecs     { $$ = $1; }
             ;
opt_data_type: dtype                          { $$ = new std::vector<std::shared_ptr<cdk::basic_type>>(); $$->push_back($1);}
             | opt_data_type ',' dtype        { $$ = $1; $$->push_back($3);}
             ;

dtype :  tINT                          { $$ = cdk::primitive_type::create(4, cdk::TYPE_INT); }
     | tTYPE_TEXT                      { $$ = cdk::primitive_type::create(4, cdk::TYPE_STRING); }
     | tTYPE_DOUBLE                    { $$ = cdk::primitive_type::create(8, cdk::TYPE_DOUBLE); }
     | tTYPE_VOID                      { $$ = cdk::primitive_type::create(0, cdk::TYPE_VOID); }
     | '[' dtype ']'                   { $$ = cdk::reference_type::create(4, $2); }
     | func_type '<' opt_data_type '>'  { $$ = cdk::functional_type::create(*$3,*$1); } 
     | func_type '<' '>'                { $$ = cdk::functional_type::create(*(new std::vector<std::shared_ptr<cdk::basic_type>>()),*$1); } 
     ;


func_type: dtype {$$=new std::vector<std::shared_ptr<cdk::basic_type>>(); $$->push_back($1);} 
          ;


func_args  : func_arg       { $$ = new cdk::sequence_node(LINE, $1);     }
           | func_args ',' func_arg     { $$ = new cdk::sequence_node(LINE, $3, $1); }
           | /*empty*/   { $$ = new cdk::sequence_node(LINE);     }
           ;


func_arg   : dtype tIDENTIFIER { $$ = new mml::declaration_node(LINE, false, false, false, true, $1, *$2, nullptr); }
          ;


block_stmts : opt_vardecs list        { $$ = new mml::block_node(LINE, $1, $2); }
            | opt_vardecs               { $$ = new mml::block_node(LINE, $1, nullptr); }
            ;

block    : '{' block_stmts '}' {$$ = $2;}
         ;


stmt : expr ';'                         { $$ = new mml::evaluation_node(LINE, $1); }
     | exprs tPRINTLINE          { $$ = new mml::print_node(LINE, $1, true); }
     | exprs '!'                   { $$ = new mml::print_node(LINE, $1, false); }
     | tREAD lval ';'                   { $$ = new mml::read_node(LINE, $2); }
     | whiledec                         { $$ = $1; }
     | tIF '(' expr ')' stmt %prec tIFX { $$ = new mml::if_node(LINE, $3, $5); }
     | tIF '(' expr ')' stmt iffalse { $$ = new mml::if_else_node(LINE, $3, $5, $6); } 
     | '{' block_stmts '}'                     { $$ = $2; }
     | tRETURN expr ';'                  { $$ = new mml::return_node(LINE, $2); }
     | tRETURN ';'            { $$ = new mml::return_node(LINE); }
     | tSTOP tINTEGER ';' { $$ = new mml::stop_node(LINE, $2); }
     | tSTOP  ';' { $$ = new mml::stop_node(LINE, 1); }
     | tNEXT  tINTEGER  ';' { $$ = new mml::next_node(LINE, $2); }
     | tNEXT  ';' { $$ = new mml::next_node(LINE,1); }
     ;


iffalse   : tELSE stmt                             { $$ = $2; }
          | tELIF '(' expr ')' stmt %prec tIFX            { $$ = new mml::if_node(LINE, $3, $5); }
          | tELIF '(' expr ')' stmt iffalse    { $$ = new mml::if_else_node(LINE, $3, $5, $6); }
          ;


whiledec : tWHILE '(' expr ')' block { $$ = new mml::while_node(LINE,$3,$5); }

exprs : { $$ = new cdk::sequence_node(LINE); }
      | expr           { $$ = new cdk::sequence_node(LINE, $1); }
      | exprs ',' expr { $$ = new cdk::sequence_node(LINE, $3, $1); }
      ;



expr : tINTEGER                   { $$ = new cdk::integer_node(LINE, $1); }
     | tDOUBLE                    { $$ = new cdk::double_node(LINE, $1); }
     | string                     { $$ = new cdk::string_node(LINE, $1); delete $1;  }          
     | '-' expr %prec tUNARY      { $$ = new cdk::neg_node(LINE, $2); }
     | expr '+' expr	         { $$ = new cdk::add_node(LINE, $1, $3); }
     | expr '-' expr	         { $$ = new cdk::sub_node(LINE, $1, $3); }
     | expr '*' expr	         { $$ = new cdk::mul_node(LINE, $1, $3); }
     | expr '/' expr	         { $$ = new cdk::div_node(LINE, $1, $3); }
     | expr '%' expr	         { $$ = new cdk::mod_node(LINE, $1, $3); }
     | expr '<' expr	         { $$ = new cdk::lt_node(LINE, $1, $3); }
     | expr '>' expr	         { $$ = new cdk::gt_node(LINE, $1, $3); }
     | expr tOR expr              { $$ = new cdk::or_node(LINE, $1, $3); }
     | expr tAND expr             { $$ = new cdk::and_node(LINE, $1, $3); } 
     | expr tGE expr	         { $$ = new cdk::ge_node(LINE, $1, $3); }
     | expr tLE expr              { $$ = new cdk::le_node(LINE, $1, $3); }
     | expr tNE expr	         { $$ = new cdk::ne_node(LINE, $1, $3); }
     | expr tEQ expr	         { $$ = new cdk::eq_node(LINE, $1, $3); }
     | tSIZEOF '(' expr ')'       { $$ = new mml::size_of_node(LINE, $3); }
     | '(' func_args ')' tFE dtype block { $$ = new mml::function_definition_node(LINE, $2, $5, $6); }
     | expr '(' exprs ')'               { $$ = new mml::function_call_node(LINE, $1, $3); }
     | '@' '(' exprs ')'               { $$ = new mml::function_call_node(LINE, nullptr, $3); }
     | '+' expr %prec tUMINUS     { $$ = $2; }
     | '~' expr      { $$ = new cdk::not_node(LINE, $2);}
     | '(' expr ')'               { $$ = $2; }
     | lval                       { $$ = new cdk::rvalue_node(LINE, $1); }  
     | lval '=' expr              { $$ = new cdk::assignment_node(LINE, $1, $3); }
     | '[' expr ']'            { $$ = new mml::alloc_node(LINE, $2); }
     | lval '?' { $$ = new mml::read_node(LINE, $1); }
     ;




lval  : tIDENTIFIER             { $$ = new cdk::variable_node(LINE, $1); }
      | lval             '[' expr ']'                 { $$ = new mml::index_node(LINE, new cdk::rvalue_node(LINE, $1), $3); }
      | '(' expr ')' '[' expr ']'                 { $$ = new mml::index_node(LINE, $2, $5); }    
      ;

string         : tSTRING                                              { $$ = $1;                                                                                                  }
               | string tSTRING                                       { $$ = $1; $$->append(*$2); delete $2;                                                                      }
               ;


%%