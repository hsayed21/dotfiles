
-- Call files
require("config.opts") -- should be first to set options before mappings
require("config.keys")
require("lazy-setup")
require("utils.autocmds")
require("utils.functions")
require("utils.features")
require("registers.registers")
require("registers.text-objects")

print("nvim loaded")

if vim.g.vscode then
    print("vscode loaded")
    VSCodeNotify = vim.fn.VSCodeNotify
    VSCodeCall = vim.fn.VSCodeCall
    require('config.keys_vscode')
end
