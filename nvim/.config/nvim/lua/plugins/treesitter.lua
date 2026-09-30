return {
    {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",     -- required for Neovim 0.12; `master` is 0.10/0.11 only
	lazy = false,        -- the `main` branch does not support lazy-loading
	build = ":TSUpdate",
	config = function ()
	    require("nvim-treesitter").setup()

	    -- Parsers to keep installed (replaces the old `ensure_installed`).
	    require("nvim-treesitter").install({
		"c", "c_sharp", "lua", "vim", "vimdoc", "query", "markdown",
		"markdown_inline", "javascript", "go", "rust", "php", "typescript",
		"xml", "yaml", "python", "perl", "json", "jsdoc", "phpdoc", "html",
	    })

	    -- Enable treesitter highlighting per-filetype (replaces the old
	    -- `highlight = { enable = true, disable = <large files> }`).
	    vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
		    local buf = args.buf
		    local max_filesize = 100 * 1024 -- 100 KB
		    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
		    if ok and stats and stats.size > max_filesize then
			return
		    end
		    -- no-op for filetypes without an installed parser
		    pcall(vim.treesitter.start, buf)
		end,
	    })
	end
    }
}
