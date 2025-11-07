-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local HOME=os.getenv("HOME")
local USERNAME=os.getenv("USER")

vim.opt.scl = 'yes'

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt_local.spelllang='en_ca'
vim.opt.spellfile = {
	HOME .. "/.gsync/wordlist.en-ca.add",
	HOME .. "/.esync/individual/" .. USERNAME .. "/wordlist.en-ca.add"
}


-- vim.g.mapleader = ' '
--
map("n", "t", ":Files<CR>")
-- map("", "<leader>p", ":Files<CR>")
-- map("", "<leader><space>", ":Buffers<CR>")
vim.keymap.set("", "<leader>p", function() require('fzf-lua').files() end)
vim.keymap.set("", "<leader><space>", function() require('fzf-lua').buffers() end)
vim.keymap.set("", "<leader>g", function() require('fzf-lua').grep() end)
map("", "gp", ":tabprevious<CR>")
map("", "gn", ":tabnext<CR>")

-- Function to get visual selection
local function get_visual_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.fn.getline(start_pos[2], end_pos[2])

    if #lines == 0 then
        return ""
    end

    -- Handle single line selection
    if #lines == 1 then
        return string.sub(lines[1], start_pos[3], end_pos[3])
    end

    -- Handle multi-line selection
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])

    return table.concat(lines, " ")
end

-- Function to URL encode text
local function url_encode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w _%%%-%.~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

-- Function to search with Google
local function google_search(text)
    local filetype = vim.bo.filetype
    local query = url_encode(text .. " " .. filetype)
    local url = "https://www.google.com/search?q=" .. query
    vim.fn.system("open '" .. url .. "'")
end

-- lookup - searches for current word with file type
map('n', "gl", ':silent !open "https://www.google.com/search?q=<c-r>=expand("<cword>")<cr>+<c-r>=&filetype<cr>"<CR>')

-- lookup - searches for selected text with file type in visual mode
vim.keymap.set('v', 'gl', function()
    local selection = get_visual_selection()
    google_search(selection)
end, { noremap = true, silent = true })

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

  vim.keymap.set('n', '<leader>e', function () vim.diagnostic.open_float() end, bufopts)

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
