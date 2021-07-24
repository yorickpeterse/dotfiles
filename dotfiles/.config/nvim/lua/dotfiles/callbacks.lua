-- Functions invoked from VimL, such as when a key is pressed.
local M = {}

local completion = require('dotfiles.completion')
local pairs = require('dotfiles.pairs')
local util = require('dotfiles.util')
local icons = require('dotfiles.icons')

local keycode = util.keycode
local popup_visible = util.popup_visible
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp

function M.yanked()
  vim.highlight.on_yank({
    higroup = 'Visual',
    timeout = 150,
    on_visual = false
  })
end

function M.abbreviate_grep()
  if fn.getcmdtype() == ':' and fn.getcmdline():match('^grep') then
    return 'silent grep!'
  else
    return 'grep'
  end
end

function M.terminal(cmd)
  vim.cmd(cmd)
  vim.cmd('term')
  vim.cmd('startinsert')
end

-- Finds all occurrences of text stored in register A, replacing it with the
-- contents of register B.
function M.find_replace_register(find, replace)
  local cmd = '%s/\\V'
    .. fn.escape(fn.getreg(find), '/'):gsub('\n', '\\n')
    .. '/'
    .. fn.escape(fn.getreg(replace), '/&'):gsub('\n', '\\r')
    .. '/g'

  print(cmd)

  vim.cmd(cmd)
end

function M.remove_trailing_whitespace()
  local line = fn.line('.')
  local col = fn.col('.')

  vim.cmd([[%s/\s\+$//eg]])
  fn.cursor(line, col)
end

function M.format_buffer()
  return vim.lsp.buf.formatting_sync(nil, 1000)
end

function M.fzf_statusline()
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.statusline = 'FZF'
  vim.opt_local.signcolumn = 'no'

  vim.cmd('silent file FZF')
end

return M
