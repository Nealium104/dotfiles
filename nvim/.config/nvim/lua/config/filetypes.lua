vim.filetype.add({
   extension = {
      yml = function(path, bufnr)
         if path:match("/playbooks/") or path:match("/roles/") or path:match("/tasks/") then
            return "yaml.ansible"
         end

         -- Check file content for Ansible keywords
         local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
         if content:match("^%-%s?hosts:") or content:match("^%-%s?name:") then
            return "yaml.ansible"
         end

         return "yaml"
      end,
   },
   pattern = {
      -- Force specific filenames
      [".*/playbooks/.*%.yml"]    = "yaml.ansible",
      [".*/roles/.*%.yml"]        = "yaml.ansible",
      ["ansible.yml"]             = "yaml.ansible",
      [".*prod.*%.conf"]          = "nginx",
      [".*nginx.*%.conf"]         = "nginx",
   },
})

local indent_by_filetype = {
   -- filetype = { width, use_tabs }
   html = { 4 },
   css = { 2 },
   javascript = { 2 },
   javascriptreact = { 2 },
   typescript = { 2 },
   typescriptreact = { 2 },
   mustache = { 4 },

   php = { 4 },
   sh = { 4 },
   python = { 4 },
   go = { 4, true },
   sql = { 2 },

   nginx = { 4 },
   dockerfile = { 2 },

   cs = { 4 }, -- c sharp
   rust = { 4 },
   lua = { 3 },
}

local function set_indent(width, use_tabs)
   vim.opt_local.expandtab = not use_tabs
   vim.opt_local.tabstop = width
   vim.opt_local.shiftwidth = width
   vim.opt_local.softtabstop = width
   if use_tabs then
      -- Tabs expected, don't flag them; still show trailing spaces.
      vim.opt_local.listchars = { tab = "  ", trail = "•" }
   end
end

vim.api.nvim_create_autocmd("FileType", {
   group = vim.api.nvim_create_augroup("filetype-indent", { clear = true }),
   callback = function(args)
      local spec = indent_by_filetype[args.match]
      -- docker compose
      local name = vim.fs.basename(args.file)
      if not spec and args.match == "yaml" and (name:match("^compose.*%.ya?ml$") or name:match("^docker%-compose.*%.ya?ml$")) then
         spec = { 2 }
      end
      if spec then
         set_indent(spec[1], spec[2])
      end
   end,
})

-- Spell check prose: notes, docs, and commit messages.
vim.api.nvim_create_autocmd("FileType", {
   group = vim.api.nvim_create_augroup("filetype-spell", { clear = true }),
   pattern = { "markdown", "gitcommit" },
   callback = function()
      vim.opt_local.spell = true
      vim.opt_local.spelllang = "en_us"
   end,
})
