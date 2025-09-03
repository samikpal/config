return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
  keys = {
    {
      "<leader>tf",
      function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        if vim.b.disable_autoformat then
          vim.notify("Disabled autoformat for current buffer")
        else
          vim.notify("Enabled autoformat for current buffer")
        end
      end,
      desc = "Toggle autoformat for current buffer",
    },
    {
      "<leader>tF",
      function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        if vim.g.disable_autoformat then
          vim.notify("Disabled autoformat globally")
        else
          vim.notify("Enabled autoformat globally")
        end
      end,
      desc = "Toggle autoformat globally",
    }
  },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "flake8", "black" },
			},
      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
          return
        end
        return {
          lsp_fallback = true,
          async = false,
          timeout_ms = 5000,
        }
      end,
			formatters = {
				injected = { options = { ignore_errors = true } },
				black = {
					prepend_args = { "--line-length", "120", "--fast" },
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
