if vim.fn.has("nvim-0.10") == 0 then
  vim.notify("totes requires NeoVim 0.10+. Some features may not work.", vim.log.levels.WARN)
end

vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true

vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

local totes_root = vim.fn.expand("~/.local/share/totes")

-- Bootstrap lazy.nvim into the totes data dir (isolated from ~/.local/share/nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
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
    opts = {
      anti_conceal = { enabled = false },
      checkbox = {
        checked = { icon = "✔" },
        unchecked = { icon = "○" },
      },
    },
  },
  { "MunifTanjim/nui.nvim" },
  { "goolord/alpha-nvim" },
  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    opts = {
      sources = {
        default = { "totes_wikilink", "buffer" },
        providers = {
          totes_wikilink = {
            name = "WikiLink",
            module = "totes.wikilink_completion_source",
          },
        },
      },
    },
  },
}, {
  root = vim.fn.stdpath("data") .. "/lazy",
})

-- lazy.nvim resets rtp on setup; re-add totes_root so require("totes.*") resolves
vim.opt.rtp:prepend(totes_root)

require("totes.vault").init()
require("totes.splash").setup()
require("totes.autogit").setup()
require("totes.notes").setup()
require("totes.daily").setup()
require("totes.telescope_sources").setup()
require("totes.wikilink_nav").setup()
require("totes.promotion").setup()
require("totes.archive").setup()
require("totes.tasks").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>x", function()
      local line = vim.api.nvim_get_current_line()
      local new_line
      if line:match("%- %[x%]") then
        new_line = line:gsub("%- %[x%]", "- [ ]", 1)
      elseif line:match("%- %[ %]") then
        new_line = line:gsub("%- %[ %]", "- [x]", 1)
      end
      if new_line then
        vim.api.nvim_set_current_line(new_line)
      end
    end, { desc = "Toggle checkbox", buffer = true })
  end,
})
