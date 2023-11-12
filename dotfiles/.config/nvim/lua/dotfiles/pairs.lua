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

-- The file types for which to ignore the pair mappings.
local ignore_filetypes = { TelescopePrompt = true }

local keep_undo = '<C-g>U'
local left = keep_undo .. '<left>'
local right = keep_undo .. '<right>'

local function map(pair, func)
  vim.keymap.set('i', pair, function()
    return ignore_filetypes[vim.bo.ft] and pair or func()
  end, { silent = true, remap = false, expr = true })
end

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

local function enter()
  local before = peek(-1)
  local after = peek()

  if brackets[before] == after then
    return '<cr><C-o>O'
  end

  return '<cr>'
end

local function space()
  local before = peek(-1)
  local after = peek()

  if brackets[before] == after then
    return '<space><space>' .. left
  end

  return '<space>'
end

local function backspace()
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

local function curly_open()
  return pair('{', '}')
end

local function curly_close()
  return jump_over('}')
end

local function bracket_open()
  return pair('[', ']')
end

local function bracket_close()
  return jump_over(']')
end

local function paren_open()
  if peek() == '(' then
    return right
  end

  return pair('(', ')')
end

local function paren_close()
  return jump_over(')')
end

local function angle_open()
  local prev = peek(-1)

  if not is_space(prev) and prev ~= '<' then
    return pair('<', '>')
  end

  return '<'
end

local function angle_close()
  return jump_over('>')
end

local function single_quote()
  if vim.bo.ft == 'rust' then
    -- Rust uses single quotes for lifetimes. Having to delete the closing quote
    -- is too annoying, so pairing single quotes is disabled.
    return "'"
  end

  return quote("'")
end

local function double_quote()
  return quote('"')
end

local function backtick()
  return quote('`')
end

map('<space>', space)
map('<S-space>', space)
map('<bs>', backspace)
map('<S-bs>', backspace)
map('{', curly_open)
map('}', curly_close)
map('[', bracket_open)
map(']', bracket_close)
map('(', paren_open)
map(')', paren_close)
map('<', angle_open)
map('>', angle_close)
map("'", single_quote)
map('"', double_quote)
map('`', backtick)
map('<CR>', enter)
