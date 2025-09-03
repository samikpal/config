return {
  {
    "loctvl842/monokai-pro.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("monokai-pro").setup({
        style = "octagon",
      })
      -- load the colorscheme here
      vim.cmd([[colorscheme monokai-pro]])
    end,
  },
}
