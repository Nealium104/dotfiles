-- Everything Neovim installs and enables, built from config/languages.lua (the
-- one file to edit). Read by the plugin specs (lsp.lua, treesitter.lua,
-- conform.lua, lint.lua), config/filetypes.lua, and config/bootstrap.lua, which
-- `make install` runs headless so a fresh machine is ready before nvim is opened.
--
-- Command-line tools (ruff, shfmt, prettier, hadolint, yamllint, ...) are not
-- installed from here: the dotfiles Ansible setup installs those system-wide.
local languages = require("config.languages")

-- Language names in a fixed order, so the lists below don't change between runs.
local names = vim.tbl_keys(languages)
table.sort(names)

-- All values of one list field across languages, without duplicates.
local function collect(field)
   local ret, seen = {}, {}
   for _, name in ipairs(names) do
      for _, value in ipairs(languages[name][field] or {}) do
         if not seen[value] then
            seen[value] = true
            table.insert(ret, value)
         end
      end
   end
   return ret
end

-- filetype -> value, for a field that applies per filetype.
local function by_filetype(field)
   local ret = {}
   for _, name in ipairs(names) do
      local lang = languages[name]
      if lang[field] ~= nil then
         for _, ft in ipairs(lang.filetypes or {}) do ret[ft] = lang[field] end
      end
   end
   return ret
end

local indent = {}
for ft, width in pairs(by_filetype("indent")) do
   indent[ft] = { width = width, tabs = by_filetype("tabs")[ft] == true }
end

return {
   lsp_servers = collect("servers"), -- installed by mason and enabled
   system_servers = collect("system"), -- enabled only; binary from Ansible
   mason_packages = collect("mason"),
   parsers = collect("parsers"),
   formatters_by_ft = by_filetype("formatters"),
   linters_by_ft = by_filetype("linters"),
   indent_by_ft = indent, -- filetype -> { width, tabs }
}
