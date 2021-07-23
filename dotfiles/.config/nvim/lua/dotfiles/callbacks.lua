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

local function start_or_after_space()
  local col = fn.col('.') - 1

  return col == 0 or api.nvim_get_current_line():sub(col, col):match('%s')
end

function M.yanked()
  vim.highlight.on_yank({
    higroup = 'Visual',
    timeout = 150,
    on_visual = false
  })
end

function M.tab()
  if popup_visible() then
    return keycode('<C-n>')
  end

  return start_or_after_space() and keycode('<tab>') or keycode('<C-x><C-U>')
end

function M.shift_tab()
  return popup_visible() and keycode('<C-p>') or keycode('<S-tab>')
end

function M.enter()
  return popup_visible() and completion.confirm() or pairs.enter()
end

function M.abbreviate_grep()
  if fn.getcmdtype() == ':' and fn.getcmdline():match('^grep') then
    return 'silent grep!'
  else
    return 'grep'
  end
end

function M.control_s()
  if fn['vsnip#expandable']() then
    return keycode('<Plug>(vsnip-expand)')
  else
    return keycode('<C-s>')
  end
end

function M.control_j()
  if fn['vsnip#jumpable'](1) then
    return keycode('<Plug>(vsnip-jump-next)')
  else
    return keycode('<C-j>')
  end
end

function M.control_k()
  if fn['vsnip#jumpable'](-1) then
    return keycode('<Plug>(vsnip-jump-prev)')
  else
    return keycode('<C-k>')
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

function M.definition()
  local bufnr = api.nvim_get_current_buf()

  if #lsp.buf_get_clients(bufnr) == 0 then
    api.nvim_feedkeys(keycode('<C-]>'), 'n', true)
  else
    lsp.buf.definition()
  end
end

return M
