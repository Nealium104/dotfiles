return {
  "neoclide/coc.nvim",
  branch = "release",
  config = function()
    -- CoC Recommended Options
    vim.opt.backup = false
    vim.opt.writebackup = false

    vim.opt.updatetime = 300

    vim.opt.signcolumn = "yes"

    -- Key Mapping Utility
    local keyset = vim.keymap.set
    local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

    -- Autocomplete Configuration (Tab / Shift-Tab)
    function _G.check_back_space()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
    end

    keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
    keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

    -- Make <CR> (Enter) to accept selected completion item or notify coc.nvim to format
    keyset("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

    -- Code Navigation (The "Go To" commands)
    local code_opts = { silent = true, nowait = true }
    keyset("n", "gd", "<Plug>(coc-definition)", code_opts)
    keyset("n", "gy", "<Plug>(coc-type-definition)", code_opts)
    keyset("n", "gi", "<Plug>(coc-implementation)", code_opts)
    keyset("n", "gr", "<Plug>(coc-references)", code_opts)

    -- Use K to show documentation in preview window
    function _G.show_docs()
        local cw = vim.fn.expand('<cword>')
        if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
            vim.api.nvim_command('h ' .. cw)
        elseif vim.api.nvim_eval('coc#rpc#ready()') then
            vim.fn.CocActionAsync('doHover')
        else
            vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
        end
    end
    keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true })

    -- Renaming
    keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })

    -- Formatting
    keyset("n", "<leader>f", "<Plug>(coc-format)", { silent = true })

    -- Diagnostics
    -- move between diagnostics
    keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
    keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

    -- show full diagnostic on current line
    keyset("n", "gl", "<Plug>(coc-diagnostic-info)", { silent = true })

    -- show all diagnostics in a window
    keyset("n", "<leader>a", ":<C-u>CocList diagnostics<cr>", code_opts)

  end
}
