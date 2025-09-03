return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  config = function()
    local option = vim.o
    -- Folding settings
    option.foldcolumn = '1' -- '0' is also an option
    option.foldlevel = 99 -- Required for ufo, adjust as needed
    option.foldlevelstart = 99
    option.foldenable = true

    local keymap = vim.keymap
    -- Key mappings for ufo folding
    keymap.set('n', 'zR', require('ufo').openAllFolds)
    keymap.set('n', 'zM', require('ufo').closeAllFolds)
    keymap.set('n', 'zK', function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, { desc = "Peek Fold" })

    require('ufo').setup({
      provider_selector = function(bufnr, filetype, buftype)
        return { "lsp", "indent" }
      end
    })
  end
}
