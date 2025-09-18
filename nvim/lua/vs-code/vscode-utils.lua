-- VSCode utility functions and helpers
-- Comprehensive utilities for VSCode Neovim integration

local M = {}

-- ========================================
-- CORE VSCode INTEGRATION
-- ========================================

-- VSCode API wrappers
M.notify = vim.fn.VSCodeNotify
M.call = vim.fn.VSCodeCall
M.action = function(cmd) require('vscode').action(cmd) end
M.eval = function(expr) return require('vscode').eval(expr) end

-- Check if running in VSCode
M.is_vscode = function()
  return vim.g.vscode ~= nil
end

-- ========================================
-- NAVIGATION WITH CENTERING
-- ========================================

-- Define center_cursor first to avoid circular reference
local function center_cursor()
  M.action("center-editor-window.center")
end

-- Define move_and_center function to avoid circular reference
local function move_and_center(movement)
  return function()
    vim.api.nvim_feedkeys(movement, "n", false)
    center_cursor()
  end
end

local function move(movement)
  return function()
    vim.api.nvim_feedkeys(movement, "n", false)
  end
end

M.navigation = {
  -- Cursor positioning & centering
  center_cursor = center_cursor,

  -- Helper to create movement + center combinations
  move_and_center = move_and_center,

  -- Get visible range information
  get_visible_range = function()
    return M.eval("return vscode.window.activeTextEditor.visibleRanges")
  end,

  -- Get visible height
  get_visible_height = function()
    local ranges = M.navigation.get_visible_range()
    return ranges[1][2].line - ranges[1][1].line
  end,

  -- Scrolling functions
  scroll_up_and_center = function(lines)
    lines = lines or 6
    for i = 1, lines do
      vim.api.nvim_feedkeys("k", "n", false)
    end
    center_cursor()
  end,

  scroll_down_and_center = function(lines)
    lines = lines or 6
    for i = 1, lines do
      vim.api.nvim_feedkeys("j", "n", false)
    end
    center_cursor()
  end,

  page_up_and_center = function()
    local height = M.navigation.get_visible_height()
    for i = 1, height do
      vim.api.nvim_feedkeys("k", "n", false)
    end
    center_cursor()
  end,

  page_down_and_center = function()
    local height = M.navigation.get_visible_height()
    for i = 1, height do
      vim.api.nvim_feedkeys("j", "n", false)
    end
    center_cursor()
  end,

  -- Movement commands
  go_to_end_and_center = move_and_center("G"),
  go_to_beginning_and_center = move_and_center("gg"),
  next_paragraph_and_center = move_and_center("}"),
  prev_paragraph_and_center = move_and_center("{"),
  top_of_screen = move("H"),
  bottom_of_screen = move("L"),
  middle_of_screen_and_center = move_and_center("M"),

  -- Search with centering
  search_next_and_center = function()
    vim.api.nvim_feedkeys("n", "n", false)
    vim.api.nvim_feedkeys("zv", "n", false) -- unfold if needed
    center_cursor()
  end,

  search_prev_and_center = function()
    vim.api.nvim_feedkeys("N", "n", false)
    vim.api.nvim_feedkeys("zv", "n", false) -- unfold if needed
    center_cursor()
  end,

  search_word_forward_and_center = function()
    vim.api.nvim_feedkeys("*", "n", false)
    vim.api.nvim_feedkeys("zv", "n", false) -- unfold if needed
    center_cursor()
  end,

  search_word_backward_and_center = function()
    vim.api.nvim_feedkeys("#", "n", false)
    vim.api.nvim_feedkeys("zv", "n", false) -- unfold if needed
    center_cursor()
  end,

  -- Jump list navigation
  jump_back_and_center = move_and_center([[<C-o>]]),
  jump_forward_and_center = move_and_center([[<C-i>]]),
}

-- ========================================
-- EDITOR OPERATIONS
-- ========================================

M.editor = {
  -- File operations
  save = function() M.call("workbench.action.files.save") end,
  save_without_format = function() M.call("workbench.action.files.saveWithoutFormatting") end,
  format_document = function() M.call("editor.action.formatDocument") end,
  format_prettier = function() M.call("prettier.forceFormatDocument") end,
  trim_whitespace = function() M.call("editor.action.trimTrailingWhitespace") end,

  -- Combined operations
  save_and_format = function()
    M.editor.trim_whitespace()
    M.editor.format_document()
    M.editor.save()
  end,

  save_and_format_prettier = function()
    M.editor.trim_whitespace()
    M.editor.format_prettier()
    M.editor.save()
  end,

  -- Text manipulation
  indent_lines = function() M.notify("editor.action.indentLines", false) end,
  outdent_lines = function() M.notify("editor.action.outdentLines", false) end,

  -- Indentation operations with count support (from helpers)
  outdent = function()
    for i = 1, vim.v.count1 do
      M.notify("editor.action.outdentLines")
    end
  end,

  indent = function()
    for i = 1, vim.v.count1 do
      M.notify("editor.action.indentLines")
    end
  end,

  -- Selection operations
  select_all = function() M.call("editor.action.selectAll") end,
  copy_line_up = function() M.call("editor.action.copyLinesUpAction") end,
  copy_line_down = function() M.call("editor.action.copyLinesDownAction") end,
  move_line_up = function() M.call("editor.action.moveLinesUpAction") end,
  move_line_down = function() M.call("editor.action.moveLinesDownAction") end,
}

-- ========================================
-- WINDOW MANAGEMENT
-- ========================================

M.window = {
  -- Split operations
  split_right = function() M.notify("workbench.action.splitEditorRight") end,
  split_down = function() M.notify("workbench.action.splitEditorDown") end,

  -- Focus operations
  focus_left = function() M.notify("workbench.action.focusLeftGroup") end,
  focus_right = function() M.notify("workbench.action.focusRightGroup") end,
  focus_above = function() M.notify("workbench.action.focusAboveGroup") end,
  focus_below = function() M.notify("workbench.action.focusBelowGroup") end,

  -- Resize operations
  increase_width = function() M.notify("workbench.action.increaseViewWidth") end,
  decrease_width = function() M.notify("workbench.action.decreaseViewWidth") end,
  increase_height = function() M.notify("workbench.action.increaseViewHeight") end,
  decrease_height = function() M.notify("workbench.action.decreaseViewHeight") end,

  -- Editor management
  close_editor = function() M.notify("workbench.action.closeActiveEditor") end,
  reopen_editor = function() M.notify("workbench.action.reopenClosedEditor") end,

  -- Sidebar operations
  toggle_sidebar = function() M.call("workbench.action.toggleSidebarVisibility") end,
  close_sidebar = function() M.call("workbench.action.closeSidebar") end,

  -- Screen positioning functions (legacy vim functions)
  center_screen = function() vim.cmd("call <SNR>3_reveal('center', 0)") end,
  top_screen = function() vim.cmd("call <SNR>3_reveal('top', 0)") end,
  bottom_screen = function() vim.cmd("call <SNR>3_reveal('bottom', 0)") end,
  scroll_line_down = function() M.call("scrollLineDown") end,
  scroll_line_up = function() M.call("scrollLineUp") end,

  -- Movement operations (legacy vim functions)
  move_to_bottom_screen = function()
    vim.cmd("call <SNR>3_moveCursor('bottom')")
  end,

  move_to_top_screen = function()
    vim.cmd("call <SNR>3_moveCursor('top')")
  end,

  move_to_bottom_screen_center = function()
    M.window.move_to_bottom_screen()
    M.window.center_screen()
  end,

  move_to_top_screen_center = function()
    M.window.move_to_top_screen()
    M.window.center_screen()
  end,
}

-- ========================================
-- SEARCH & NAVIGATION
-- ========================================

M.search = {
  -- Find operations
  find_files = function() M.call("find-it-faster.findFiles") end,
  find_files_with_type = function() M.call("find-it-faster.findFilesWithType") end,
  find_in_files = function() M.call("find-it-faster.findWithinFiles") end,
  find_in_files_with_type = function() M.call("find-it-faster.findWithinFilesWithType") end,

  -- Symbol search
  go_to_symbol = function() M.notify("workbench.action.gotoSymbol") end,
  go_to_workspace_symbol = function() M.notify("workbench.action.showAllSymbols") end,

  -- Quick search
  quick_open = function() M.notify("workbench.action.quickOpen") end,
  command_palette = function() M.notify("workbench.action.showCommands") end,

  -- Search for exact text without regex
  search_exact_text = function(text)
    if text and text ~= "" then
      local escaped_text = text:gsub("([%(%)%.%+%-%*%?%[%]%^%$%%])", "%%%1")
      vim.cmd("normal! /" .. escaped_text)
    else
      M.search.quick_open()
    end
  end,

  -- Smart search that handles both patterns and literal text
  smart_search = function(query)
    if not query or query == "" then
      M.search.quick_open()
      return
    end

    local has_regex_chars = query:match("[%.%+%-%*%?%[%]%^%$%(%)%%]")
    if has_regex_chars then
      vim.cmd("normal! /" .. query)
    else
      M.search.search_exact_text(query)
    end
  end,

  -- Search operations with sidebar management
  find_files_with_sidebar_closed = function()
    M.window.close_sidebar()
    M.search.find_files()
  end,

  find_files_with_type_sidebar_closed = function()
    M.window.close_sidebar()
    M.search.find_files_with_type()
  end,

  find_inside_files = function()
    M.window.close_sidebar()
    M.search.find_in_files()
  end,

  find_inside_files_with_type = function()
    M.window.close_sidebar()
    M.search.find_in_files_with_type()
  end,
}

-- ========================================
-- GIT OPERATIONS
-- ========================================

M.git = {
  -- Stage operations
  stage_file = function() M.notify("git.stage") end,
  unstage_file = function() M.notify("git.unstage") end,
  stage_selected = function() M.notify("git.stageSelectedRanges") end,
  unstage_selected = function() M.notify("git.unstageSelectedRanges") end,

  -- View operations
  show_changes = function() M.notify("git.openChange") end,
  show_source_control = function() M.notify("workbench.view.scm") end,

  -- Navigation
  next_change = function() M.notify("editor.action.dirtydiff.next") end,
  prev_change = function() M.notify("editor.action.dirtydiff.previous") end,

  -- Advanced git operations with stage management
  stage_and_commit = function()
    M.git.stage_file()
    vim.defer_fn(function()
      M.notify("git.commit")
    end, 500)
  end,

  commit_and_push = function()
    M.notify("git.commit")
    vim.defer_fn(function()
      M.notify("git.push")
    end, 1000)
  end,

  -- Quick commit workflow
  quick_commit = function(message)
    if message and message ~= "" then
      M.git.stage_file()
      vim.defer_fn(function()
        vim.cmd('!git commit -m "' .. message .. '"')
      end, 500)
    else
      M.git.stage_and_commit()
    end
  end,

  -- Git operations with additional logic
  stage_file_with_save = function()
    M.editor.trim_whitespace()
    M.editor.save()
    M.git.stage_file()
  end,

  unstage_file_with_save = function()
    M.editor.save()
    M.git.unstage_file()
  end,

  reset_file = function()
    M.editor.save()
    M.notify("git.clean")
  end,

  reset_selected_lines = function() M.notify("git.revertSelectedRanges") end,

  -- Git branch creation with user input
  fetch_and_create_branch = function()
    local vscode = require('vscode')
    local remote_branch = vim.fn.input('Enter remote branch (default: master): ')
    local new_branch = vim.fn.input('Enter new branch name to create: ')

    if remote_branch == '' then
      remote_branch = 'master'
    end

    if new_branch == "" then
      vscode.notify("No new branch provided. Exiting...")
      return
    end

    local fetch_command = 'git fetch origin ' .. remote_branch .. ':' .. new_branch
    local fetch_result = os.execute(fetch_command)

    if fetch_result == 0 then
      local checkout_command = 'git checkout ' .. new_branch
      local checkout_result = os.execute(checkout_command)
      if checkout_result == 0 then
        vscode.notify('Fetch and Checkout to new branch from origin successful: ' .. remote_branch .. ' -> ' .. new_branch)
      else
        vscode.notify('Failed to checkout to new branch: ' .. new_branch)
      end
    else
      vscode.notify('Failed to fetch from origin: ' .. remote_branch)
    end
  end,

  -- Merge conflict resolution
  merge_accept_both = function() M.notify("merge-conflict.accept.both") end,
  merge_accept_all_both = function() M.notify("merge-conflict.accept.all-both") end,
  merge_accept_current = function() M.notify("merge-conflict.accept.current") end,
  merge_accept_all_current = function() M.notify("merge-conflict.accept.all-current") end,
  merge_accept_incoming = function() M.notify("merge-conflict.accept.incoming") end,
  merge_accept_all_incoming = function() M.notify("merge-conflict.accept.all-incoming") end,
  merge_accept_selection = function() M.notify("merge-conflict.accept.selection") end,
}

-- ========================================
-- UTILITIES
-- ========================================

M.utils = {
  -- Notifications
  show_info = function(message, timeout)
    timeout = timeout or 3000
    M.notify("extension.commandRunner.run", {
      command = "echo '" .. message .. "'",
      timeout = timeout
    })
  end,

  -- Clipboard operations
  copy_file_path = function() M.notify("copyFilePath") end,
  copy_relative_path = function() M.notify("copyRelativeFilePath") end,

  -- Development helpers
  reload_window = function() M.notify("workbench.action.reloadWindow") end,
  toggle_dev_tools = function() M.notify("workbench.action.toggleDevTools") end,

  -- Theme operations
  select_theme = function() M.notify("workbench.action.selectTheme") end,
  toggle_zen_mode = function() M.notify("workbench.action.toggleZenMode") end,

  -- CodeSnap functionality
  codesnap_start = function() M.notify("codesnap.start", true) end
}

-- ========================================
-- BACKWARD COMPATIBILITY
-- ========================================

-- Export individual navigation functions for backward compatibility
for name, func in pairs(M.navigation) do
  M[name] = func
end

-- Export individual editor functions
for name, func in pairs(M.editor) do
  M[name] = func
end

-- Export individual window functions
for name, func in pairs(M.window) do
  M[name] = func
end

-- Export individual search functions
for name, func in pairs(M.search) do
  M[name] = func
end

-- Export individual git functions
for name, func in pairs(M.git) do
  M[name] = func
end

-- Export individual utils functions
for name, func in pairs(M.utils) do
  M[name] = func
end

--[[
USAGE EXAMPLES:
===============
-- Utilities
vscode_utils.utils.copy_file_path()
vscode_utils.utils.reload_window()

-- Direct VSCode API access
vscode_utils.action("workbench.action.quickOpen")
vscode_utils.notify("extension.command")
--]]

return M
