if vim.fn.has("nvim-0.10") == 0 then
  vim.notify("totes requires NeoVim 0.10+. Some features may not work.", vim.log.levels.WARN)
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Make lua/totes/* resolvable via require()
local totes_root = vim.fn.expand("~/.local/share/totes")
vim.opt.rtp:prepend(totes_root)

-- Bootstrap lazy.nvim into the totes data dir (isolated from ~/.local/share/nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  { "MunifTanjim/nui.nvim" },
  { "goolord/alpha-nvim", opts = {} },
}, {
  root = vim.fn.stdpath("data") .. "/lazy",
})

require("totes.vault").init()
require("totes.splash").setup()
require("totes.command").setup()
require("totes.autogit").setup()
require("totes.notes").setup()
