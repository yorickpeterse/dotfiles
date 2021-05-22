-- Utility functions for my dotfiles.
local M = {}

-- Returns a callback to use for reading the output of STDOUT or STDERR.
function M.reader(done)
  local output = ''

  return function(err, chunk)
    if chunk then
      output = output .. chunk
    else
      done(output)
    end
  end
end

-- Right pads a string with spaces.
function M.pad_right(string, pad_to)
  local new = string

  for i = #string, pad_to do
    new = new .. ' '
  end

  return new
end

return M
