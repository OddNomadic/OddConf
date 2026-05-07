vim.g.mapleader = " "
vim.g.maplocalleader = " "

local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to install lazy.nvim:\n", "ErrorMsg" },
      { output, "ErrorMsg" },
    }, true, {})
    vim.cmd("cq")
    return
  end
end

vim.opt.rtp:prepend(lazypath)

require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup(require("plugins"), {
  change_detection = {
    notify = false,
  },
  defaults = {
    lazy = true,
  },
  install = {
    colorscheme = { "catppuccin" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
