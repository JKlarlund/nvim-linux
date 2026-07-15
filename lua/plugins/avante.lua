-- ~/.config/nvim/lua/plugins/avante.lua
-- Avante.nvim configured to use Claude Code via ACP (Agent Client Protocol).
-- Auth comes from the Claude CLI's own login (Pro/Max subscription) —
-- no ANTHROPIC_API_KEY needed. Make sure `claude` works in a terminal first.

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- never set to "*" (per avante's own docs)
  build = "make",
  -- On Windows use instead:
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false",

  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "claude-code",

    acp_providers = {
      ["claude-code"] = {
        command = "npx",
        args = { "@zed-industries/claude-code-acp" },
        env = {
          NODE_NO_WARNINGS = "1",
          -- Deliberately NO ANTHROPIC_API_KEY here.
          -- Absent key => the adapter falls back to the Claude CLI's
          -- stored subscription login instead of API billing.
        },
      },
    },

    -- Optional fallback: direct API provider, kept around so you can
    -- switch with :AvanteSwitchProvider claude if you ever want to.
    -- Requires ANTHROPIC_API_KEY exported in your shell to actually work.
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-5",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
    },

    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true,
      minimize_diff = true,
      auto_approve_tool_permissions = false, -- keep the permission prompts
    },
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    -- Optional but nice to have:
    "ibhagwan/fzf-lua", -- file selector
    {
      -- image pasting support
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
        },
      },
    },
    {
      -- markdown rendering in the sidebar
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "Avante" } },
      ft = { "markdown", "Avante" },
    },
  },
}
