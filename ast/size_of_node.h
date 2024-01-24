#ifndef __MML_AST_SIZE_OF_H__
#define __MML_AST_SIZE_OF_H__

#include <cdk/ast/expression_node.h>

namespace mml {

  class size_of_node: public cdk::expression_node {
    cdk::expression_node *_expression;

  public:
    size_of_node(int lineno, cdk::expression_node *expression = nullptr) :
        cdk::expression_node(lineno), _expression(expression) {
    }

  public:
    cdk::expression_node* expression() {
      return _expression;
    }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_size_of_node(this, level);
    }

  };

} // mml

#endif
