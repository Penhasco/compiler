#ifndef __MML_TARGETS_SYMBOL_H__
#define __MML_TARGETS_SYMBOL_H__

#include <cdk/types/basic_type.h>
#include <memory>
#include <string>
#include <vector>

namespace mml {

class symbol {
  std::shared_ptr<cdk::basic_type> _type;
  std::string _name;
  long _value; // hack!

  bool _constant; // is it a constant?
  bool _isForward;
  bool _isForeign;
  bool _isPublic;
  bool _isAuto;
  std::vector<std::shared_ptr<cdk::basic_type>> _argument_types;
  bool _initialized; // initialized?
  int _offset = 0;   // 0 (zero) means global variable/function
  bool _function;    // false for variables
  bool _forward = false;

public:
  symbol(std::shared_ptr<cdk::basic_type> type, const std::string &name,
         long value, bool constant = false)
      : _type(type), _name(name), _value(value), _constant(constant){}

  virtual ~symbol() {
    // EMPTY
  }

  std::shared_ptr<cdk::basic_type> type() const { return _type; }
  bool is_typed(cdk::typename_type name) const { return _type->name() == name; }
  const std::string &name() const { return _name; }
  long value() const { return _value; }
  long value(long v) { return _value = v; }

  bool constant() const { return _constant; }

  bool isForward() { return _isForward; }

  bool isForeign() { return _isForeign; }

  bool isPublic() { return _isPublic; }

  bool isAuto() { return _isAuto; }

  bool initialized() const { return _initialized; }
  int offset() const { return _offset; }
  void set_offset(int offset) { _offset = offset; }
  bool isFunction() const { return _function; }

  bool global() const { return _offset == 0; }
  bool isVariable() const { return !_function; }

  bool forward() const { return _forward; }

  void set_argument_types(
      const std::vector<std::shared_ptr<cdk::basic_type>> &types) {
    _argument_types = types;
  }

  bool argument_is_typed(size_t ax, cdk::typename_type name) const {
    return _argument_types[ax]->name() == name;
  }
  std::shared_ptr<cdk::basic_type> argument_type(size_t ax) const {
    return _argument_types[ax];
  }

  size_t argument_size(size_t ax) const { return _argument_types[ax]->size(); }

  size_t number_of_arguments() const { return _argument_types.size(); }
};

} // namespace mml

#endif