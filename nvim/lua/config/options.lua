local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.mouse = "a"
opt.mousemodel = "popup_setpos"
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

opt.showtabline = 2
opt.tabline = "%!v:lua.OddconfTabline()"

function _G.OddconfTabline()
  local parts = {}

  for tab = 1, vim.fn.tabpagenr("$") do
    local is_current = tab == vim.fn.tabpagenr()
    local tab_vars = vim.t[tab]
    local name = tab_vars and tab_vars.tabname

    if not name or name == "" then
      local win = vim.fn.tabpagewinnr(tab)
      local buflist = vim.fn.tabpagebuflist(tab)
      local buf = buflist[win]
      name = vim.fn.fnamemodify(vim.fn.bufname(buf), ":t")
      if name == "" then
        name = "[No Name]"
      end
    end

    local highlight = is_current and "%#TabLineSel#" or "%#TabLine#"
    table.insert(parts, string.format("%s%%%dT %d:%s ", highlight, tab, tab, name))
  end

  table.insert(parts, "%#TabLineFill#%T")
  return table.concat(parts)
end

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
