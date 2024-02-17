setlocal spell spelllang=en
setlocal bufhidden=wipe

au BufDelete <buffer> :lua vim.diagnostic.reset(nil, tonumber(vim.fn.expand('<abuf>')))
