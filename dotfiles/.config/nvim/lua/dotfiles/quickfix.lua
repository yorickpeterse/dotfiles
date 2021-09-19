-- Formatting of quickfix and location list entries.
local util = require('dotfiles.util')
local api = vim.api
local fn = vim.fn

local M = {}
local type_mapping = {
  E = 'E ',
  W = 'W '
}

-- Trims a file path
local function trim_path(path)
  return fn.fnamemodify(path, ':p:.')
end

-- Returns the quickfix or location list items, depending on what type of list
-- we're formatting.
local function list_items(info)
  if info.quickfix == 1 then
    return fn.getqflist({ id = info.id, items = 1 }).items
  else
    return fn.getloclist(info.winid, { id = info.id, items = 1 }).items
  end
end

-- Formats a quickfix and location list window.
--
-- This is available in NeoVim since the merging of
-- https://github.com/neovim/neovim/pull/14490
--
-- The resulting format is as follows:
--
--     E: file.ext:line:column        text
--     W: foo/bar/baz.ext:line:column text
function M.format(info)
  local items = list_items(info)
  local lines = {}
  local pad_to = 0

  for i = info.start_idx, info.end_idx do
    local item = items[i]

    if item then
      local path = trim_path(fn.bufname(item.bufnr))
      local location = path .. ':' .. item.lnum

      if item.col > 0 then
        location = location .. ':' .. item.col
      end

      local size = #location

      if size > pad_to then
        pad_to = size
      end

      item.location = location
    end
  end

  for list_index = info.start_idx, info.end_idx do
    local item = items[list_index]

    if item then
      local text = vim.split(fn.trim(item.text), "\n")[1]
      local location = item.location

      if text ~= '' then
        location = util.pad_right(location, pad_to)
      end

      local kind = type_mapping[item.type] or ''

      table.insert(lines, kind .. location .. text)
    end
  end

  return lines
end

return M
