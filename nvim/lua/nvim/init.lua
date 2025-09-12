-- Neovim-specific initialization (native Neovim only)
print("Native Neovim mode loaded")

-- Load common configuration first
require("common.opts")

-- Neovim-specific options that don't apply to VSCode
local nvim_opts = {
  -- UI elements that are handled by VSCode in vscode-neovim
  guifont = "monospace:h17",
  guicursor = "",
  -- Terminal and UI specific
  termguicolors = true,
  showmode = true,
  ruler = true,
  laststatus = 3, -- Global statusline
  showcmd = true,
  cmdheight = 1,
}

for k, v in pairs(nvim_opts) do
  vim.opt[k] = v
end

-- Neovim-specific keymaps
require("nvim.keymaps")

-- Load common utilities and features
require("common.utils.autocmds")
require("common.utils.functions")
require("common.utils.features")
require("common.utils.treesitter").setup()
require("common.registers.registers")
require("common.registers.text-objects")

-- Custom user command for keymap listing (nvim-specific)
vim.api.nvim_create_user_command("KeymapListClean", function()
    local modes = {"n", "i", "v", "x", "s", "o", "t", "c"}
    local mode_names = {
        n = "Normal",
        i = "Insert",
        v = "Visual",
        x = "Visual Block",
        s = "Select",
        o = "Operator Pending",
        t = "Terminal",
        c = "Command"
    }

    local lines = {}
    for _, mode in ipairs(modes) do
        local keymaps = vim.api.nvim_get_keymap(mode)

        for _, map in ipairs(keymaps) do
            local desc = map.desc or ""
            local lhs = map.lhs or ""
            -- Only include keymaps that have a meaningful description
            if desc ~= "" and desc ~= "Nvim builtin" and not lhs:match("^<Plug>") then
                table.insert(lines, string.format("(%s) %-20s %s", mode_names[mode], lhs, desc))
            end
        end
    end

    vim.cmd("new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.opt_local.modifiable = false
    vim.opt_local.buftype = "nofile"
    vim.opt_local.bufhidden = "wipe"
end, { desc = "List clean keymaps" })

-- Load plugins
require("lazy").setup({
  -- Common plugins that work in both environments
  { import = "common.plugins.shared" },
  -- Neovim-specific plugins
  { import = "nvim.plugins.lsp" },
  { import = "nvim.plugins.ui" },
  { import = "nvim.plugins.tools" },
  { import = "nvim.plugins.coding" },
  { import = "nvim.plugins.editing" },
}, {
  checker = { enabled = true },
  change_detection = { notify = true },
  ui = {
    border = "rounded",
  },
})
