local chars = {}

if vim.fn.hostname() == 'sharkie' then
  chars = {
    'a', 'r', 's', 't', 'g',
    'k', 'n', 'e', 'i', 'o',
    'w', 'f', 'p', 'l', 'u',
    'y', 'c', 'd', 'v', 'm',
    'h', 'j', 'b', 'q', 'x',
    'z'
  }
else
  chars = {
    'a', 's', 'd', 'f', 'g',
    'h', 'j', 'k', 'l', 'q',
    'w', 'e', 'r', 't', 'y',
    'u', 'i', 'o', 'p', 'z',
    'x', 'c', 'v', 'b', 'n',
    'm'
  }
end

require('nvim-window').setup({
  border = 'none',
  normal_hl = 'BlackOnLightYellow',
  chars = chars,
})
