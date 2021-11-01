local ls = require('luasnip')
local util = require('dotfiles.util')
local fn = vim.fn
local uv = vim.loop
local startswith = vim.startswith
local parse = ls.parser.parse_snippet

-- Parses a file containing Snipmate snippets.
--
-- This parser is quite permissive when it comes to the syntax. For example, it
-- doesn't actually care about the indentation. Instead this parser is optimised
-- for simplicity.
local function parse(file, source)
  local lines = vim.split(source, '\n', { plain = true })
  local index = 1
  local snippet_start = 'snippet '
  local snippets = {}

  while index <= #lines do
    local line = lines[index]

    if startswith(line, snippet_start) then
      local name = line:match('snippet (%w+)%s*')
      local desc = line:match('%s*"([^"]*)"')
      local body = {}

      assert(name, file .. ': invalid snippet on line ' .. index)

      index = index + 1

      while index <= #lines do
        local line = lines[index]

        if startswith(line, snippet_start) then
          break
        end

        if not startswith(line, '#') then
          table.insert(body, (line:gsub('^\t', '')))
        end

        index = index + 1
      end

      table.insert(
        snippets,
        { name = name, desc = desc, body = table.concat(body, '\n') }
      )
    end

    index = index + 1
  end

  return snippets
end

local function parse_files()
  local root = fn.join({ fn.stdpath('config'), 'snippets' }, '/')
  local files = fn.globpath(root, '*.snippets', false, true)

  for _, file in ipairs(files) do
    local name = fn.fnamemodify(file, ':t:r')
    local snippets = {}

    for _, snippet in ipairs(parse(file, util.read(file, true))) do
      table.insert(
        snippets,
        ls.parser.parse_snippet(
          { trig = snippet.name, dscr = snippet.desc },
          snippet.body
        )
      )
    end

    ls.snippets[name] = snippets
  end
end

-- The snippet parser is fast enough that we don't need to lazy load snippets.
parse_files()
