local m = {}

m.global = function()
  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
      vim.highlight.on_yank()
    end,
  })
end

m.native = function()
  -- Set up an autocommand to open AhkTest.ahk in the _MyAutohotkey folder when starting Neovim
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.fn.getcwd() == "G:\\My Drive\\_MyAutohotkey" then
        vim.defer_fn(function()
          vim.cmd("edit G:/My Drive/_MyAutohotkey/Test/AhkTest.ahk")
          -- Close NvimTree if it's available
          local ok, _ = pcall(require, "nvim-tree")
          if ok and require("nvim-tree.api") then
            require("nvim-tree.api").tree.close()
          end
        end, 100)
      end
    end,
  })

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
end

m.vscode = function()
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*",
    callback = function()
      local mode = vim.api.nvim_get_mode().mode
      if mode == "i" then
        require('nvim.lua.vs_code.init').action("neovim-ui-indicator.insert")
      elseif mode == "v" then
        require('nvim.lua.vs_code.init').action("neovim-ui-indicator.visual")
      elseif mode == "n" then
        require('nvim.lua.vs_code.init').action("neovim-ui-indicator.normal")
      end
    end,
  })
end

m.global()
if vim.g.vscode then
  m.vscode()
else
  m.native()
end
