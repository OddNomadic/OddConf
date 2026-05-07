local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.confirm = true
opt.hidden = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.timeoutlen = 400
opt.updatetime = 200
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.shiftround = true
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "␣",
}

vim.diagnostic.config({
  float = {
    border = "rounded",
    source = "if_many",
  },
  severity_sort = true,
  signs = true,
  update_in_insert = false,
  virtual_text = false,
})
