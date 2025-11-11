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
    -- Get the start and end positions of the visual selection
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    -- Get the lines in the selection
    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

    if #lines == 0 then
        return ""
    end

    -- Handle single line selection
    if #lines == 1 then
        local line = lines[1]
        -- Extract the substring from start column to end column (1-indexed)
        return string.sub(line, start_pos[3], end_pos[3])
    end

    -- Handle multi-line selection
    -- First line: from start column to end
    lines[1] = string.sub(lines[1], start_pos[3])
    -- Last line: from beginning to end column
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])

    -- Join all lines with spaces
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

-- Function to check if text is a URL
local function is_url(text)
    -- Match common URL patterns (http, https, ftp, file, etc.)
    return text:match("^https?://") or
           text:match("^ftp://") or
           text:match("^file://") or
           text:match("^[%w%.%-]+%.%w+/") or  -- domain.com/path
           text:match("^www%.%w+%.%w+")      -- www.example.com
end

-- Function to open URL directly
local function open_url(url)
    -- Add https:// prefix if missing for www. URLs
    if url:match("^www%.") then
        url = "https://" .. url
    end
    -- Properly escape the URL for shell execution
    local escaped_url = string.gsub(url, "'", "'\"'\"'")
    vim.fn.system("open '" .. escaped_url .. "'")
end

-- Function to search with Google
local function google_search(text)
    local filetype = vim.bo.filetype
    local query = url_encode(text .. " " .. filetype)
    local url = "https://www.google.com/search?q=" .. query
    -- Properly escape the URL for shell execution
    local escaped_url = string.gsub(url, "'", "'\"'\"'")
    vim.fn.system("open '" .. escaped_url .. "'")
end

-- lookup - opens URL if cursor is on one, otherwise searches for current word with file type
vim.keymap.set('n', 'gl', function()
    -- First try to get the word under cursor
    local word = vim.fn.expand("<cword>")

    -- If the word looks like a URL, use it
    if is_url(word) then
        open_url(word)
        return
    end

    -- If not, try to extract a longer URL from the current line
    -- This handles cases where the cursor is on part of a URL that extends beyond word boundaries
    local line = vim.fn.getline('.')
    local col = vim.fn.col('.')

    -- Look for URL patterns in the current line around the cursor position
    for url in line:gmatch("https?://[%w%.%-_~:/?#%[%]@!$&'%(%)%*%+,;=%%]+") do
        local start_pos, end_pos = line:find(url, 1, true)
        if start_pos and end_pos and col >= start_pos and col <= end_pos then
            open_url(url)
            return
        end
    end

    -- Check for www. URLs too
    for url in line:gmatch("www%.[%w%.%-_~:/?#%[%]@!$&'%(%)%*%+,;=%%]+") do
        local start_pos, end_pos = line:find(url, 1, true)
        if start_pos and end_pos and col >= start_pos and col <= end_pos then
            open_url(url)
            return
        end
    end

    -- If no URL found, do regular Google search
    google_search(word)
end, { noremap = true, silent = true })

-- lookup - searches for selected text with file type in visual mode
vim.keymap.set('v', 'gl', function()
    -- Use a much simpler approach: yank to a specific register and get it immediately
    vim.cmd('normal! "zy')
    local selection = vim.fn.getreg('z')

    -- Clean up the selection
    selection = string.gsub(selection, '\n', ' ')
    selection = string.gsub(selection, '\r', ' ')
    selection = string.gsub(selection, '%s+', ' ')
    selection = string.gsub(selection, '^%s*(.-)%s*$', '%1')

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
