local M = {}

local completion = require('dotfiles.completion')
local dpairs = require('dotfiles.pairs')
local util = require('dotfiles.util')
local window = require('nvim-window')
local telescope_builtin = require('telescope.builtin')
local parsers = require('nvim-treesitter.parsers')
local snippy = require('snippy')
local pickers = require('dotfiles.telescope.pickers')
local quickfix = require('dotfiles.quickfix')
local pounce = require('pounce')

local keycode = util.keycode
local popup_visible = util.popup_visible
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local g = vim.g
local diag = vim.diagnostic
local keymap = vim.keymap

-- The LSP symbols to include when using Telescope.
local ts_lsp_symbols = {
  Class = true,
  Constant = true,
  Constructor = true,
  Enum = true,
  EnumMember = true,
  Function = true,
  Interface = true,
  Method = true,
  Module = true,
  Reference = true,
  Snippet = true,
  Struct = true,
  TypeParameter = true,
  Unit = true,
  Value = true,
}

local function map_key(kind, key, action, options)
  local opts = vim.tbl_extend('force', { silent = true }, options or {})

  keymap.set(kind, key, action, opts)
end

local function unmap(key)
  keymap.del('', key)
end

local function map(key, action, options)
  map_key('', key, action, options)
end

local function nmap(key, action, options)
  map_key('n', key, action, options)
end

local function imap(key, action, options)
  map_key('i', key, action, options)
end

local function smap(key, action, options)
  map_key('s', key, action, options)
end

local function tmap(key, action, options)
  map_key('t', key, action, options)
end

local function vmap(key, action, options)
  map_key('v', key, action, options)
end

local function xmap(key, action, options)
  map_key('x', key, action, options)
end

local function ismap(key, action, options)
  imap(key, action, options)
  smap(key, action, options)
end

local function cmd(string)
  return '<cmd>' .. string .. '<CR>'
end

local function pair(key, func)
  return imap(key, dpairs[func], { remap = false, expr = true })
end

-- The leader key must be defined before any mappings are set.
g.mapleader = ' '
g.maplocalleader = ' '

-- Generic
map('<space>', '<nop>')
nmap('<leader>w', window.pick)
nmap('<leader>s', cmd('update'))
nmap('<leader>c', cmd('quit'))
nmap('<leader>v', cmd('vsplit'))
nmap('<leader>F', lsp.buf.format)

nmap('<C-j>', '<C-w>j')
nmap('<C-k>', '<C-w>k')
nmap('<C-l>', '<C-w>l')
nmap('<C-h>', '<C-w>h')

nmap('s', pounce.pounce)
xmap('s', pounce.pounce)

nmap('S', function()
  pounce.pounce({ do_repeat = true })
end)

xmap('S', function()
  pounce.pounce({ do_repeat = true })
end)

vmap('y', 'ygv<Esc>')

-- Use d/dd for actually deleting, while using dx for cutting the line.
nmap('dx', 'dd', { noremap = true })

nmap('d', '"_d', { noremap = true })
nmap('d', '"_d', { noremap = true })
xmap('d', '"_d', { noremap = true })
nmap('dd', '"_dd', { noremap = true })

-- Allow copy/pasting using Control-c and Control-v
vmap('<C-c>', '"+y')
imap('<C-v>', '<Esc>"+pa')
tmap('<C-s-v>', [[<C-\><C-n>"+pa]])

-- Code and pairs completion
imap('<CR>', function()
  return dpairs.enter()
end, { expr = true })

imap('<Esc>', function()
  return popup_visible() and '<C-e><Esc>' or '<Esc>'
end, { expr = true })

pair('<space>', 'space')
pair('<S-space>', 'space')
pair('<bs>', 'backspace')
pair('<S-bs>', 'backspace')

pair('{', 'curly_open')
pair('}', 'curly_close')

pair('[', 'bracket_open')
pair(']', 'bracket_close')

pair('(', 'paren_open')
pair(')', 'paren_close')

pair('<', 'angle_open')
pair('>', 'angle_close')

pair("'", 'single_quote')
pair('"', 'double_quote')
pair('`', 'backtick')

imap('<tab>', function()
  if popup_visible() then
    api.nvim_feedkeys(keycode('<C-n>'), 'n', true)
    return
  end

  local col = fn.col('.') - 1

  if col == 0 or api.nvim_get_current_line():sub(col, col):match('%s') then
    api.nvim_feedkeys(keycode('<tab>'), 'n', true)
  else
    completion.start()
  end
end)

imap('<S-tab>', function()
  return popup_visible() and '<C-p>' or '<S-tab>'
end, { expr = true })

vmap('<s-tab>', '<')
vmap('<tab>', '>')

nmap(']n', function()
  util.restore_register('/', function()
    vim.cmd('silent! /<<< HEAD')
  end)
end)

nmap('[n', function()
  util.restore_register('/', function()
    vim.cmd('silent! ?<<< HEAD')
  end)
end)

-- LSP
nmap('<leader>h', cmd('lua vim.lsp.buf.hover()'))
nmap('<leader>n', cmd('lua vim.lsp.buf.rename()'))
nmap('<leader>d', function()
  local bufnr = api.nvim_get_current_buf()

  if util.has_lsp_clients_supporting(bufnr, 'goto_definition') then
    lsp.buf.definition()
  else
    api.nvim_feedkeys(keycode('<C-]>'), 'm', true)
  end
end)

nmap('<leader>z', function()
  diag.setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
end)

nmap('<leader>r', function()
  lsp.buf.references({ includeDeclaration = false })
end)

-- Shows all implementations of an interface.
--
-- The function `vim.lsp.buf.implementation()` automatically jumps to the first
-- location, which I don't like.
nmap('<leader>i', function()
  local bufnr = api.nvim_get_current_buf()
  local params = lsp.util.make_position_params()

  lsp.buf_request_all(
    bufnr,
    'textDocument/implementation',
    params,
    function(response)
      for _, result in ipairs(response) do
        if result.result then
          local items = result.result

          if not vim.tbl_islist(result.result) then
            items = { items }
          end

          if #items > 0 then
            fn.setqflist({}, ' ', {
              title = 'Implementations',
              items = lsp.util.locations_to_items(items, 'utf-8'),
            })
            vim.cmd('copen')
          end
        end
      end
    end
  )
end)

nmap('<leader>a', cmd('lua vim.lsp.buf.code_action()'))

nmap('<leader>e', function()
  diag.open_float(0, { scope = 'line' })
end)

-- Searching
nmap('K', cmd([[silent grep! '\b<cword>\b']]))
nmap('<leader>g', ':silent grep! ', { silent = false })

-- Telescope
nmap('<leader>f', function()
  telescope_builtin.find_files({
    hidden = true,
    find_command = { 'rg', '--files', '--color', 'never' },
  })
end)

nmap('<leader>t', function()
  local bufnr = api.nvim_get_current_buf()
  local ft = api.nvim_buf_get_option(bufnr, 'ft')

  if util.has_lsp_clients_supporting(bufnr, 'document_symbol') then
    pickers.lsp_document_symbols(bufnr, {
      -- Lua exposes variables as constants for some weird reason
      ignore_scoped_constants = ft == 'lua',
      symbols = ts_lsp_symbols,
      previewer = false,
      results_title = false,
      prompt_title = false,
    })

    return
  end

  if parsers.has_parser() then
    telescope_builtin.treesitter()
    return
  end

  telescope_builtin.current_buffer_tags()
end)

nmap('<leader>b', cmd('Telescope buffers'))

-- Terminals
tmap('<Esc>', [[<C-\><C-n>]])
tmap('<C-]>', [[<C-\><C-n>]])
tmap('<S-space>', '<space>')

-- Quickfix
nmap(']q', cmd('try | silent cnext | catch | silent! cfirst | endtry'))
nmap('[q', cmd('try | silent cprev | catch | silent! clast | endtry'))

nmap(']l', cmd('lua dotfiles.location_list.next()'))
nmap('[l', cmd('lua dotfiles.location_list.prev()'))
nmap('<leader>l', cmd('lua dotfiles.location_list.toggle()'))
nmap('<leader>q', quickfix.toggle)

-- Snippets
ismap('<C-s>', function()
  if snippy.can_expand() then
    snippy.expand()
  end
end)

ismap('<C-j>', function()
  if snippy.can_jump(1) then
    snippy.next()
  end
end)

return M
