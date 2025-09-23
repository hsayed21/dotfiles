-- VSCode-specific initialization
print("VSCode mode loaded")

-- Load common configuration first
require("common.utils.functions")
require("common.opts")

-- VSCode-specific options
local vscode_opts = {
  -- VSCode handles UI, so disable some nvim UI elements
  showmode = false,
  ruler = false,
  laststatus = 0,
  showcmd = false,
  -- VSCode handles clipboard, but keep this for consistency
  clipboard = "unnamedplus",
}

for k, v in pairs(vscode_opts) do
  vim.opt[k] = v
end

-- Load VSCode-specific keymaps
require("vs-code.keymaps")

-- Load common utilities
require("common.utils.autocmds")
require("common.utils.registers")
-- require("common.utils.treesitter")

-- Load common plugins that work in VSCode
require("lazy").setup({
  { import = "common.plugins.shared" },
}, {
  checker = { enabled = false },
  change_detection = { notify = false },
})
