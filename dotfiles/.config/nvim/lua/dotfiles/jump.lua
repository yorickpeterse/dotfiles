local jump = require('mini/jump2d')

jump.setup({
  spotter = jump.gen_pattern_spotter('[^%s%p][^%s%p]+'),
  labels = 'mgntesiroajblpufywqvdkch',
  allowed_lines = { blank = false },
  allowed_windows = { not_current = false },
  mappings = {
    start_jumping = 's',
  },
  view = {
    n_steps_ahead = 1,
  },
  silent = true,
})
