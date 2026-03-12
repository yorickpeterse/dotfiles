local fn = vim.fn
local api = vim.api

local M = {}
local NS = api.nvim_create_namespace('dotfiles_jump')
local CR = api.nvim_replace_termcodes('<Cr>', true, true, true)
local BS = api.nvim_replace_termcodes('<Bs>', true, true, true)
local ESC = api.nvim_replace_termcodes('<Esc>', true, true, true)
local LABELS = fn.split('tnseriaogmplfuwyqbjdhvkzxc', '\\zs')
local HL = {
  search = 'Search',
  label = 'FlashLabel',
}

local function search(pattern, lines, start_line, matches)
  local lower = pattern == pattern:lower()

  for idx, line in ipairs(lines) do
    local lnum = start_line + idx - 1
    local line = lower and line:lower() or line

    if #line > 0 then
      local col = 1

      while true do
        local start, stop = line:find(pattern, col, true)

        if not start then
          break
        end

        col = stop + 1
        table.insert(matches, {
          line = lnum - 1,
          start_col = start - 1,
          end_col = stop,
          line_index = idx,
        })
      end
    end
  end
end

local function available_labels(lines, matches)
  local avail = {}

  for _, char in ipairs(LABELS) do
    avail[char] = true
  end

  -- First disable all the labels that conflict with any of the characters
  -- that may be matched by the next input.
  for _, match in ipairs(matches) do
    local next_col = match.end_col + 1
    local next_char = lines[match.line_index]:sub(next_col, next_col):lower()

    avail[next_char] = false
  end

  return avail
end

function M.start()
  local win = api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)
  local info = fn.getwininfo(win)[1]
  local top = info.topline
  local bot = info.botline
  local lines = api.nvim_buf_get_lines(buf, top - 1, bot, true)
  local chars = ''
  local matches = {}
  local active = {}

  while true do
    api.nvim_echo({ { '/' .. chars, '' } }, false, {})

    local char = fn.getcharstr(-1)
    local jump_to = active[char]

    if char == ESC then
      break
    elseif char == CR then
      for _, char in ipairs(LABELS) do
        jump_to = active[char]

        if jump_to then
          break
        end
      end

      if jump_to then
        api.nvim_win_set_cursor(win, jump_to)
      end

      break
    elseif char == BS then
      chars = chars:sub(1, #chars - 1)
    elseif jump_to then
      api.nvim_win_set_cursor(win, jump_to)
      break
    else
      chars = chars .. char
    end

    matches = {}
    active = {}
    api.nvim_buf_clear_namespace(buf, NS, 0, -1)

    if #chars > 0 then
      search(chars, lines, top, matches)

      local avail = available_labels(lines, matches)

      for _, match in ipairs(matches) do
        local label = nil

        for _, cur in ipairs(LABELS) do
          if avail[cur] then
            label = cur
            avail[cur] = false
            break
          end
        end

        vim.hl.range(
          buf,
          NS,
          HL.search,
          { match.line, match.start_col },
          { match.line, match.end_col },
          { priority = 1 }
        )

        if label then
          active[label] = { match.line + 1, match.start_col }
          api.nvim_buf_set_extmark(buf, NS, match.line, match.start_col, {
            virt_text = { { label, HL.label } },
            virt_text_pos = 'overlay',
            priority = 2,
          })
        end
      end
    end

    vim.cmd.redraw()
  end

  api.nvim_buf_clear_namespace(buf, NS, 0, -1)
  api.nvim_echo({ { '', '' } }, false, {})
  vim.cmd.redraw()
end

return M
