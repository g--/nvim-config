local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.diagnostic.config({
  underline = true,
  virtual_text = false,

  signs = true,
  update_in_insert = false,
  severity = true,
  signs = {
	text = {
        [vim.diagnostic.severity.ERROR] = '‼️',
        [vim.diagnostic.severity.WARN] = '⚠️',
    },
    linehl = {
        [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
    },
    numhl = {
        [vim.diagnostic.severity.WARN] = 'WarningMsg',
    },
  },
})

require('lazy').setup({
  'nvim-treesitter/nvim-treesitter',
  {'prettier/vim-prettier', build = 'yarn install' },
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = 'light' -- or 'light'

      vim.cmd.colorscheme 'solarized'
    end,
  },

  -- consider https://github.com/williamboman/mason.nvim
  {
    'neovim/nvim-lspconfig',

    config = function()
      util = require "lspconfig/util"
	  -- util.default_config = {
	  -- }

      require('lspconfig').gopls.setup{
       cmd = {"gopls", "serve"},
       filetypes = {"go", "gomod"},
       root_dir = util.root_pattern("go.work", "go.mod", ".git"),
       settings = {
         gopls = {
           analyses = {
             unusedparams = true,
           },
           staticcheck = true,
         },
       },
      }
      require('lspconfig').terraformls.setup{
        cmd = {"terraform-ls", "serve"},
        filetypes = {"terraform", "hcl"},
        root_dir = util.root_pattern(".terraform", ".git"),
        settings = {
        },
      }
      require('lspconfig').rust_analyzer.setup{
		  -- Server-specific settings. See `:help lspconfig-setup`
		  settings = {
			['rust-analyzer'] = {},
		  },
	  }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    -- event = "LazyFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      signs_staged_enable = true,
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`

      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
  
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end
  
        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
      require("claude-code").setup()
    end
  },
  'nvim-lua/completion-nvim',
  'anott03/nvim-lspinstall',
  'ryanoasis/vim-devicons',
  'mfussenegger/nvim-jdtls',

  {
      'ruifm/gitlinker.nvim',
      dependencies = 'nvim-lua/plenary.nvim',
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "ibhagwan/fzf-lua",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup()
    end
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      local actions = require "fzf-lua.actions"
      require("fzf-lua").setup({
          actions = {
              files = {
                ["enter"]  = actions.file_switch_or_edit,
                ["ctrl-s"] = actions.file_split,
                ["ctrl-v"] = actions.file_vsplit,
                ["ctrl-t"] = actions.file_tabedit,
                ["alt-q"]  = actions.file_sel_to_qf,
                ["alt-Q"]  = actions.file_sel_to_ll,
--         ["ctrl-b"] = function(selected)
--	           for _, file in ipairs(selected) do
--	             vim.cmd('edit ' .. file)
--	           end
--	         end,
              }
          }
      })
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        require('lualine').setup {
            options = {
                theme = 'solarized_light',
            }
        }
    end,

  },
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts) require'lsp_signature'.setup(opts) end
  },

  -- ideas:
  --   nvim-tree/nvim-tree.lua
  --   nvim-tree/nvim-web-devicons.lua
  --   nvim-lualine/lualine.nvim

  -- util = require "lspconfig/util"
  --
 
})


