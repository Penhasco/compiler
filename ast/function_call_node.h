#ifndef __MML_FUNCTION_CALL_NODE_H__
#define __MML_FUNCTION_CALL_NODE_H__

#include <cdk/ast/expression_node.h>

namespace mml {

  /**
   * Class for describing function call nodes.
   */
  class function_call_node: public cdk::expression_node {
    cdk::expression_node *_expression;
    cdk::sequence_node * _arguments;

  public:
    inline function_call_node(int lineno, cdk::expression_node *expression, cdk::sequence_node * arguments) :
        cdk::expression_node(lineno), _expression(expression), _arguments(arguments) {
    }

  public:
    inline cdk::expression_node* expression() {
      return _expression;
    }
     
    inline cdk::sequence_node *arguments() {
      return _arguments;
    }
    
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_call_node(this, level);
    }

  };

} // mml

#endif