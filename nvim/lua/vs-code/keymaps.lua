-- VSCode-specific helper functions
VSCodeNotify = vim.fn.VSCodeNotify
VSCodeCall = vim.fn.VSCodeCall

-- Merge conflict functions
local function accept_merge_both() VSCodeNotify("merge-conflict.accept.both") end
local function accept_merge_all_both() VSCodeNotify("merge-conflict.accept.all-both") end
local function accept_merge_current() VSCodeNotify("merge-conflict.accept.current") end
local function accept_merge_all_current() VSCodeNotify("merge-conflict.accept.all-current") end
local function accept_merge_incoming() VSCodeNotify("merge-conflict.accept.incoming") end
local function accept_merge_all_incoming() VSCodeNotify("merge-conflict.accept.all-incoming") end
local function accept_merge_selection() VSCodeNotify("merge-conflict.accept.selection") end

-- Screen positioning functions
local function center_screen() Cmd("call <SNR>3_reveal('center', 0)") end
local function top_screen() Cmd("call <SNR>3_reveal('top', 0)") end
local function bottom_screen() Cmd("call <SNR>3_reveal('bottom', 0)") end
local function scroll_line_down() VSCodeCall("scrollLineDown") end
local function scroll_line_up() VSCodeCall("scrollLineUp") end

-- File operations
local function trim_trailing_whitespace() VSCodeCall("editor.action.trimTrailingWhitespace") end
local function save() VSCodeCall("workbench.action.files.save") end
local function save_no_format() VSCodeCall("workbench.action.files.saveWithoutFormatting") end
local function format() VSCodeCall("editor.action.formatDocument") print("formatted!") end
local function format_prettier() VSCodeCall("prettier.forceFormatDocument") print("formatted!") end

-- Combined operations
local function trim_save_format_prettier()
  trim_trailing_whitespace()
  format_prettier()
  save()
end

local function trim_save_format()
  trim_trailing_whitespace()
  format()
  save()
end

local function trim_save_no_format()
  trim_trailing_whitespace()
  save_no_format()
end

-- Sidebar operations
local function close_primary_sidebar() VSCodeCall("workbench.action.closeSidebar") end

-- Search operations
local function find_files()
  close_primary_sidebar()
  VSCodeCall("find-it-faster.findFiles")
end

local function find_files_with_type()
  close_primary_sidebar()
  VSCodeCall("find-it-faster.findFilesWithType")
end

local function find_inside_files()
  close_primary_sidebar()
  VSCodeCall("find-it-faster.findWithinFiles")
end

local function find_inside_files_with_type()
  close_primary_sidebar()
  VSCodeCall("find-it-faster.findWithinFilesWithType")
end

-- Git operations
local function git_stage_selected_lines() VSCodeNotify("git.stageSelectedRanges") end
local function git_unstage_selected_lines() VSCodeNotify("git.unstageSelectedRanges") end
local function git_reset_selected_lines() VSCodeNotify("git.revertSelectedRanges") end

local function git_stage_file()
  trim_trailing_whitespace()
  save()
  VSCodeNotify("git.stage")
end

local function git_unstage_file()
  save()
  VSCodeNotify("git.unstage")
end

local function git_reset_file()
  save()
  VSCodeNotify("git.clean")
end

-- Movement operations
local function move_to_bottom_screen()
  Cmd("call <SNR>3_moveCursor('bottom')")
end

local function move_to_top_screen()
  Cmd("call <SNR>3_moveCursor('top')")
end

local function move_to_bottom_screen_center()
  move_to_bottom_screen()
  center_screen()
end

local function move_to_top_screen_center()
  move_to_top_screen()
  center_screen()
end

-- Indentation operations
local function outdent()
  for i = 1, vim.v.count1 do
    VSCodeNotify("editor.action.outdentLines")
  end
end

local function indent()
  for i = 1, vim.v.count1 do
    VSCodeNotify("editor.action.indentLines")
  end
end

-- Special scrolling functions
local function vscode_ctrl_d() VSCodeNotify("vscode-neovim.ctrl-d") end
local function vscode_ctrl_u() VSCodeNotify("vscode-neovim.ctrl-u") end

-- Git branch creation
local function fetch_and_create_branch()
  local vscode = require('nvim.lua.vscode_.init')
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
end

-- VSCode Keymaps - organized as array of objects for clean setup
local vscode_keymaps = {
  -- Angular Development
  { "", "<leader>ah", "extension.open.template", { desc = "Switch to HTML" } },
  { "", "<leader>at", "extension.open.class", { desc = "Switch to TypeScript" } },
  { "", "<leader>ac", "extension.open.style", { desc = "Switch to CSS" } },

  -- JSON i18n keys
  { { "n", "v" }, "<leader>jf", "json-i18n-key.findKey", { desc = "Find json i18n key" } },
  { { "n", "v" }, "<leader>jc", "json-i18n-key.checkExistKey", { desc = "Check json i18n key" } },
  { { "n", "v" }, "<leader>jr", "json-i18n-key.renameKey", { desc = "Rename json i18n key" } },
  { { "n", "v" }, "<leader>ja", "json-i18n-key.addKey", { desc = "Add json i18n key" } },
  { { "n", "v" }, "<leader>jd", "json-i18n-key.removeKey", { desc = "Remove json i18n key" } },
  { { "n", "v" }, "<leader>ju", "json-i18n-key.updateKey", { desc = "Update json i18n key value" } },

  -- Code conversion
  { { "n", "v" }, "<leader>ct", "converter.pasteAsCs2Ts", { desc = "C# to TypeScript" } },

  -- Core LSP functionality
  { "n", "gd", "editor.action.revealDefinition", { desc = "Go to definition" } },
  { "n", "gr", "references-view.findReferences", { desc = "Find references" } },
  { "n", "gR", "editor.action.goToReferences", { desc = "Go to references" } },
  { "n", "gI", "editor.action.goToImplementation", { desc = "Go to implementation" } },
  { "n", "gt", "editor.action.goToTypeDefinition", { desc = "Go to type definition" } },
  { "n", "gD", "editor.action.revealDeclaration", { desc = "Go to declaration" } },
  { "n", "<leader>sd", "workbench.action.gotoSymbol", { desc = "Go to document symbol" } },
  { "n", "<leader>sw", "workbench.action.showAllSymbols", { desc = "Show all workspace symbols" } },
  { "n", "<leader>rn", "editor.action.rename", { desc = "Rename code" } },
  { "n", ",r", "editor.action.rename", { desc = "Rename symbol" } },
  { "n", "<leader>ca", "editor.action.quickFix", { desc = "Quick fix 'Code Action'" } },
  { "n", "<leader>db", "workbench.action.problems.focus", { desc = "Focus on problems 'diagnostics'" } },
  { "n", "<leader>td", "workbench.actions.view.problems", { desc = "Toggle problems 'diagnostics'" } },
  { "n", "]d", "editor.action.marker.next", { desc = "Next problem" } },
  { "n", "[d", "editor.action.marker.prev", { desc = "Previous problem" } },
  { "n", "K", "editor.action.showHover", { desc = "Show documentation hover" } },
  { "n", "<leader>ww", "editor.action.toggleWordWrap", { desc = "Toggle word wrap" } },
  { "n", "zy", "editor.debug.action.toggleBreakpoint", { desc = "Toggle breakpoint" } },

  -- Clipboard operations
  { "v", "<C-S-c>", '"+y', { desc = "Copy selection to system clipboard" } },
  { "n", "<C-S-c>", '"+yy', { desc = "Copy line to system clipboard" } },
  { "v", "<C-S-v>", '"_dP', { desc = "Paste from system clipboard over selection" } },
  { "n", "<C-S-v>", '"+P', { desc = "Paste from system clipboard" } },

  -- Harpoon - VS Code Harpoon extension
  { "n", "<leader>a", "vscode-harpoon.addEditor", { desc = "Harpoon add file" } },
  { "n", "<C-e>", "vscode-harpoon.editorQuickPick", { desc = "Harpoon quick menu" } },
  { "n", "<leader>hh", "vscode-harpoon.editEditors", { desc = "Harpoon Edit Editors" } },
  { "n", "<C-j>", "vscode-harpoon.navigatePreviousEditor", { desc = "Harpoon previous" } },
  { "n", "<C-S-j>", "vscode-harpoon.navigatePreviousEditor", { desc = "Harpoon previous" } },
  { "n", "<C-k>", "vscode-harpoon.navigateNextEditor", { desc = "Harpoon next" } },
  { "n", "<C-S-k>", "vscode-harpoon.navigateNextEditor", { desc = "Harpoon next" } },
  { "n", "<leader>1", "vscode-harpoon.gotoEditor1", { desc = "Harpoon file 1" } },
  { "n", "<leader>2", "vscode-harpoon.gotoEditor2", { desc = "Harpoon file 2" } },
  { "n", "<leader>3", "vscode-harpoon.gotoEditor3", { desc = "Harpoon file 3" } },
  { "n", "<leader>4", "vscode-harpoon.gotoEditor4", { desc = "Harpoon file 4" } },
  { "n", "<leader>ra", "vscode-harpoon.removeAllEditors", { desc = "Harpoon remove all" } },

  -- Bookmarks
  { "n", "mm", "bookmarks.toggle", { desc = "Toggle bookmark" } },
  { "n", "mi", "bookmarks.toggleLabeled" , { desc = "Toggle labeled bookmark" } },
  { "n", "mc", "bookmarks.clear", { desc = "Clear bookmarks for current file" } },
  { "n", "mC", "bookmarks.clearFromAllFiles", { desc = "Clear bookmarks for all files" } },
  { "n", "mn", "bookmarks.jumpToNext", { desc = "Next bookmark" } },
  { "n", "mp", "bookmarks.jumpToPrevious", { desc = "Previous bookmark" } },
  { "n", "ml", "bookmarks.list", { desc = "List bookmarks for current file" } },
  { "n", "mL", "bookmarks.listFromAllFiles", { desc = "List bookmarks for all files" } },

  -- Editor operations
  { "", "L", move_to_bottom_screen, { desc = "Move to bottom screen" } },
  { "", "H", move_to_top_screen, { desc = "Move to top screen" } },
  { "n", "U", trim_save_format_prettier, { desc = "Trim, save and format with Prettier" } },
  { "n", "<leader>U", trim_save_format, { desc = "Trim, save and format" } },
  { "n", "<<", outdent, { desc = "Outdent line" } },
  { "n", ">>", indent, { desc = "Indent line" } },
  { "v", "<", function() VSCodeNotify("editor.action.outdentLines", false) end, { desc = "Outdent selected lines" } },
  { "v", ">", function() VSCodeNotify("editor.action.indentLines", false) end, { desc = "Indent selected lines" } },
  { "n", "=s", "editor.action.indentationToSpaces", { desc = "Indentation to spaces" } },
  { "n", "=t", "editor.action.indentationToTabs", { desc = "Indentation to tabs" } },
  { "n", "=d", "editor.action.indentUsingSpaces", { desc = "Indent using spaces" } },
  { "n", "=g", "editor.action.indentUsingTabs", { desc = "Indent using tabs" } },
  { "n", "<leader>K", "workbench.action.closeActiveEditor", { desc = "Close active editor" } },
  { "n", "<leader>,K", "workbench.action.reopenClosedEditor", { desc = "Reopen closed editor" } },
  { "n", "yr", "copyRelativeFilePath", { desc = "Copy relative file path" } },
  { "n", "yR", "copyFilePath", { desc = "Copy file path" } },
  { "v", "gs", function() VSCodeNotify("codesnap.start", true) end, { desc = "Start code snapshot" } },
  { { "n", "v" }, "zb", vscode_ctrl_d, { desc = "Scroll down" } },
  { { "n", "v" }, "zt", vscode_ctrl_u, { desc = "Scroll up" } },
  { "n", "<leader>pp", "projectManager.listProjects", { desc = "List projects" } },
  { "n", "<leader>pn", "projectManager.listProjectsNewWindow", { desc = "List projects in new window" } },
  { "n", "<leader>ss", "editor.action.toggleStickyScroll", { desc = "Toggle sticky scroll" } },

  -- Utility operations
  { 'v', '<leader>tw', function()
    vim.cmd([['<,'>s/\(\S\)\([ \t]\{3,\}\)\(\/\/\|--\|#\|;\|\*\*\?\|\<REM\>\)/\1  \3/g]])
    print("Trimmed comment whitespace in selection")
  end, { desc = "Trim excessive whitespace before comments in selection" } },
  { 'n', '<leader>tw', ':%s/\\(\\S\\)\\([ \\t]\\{3,\\}\\)\\(\\/\\/\\|--\\|#\\|;\\|\\*\\*\\?\\|\\<REM\\>\\)/\\1  \\3/g<CR>',
    { desc = "Trim whitespace before comments" } },

  { "n", "C-r", "redo", { desc = "Redo" } },
  { "n", "<leader>sk", "neovim-keymaps-list.searchKeymaps", { desc = "Search keymaps" } },
  { "n", "<leader>ru", "typescript.removeUnusedImports", { desc = "Remove unused imports" } },
  { "n", "<leader>rc", "csharpOrganizeUsings.organize", { desc = "Remove unused imports" } },

  -- Window management
  { "n", "<leader>vs", "workbench.action.splitEditorRight", { desc = "Split window vertically" } },
  { "n", "<leader>hs", "workbench.action.splitEditorDown", { desc = "Split window horizontally" } },

  -- Focus around windows
  { { "n", "t" }, "<A-h>", "workbench.action.focusLeftGroup", { desc = "Move to window left" } },
  { { "n", "t" }, "<A-j>", "workbench.action.focusBelowGroup", { desc = "Move to window down" } },
  { { "n", "t" }, "<A-k>", "workbench.action.focusAboveGroup", { desc = "Move to window up" } },
  { { "n", "t" }, "<A-l>", "workbench.action.focusRightGroup", { desc = "Move to window right" } },

  -- Resizing windows
  { "n", "<A-S-h>", "workbench.action.decreaseViewWidth", { desc = "Decrease window width" } },
  { "n", "<A-S-l>", "workbench.action.increaseViewWidth", { desc = "Increase window width" } },
  { "n", "<A-S-j>", "workbench.action.decreaseViewHeight", { desc = "Decrease window height" } },
  { "n", "<A-S-k>", "workbench.action.increaseViewHeight", { desc = "Increase window height" } },

  -- Moving around splits
  { "n", "<C-S-h>", "workbench.action.moveActiveEditorGroupLeft", { desc = "Move split to the left" } },
  { "n", "<C-S-j>", "workbench.action.moveActiveEditorGroupDown", { desc = "Move split down" } },
  { "n", "<C-S-k>", "workbench.action.moveActiveEditorGroupUp", { desc = "Move split up" } },
  { "n", "<C-S-l>", "workbench.action.moveActiveEditorGroupRight", { desc = "Move split to the right" } },

  -- Search and find
  { "n", "<leader>sb", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "List all buffers" } },
  { "n", "<leader>pf", find_files, { desc = "Find files" } },
  { "n", "<leader>pt", find_files_with_type, { desc = "Find files with type" } },
  { "n", "<leader>sg", "workbench.action.quickTextSearch", { desc = "Find inside files" } },
  { "n", "<leader>sG", find_inside_files_with_type, { desc = "Find inside files with type" } },

  -- Git operations
  { "n", "<leader>gS", git_stage_file, { desc = "Stage file" } },
  { "n", "<leader>gU", git_unstage_file, { desc = "Unstage file" } },
  { "n", "<leader>gR", git_reset_file, { desc = "Reset file" } },
  { { "n", "v" }, "<leader>gs", git_stage_selected_lines, { desc = "Stage selected lines" } },
  { { "n", "v" }, "<leader>gu", git_unstage_selected_lines, { desc = "Unstage selected lines" } },
  { { "n", "v" }, "<leader>gr", git_reset_selected_lines, { desc = "Reset selected lines" } },
  { "n", "zi", "git.openChange", { desc = "View changes for the current file " } },
  { "n", "zI", "git.viewChanges", { desc = "View changes for all files" } },
  { "n", "zC", "git.openAllChanges", { desc = "Open only changed files" } },
  { "n", "zg", "workbench.view.scm", { desc = "Open Source Control" } },
  { "n", "]h", "editor.action.dirtydiff.next", { desc = "Preview Next Git Change" } },
  { "n", "[h", "editor.action.dirtydiff.previous", { desc = "Preview Previous Git Change" } },
  { "n", "<leader>gtfb", "gitlens.toggleFileBlame", { desc = "Toggle Git Blame" } },
  { "n", "<leader>gtlb", "gitlens.toggleLineBlame", { desc = "Toggle line blame" } },
  { "n", "<leader>gtfc", "gitlens.toggleFileChanges", { desc = "Toggle line blame" } },
  { "n", "<leader>gvh", "githd.viewHistory", { desc = "Git History" } },
  { "n", "<leader>gvfh", "githd.viewFileHistory", { desc = "Git History File" } },
  { "n", "<leader>gch", "git.checkout", { desc = "Checkout to" } },
  { "n", "<leader>gss", "gitlens.stashSave", { desc = "Stash All Changes" } },
  { "n", "<leader>gpl,", "git.pull", { desc = "Pull" } },
  { "n", "<leader>gps,", "git.push", { desc = "Push" } },
  { "n", "<leader>gbf", "git.branchFrom", { desc = "Create branch from" } },
  { "n", "<leader>gfcb", fetch_and_create_branch, { desc = "Fetch and create branch" } },
  { "n", "<leader>gdp", "gitlens.diffWithPrevious", { desc = "Open Changes with Previous Revision" } },
  { "n", "<leader>gdn", "gitlens.diffWithNext", { desc = "Open Changes with Next Revision" } },
  { "n", "<leader>gdr", "gitlens.diffWithRevision", { desc = "Open Changes with Revision" } },
  { "n", "<leader>gsc", "gitlens.showCommitSearch", { desc = "Search Commits" } },
  { "n", "<leader>gsg", "gitlens.showGraphPage", { desc = "Search Commits" } },
  { { "n", "t" }, "<leader>lg", "lazygit-vscode.toggle", { desc = "Toggle Lazygit" } },
  { "n", "<leader>gg", "gitSemanticCommit.semanticCommit", { desc = "Semantic Commits" } },

  -- Folding
  { "n", "za", "fold.foldLevelDefault", { desc = "Toggle Fold" } },
  { "n", "zA", "editor.unfoldAll", { desc = "Unfold All" } },
  { "n", "zo", "editor.fold", { desc = "Fold" } },
  { "n", "zO", "editor.unfold", { desc = "Unfold" } },
  { "n", "zr", "editor.foldRecursively", { desc = "Fold Recursively" } },
  { "n", "zR", "editor.unfoldRecursively", { desc = "Unfold Recursively" } },
  { "n", "ze", "editor.foldAllExcept", { desc = "Fold All Except" } },
  { "n", "z1", "editor.foldLevel1", { desc = "Fold Level 1" } },
  { "n", "z2", "editor.foldLevel2", { desc = "Fold Level 2" } },
  { "n", "z3", "editor.foldLevel3", { desc = "Fold Level 3" } },
  { "n", "z4", "editor.foldLevel4", { desc = "Fold Level 4" } },
  { "n", "z5", "editor.foldLevel5", { desc = "Fold Level 5" } },
  { "n", "z6", "editor.foldLevel6", { desc = "Fold Level 6" } },
  { "n", "z7", "editor.foldLevel7", { desc = "Fold Level 7" } },

  -- Special scrolling with centering
  { { "n", "x" }, "<C-u>", function()
    local visibleRanges = require('nvim.lua.vscode_.init').eval("return vscode.window.activeTextEditor.visibleRanges")
    local height = visibleRanges[1][2].line - visibleRanges[1][1].line
    for i = 1, height * 2 / 3 do
      vim.api.nvim_feedkeys("k", "n", false)
    end
    require('nvim.lua.vscode_.init').action("neovim-ui-indicator.cursorCenter")
  end, { desc = "Scroll up and center" } },

  { { "n", "x" }, "<C-d>", function()
    local visibleRanges = require('nvim.lua.vscode_.init').eval("return vscode.window.activeTextEditor.visibleRanges")
    local height = visibleRanges[1][2].line - visibleRanges[1][1].line
    for i = 1, height * 2 / 3 do
      vim.api.nvim_feedkeys("j", "n", false)
    end
    require('nvim.lua.vscode_.init').action("neovim-ui-indicator.cursorCenter")
  end, { desc = "Scroll down and center" } },

  { { "n", "x" }, "<C-f>", function()
    local visibleRanges = require('nvim.lua.vscode_.init').eval("return vscode.window.activeTextEditor.visibleRanges")
    local height = visibleRanges[1][2].line - visibleRanges[1][1].line
    for i = 1, height do
      vim.api.nvim_feedkeys("j", "n", false)
    end
    require('nvim.lua.vscode_.init').action("neovim-ui-indicator.cursorCenter")
  end, { desc = "Page down and center" } },

  { { "n", "x" }, "<C-b>", function()
    local visibleRanges = require('nvim.lua.vscode_.init').eval("return vscode.window.activeTextEditor.visibleRanges")
    local height = visibleRanges[1][2].line - visibleRanges[1][1].line
    for i = 1, height do
      vim.api.nvim_feedkeys("k", "n", false)
    end
    require('nvim.lua.vscode_.init').action("neovim-ui-indicator.cursorCenter")
  end, { desc = "Page up and center" } },
}


-- change o in normal mode to also auto indent using VSCode
Map( 'n', 'o', "o<Cmd>call VSCodeNotifyRange('editor.action.reindentselectedlines', line('.'), line('.'), 1)<CR>")
Map( 'n', 'O', "O<Cmd>call VSCodeNotifyRange('editor.action.reindentselectedlines', line('.'), line('.'), 1)<CR>")



-- Apply all VSCode keymaps using a for loop
for _, keymap in ipairs(vscode_keymaps) do
  local rhs = keymap[3]

  -- If rhs is a string, wrap it in VSCodeNotify function
  if type(rhs) == "string" then
    local cmd = rhs
    Map(keymap[1], keymap[2], function() VSCodeNotify(cmd) end, keymap[4])
  else
    Map(keymap[1], keymap[2], rhs, keymap[4])
  end
end

return {
  keymaps = vscode_keymaps
}
