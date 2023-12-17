local ccc = require('ccc')

ccc.setup({
  inputs = { ccc.input.rgb, ccc.input.hsv },
  outputs = { ccc.output.hex, ccc.output.css_rgb },
  highlighter = {
    lsp = false,
  },
})
