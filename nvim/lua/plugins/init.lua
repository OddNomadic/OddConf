return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          cmp = true,
          gitsigns = true,
          lsp_trouble = false,
          mason = true,
          telescope = true,
          treesitter = true,
          which_key = true,
          native_lsp = {
            enabled = true,
          },
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = {
      "NvimTreeFindFile",
      "NvimTreeFocus",
      "NvimTreeToggle",
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
      { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal current file" },
    },
    config = function()
      require("nvim-tree").setup({
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
        filters = {
          dotfiles = false,
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = {
            git_placement = "after",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          side = "left",
          width = 32,
        },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "catppuccin/nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "css",
          "go",
          "html",
          "asm",
          "javascript",
          "json",
          "julia",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "rust",
          "toml",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = "❯ ",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
        },
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "asm_lsp",
          "bashls",
          "clangd",
          "gopls",
          "julials",
          "jsonls",
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "ts_ls",
          "yamlls",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local function buffer_map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            desc = desc,
          })
        end

        buffer_map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        buffer_map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        buffer_map("n", "gr", vim.lsp.buf.references, "Go to references")
        buffer_map("n", "K", vim.lsp.buf.hover, "Hover documentation")
        buffer_map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        buffer_map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        buffer_map("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, "Format buffer")
      end

      local servers = {
        asm_lsp = {},
        bashls = {},
        clangd = {},
        gopls = {},
        julials = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
        pyright = {},
        rust_analyzer = {},
        ts_ls = {},
        yamlls = {},
      }

      for name, server_config in pairs(servers) do
        server_config.capabilities = capabilities
        server_config.on_attach = on_attach
        lspconfig[name].setup(server_config)
      end
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
