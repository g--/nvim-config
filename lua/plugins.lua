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

-- vim.cmd [[packadd packer.nvim]]
vim.g.fzf_action = { enter= 'tab split' }

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
  {
	  	 'neovim/nvim-lspconfig',
		 config = function()
            util = require "lspconfig/util"
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
		end,
  },
  'nvim-lua/completion-nvim',
  'anott03/nvim-lspinstall',
  'ryanoasis/vim-devicons',
  'mfussenegger/nvim-jdtls',

  {
      'ruifm/gitlinker.nvim',
      dependencies = 'nvim-lua/plenary.nvim',
  },


  { 'junegunn/fzf', build = ":call fzf#install()" },
  { 'junegunn/fzf.vim',
    --  optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
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

  -- ideas:
  --   nvim-tree/nvim-tree.lua
  --   nvim-tree/nvim-web-devicons.lua
  --   nvim-lualine/lualine.nvim

  -- util = require "lspconfig/util"
  --
 
})

