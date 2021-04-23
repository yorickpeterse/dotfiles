require('dotfiles/lsp')

-- Here we export some modules into the global namespace, making it easier to
-- use them through Vimscript.
_G.dotfiles = {
  completion = require('dotfiles/completion'),

  -- A function for showing line diagnostics, supporting both LSP and ALE
  -- diagnostics.
  show_line_diagnostics = function()
    local bufnr = vim.fn.bufnr('')
    local lsp_bufnr, _ =
      vim.lsp.diagnostic.show_line_diagnostics({}, bufnr)

    -- LSP diagnostics take priority over ALE diagnostics.
    if lsp_bufnr ~= nil then
      return
    end

    local line = vim.api.nvim_win_get_cursor(0)[1]
    local items = vim.fn['ale#util#FindItemAtCursor'](bufnr)[1].loclist
    local lines = { 'Diagnostics:' }

    for _, item in ipairs(items) do
      if item.lnum == line then
        table.insert(lines, #lines .. '. ' .. item.text)
      end
    end

    if #lines == 1 then
      return
    end

    local ale_bufnr, _ = vim.lsp.util.open_floating_preview(lines, 'plaintext')

    -- Highlight the header in Bold, just like to LSP previews.
    vim.api.nvim_buf_add_highlight(ale_bufnr, -1, 'Bold', 0, 0, -1)
  end
}
