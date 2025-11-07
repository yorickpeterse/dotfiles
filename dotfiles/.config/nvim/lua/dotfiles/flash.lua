require("flash").setup({
	labels = "tnseriaogmplfuwyqbjdhvkzxc",
	modes = {
		search = { enabled = false },
		char = { enabled = false },
		treesitter = {
			label = { before = { 0, 0 }, after = false, style = "overlay" },
		},
	},
	prompt = {
		enabled = false,
		win_config = { border = "none" },
	},
	label = {
		before = { 0, 0 },
		after = false,
	},
})
