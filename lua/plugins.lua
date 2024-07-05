local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

vim.cmd [[packadd packer.nvim]]
vim.g.fzf_action = { enter= 'tab split' }

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'nvim-treesitter/nvim-treesitter'
  use {'prettier/vim-prettier', run = 'yarn install' }

  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/completion-nvim'
  use 'anott03/nvim-lspinstall'
  use 'ryanoasis/vim-devicons'
  use 'mfussenegger/nvim-jdtls'

  use {
      'ruifm/gitlinker.nvim',
      requires = 'nvim-lua/plenary.nvim',
  }


  use { 'junegunn/fzf', run = ":call fzf#install()" }
  use { 'junegunn/fzf.vim',
    --  optional for icon support
    requires = { "nvim-tree/nvim-web-devicons" }
  }

  -- ideas:
  --   nvim-tree/nvim-tree.lua
  --   nvim-tree/nvim-web-devicons.lua
  --   nvim-lualine/lualine.nvim

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


  if packer_bootstrap then
    require('packer').sync()
  end
end)

