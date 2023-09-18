setlocal spell spelllang=en
setlocal formatexpr={->1}
setlocal bufhidden=wipe

au BufDelete <buffer> :lua vim.diagnostic.reset(nil, tonumber(vim.fn.expand('<abuf>')))
