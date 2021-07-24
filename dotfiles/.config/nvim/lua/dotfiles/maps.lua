local M = {}

local completion = require('dotfiles.completion')
local pairs = require('dotfiles.pairs')
local util = require('dotfiles.util')
local keycode = util.keycode
local popup_visible = util.popup_visible

local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local g = vim.g

local function map_key(kind, key, action, options)
  local opts = vim.tbl_extend('force', { silent = true }, options or {})

  api.nvim_set_keymap(kind, key, action, opts)
end

local function map(key, action, options) map_key('', key, action, options) end
local function imap(key, action, options) map_key('i', key, action, options) end
local function smap(key, action, options) map_key('s', key, action, options) end
local function tmap(key, action, options) map_key('t', key, action, options) end
local function vmap(key, action, options) map_key('v', key, action, options) end

local function start_or_after_space()
  local col = fn.col('.') - 1

  return col == 0 or api.nvim_get_current_line():sub(col, col):match('%s')
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

function M.definition()
  local bufnr = api.nvim_get_current_buf()

  if #lsp.buf_get_clients(bufnr) == 0 then
    api.nvim_feedkeys(keycode('<C-]>'), 'n', true)
  else
    lsp.buf.definition()
  end
end

-- The leader key must be defined before any mappings are set.
g.mapleader = ' '
g.maplocalleader = ' '

imap('<CR>', 'v:lua.dotfiles.maps.enter()', { expr = true })
imap('<S-tab>', 'v:lua.dotfiles.maps.shift_tab()', { expr = true })
imap('<tab>', 'v:lua.dotfiles.maps.tab()', { expr = true })
map('<leader>c', '<Plug>NERDCommenterToggle')
map('<leader>w', '<cmd>lua require("nvim-window").pick()<CR>')
map('K', '<nop>')
map('s', '<cmd>HopWord<CR>')

-- FZF
map('<leader>f', ':Files<CR>')
map('<leader>t', ':BTags<CR>')
map('<leader>b', ':Buffers<CR>')

-- Fugitive
map('<leader>gs', ':vert rightbelow Git<CR>')
map('<leader>gc', ':vert rightbelow Git commit<CR>')
map('<leader>gd', ':Gdiffsplit<CR>')

-- LSP
map('<leader>h', ':lua vim.lsp.buf.hover()<CR>')
map('<leader>r', ':lua vim.lsp.buf.rename()<CR>')
map('<leader>d', ':lua dotfiles.maps.definition()<CR>')
map('<leader>i', ':lua vim.lsp.buf.references()<CR>')
map('<leader>a', ':lua vim.lsp.buf.code_action()<CR>')
map('<leader>e', ':lua dotfiles.diagnostics.show_line_diagnostics()<CR>')

-- Support exiting terminal INSERT mode using C-[ and C-]. C-] is mapped so we
-- can still exist in nested Vim sessions.
tmap('<C-[>', [[<C-\><C-n>]])
tmap('<C-]>', [[<C-\><C-n>]])

-- Allow Control C and V for copying and pasting, mostly to make this easier in
-- Vim terminals.
vmap('<C-c>', '"+y')
imap('<C-v>', '<Esc>"+pa')
tmap('<C-s-v>', [[<C-\><C-n>"+pa]])

-- Quickfix
map('<leader>qf', ':cfirst<CR>')
map('<leader>qn', ':cnext<CR>')
map('<leader>qp', ':cprev<CR>')
map('<leader>lf', ':lfirst<CR>')
map('<leader>ln', ':lnext<CR>')
map('<leader>lp', ':lprev<CR>')

-- Snippets
imap('<C-s>', 'v:lua.dotfiles.maps.control_s()', { expr = true })
smap('<C-s>', 'v:lua.dotfiles.maps.control_s()', { expr = true })
imap('<C-j>', 'v:lua.dotfiles.maps.control_j()', { expr = true })
smap('<C-j>', 'v:lua.dotfiles.maps.control_j()', { expr = true })
smap('<C-k>', 'v:lua.dotfiles.maps.control_k()', { expr = true })
smap('<C-k>', 'v:lua.dotfiles.maps.control_k()', { expr = true })

return M
