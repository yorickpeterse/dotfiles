local M = {}

local util = require('dotfiles.util')
local keycode = util.keycode
local fn = vim.fn
local api = vim.api

-- When deleting a starting pair, also delete the closing pair if it directly
-- follows the cursor.
local backspace_open_pairs = {
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`'
}

-- When deleting one of these closing pairs, also delete the opening pair if it
-- comes before the closing pair.
local backspace_close_pairs = {
  [')'] = '(',
  [']'] = '[',
  ['}'] = '{',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`'
}

-- When entering a newline after one of these pairs, automatically indent the
-- line.
local newline_pairs = {
  ['{'] = true,
  ['['] = true,
  ['('] = true,
}

-- When pressing a space after one of these opening pairs, insert a space after
-- the cursor if the next character is a closing pair.
local space_pairs = {
  ['{'] = '}',
  ['['] = ']',
  ['('] = ')',
}

local keep_undo = keycode('<C-g>U')
local left = keep_undo .. keycode('<left>')
local right = keep_undo .. keycode('<right>')

local function is_space(val)
  return val == ' ' or val == '\t'
end

local function peek(shift)
  local line = api.nvim_get_current_line()
  local col = fn.col('.')
  local idx = col + (shift or 0)

  return line:sub(idx, idx)
end

local function pair(open, close)
  local before = peek(-1)
  local after = peek()

  if before == '\\' then
    return open
  end

  if #after > 0 and not is_space(after) and close ~= after then
    return open
  end

  return keycode(open .. close) .. left
end

local function quote(kind)
  if peek() == kind then
    return right
  end

  local before = peek(-1)

  if #before > 0 and not is_space(before) then
    return kind
  end

  return pair(kind, kind)
end

local function jump_over(thing)
  local after = peek()

  if after == thing then
    return right
  end

  if is_space(after) and peek(1) == thing then
    return right .. right
  end

  return thing
end

function M.enter()
  if newline_pairs[peek(-1)] then
    return keycode('<cr><C-o>O')
  end

  return keycode('<cr>')
end

function M.space()
  local before = peek(-1)
  local after = peek()

  if space_pairs[before] == after then
    return keycode('<space><space>') .. left
  end

  return keycode('<space>')
end

function M.backspace()
  local before = peek(-1)
  local after = peek()

  if is_space(before) and is_space(after) then
    if space_pairs[peek(-2)] == peek(1) then
      return keycode('<bs><del>')
    end
  end

  if backspace_open_pairs[before] == after then
    return keycode('<bs><del>')
  end

  if backspace_close_pairs[before] == peek(-2) then
    return keycode('<bs><bs>')
  end

  return keycode('<bs>')
end

function M.curly_open()
  return pair('{', '}')
end

function M.curly_close()
  return jump_over('}')
end

function M.bracket_open()
  return pair('[', ']')
end

function M.bracket_close()
  return jump_over(']')
end

function M.paren_open()
  return pair('(', ')')
end

function M.paren_close()
  return jump_over(')')
end

function M.single_quote()
  if vim.bo.ft == 'rust' then
    -- Rust uses single quotes for lifetimes. Having to delete the closing quote
    -- is too annoying, so pairing single quotes is disabled.
    return "'"
  end

  return quote("'")
end

function M.double_quote()
  return quote('"')
end

function M.backtick()
  return quote('`')
end

return M
