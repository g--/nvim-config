-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt_local.spelllang='en_ca'

-- vim.g.mapleader = ' '
--
map("n", "t", ":Files<CR>")
-- map("", "<leader>p", ":Files<CR>")
-- map("", "<leader><space>", ":Buffers<CR>")
vim.keymap.set("", "<leader>p", function() require('fzf-lua').files() end)
vim.keymap.set("", "<leader><space>", function() require('fzf-lua').buffers() end)
map("", "<leader>g", ":Rg<CR>")
map("", "gp", ":tabprevious<CR>")
map("", "gn", ":tabnext<CR>")

-- lookup
map('', "gl", ':silent !open "https://www.google.com/search?q=<c-r>=expand("<cword>")<cr>"<CR>')

-- TODO: open definition in new tab
-- https://neovim.discourse.group/t/go-to-definition-in-new-tab/1552/3

 -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration { reuse_win = true } end, bufopts)
  vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition { reuse_win = true } end, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation { reuse_win = true } end, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))


  end, bufopts)
  vim.keymap.set('n', '<space>D', function() vim.lsp.buf.type_definition { reuse_win = true } end, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

  vim.opt.clipboard='unnamedplus'

  require"gitlinker".setup()

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'txt', 'markdown'},
  callback = function(args)
	  vim.opt_local.spell = true
  end
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'gitcommit'},
  callback = function(args)
	  vim.opt_local.spell = true
	  vim.wo.wrap = true
	  vim.wo.linebreak = true
	  vim.opt_local.textwidth = 72
  end
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = {
    "/private/*comment*.yml",
  },
  callback = function(args)
	  vim.opt_local.spell = true
	  vim.wo.wrap = true
	  vim.wo.linebreak = true
	  vim.opt_local.textwidth = 72
  end
})
