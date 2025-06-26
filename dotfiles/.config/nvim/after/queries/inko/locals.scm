;; extends

; This is to work around https://github.com/folke/snacks.nvim/issues/1883.
(source_file) @local.scope
(import) @local.scope
(define_constant) @local.scope

((reopen_class
  name: _ @local.definition.type) @local.scope
 (#set! definition.type.scope "parent"))

((implement_trait
  class: _ @local.definition.type) @local.scope
 (#set! definition.type.scope "parent"))
