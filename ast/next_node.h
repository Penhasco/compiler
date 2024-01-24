#ifndef __MML_AST_NEXT_NODE_H__
#define __MML_AST_NEXT_NODE_H__

#include <cdk/ast/expression_node.h>

namespace mml {
  /**
   * Class for describing next nodes.
   */
  class next_node: public cdk::basic_node {
    int _level;
    public:
    inline next_node(int lineno, int level) :
      cdk::basic_node(lineno) , _level(level){}

    public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_next_node(this, level);
    }
    inline int level() {
      return _level;
    }

  };

} // mml

#endif