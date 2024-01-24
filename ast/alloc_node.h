#ifndef __MML_AST_ALLOC_NODE_H__
#define __MML_AST_ALLOC_NODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/unary_operation_node.h>

namespace mml {

	/**
	* Class for describing memory reservation node
	**/

	class alloc_node: public cdk::unary_operation_node {

	public:
		inline alloc_node(int lineno, cdk::expression_node *arg) :
			cdk::unary_operation_node(lineno, arg) {}

	public:
		void accept(basic_ast_visitor *sp, int level) {
			sp->do_alloc_node(this, level);
		}

	};

} // mml

#endif