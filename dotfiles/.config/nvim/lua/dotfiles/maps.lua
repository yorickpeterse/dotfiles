local completion = require('dotfiles.completion')
local util = require('dotfiles.util')
local window = require('nvim-window')
local snippet = require('dotfiles.snippet')
local quickfix = require('dotfiles.quickfix')
local loclist = require('dotfiles.location_list')
local git_diff = require('dotfiles.git.diff')
local pick = require('mini.pick')
local popup_visible = util.popup_visible
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local diag = vim.diagnostic
local keymap = vim.keymap

local function map(kind, key, action, options)
  local opts = vim.tbl_extend('force', { silent = true }, options or {})

  keymap.set(kind, key, action, opts)
end

local function cmd(string)
  return '<cmd>' .. string .. '<CR>'
end

-- The leader key must be defined before any mappings are set.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Generic
map('', '<space>', '<nop>')
map('n', '<leader>F', util.format_buffer)
map('n', '<leader>w', cmd('update'))
map({ 'n', 'x' }, '<leader>p', '"0p')

-- Window management
map('n', '<leader>c', cmd('quit'))
map('n', '<leader>v', cmd('vsplit'))
map('n', '<leader>s', cmd('split'))
map('n', ',', window.pick)
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<C-h>', '<C-w>h')

map('n', '<leader>q', quickfix.toggle)
map('n', '<leader>l', loclist.toggle)
map('n', '<leader>d', function()
  diag.setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
end)
map('n', '<leader>e', function()
  diag.open_float({ scope = 'line' })
end)
map('n', '<leader>a', vim.lsp.buf.code_action)

-- Pickers
map('n', '<leader>f', require('dotfiles.mini.pickers.files').start)
map('n', '<leader>t', require('dotfiles.mini.pickers.symbols').start)
map('n', '<leader>b', pick.builtin.buffers)
map('n', '<leader>h', pick.builtin.help)

-- Going places
map({ 'n', 'x', 'o' }, 'gs', '^')
map({ 'n', 'x', 'o' }, 'ge', 'g_')
map({ 'n', 'x', 'o' }, 'gh', '0')
map({ 'n', 'x', 'o' }, 'gl', '$')
map({ 'n', 'x', 'o' }, 'gm', '%')
map('n', 'gp', cmd('b#'))
map('n', 'gd', function()
  local bufnr = api.nvim_get_current_buf()

  if util.has_lsp_clients_supporting(bufnr, 'goto_definition') then
    lsp.buf.definition()
  else
    api.nvim_feedkeys(vim.keycode('<C-]>'), 'm', true)
  end
end)

map({ 'n', 'x', 'o' }, 's', function()
  local ignore = vim.go.ignorecase

  vim.go.ignorecase = true
  require('flash').jump({ search = { multi_window = false } })
  vim.go.ignorecase = ignore
end)
map('x', 'y', 'ygv<Esc>')

-- Allow copy/pasting using Control-c and Control-v
map({ 'n', 'x' }, '<C-c>', '"+y')
map('i', '<C-v>', '<Esc>"+pa')
map('t', '<C-s-v>', [[<C-\><C-n>"+pa]])

-- Code and pairs completion
map('i', '<Esc>', function()
  return popup_visible() and '<C-e>' or '<Esc>'
end, { expr = true })

map('i', '<tab>', function()
  if popup_visible() then
    api.nvim_feedkeys(vim.keycode('<C-n>'), 'n', true)
    return
  end

  local col = fn.col('.') - 1

  if col == 0 or api.nvim_get_current_line():sub(col, col):match('%s') then
    api.nvim_feedkeys(vim.keycode('<tab>'), 'n', true)
  else
    completion.start()
  end
end)

map('i', '<S-tab>', function()
  return popup_visible() and '<C-p>' or '<S-tab>'
end, { expr = true })

map('x', '<s-tab>', '<')
map('x', '<tab>', '>')

-- Information about the name under the cursor (i.e. type/symbol information)
map('n', '<leader>i', function()
  vim.lsp.buf.hover({ max_width = 120, max_height = 20 })
end)
map('n', '<leader>n', vim.lsp.buf.rename)
map('n', '<leader>r', function()
  lsp.buf.references({ includeDeclaration = false })
end)

-- Searching
map('n', 'K', cmd([[silent grep! '\b<cword>\b']]))
map('n', '<leader>g', ':silent grep! ', { silent = false })

-- Terminals
map('t', '<Esc>', [[<C-\><C-n>]])
map('t', '<C-]>', [[<C-\><C-n>]])
map('t', '<S-space>', '<space>')

-- Quickfix
map('n', ']q', cmd('try | silent cnext | catch | silent! cfirst | endtry'))
map('n', '[q', cmd('try | silent cprev | catch | silent! clast | endtry'))
map('n', ']l', loclist.next)
map('n', '[l', loclist.prev)

-- Snippets
map({ 'i', 's' }, '<C-e>', function()
  snippet.expand()
end)

map({ 'i', 's' }, '<C-n>', function()
  snippet.next()
end)

-- Code review
map('n', ']f', git_diff.next_file)
map('n', '[f', git_diff.previous_file)
