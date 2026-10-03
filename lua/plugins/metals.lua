return {
  "scalameta/nvim-metals",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  ft = { "scala", "sbt" },
  config = function()
    -- Ensure coursier bin is on PATH so nvim-metals can find cs
    local coursier_bin = vim.fn.expand("$HOME/.local/share/coursier/bin")
    if vim.fn.isdirectory(coursier_bin) == 1 and not vim.env.PATH:find(coursier_bin, 1, true) then
      vim.env.PATH = coursier_bin .. ":" .. vim.env.PATH
    end

    local metals = require("metals")
    local metals_config = metals.bare_config()
    metals_config.settings = {
      showImplicitArguments = true,
      fallbackScalaVersion = "3.3.4",
    }
    metals_config.init_options.statusBarProvider = "off"
    metals_config.capabilities = vim.lsp.protocol.make_client_capabilities()

    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt" },
      callback = function()
        metals.initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })

    -- Attach to the current buffer immediately since ft loading means
    -- the FileType event already fired before this config runs
    metals.initialize_or_attach(metals_config)
  end,
}
