local M = {}
local lsp = vim.lsp
local diag = vim.diagnostic
local util = require('dotfiles.util')
local highlight = util.statusline_highlight
local forced_space = util.forced_space

local separator = '%='
local active_hl = 'BlackOnLightYellow'

local function diagnostic_count(buffer, kind)
  local severity = kind == 'E' and diag.severity.ERROR or diag.severity.WARN
  local amount = #diag.get(buffer, { severity = severity })

  if amount > 0 then
    return forced_space .. kind .. ': ' .. amount .. forced_space
  else
    return ''
  end
end

local function lsp_status()
  local statuses = {}

  for _, msg in ipairs(lsp.util.get_progress_messages()) do
    if not msg.done and not statuses[msg.name] then
      local status = msg.title

      if msg.percentage then
        status = status .. ' ' .. msg.percentage .. '%%'
      end

      statuses[msg.name] = status
    end
  end

  for _, client in ipairs(lsp.get_active_clients()) do
    if not statuses[client.name] then
      statuses[client.name] = 'active'
    end
  end

  if vim.tbl_isempty(statuses) then
    return ''
  end

  local cells = {}
  local names = {}

  -- This ensures clients are always displayed in a consistent order.
  for name, _ in pairs(statuses) do
    table.insert(names, name)
  end

  table.sort(names, function(a, b)
    return a < b
  end)

  for _, name in ipairs(names) do
    local status = statuses[name]
    local text = name .. ': ' .. status

    table.insert(cells, text)
  end

  return forced_space .. table.concat(cells, ', ') .. forced_space
end

function M.render()
  return table.concat({
    separator,
    lsp_status(),
    highlight(diagnostic_count(nil, 'W'), 'WhiteOnYellow'),
    highlight(diagnostic_count(nil, 'E'), 'WhiteOnRed'),
  })
end

return M
