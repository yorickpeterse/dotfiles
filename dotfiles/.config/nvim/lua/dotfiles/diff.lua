local M = {}
local api = vim.api
local wo = vim.wo

-- The overrides to apply to the old diff.
local override = 'DiffAdd:LightRedBackground,DiffChange:Disabled'

-- This overrides DiffAdd in fugitive buffers, turning them into something that
-- looks like DiffDelete (while allowing it to be highlighted differently).
--
-- This hack ensures that deletions in the previous version of a diff show up
-- as actual deletions, not additions (relative to the current version).
function M.fix_highlight(id, options)
  options = options or { force = false }

  local window_id = id or api.nvim_get_current_win()
  local nr = api.nvim_win_get_buf(window_id)
  local name = api.nvim_buf_get_name(nr)
  local winhl = wo[window_id].winhl

  if not options.force then
    if not wo[window_id].diff or winhl:match(override) then
      return
    end
  end

  if winhl == '' then
    wo[window_id].winhl = override
  else
    wo[window_id].winhl = winhl .. ',' .. override
  end
end

return M
