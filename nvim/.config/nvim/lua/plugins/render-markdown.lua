return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.nvim", -- provides mini.icons; falls back gracefully if unavailable
	},
	ft = { "markdown" },
	opts = {
        checkbox = {
            unchecked = { icon = " " },
            checked = { icon = " " },
            custom = {
                forwarded = { raw = "[>]", rendered = " ", highlight = "DiagnosticInfo" },
                cancelled = { raw = "[~]", rendered = " ", highlight = "Comment" },
                important = { raw = "[!]", rendered = " ", highlight = "DiagnosticWarn" },
            },
        },
    },
	keys = {
		{ "<leader>p", "<cmd>RenderMarkdown toggle<cr>", desc = "Preview markdown (toggle render)" },
	},
}
