local completion = require('dotfiles.completion')
local util = require('dotfiles.util')
local window = require('nvim-window')
local telescope_builtin = require('telescope.builtin')
local snippet = require('dotfiles.snippet')
local parsers = require('nvim-treesitter.parsers')
local pickers = require('dotfiles.telescope.pickers')
local quickfix = require('dotfiles.quickfix')
local pounce = require('pounce')
local loclist = require('dotfiles.location_list')
local popup_visible = util.popup_visible
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
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
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<C-h>', '<C-w>h')
map('n', '<leader>F', util.format_buffer)
map('n', '<leader>s', cmd('update'))

-- Window management
map('n', '<leader>w', window.pick)
map('n', '<leader>c', cmd('quit'))
map('n', '<leader>v', cmd('vsplit'))
map('n', '<leader>k', cmd('split'))
map('n', '<leader>l', loclist.toggle)
map('n', '<leader>q', quickfix.toggle)

-- Going places
map('', 'gs', '^')

map({ 'n', 'x' }, 's', pounce.pounce)
map({ 'n', 'x' }, 'S', function()
  pounce.pounce({ do_repeat = true })
end)

map('x', 'y', 'ygv<Esc>')
map({ 'n', 'x' }, '<leader>p', '"0p')

-- Allow copy/pasting using Control-c and Control-v
map({ 'n', 'x' }, '<C-c>', '"+y')
map('i', '<C-v>', '<Esc>"+pa')
map('t', '<C-s-v>', [[<C-\><C-n>"+pa]])

-- Code and pairs completion
map('i', '<Esc>', function()
  return popup_visible() and '<C-e><Esc>' or '<Esc>'
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

-- LSP
map('n', '<leader>h', vim.lsp.buf.hover)
map('n', '<leader>n', vim.lsp.buf.rename)
map('n', '<leader>d', function()
  local bufnr = api.nvim_get_current_buf()

  if util.has_lsp_clients_supporting(bufnr, 'goto_definition') then
    lsp.buf.definition()
  else
    api.nvim_feedkeys(vim.keycode('<C-]>'), 'm', true)
  end
end)

map('n', '<leader>z', function()
  diag.setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
end)

map('n', '<leader>r', function()
  lsp.buf.references({ includeDeclaration = false })
end)

-- Shows all implementations of an interface.
--
-- The function `vim.lsp.buf.implementation()` automatically jumps to the first
-- location, which I don't like.
map('n', '<leader>i', function()
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

map('n', '<leader>a', vim.lsp.buf.code_action)
map('n', '<leader>e', function()
  diag.open_float({ scope = 'line' })
end)

-- Searching
map('n', 'K', cmd([[silent grep! '\b<cword>\b']]))
map('n', '<leader>g', ':silent grep! ', { silent = false })

-- Telescope
map('n', '<leader>f', function()
  telescope_builtin.find_files({
    hidden = true,
    find_command = { 'rg', '--files', '--color', 'never' },
  })
end)

map('n', '<leader>t', function()
  local bufnr = api.nvim_get_current_buf()
  local ft = api.nvim_get_option_value('ft', { buf = bufnr })

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

map('n', '<leader>b', telescope_builtin.buffers)

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
map({ 'i', 's' }, '<C-s>', function()
  snippet.expand()
end)

map({ 'i', 's' }, '<C-k>', function()
  snippet.previous()
end)

map({ 'i', 's' }, '<C-j>', function()
  snippet.next()
end)
