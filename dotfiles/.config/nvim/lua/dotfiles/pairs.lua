local M = {}
local fn = vim.fn
local api = vim.api

-- When inserting a quote after one of these characters, always insert the
-- closing quote.
local force_closing_quote = {
  ['('] = true,
  ['['] = true,
  ['{'] = true,
  [' '] = true,
  ['\t'] = true,
  [','] = true,
  ['&'] = true,
}

-- When deleting a starting pair, also delete the closing pair if it directly
-- follows the cursor.
local backspace_open_pairs = {
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  ['<'] = '>',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`',
}

-- When deleting one of these closing pairs, also delete the opening pair if it
-- comes before the closing pair.
local backspace_close_pairs = {
  [')'] = '(',
  [']'] = '[',
  ['}'] = '{',
  ['>'] = '<',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`',
}

-- Pairs that need special handling when pressing space or enter.
--
-- When pressing enter in between two brackets, the curser is placed indented
-- between the brackets like this:
--
--     {
--       |
--     }
--
-- When pressing space between two brackets, an extra space is added arounc the
-- cursor like this:
--
--     [ | ]
local brackets = {
  ['{'] = '}',
  ['['] = ']',
  ['('] = ')',
}

local keep_undo = '<C-g>U'
local left = keep_undo .. '<left>'
local right = keep_undo .. '<right>'

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

  if before == '\\' then
    return open
  end

  if peek() == open then
    return right
  end

  return open .. close .. left
end

local function quote(kind)
  if peek() == kind then
    return right
  end

  local before = peek(-1)

  if #before > 0 and not force_closing_quote[before] then
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
  local before = peek(-1)
  local after = peek()

  if brackets[before] == after then
    return '<cr><C-o>O'
  end

  return '<cr>'
end

function M.space()
  local before = peek(-1)
  local after = peek()

  if brackets[before] == after then
    return '<space><space>' .. left
  end

  return '<space>'
end

function M.backspace()
  local before = peek(-1)
  local after = peek()

  if is_space(before) and is_space(after) then
    if brackets[peek(-2)] == peek(1) then
      return '<bs><del>'
    end
  end

  if backspace_open_pairs[before] == after then
    return '<bs><del>'
  end

  if backspace_close_pairs[before] == peek(-2) then
    return '<bs><bs>'
  end

  return '<bs>'
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

function M.angle_open()
  local prev = peek(-1)

  if not is_space(prev) and prev ~= '<' then
    return pair('<', '>')
  end

  return '<'
end

function M.angle_close()
  return jump_over('>')
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
