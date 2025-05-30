local util = require('dotfiles.util')
local fn = vim.fn
local lsp = vim.lsp
local api = vim.api
local diag = require('dotfiles.diagnostics')
local loclist = require('dotfiles.location_list')
local statusline = require('dotfiles.statusline')
local lint = require('lint')

local function au(name, commands)
  local group = api.nvim_create_augroup('dotfiles_' .. name, { clear = true })

  for _, command in ipairs(commands) do
    local event = command[1]
    local patt = command[2]
    local action = command[3]

    if type(action) == 'string' then
      api.nvim_create_autocmd(
        event,
        { pattern = patt, command = action, group = group }
      )
    else
      api.nvim_create_autocmd(
        event,
        { pattern = patt, callback = action, group = group }
      )
    end
  end
end

local function remove_trailing_whitespace()
  local line = fn.line('.')
  local col = fn.col('.')

  -- In .snippets files, a line may start with just a tab so snippets can
  -- include empty lines. In this case we don't want to remove the tab.
  if vim.bo.ft == 'snippets' then
    vim.cmd([[silent! %s/ \+$//eg]])
  else
    vim.cmd([[silent! %s/\s\+$//eg]])
  end

  fn.cursor(line, col)
end

local function yanked()
  vim.highlight.on_yank({
    higroup = 'Visual',
    timeout = 150,
    on_visual = false,
  })
end

-- Deletes empty anonymous buffers when hiding them, so they don't pile up.
local function remove_buffer()
  local buffer = api.nvim_get_current_buf()

  -- Only remove the buffer if the buffer being closed is the buffer that was
  -- active.
  if buffer ~= tonumber(fn.expand('<abuf>')) then
    return
  end

  local ft = api.nvim_get_option_value('ft', { buf = buffer })

  if ft == 'qf' or ft == 'help' then
    return
  end

  if fn.bufname(buffer) ~= '' then
    return
  end

  local lines = fn.getbufline(buffer, 1, 1)

  if #lines == 0 or #lines[1] == 0 then
    -- The buffer is still in use at this point, so we must schedule the removal
    -- until after the hook finishes.
    vim.schedule(function()
      if fn.bufloaded(buffer) then
        pcall(api.nvim_buf_delete, buffer, {})
      end
    end)
  end
end

local function create_dirs(info)
  if not vim.startswith(info.match, 'oil:') then
    fn.mkdir(fn.expand('<afile>:p:h'), 'p')
  end
end

local function lint_buffer()
  lint.try_lint(nil, { ignore_errors = true })
end

au('buffer_management', {
  { 'BufWinLeave', '*', remove_buffer },
  {
    'BufWinEnter',
    '*',
    function()
      local line = api.nvim_buf_get_mark(0, '"')[1]

      if line > 1 and line <= api.nvim_buf_line_count(0) then
        api.nvim_feedkeys([[g`"]], 'nx', false)
      end
    end,
  },
})

au('yank', {
  { 'TextYankPost', '*', yanked },
})

au('trailing_whitespace', {
  { 'BufWritePre', '*', remove_trailing_whitespace },
  {
    'InsertEnter',
    '*',
    function()
      if vim.bo.buftype == 'terminal' then
        return
      end

      vim.wo.list = false
    end,
  },
  {
    'InsertLeave',
    '*',
    function()
      if vim.bo.buftype == 'terminal' then
        return
      end

      vim.wo.list = true
    end,
  },
})

do
  local throttle_timer = nil
  local enter_state = util.buffer_cache(function()
    return false
  end)

  au('lsp', {
    { 'BufWritePre', '*', util.format_buffer },
    { 'CursorMoved', '*', diag.underline },
    { 'BufWinEnter', '*', loclist.enter_window },
    {
      'DiagnosticChanged',
      '*',
      function()
        diag.refresh()
        loclist.diagnostics_changed()
        statusline.refresh_diagnostics()
      end,
    },
    { 'BufWritePost', '*', lint_buffer },
    {
      -- For some reason BufReadPost doesn't work with nvim-lint, so we use this
      -- approach instead.
      'BufEnter',
      '*',
      function()
        local buf = api.nvim_get_current_buf()

        if enter_state[buf] then
          return
        end

        enter_state[buf] = true
        lint_buffer()
      end,
    },
    {
      'LspProgress',
      '*',
      function()
        -- LspProgress fires frequently, so we throttle statusline updates.
        if throttle_timer then
          throttle_timer:stop()
        end

        throttle_timer = vim.defer_fn(function()
          throttle_timer = nil
          statusline.refresh_lsp_status()
          vim.cmd.redrawstatus()
        end, 250)
      end,
    },
    {
      'BufDelete',
      '*',
      function(event)
        -- When using a linter that isn't an LSP, I don't want diagnostics to
        -- linger after deleting a buffer.
        if not util.has_lsp_clients(event.buf) then
          vim.diagnostic.reset(nil, event.buf)
        end
      end,
    },
  })
end

au('diffs', {
  { 'BufEnter', 'diffview:///panels*', 'set cursorlineopt+=line' },
})

-- Automatically create leading directories when writing a file. This makes it
-- easier to create new files in non-existing directories.
au('create_dirs', {
  { 'BufWritePre', '*', create_dirs },
})

-- Open the quickfix window at the bottom when using `:grep`.
au('grep_quickfix', {
  { 'QuickFixCmdPost', 'grep', 'cwindow' },
})

-- Highlight all search matches while searching, but not when done searching.
do
  local search_reg = ''

  au('search_highlight', {
    {
      'CmdlineEnter',
      '*',
      function()
        search_reg = fn.getreg('/')
        fn.setreg('/', '')
        vim.opt.hlsearch = true
      end,
    },
    {
      'CmdlineLeave',
      '*',
      function()
        fn.setreg('/', search_reg)
        vim.opt.hlsearch = false
      end,
    },
  })
end

-- Clear the command-line when entering insert mode, so they don't linger around
-- due to the lack of `showmode`.
au('commandline', {
  {
    'InsertEnter',
    '*',
    function()
      api.nvim_echo({ { '' } }, false, {})
    end,
  },
})

au('terminal', {
  {
    'TermOpen',
    '*',
    function(args)
      vim.opt_local.scrolloff = 0
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = 'no'
      vim.opt_local.statuscolumn = ''
      vim.opt_local.list = false
    end,
  },
})

au('tabs', {
  {
    'TabClosed',
    '*',
    function(args)
      -- `tabprev` is relative to the new/current tab, whereas we want to move
      -- to whatever tab was the tab before the _closed_ tab.
      local old = tonumber(args.file)

      if old > 1 then
        vim.cmd.tabnext(old - 1)
      end
    end,
  },
})
