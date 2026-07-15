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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.wo.relativenumber = true
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>")
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })
vim.keymap.set("n", "<C-n>", ":Neotree toggle filesystem left<CR>", { desc = "Toggle file explorer" })
-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
require("neo-tree").setup({})

require('lspconfig')['clangd'].setup({
  on_attach = on_attach,
  cmd = { 'clangd' }, 
  flags = {
    debounce_text_changes = 150
  }
})
require('lspconfig').pyright.setup{}
require('lspconfig').cmake.setup({
    cmd = { "cmake-language-server" },
})
require('lspconfig').coq_lsp.setup({
    cmd = { "opam", "exec", "--", "coq-lsp" },
})

--For next.js projects-----
local front_end_servers = { 'tailwindcss', 'jsonls', 'eslint-lsp', 'vtsls'}
for _, lsp in pairs(front_end_servers) do
  require('lspconfig')[lsp].setup({
    on_attach = on_attach,
    capabilites = capabilities,
  })
end
---------------------------

require('render-markdown').setup({})

vim.cmd("colorscheme onedark")

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'onedark',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
      refresh_time = 16, -- ~60fps
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'CursorMovedI',
        'ModeChanged',
      },
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "rounded",
    max_width = 80,
  }
)

local orig_hover = vim.lsp.handlers.hover

vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  if result and result.contents then
    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)

    for i, line in ipairs(lines) do
      lines[i] = line
        :gsub("\\brief", "")
        :gsub("\\param", "")
        :gsub("\\return", "")
        :gsub("\\p", "")
        :gsub("\\note[%w_]*", "")
    end

    result.contents = lines
  end

  return orig_hover(err, result, ctx, config)
end

vim.keymap.set("n", "<C-t>", "<cmd>ToggleTerm<CR>")
