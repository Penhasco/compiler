%option c++ prefix="mml_scanner_" outfile="mml_scanner.cpp"
%option stack noyywrap yylineno 8bit debug
%{ 
// make relevant includes before including the parser's tab file
#include <string>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include "mml_parser.tab.h"

// don't change this
#define yyerror LexerError

/*  ([0-9]+[89][0-9]+)? */
%}
%x X_STRING
%x X_COMMENT
%x X_IGNORE

%%
  yydebug=1; set_debug(1);

  /* ====================================================================== */
  /* ====[                      COMMENTS                              ]==== */
  /* ====================================================================== */

"//".*                 ; /* ignore comments */
"/*"                   yy_push_state(X_COMMENT);
<X_COMMENT>"/*"        yy_push_state(X_COMMENT);
<X_COMMENT>"*/"        yy_pop_state();
<X_COMMENT>.|"\n"      ;  /* ignore inside comments */


  /* ====================================================================== */
  /* ====[                   EXPRESSION OPERATORS                     ]==== */
  /* ====================================================================== */

"->"                   return tFE;
">="                   return tGE; 
"<="                   return tLE; 
"=="                   return tEQ; 
"!="                   return tNE; 
"!!"                   return tPRINTLINE; 
"||"                   return tOR;
"&&"                   return tAND;
[-()[\]<>=+*/%&!;?@{}~,.]       return *yytext;

  /* ====================================================================== */
  /* ====[                   DATA TYPES                               ]==== */
  /* ====================================================================== */

"int"                  return tINT;
"string"               return tTYPE_TEXT;
"auto"                 return tTYPE_AUTO;
"double"               return tTYPE_DOUBLE;
"void"                 return tTYPE_VOID;
"sizeof"               return tSIZEOF;

  /* ====================================================================== */
  /* ====[                  GLOBAL SYMBOLS                            ]==== */
  /* ====================================================================== */

"forward"              return tFORWARD;
"foreign"              return tFOREIGN;
"public"               return tPUBLIC;

  /* ====================================================================== */
  /* ====[               CONDITIONAL INSTRUCTION                      ]==== */
  /* ====================================================================== */
 
"if"                   return tIF; 
"else"                 return tELSE; 
"elif"                 return tELIF;


  /* ====================================================================== */
  /* ====[                 ITERATION INSTRUCTION                      ]==== */
  /* ====[                 RETURN INSTRUCTION                         ]==== */
  /* ====[                 STOP INSTRUCTION                           ]==== */
  /* ====================================================================== */

"while"                return tWHILE;
"read"                 return tREAD; 
"return"               return tRETURN;
"next"                 return tNEXT;
"stop"                 return tSTOP;

  /* ====================================================================== */
  /* ====[                FUNCTION LIMITERS                           ]==== */
  /* ====================================================================== */

"begin"                return tBEGIN; 
"end"                  return tEND; 

  /* ====================================================================== */
  /* ====[                 IDENTIFIER                                 ]==== */
  /* ====================================================================== */

[A-Za-z][A-Za-z0-9_]*  yylval.s = new std::string(yytext); return tIDENTIFIER;


  /* ====================================================================== */
  /* ====[                 STRING OF CHARACTERES                      ]==== */
  /* ====================================================================== */

\"                           yy_push_state(X_STRING); yylval.s = new std::string("");
<X_STRING>\"                 yy_pop_state(); return tSTRING;
<X_STRING>\\\"               *yylval.s += yytext + 1;
<X_STRING>\\\\               *yylval.s += yytext + 1;
<X_STRING>\\n                *yylval.s += '\n';
<X_STRING>\\r                *yylval.s += '\r';
<X_STRING>\\t                *yylval.s += '\t';
<X_STRING>\\0                yy_push_state(X_IGNORE);
<X_STRING>\\[0-7]{1,3}       *yylval.s += (char) strtol(yytext+1, NULL, 8);
<X_STRING>\0                 yyerror("nullbyte in string");
<X_STRING>.|\n               *yylval.s += yytext;

<X_IGNORE>\0                 yyerror("null byte in string");
<X_IGNORE>\"                 yy_pop_state(); yy_pop_state(); return tSTRING;
<X_IGNORE>.|\n        

  /* ====================================================================== */
  /* ====[                   INTEGERS                                 ]==== */
  /* ====================================================================== */

0|[1-9][0-9]*         yylval.i = strtol(yytext, nullptr, 10); return tINTEGER;
0[0-7]+               yylval.i = strtol(yytext, nullptr, 8); return tINTEGER;

  /* ====================================================================== */
  /* ====[                   ACTUAL FIGURES                           ]==== */
  /* ====================================================================== */

([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)([eE][-+]?[0-9]+)? { yylval.d = strtod(yytext, NULL); return tDOUBLE; }

[0-9]+[eE][-+]?[0-9]+   { yylval.d = strtod(yytext, NULL); return tDOUBLE; }       /*Float sem ponto, apenas com o exponecial */

 




[ \t\n]+               ; /* ignore whitespace */

.                      yyerror("Unknown character");

%%