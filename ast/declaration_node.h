#ifndef __MML_AST_DECLARATION_NODE_H__
#define __MML_AST_DECLARATION_NODE_H__

#include <cdk/ast/basic_node.h>

namespace mml
{

    /**
     * Class for describing variable and function declaration nodes.
     */
    class declaration_node : public cdk::basic_node
    {
        bool _isForward;
        bool _isForeign;
        bool _isPublic;
        bool _isAuto;

        std::shared_ptr<cdk::basic_type> _type;
        std::string _identifier;
        cdk::expression_node *_initializer;

    public:
        inline declaration_node(int lineno, bool isForward, bool isForeign, bool isPublic, bool isAuto, std::shared_ptr<cdk::basic_type> type, std::string identifier, cdk::expression_node *initializer) : cdk::basic_node(lineno), _isForward(isForward), _isForeign(isForeign), _isPublic(isPublic), _isAuto(isAuto), _type(type), _identifier(identifier), _initializer(initializer)
        {
        }

                inline bool isForward()
        {
            return _isForward;
        }

        inline bool isForeign()
        {
            return _isForeign;
        }

        inline bool isPublic()
        {
            return _isPublic;
        }

        inline bool isAuto()
        {
            return _isAuto;
        }

        inline std::shared_ptr<cdk::basic_type> type()
        {
            return _type;
        }

        inline std::string identifier()
        {
            return _identifier;
        }

        inline cdk::expression_node *initializer()
        {
            return _initializer;
        }

        bool constant() {
            return false; 
        }

    public:
        void accept(basic_ast_visitor *sp, int level)
        {
            sp->do_declaration_node(this, level);
        }
    };

} // mml

#endif
