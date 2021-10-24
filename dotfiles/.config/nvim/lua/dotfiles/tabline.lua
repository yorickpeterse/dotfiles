local fn = vim.fn
local M = {}
local lsp = vim.lsp
local icons = require('dotfiles.icons')
local util = require('dotfiles.util')
local highlight = util.statusline_highlight
local forced_space = util.forced_space

local active_tab = 'TabLineSel'
local inactive_tab = 'TabLine'
local default_name = '[No Name]'
local separator = '%='
local lsp_hl = 'PmenuSel'
local lsp_icons = {
  clangd = icons.by_name('c'),
  gopls = icons.by_name('go'),
  rust_analyzer = icons.by_name('rs'),
  sumneko_lua = icons.by_name('lua'),
}

local function lsp_status()
  local statuses = {}
  local handled = {}

  for _, msg in ipairs(lsp.util.get_progress_messages()) do
    if not msg.done and not handled[msg.name] then
      local icon = lsp_icons[msg.name] or ''
      local status =
        highlight(icon .. ' ' .. msg.name .. ': ', lsp_hl) .. msg.title

      if msg.percentage then
        status = status .. ' ' .. msg.percentage .. '%%'
      end

      table.insert(statuses, status)
      handled[msg.name] = true
    end
  end

  if #statuses == 0 then
    return ''
  else
    return forced_space .. table.concat(statuses, ' ') .. forced_space
  end
end

function M.render()
  local line = ''

  for tab = 1, fn.tabpagenr('$') do
    local winnr = fn.tabpagewinnr(tab)
    local buflist = fn.tabpagebuflist(tab)
    local bufnr = buflist[winnr]
    local bufname = fn.bufname(bufnr)

    if bufname == '' then
      bufname = default_name
    else
      bufname = fn.fnamemodify(bufname, ':t')
    end

    local modified = fn.getbufvar(bufnr, '&mod')

    line = line .. table.concat({
      '%',
      tab,
      'T',
      '%#',
      tab == fn.tabpagenr() and active_tab or inactive_tab,
      '#',
      ' ',
      tab,
      ': ',
      icons.icon(bufname),
      bufname,
      ' ',
      modified == 1 and '[+] ' or ''
    })
  end

  return line .. '%#TabLineFill#' .. separator .. lsp_status()
end

return M
