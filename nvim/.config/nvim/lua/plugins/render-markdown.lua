return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.nvim", -- provides mini.icons; falls back gracefully if unavailable
	},
	ft = { "markdown" },
	opts = {},
	keys = {
		{ "<leader>p", "<cmd>RenderMarkdown toggle<cr>", desc = "Preview markdown (toggle render)" },
	},
}
