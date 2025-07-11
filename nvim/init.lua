-- Call files
require("config.opts") -- should be first to set options before mappings
require("config.keys")
require("lazy-setup")
require("utils.autocmds")
require("utils.functions")
require("utils.features")
require("utils.treesitter").setup() -- Initialize treesitter utilities
require("registers.registers")
require("registers.text-objects")

print("nvim loaded")

if vim.g.vscode then
    print("vscode loaded")
    VSCodeNotify = vim.fn.VSCodeNotify
    VSCodeCall = vim.fn.VSCodeCall
    require('config.keys_vscode')
end


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
end, {})
