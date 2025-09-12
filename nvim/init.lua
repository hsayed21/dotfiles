-- Neovim Configuration - Organized Structure
-- Main entry point that conditionally loads the appropriate configuration
-- based on whether we're running in VSCode or native Neovim

-- Ensure lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load appropriate configuration based on environment
if vim.g.vscode then
    -- VSCode Neovim extension
    require("vs-code")
else
    -- Native Neovim
    require("nvim")
end
