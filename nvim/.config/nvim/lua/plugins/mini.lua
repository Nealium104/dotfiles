return {
   {
      'echasnovski/mini.nvim',
      dependencies = {
         -- Only `textobjects` queries are used by mini.ai
         { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
      },
      config = function()
         local ai = require('mini.ai')
         local ts = ai.gen_spec.treesitter
         ai.setup({
            n_lines = 500, -- search further for function/class bodies
            custom_textobjects = {
               -- Lowercase `f` stays mini.ai's function *call*; these are definitions/blocks.
               F = ts({ a = '@function.outer', i = '@function.inner' }), -- function definition
               c = ts({ a = '@class.outer', i = '@class.inner' }),       -- class
               o = ts({                                                  -- block: conditional or loop
                  a = { '@conditional.outer', '@loop.outer' },
                  i = { '@conditional.inner', '@loop.inner' },
               }),
            },
         })
         require('mini.icons').setup()
         local animate = require('mini.animate')
         animate.setup({
            cursor = {
               enable = true,
               -- Easing: linear, quadratic, cubic, quartic, exponential (or none)
               timing = animate.gen_timing.cubic({ easing = 'out', duration = 120, unit = 'total' }),
               -- shape of cursor trail: line (default), angle, walls, spiral
               path = animate.gen_path.line({ max_output_steps = 5 }),
            },
            scroll = {
               enable = true,
               timing = animate.gen_timing.linear({ duration = 100, unit = 'total' }),
               subscroll = animate.gen_subscroll.equal({ max_output_steps = 10 }),
            },
            resize = { enable = true },
            open = { enable = false },
            close = { enable = false },
         })
         local statusline = require('mini.statusline')

         -- Indentation the buffer uses: "␣3" (spaces) or "⇥4" (tabs, display width).
         local function section_indent()
            if vim.bo.expandtab then return '␣' .. vim.fn.shiftwidth() end
            return '⇥' .. vim.bo.tabstop
         end

         -- Active session (set by mini.sessions on read/write); "local" for a Session.vim.
         local function section_session()
            local path = vim.v.this_session
            if path == '' then return '' end
            local name = vim.fn.fnamemodify(path, ':t')
            return ' ' .. (name == 'Session.vim' and 'local' or vim.fn.fnamemodify(name, ':r'))
         end

         -- Filetype icon + name; encoding/line endings only when they're not utf-8/unix.
         local function section_fileinfo(trunc_width)
            local ft = vim.bo.filetype
            if ft == '' then return '' end
            local parts = { MiniIcons.get('filetype', ft) .. ' ' .. ft }
            if not statusline.is_truncated(trunc_width) then
               local enc = vim.bo.fileencoding ~= '' and vim.bo.fileencoding or vim.o.encoding
               if enc ~= 'utf-8' then table.insert(parts, enc) end
               if vim.bo.fileformat ~= 'unix' then table.insert(parts, vim.bo.fileformat) end
            end
            return table.concat(parts, ' ')
         end

         -- What <leader>cf would run (conform formatters, or the LSP fallback).
         -- Cached per buffer: resolving formatters checks the filesystem.
         local function section_formatter(trunc_width)
            if statusline.is_truncated(trunc_width) or vim.bo.buftype ~= '' then return '' end
            if vim.b.statusline_formatter == nil then
               local ok, conform = pcall(require, 'conform')
               local text = ''
               if ok then
                  local formatters, lsp = conform.list_formatters_to_run(0)
                  -- ruff_organize_imports + ruff_format -> "ruff"
                  local names, seen = {}, {}
                  for _, f in ipairs(formatters) do
                     local tool = f.name:gsub('_organize_imports$', ''):gsub('_format$', '')
                     if not seen[tool] then
                        seen[tool] = true; table.insert(names, tool)
                     end
                  end
                  if lsp then table.insert(names, 'lsp') end
                  text = #names > 0 and ('󰉼 ' .. table.concat(names, ',')) or ''
               end
               vim.b.statusline_formatter = text
            end
            return vim.b.statusline_formatter
         end
         -- Recompute when the LSP fallback or a project's formatter could have changed.
         vim.api.nvim_create_autocmd({ 'LspAttach', 'LspDetach', 'BufWritePost' }, {
            group = vim.api.nvim_create_augroup('statusline-formatter-cache', { clear = true }),
            callback = function(args) vim.b[args.buf].statusline_formatter = nil end,
         })

         statusline.setup({
            use_icons = true,
            content = {
               active = function()
                  local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
                  local git = statusline.section_git({ trunc_width = 40 })
                  local diff = statusline.section_diff({ trunc_width = 75 })
                  local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
                  local filename = statusline.section_filename({ trunc_width = 140 })
                  local fileinfo = section_fileinfo(120)
                  local indent = section_indent()
                  local formatter = section_formatter(140)
                  local session = section_session()
                  local location = statusline.section_location({ trunc_width = 75 })
                  local search = statusline.section_searchcount({ trunc_width = 75 })

                  local clients = vim.lsp.get_clients({ bufnr = 0 })
                  local client_names = vim.tbl_map(function(client)
                     return client.name
                  end, clients)
                  local language_tools = #client_names > 0 and table.concat(client_names, ', ') or ''

                  local project = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
                  local flags = table.concat({
                     vim.bo.modified and '[+]' or '',
                     vim.bo.readonly and 'RO' or '',
                     vim.bo.modifiable and '' or '-',
                  }, ' ')
                  local recording = vim.fn.reg_recording()
                  recording = recording == '' and '' or ('REC @' .. recording)

                  return statusline.combine_groups({
                     { hl = mode_hl,                  strings = { mode } },
                     { hl = 'MiniStatuslineDevinfo',  strings = { git, diff, diagnostics, language_tools } },
                     { hl = 'MiniStatuslineFilename', strings = { project, session } },
                     '%<',
                     { hl = 'MiniStatuslineFilename', strings = { filename } },
                     '%=',
                     { hl = 'MiniStatuslineFileinfo', strings = { flags, recording, formatter, indent, fileinfo } },
                     { hl = mode_hl,                  strings = { search, location } },
                  })
               end,
            },
         })

         local statusline_palette_group = vim.api.nvim_create_augroup('catppuccin-mini-statusline', { clear = true })
         vim.api.nvim_create_autocmd('ColorScheme', {
            group = statusline_palette_group,
            pattern = 'catppuccin*',
            callback = function()
               local colors = require('catppuccin.palettes').get_palette()
               local set_hl = vim.api.nvim_set_hl

               set_hl(0, 'MiniStatuslineDevinfo', {
                  fg = colors.subtext0,
                  bg = colors.mantle,
               })
               set_hl(0, 'MiniStatuslineFilename', {
                  fg = colors.text,
                  bg = colors.base,
                  bold = true,
               })
               set_hl(0, 'MiniStatuslineFileinfo', {
                  fg = colors.overlay2,
                  bg = colors.mantle,
               })
               set_hl(0, 'MiniStatuslineInactive', {
                  fg = colors.overlay0,
                  bg = colors.crust,
               })
               set_hl(0, 'MiniStatuslineModeNormal', {
                  fg = colors.blue,
                  bg = colors.surface0,
                  bold = true,
               })
               set_hl(0, 'MiniStatuslineModeInsert', {
                  fg = colors.green,
                  bg = colors.surface0,
                  bold = true,
               })
               set_hl(0, 'MiniStatuslineModeVisual', {
                  fg = colors.mauve,
                  bg = colors.surface0,
                  bold = true,
               })
               set_hl(0, 'MiniStatuslineModeReplace', {
                  fg = colors.red,
                  bg = colors.surface0,
                  bold = true,
               })
               set_hl(0, 'MiniStatuslineModeCommand', {
                  fg = colors.peach,
                  bg = colors.surface0,
                  bold = true,
               })
               set_hl(0, 'MiniStatuslineModeOther', {
                  fg = colors.teal,
                  bg = colors.surface0,
                  bold = true,
               })
               set_hl(0, 'MiniAnimateCursor', {
                  bg = colors.lavender,
                  nocombine = true,
               })
            end,
         })
         require('mini.pairs').setup()
         local sessions = require('mini.sessions')
         sessions.setup()
         local function session_map(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end
         session_map('<leader>Sw', function() sessions.write('Session.vim') end, 'Write local session')
         session_map('<leader>SW', function()
            vim.ui.input({ prompt = 'Session name: ' }, function(name)
               if name and name ~= '' then sessions.write(name) end
            end)
         end, 'Write named session')
         session_map('<leader>Sr', function() sessions.read() end, 'Restore default session')
         session_map('<leader>Ss', function() sessions.select('read') end, 'Select session')
         session_map('<leader>Sd', function() sessions.select('delete') end, 'Delete session')
         require('mini.surround').setup()
      end
   }
}
