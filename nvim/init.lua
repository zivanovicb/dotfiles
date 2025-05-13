-- Bootstrap lazy.nvim
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

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Plugin setup with lazy.nvim
require("lazy").setup({
  spec = {
    -- LSP Config
    {
      "neovim/nvim-lspconfig",
      config = function()
        local lspconfig = require("lspconfig")
        local util = require("lspconfig.util")

        -- Go LSP
        lspconfig.gopls.setup({
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        })

        -- Python LSP
        lspconfig.pyright.setup({
          root_dir = util.root_pattern("pyproject.toml", "setup.py", ".git"),

          before_init = function(_, config)
            local function find_venv_path(startpath)
              local path = util.search_ancestors(startpath, function(path)
                if util.path.is_dir(util.path.join(path, ".venv")) then
                  return path
                end
              end)
              return path and util.path.join(path, ".venv", "bin", "python") or nil
            end

            local venv_python = find_venv_path(config.root_dir)
            if venv_python then
              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = venv_python
            end
          end,
        })
      end,
    },

    -- Mason for managing LSPs
    {
      "williamboman/mason.nvim",
      build = ":MasonUpdate",
      config = function()
        require("mason").setup()
      end,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = { "gopls", "pyright" },
        })
      end,
    },

    -- FZF
    {
      "junegunn/fzf",
      build = function() vim.fn["fzf#install"]() end
    },
    { "junegunn/fzf.vim" },

    -- Auto pairs
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = true
    },

    -- Telescope
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },

    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "c", "lua", "vim", "vimdoc", "query",
            "elixir", "heex", "javascript", "html",
            "go", "typescript"
          },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    },
  },

  -- Optional lazy.nvim settings
  checker = { enabled = true },
})

-- Telescope keymaps
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = "Find symbols (functions/classes)" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- LSP keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover info" })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set('n', 'ga', vim.lsp.buf.references, { desc = "Find references" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Yank without line numbers
vim.keymap.set("n", "y", '"+y', { noremap = true })
vim.keymap.set("v", "y", '"+y', { noremap = true })
vim.keymap.set("n", "Y", '"+Y', { noremap = true })

-- General options
vim.wo.relativenumber = true

