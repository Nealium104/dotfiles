-- A random short quote from the Obsidian vault, for the dashboard. Two sources,
-- picked between evenly so a few typed quotes aren't buried under hundreds of
-- highlights:
--
-- Kindle highlights: one note per book in "6. Kindle Highlights", written by
-- the Kindle plugin: frontmatter with kindle-title and kindle-author, then each
-- highlight between `---` lines, ending in "— location: [...]() ^ref-...".
--
-- Quote notes: made from Templates/Quote Template.md and kept in
-- "2. Content Notes/Quotes": `type: quote` with Author and source_title, the
-- quote itself as the note's body.
--
-- The vault lives on the Windows drive, where WSL reads files slowly, so this
-- opens one random note at a time (a few at most) instead of all of them, and
-- looks for quote notes in their folder rather than across the whole vault.
local M = {}

M.dir = vim.fn.expand("~/obsidian/6. Kindle Highlights")
M.quotes_dir = vim.fn.expand("~/obsidian/2. Content Notes/Quotes")

-- Long passages and fragments are left out. Highlights also catch things that
-- aren't quotes at all: section titles, exercises, links
M.min_chars, M.max_chars, M.min_words = 40, 220, 7
local junk = { "^Exercise", "^Figure", "^Chapter", "^Section", "^Table", "https?://", "www[%.%-]" }
-- a whole sentence: starts like one and ends like one, so highlights that
-- begin or stop mid-thought are left out. (lists, not patterns: curly quotes
-- are several bytes, which lua's patterns can't put in a character class)
local starts = { "“", "‘", '"', "'", "(" }
local ends = { ".", "!", "?", "…", '"', "”", "’", "'", ".)" }

local function any(list, fn)
   for _, s in ipairs(list) do
      if fn(s) then return true end
   end
   return false
end

local function usable(text)
   if #text < M.min_chars or #text > M.max_chars then return false end
   if select(2, text:gsub("%S+", "")) < M.min_words then return false end
   if not (text:match("^[%u%d]") or any(starts, function(s) return vim.startswith(text, s) end)) then return false end
   if not any(ends, function(s) return vim.endswith(text, s) end) then return false end
   return not any(junk, function(p) return text:find(p) ~= nil end)
end

-- a frontmatter value, including the indented multi-line form (`key: >-`
-- then the value on the lines below) the plugin uses for long titles
local function field(content, key)
   local value = content:match("\n" .. key .. ": *([^\n]*)")
   if not value then return nil end
   if value:match("^[>|]%-?$") then
      local lines = {}
      for line in content:match("\n" .. key .. ": *[^\n]*\n(.-)\n%S"):gmatch("[^\n]+") do
         table.insert(lines, vim.trim(line))
      end
      value = table.concat(lines, " ")
   end
   value = value:gsub("^'(.*)'$", "%1")
   return value ~= "" and value or nil
end

-- the book's name without its subtitle, series or edition:
-- "Sapiens: A Brief History of Humankind – The #1..." → "Sapiens",
-- "The Hero of Ages_ Book Three of Mistborn" → "The Hero of Ages" (the plugin
-- writes "_" where a ":" was), "The Go Programming Language (Addison-...)" →
-- "The Go Programming Language"
local function short_title(title)
   title = title:gsub(" ?Z%-Library", ""):gsub("%s*%b()", "")
   title = vim.trim((title:gsub("[:_] .*$", ""):gsub(" [–—] .*$", ""):gsub(" %-%- .*$", "")))
   -- a few notes carry a whole collection's name; cut at a word to fit one line
   if #title > 50 then title = title:sub(1, 50):gsub("[%s,]+%S*$", "") .. "…" end
   return title
end

-- "Gibson, William" → "William Gibson"; drops a repeated "[Name]"; leaves a
-- list of several authors alone
local function tidy_author(author)
   -- "The" comes from file names like "The_et_al-The DevOps Handbook.md"
   if not author or author == "Unknown" or author == "The" then return nil end
   author = vim.trim((author:gsub("%s*%b[]", "")))
   local last, first = author:match("^([^,]+), ([^,]+)$")
   if last and not first:find(" and ") then author = first .. " " .. last end
   return author
end

--- Every usable highlight in one book's note, with its title and author.
---@param path string
---@return { text: string, title: string, author: string? }[]
function M.from_file(path)
   local f = io.open(path, "r")
   if not f then return {} end
   local content = f:read("*a")
   f:close()
   -- notes without metadata are still named "Author-Title.md"
   local name = vim.fn.fnamemodify(path, ":t:r"):gsub("%-%d+$", "")
   local name_author, name_title = name:match("^([^-]+)%-(.+)$")
   local title = short_title(field(content, "kindle%-title") or name_title or name)
   local author = tidy_author(field(content, "kindle%-author") or (name_author and name_author:gsub("_et_al$", "")))
   local body = content:match("\n## Highlights\n(.*)$") or ""
   local found = {}
   for chunk in (body .. "\n---\n"):gmatch("(.-)\n%-%-%-\n") do
      local text = chunk:gsub("%s*—%s*location:.*$", ""):gsub("%s+", " ")
      text = vim.trim(text)
      if usable(text) then table.insert(found, { text = text, title = title, author = author }) end
   end
   return found
end

-- one line of a quote note as plain text: no trailing spaces (markdown's
-- line break) and no emphasis wrapped around the whole line (_x_, *x*, **x**)
local function plain(line)
   line = vim.trim(line)
   for _, mark in ipairs({ "**", "__", "*", "_" }) do
      if #line > 2 * #mark and vim.startswith(line, mark) and vim.endswith(line, mark) then
         line = line:sub(#mark + 1, -#mark - 1)
      end
   end
   return line
end

--- The quote in a quote note, or nil if it isn't one or is too long. Only the
--- length limit applies: these were chosen by hand, so no sentence checks.
---@param path string
---@return { text: string, title: string?, author: string? }?
function M.from_quote_note(path)
   local f = io.open(path, "r")
   if not f then return nil end
   local content = f:read("*a")
   f:close()
   if field(content, "type") ~= "quote" then return nil end
   local lines = {}
   for line in ((content:match("^%-%-%-\n.-\n%-%-%-\n(.*)$") or "") .. "\n"):gmatch("(.-)\n") do
      table.insert(lines, plain(line))
   end
   local text = vim.trim(table.concat(lines, "\n"))
   if text == "" or #text > M.max_chars then return nil end
   return { text = text, title = field(content, "source_title"), author = field(content, "Author") }
end

-- random .md files in a folder, a few at most, until `pick` returns something
local function try(dir, pick)
   local ok, names = pcall(vim.fn.readdir, dir, function(name) return name:match("%.md$") and 1 or 0 end)
   if not ok or #names == 0 then return nil end
   for _ = 1, 5 do
      local found = pick(dir .. "/" .. names[math.random(#names)])
      if found then return found end
   end
end

local function highlight()
   return try(M.dir, function(path)
      local found = M.from_file(path)
      return #found > 0 and found[math.random(#found)] or nil
   end)
end

local function quote_note() return try(M.quotes_dir, M.from_quote_note) end

--- A random usable quote, from either source (the other when one has nothing),
--- or nil when the vault isn't there.
---@return { text: string, title: string?, author: string? }?
function M.random()
   math.randomseed(vim.uv.hrtime())
   local first, second = highlight, quote_note
   if math.random(2) == 1 then first, second = second, first end
   return first() or second()
end

--- Break text into lines of at most `width` columns, at spaces. Line breaks
--- already in the text (a typed quote's own lines) are kept.
---@param text string
---@param width integer
---@return string[]
function M.wrap(text, width)
   local lines = {}
   for paragraph in (text .. "\n"):gmatch("(.-)\n") do
      local line = ""
      for word in paragraph:gmatch("%S+") do
         if line ~= "" and vim.fn.strdisplaywidth(line .. " " .. word) > width then
            table.insert(lines, line)
            line = word
         else
            line = line == "" and word or (line .. " " .. word)
         end
      end
      if line ~= "" then table.insert(lines, line) end
   end
   return lines
end

--- "— Author, Title", "— Author" or "— Title", whichever parts there are.
---@param quote { title: string?, author: string? }
---@return string?
function M.credit(quote)
   local parts = vim.tbl_filter(function(s) return s and s ~= "" end, { quote.author, quote.title })
   return #parts > 0 and ("— " .. table.concat(parts, ", ")) or nil
end

return M
