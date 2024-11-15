vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})


-- Set up an autocommand to open AhkTest.ahk in the _MyAutohotkey folder when starting Neovim
vim.cmd([[
  augroup OpenTestAHK
    autocmd!
    autocmd VimEnter * if getcwd() == "G:\\My Drive\\_MyAutohotkey" | call timer_start(100, 'OpenMyFile') | NvimTreeClose | endif
  augroup END

  function! OpenMyFile(timer)
    exe "edit G:/My Drive/_MyAutohotkey/Test/AhkTest.ahk"
  endfunction
]])

-- Set the cursor color when the terminal is opened or closed
vim.api.nvim_set_hl(0, "TerminalCursorShape", { underline = true })
vim.api.nvim_create_autocmd("TermEnter", {
  callback = function()
    vim.cmd [[setlocal winhighlight=TermCursor:TerminalCursorShape]]
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    vim.cmd [[set guicursor=a:ver100]]
  end,
})

-- Remove the telescope-projects.txt file when Neovim is closed
vim.cmd([[
    augroup DeleteTelescopeProjects
        autocmd!
        autocmd VimLeave * lua DeleteTelescopeProjects()
    augroup END
]])

function DeleteTelescopeProjects()
    local telescope_projects_file = vim.fn.stdpath('data') .. '/telescope-projects.txt'
    os.remove(telescope_projects_file)
    print("Deleted telescope-projects.txt. It will be rebuilt on next Neovim start.")
end

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
    vim.cmd [[set scrolloff=9999]]
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
    vim.cmd [[set scrolloff=0]]
	end,
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  command = "TSEnable highlight",
})