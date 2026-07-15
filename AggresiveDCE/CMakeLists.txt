add_llvm_library( LLVMMyPass MODULE 
  MyPass.cpp

  PLUGIN_TOOL
  opt
  )
