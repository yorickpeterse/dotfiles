local M = {}

local completion = require('dotfiles.completion')
local pairs = require('dotfiles.pairs')
local util = require('dotfiles.util')
local window = require('nvim-window')
local diag = require('dotfiles.diagnostics')
local telescope_builtin = require('telescope.builtin')
local treesitter_info = require('nvim-treesitter.info')

local keycode = util.keycode
local popup_visible = util.popup_visible
local au = util.au
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local g = vim.g

local callbacks = {}
local id = 1

local function map_key(kind, key, options, action)
  if type(options) == 'string' and action == nil then
    action = options
    options = {}
  end

  if type(options) == 'function' then
    action = options
    options = {}
  end

  local opts = vim.tbl_extend('force', { silent = true }, options or {})
  local cmd = action

  if type(action) == 'function' then
    if options.expr then
      cmd = 'v:lua.dotfiles.maps.run(%s)'
    else
      cmd = '<cmd>lua dotfiles.maps.run(%s)<CR>'
    end

    callbacks[id] = action
    cmd = cmd:format(id)
    id = id + 1
  end

  api.nvim_set_keymap(kind, key, cmd, opts)
end

local function map(key, options, action) map_key('', key, options, action) end
local function nmap(key, options, action) map_key('n', key, options, action) end
local function imap(key, options, action) map_key('i', key, options, action) end
local function smap(key, options, action) map_key('s', key, options, action) end
local function tmap(key, options, action) map_key('t', key, options, action) end
local function vmap(key, options, action) map_key('v', key, options, action) end
local function ismap(key, options, action)
  imap(key, options, action)
  smap(key, options, action)
end

local function cmd(string)
  return '<cmd>' .. string .. '<CR>'
end

function M.run(id)
  return callbacks[id]()
end

-- The leader key must be defined before any mappings are set.
g.mapleader = ' '
g.maplocalleader = ' '

-- Generic
map('<space>', '<nop>')
map('<leader>w', window.pick)
map('K', '<nop>')
nmap('s', cmd('HopWord'))
vmap('s', cmd('HopWord'))

-- Allow copy/pasting using Control-c and Control-v
vmap('<C-c>', '"+y')
imap('<C-v>', '<Esc>"+pa')
tmap('<C-s-v>', [[<C-\><C-n>"+pa]])

-- Commenting
nmap('<leader>c', '<Plug>kommentary_line_default<Esc>')
vmap('<leader>c', '<Plug>kommentary_visual_default<Esc>')

-- Code and pairs completion
imap('<CR>', { expr = true }, function()
  return popup_visible() and completion.confirm() or pairs.enter()
end)

imap('<S-tab>', { expr = true }, function()
  return popup_visible() and keycode('<C-p>') or keycode('<S-tab>')
end)

imap('<tab>', { expr = true }, function()
  if popup_visible() then
    return keycode('<C-n>')
  end

  local col = fn.col('.') - 1

  if col == 0 or api.nvim_get_current_line():sub(col, col):match('%s') then
    return keycode('<tab>')
  else
    return keycode('<C-x><C-U>')
  end
end)

vmap('<s-tab>', '<')
vmap('<tab>', '>')

-- Dirvish
au('dirvish', {
  'FileType dirvish nmap <silent><leader>v <cmd>call dirvish#open("vsplit", 0)<CR>'
})

-- Fugitive
map('<leader>gs', cmd('vert rightbelow Git'))
map('<leader>gd', cmd('Gdiffsplit'))

-- LSP
map('<leader>h', lsp.buf.hover)
map('<leader>r', lsp.buf.rename)
map('<leader>d', function()
  if util.has_lsp_clients() then
    lsp.buf.definition()
  else
    api.nvim_feedkeys(keycode('<C-]>'), 'n', true)
  end
end)

map('<leader>i', lsp.buf.references)
map('<leader>a', lsp.buf.code_action)
map('<leader>e', diag.show_line_diagnostics)

-- Telescope
map('<leader>f', function()
  if fn.isdirectory(fn.join({ fn.getcwd(), '.git' }, '/')) == 1 then
    telescope_builtin.git_files()
  else
    telescope_builtin.find_files()
  end
end)

map('<leader>t', function()
  if util.has_lsp_clients() then
    telescope_builtin.lsp_document_symbols()
    return
  end

  if vim.tbl_contains(treesitter_info.installed_parsers(), vim.bo.ft) then
    telescope_builtin.treesitter()
    return
  end

  telescope_builtin.current_buffer_tags()
end)

map('<leader>b', cmd('Telescope buffers'))

-- Terminals
tmap('<C-[>', [[<C-\><C-n>]])
tmap('<C-]>', [[<C-\><C-n>]])

-- Quickfix
map('<leader>qf', cmd('cfirst'))
map('<leader>qn', cmd('cnext'))
map('<leader>qp', cmd('cprev'))
map('<leader>lf', cmd('lfirst'))
map('<leader>ln', cmd('lnext'))
map('<leader>lp', cmd('lprev'))

-- Snippets
ismap('<C-s>', { expr = true }, function()
  if fn['vsnip#expandable']() then
    return keycode('<Plug>(vsnip-expand)')
  else
    return keycode('<C-s>')
  end
end)

ismap('<C-j>', { expr = true }, function()
  if fn['vsnip#jumpable'](1) then
    return keycode('<Plug>(vsnip-jump-next)')
  else
    return keycode('<C-j>')
  end
end)

ismap('<C-k>', { expr = true }, function()
  if fn['vsnip#jumpable'](-1) then
    return keycode('<Plug>(vsnip-jump-prev)')
  else
    return keycode('<C-k>')
  end
end)

return M
