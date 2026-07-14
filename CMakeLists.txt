add_llvm_library( LLVMMergeReturnPass MODULE
  MergeReturnPass.cpp

  PLUGIN_TOOL
  opt
  )
