local map = vim.keymap.set

local function pick_directory(opts)
  opts = opts or {}

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local conf = require("telescope.config").values

  local find_command
  if vim.fn.executable("fd") == 1 then
    find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" }
  else
    find_command = { "find", ".", "-type", "d", "-not", "-path", "*/.git/*" }
  end

  pickers
    .new({}, {
      prompt_title = opts.prompt_title or "Directories",
      finder = finders.new_oneshot_job(find_command, {
        entry_maker = function(entry)
          local path = vim.fn.fnamemodify(entry, ":p")
          return {
            value = path,
            display = vim.fn.fnamemodify(path, ":~:."),
            ordinal = path,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if not selection then
            return
          end

          local dir = selection.value
          if opts.change_cwd then
            vim.cmd.cd(vim.fn.fnameescape(dir))
          end

          vim.cmd("NvimTreeOpen " .. vim.fn.fnameescape(dir))
        end)

        return true
      end,
    })
    :find()
end

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", ";", ":", { desc = "Command mode" })

map("n", "<leader>wh", "<C-w>h", { desc = "Window left" })
map("n", "<leader>wj", "<C-w>j", { desc = "Window down" })
map("n", "<leader>wk", "<C-w>k", { desc = "Window up" })
map("n", "<leader>wl", "<C-w>l", { desc = "Window right" })
map("n", "<leader>wv", "<C-w>v", { desc = "Vertical split" })
map("n", "<leader>ws", "<C-w>s", { desc = "Horizontal split" })
map("n", "<leader>wq", "<C-w>q", { desc = "Close window" })
map("n", "<leader>wo", "<C-w>o", { desc = "Only window" })
map("n", "<leader>w=", "<C-w>=", { desc = "Balance windows" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>quitall!<cr>", { desc = "Quit all" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>tn", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>tr", function()
  local current_name = vim.t.tabname or ""
  vim.ui.input({ prompt = "Tab name: ", default = current_name }, function(input)
    if input == nil then
      return
    end

    input = vim.trim(input)
    if input == "" then
      vim.t.tabname = nil
    else
      vim.t.tabname = input
    end

    vim.cmd.redrawtabline()
  end)
end, { desc = "Rename tab" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>fC", function()
  pick_directory({ change_cwd = true, prompt_title = "Change cwd and open tree" })
end, { desc = "Find dir, cd, open tree" })
map("n", "<leader>fE", function()
  pick_directory({ change_cwd = false, prompt_title = "Open tree at directory" })
end, { desc = "Find dir, open tree" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
