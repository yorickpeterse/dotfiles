local M = {}

local completion = require('dotfiles.completion')
local pairs = require('dotfiles.pairs')
local util = require('dotfiles.util')
local window = require('nvim-window')
local telescope_builtin = require('telescope.builtin')
local parsers = require('nvim-treesitter.parsers')
local snippy = require('snippy')
local pickers = require('dotfiles.telescope.pickers')

local keycode = util.keycode
local popup_visible = util.popup_visible
local au = util.au
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local g = vim.g
local diag = vim.diagnostic

-- The LSP symbols to include when using Telescope.
local ts_lsp_symbols = {}
local ts_lsp_kinds = {
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

for _, kind in ipairs(vim.lsp.protocol.SymbolKind) do
  if ts_lsp_kinds[kind] then
    table.insert(ts_lsp_symbols, kind)
  end
end

local function map_key(kind, key, action, options)
  local opts = vim.tbl_extend('force', { silent = true }, options or {})
  local cmd = action

  if type(cmd) == 'table' then
    local kind = cmd[1]
    local run = cmd[2]

    if kind == 'cmd' then
      cmd = '<cmd>' .. run .. '<CR>'
    elseif kind == 'expr' then
      cmd = run
      opts.expr = true
    end
  end

  api.nvim_set_keymap(kind, key, cmd, opts)
end

local function unmap(key)
  api.nvim_del_keymap('', key)
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
  return { 'cmd', string }
end

local function func(name)
  return cmd('lua dotfiles.maps.' .. name .. '()')
end

local function expr(name)
  return { 'expr', 'v:lua.dotfiles.maps.' .. name .. '()' }
end

local function pair(key, func)
  local action = { 'expr', 'v:lua.dotfiles.pairs.' .. func .. '()' }

  imap(key, action, { noremap = true })
end

function M.enter()
  return popup_visible() and completion.confirm() or pairs.enter()
end

function M.shift_tab()
  return popup_visible() and keycode('<C-p>') or keycode('<S-tab>')
end

function M.tab()
  if popup_visible() then
    return keycode('<C-n>')
  end

  local col = fn.col('.') - 1

  if col == 0 or api.nvim_get_current_line():sub(col, col):match('%s') then
    return keycode('<tab>')
  else
    return keycode('<C-x><C-U>')
  end
end

function M.next_conflict()
  util.restore_register('/', function()
    vim.cmd('silent! /<<< HEAD')
  end)
end

function M.previous_conflict()
  util.restore_register('/', function()
    vim.cmd('silent! ?<<< HEAD')
  end)
end

function M.pick_window()
  window.pick()
end

function M.definition()
  local bufnr = api.nvim_get_current_buf()

  if util.has_lsp_clients_supporting(bufnr, 'goto_definition') then
    lsp.buf.definition()
  else
    api.nvim_feedkeys(keycode('<C-]>'), 'm', true)
  end
end

function M.line_diagnostics()
  diag.open_float(0, { scope = 'line' })
end

function M.workspace_diagnostics()
  diag.setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
end

function M.telescope_files()
  telescope_builtin.find_files({
    hidden = true,
    find_command = { 'fd', '--type=f', '--strip-cwd-prefix' },
  })
end

function M.telescope_symbols()
  local bufnr = api.nvim_get_current_buf()

  if util.has_lsp_clients_supporting(bufnr, 'document_symbol') then
    pickers.lsp_document_symbols({
      symbols = ts_lsp_symbols,
      previewer = false,
      prompt_title = false,
      results_title = false,
      preview_title = false,
    })

    return
  end

  if parsers.has_parser() then
    telescope_builtin.treesitter()
    return
  end

  telescope_builtin.current_buffer_tags()
end

function M.control_s()
  if snippy.can_expand() then
    snippy.expand()
  end
end

function M.control_j()
  if snippy.can_jump(1) then
    snippy.next()
  end
end

function M.toggle_quickfix()
  if #fn.filter(fn.getwininfo(), 'v:val.quickfix') == 0 then
    vim.cmd('silent! copen')
  else
    vim.cmd('silent! cclose')
  end
end

function M.references()
  lsp.buf.references({ includeDeclaration = false })
end

-- Shows all implementations of an interface.
--
-- The function `vim.lsp.buf.implementation()` automatically jumps to the first
-- location, which I don't like.
function M.implementations()
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
              items = lsp.util.locations_to_items(items),
            })
            vim.cmd('copen')
          end
        end
      end
    end
  )
end

-- The leader key must be defined before any mappings are set.
g.mapleader = ' '
g.maplocalleader = ' '

-- Generic
map('<space>', '<nop>')
nmap('<leader>w', func('pick_window'))
nmap('<leader>s', cmd('update'))
nmap('<leader>c', cmd('quit'))
nmap('<leader>v', cmd('vsplit'))

nmap('<C-j>', '<C-w>j')
nmap('<C-k>', '<C-w>k')
nmap('<C-l>', '<C-w>l')
nmap('<C-h>', '<C-w>h')

nmap('s', cmd('HopWord'))
xmap('s', cmd('HopWord'))

-- dirbuf maps this, which is annoying.
unmap('-')

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
imap('<CR>', expr('enter'))

pair('<space>', 'space')
pair('<bs>', 'backspace')

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

imap('<tab>', expr('tab'))
imap('<S-tab>', expr('shift_tab'))

vmap('<s-tab>', '<')
vmap('<tab>', '>')

nmap(']n', func('next_conflict'))
nmap('[n', func('previous_conflict'))

-- LSP
nmap('<leader>h', cmd('lua vim.lsp.buf.hover()'))
nmap('<leader>n', cmd('lua vim.lsp.buf.rename()'))
nmap('<leader>d', func('definition'))
nmap('<leader>z', func('workspace_diagnostics'))

nmap('<leader>r', func('references'))
nmap('<leader>i', func('implementations'))
nmap('<leader>a', cmd('lua vim.lsp.buf.code_action()'))
nmap('<leader>e', func('line_diagnostics'))

-- Searching
nmap('K', cmd('silent grep! <cword>'))
nmap('<leader>g', ':silent grep! ', { silent = false })

-- Telescope
nmap('<leader>f', func('telescope_files'))
nmap('<leader>t', func('telescope_symbols'))
nmap('<leader>b', cmd('Telescope buffers'))

-- Terminals
tmap('<C-[>', [[<C-\><C-n>]])
tmap('<C-]>', [[<C-\><C-n>]])

-- Quickfix
nmap(']q', cmd('try | silent cnext | catch | silent! cfirst | endtry'))
nmap('[q', cmd('try | silent cprev | catch | silent! clast | endtry'))
nmap(']l', cmd('lua dotfiles.location_list.next()'))
nmap('[l', cmd('lua dotfiles.location_list.prev()'))
nmap('<leader>l', cmd('lua dotfiles.location_list.toggle()'))
nmap('<leader>q', func('toggle_quickfix'))

-- Snippets
ismap('<C-s>', func('control_s'))
ismap('<C-j>', func('control_j'))

return M
