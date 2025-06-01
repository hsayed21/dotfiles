-- functions vscode
function Accept_merge_both() VSCodeNotify("merge-conflict.accept.both") end

function Accept_merge_all_both() VSCodeNotify("merge-conflict.accept.all-both") end

function Accept_merge_current()  VSCodeNotify("merge-conflict.accept.current") end

function Accept_merge_all_current()  VSCodeNotify("merge-conflict.accept.all-current") end

function Accept_merge_incoming() VSCodeNotify("merge-conflict.accept.incoming") end

function Accept_merge_all_incoming() VSCodeNotify("merge-conflict.accept.all-incoming") end

function Accept_merge_selection()  VSCodeNotify("merge-conflict.accept.selection") end

function Center_screen() Cmd("call <SNR>3_reveal('center', 0)") end

function Top_screen() Cmd("call <SNR>3_reveal('top', 0)") end

function Bottom_screen() Cmd("call <SNR>3_reveal('bottom', 0)") end

function Scroll_line_down() VSCodeCall("scrollLineDown") end

function Scroll_line_up() VSCodeCall("scrollLineUp") end

function Trim_trailing_whitespace() VSCodeCall("editor.action.trimTrailingWhitespace") end

function Trim__Save__FormatPrettier()
  Trim_trailing_whitespace()
  -- Format()
  FormatPrettier()
  Save()
end

function Trim__Save__Format()
  Trim_trailing_whitespace()
  Format()
  Save()
end

function Trim__save__no_format()
  Trim_trailing_whitespace()
  Save_no_format()
end

function Trim__save__no_highlight()
  Trim_trailing_whitespace()
  Save()
  Remove_highlighting()
end

function ClosePrimarySideBar() VSCodeCall("workbench.action.closeSidebar") end

-- function CloseSecondarySideBar() VSCodeCall("workbench.action.closeSecondaryPanel") end


function FindFiles()
  ClosePrimarySideBar()
  VSCodeCall("find-it-faster.findFiles")
end

function FindFilesWithType()
  ClosePrimarySideBar()
  VSCodeCall("find-it-faster.findFilesWithType")
end

function FindInsideFiles()
  ClosePrimarySideBar()
  VSCodeCall("find-it-faster.findWithinFiles")
end

function FindInsideFilesWithType()
  ClosePrimarySideBar()
  VSCodeCall("find-it-faster.findWithinFilesWithType")
end

function ResumeSearch()
  ClosePrimarySideBar()
  VSCodeCall("find-it-faster.resumeSearch")
end

function Save() VSCodeCall("workbench.action.files.save") end

function Save_no_format() VSCodeCall("workbench.action.files.saveWithoutFormatting") end

function Vscode_ctrl_d() VSCodeNotify("vscode-neovim.ctrl-d") end

function Vscode_ctrl_u() VSCodeNotify("vscode-neovim.ctrl-u") end

function Git_stage_selected_lines()  VSCodeNotify("git.stageSelectedRanges") end

function Git_unstage_selected_lines()  VSCodeNotify("git.unstageSelectedRanges") end

function Git_reset_selected_lines()  VSCodeNotify("git.revertSelectedRanges") end

function Git_stage_file()
  Trim_trailing_whitespace()
  Save()
  VSCodeNotify("git.stage")
end

function Git_unstage_file()
  Save()
  VSCodeNotify("git.unstage")
end

function Git_reset_file()
  Save()
  VSCodeNotify("git.clean")
end

function FetchAndCreateBranch()
  local vscode = require('vscode')
  local remote_branch = vim.fn.input('Enter remote branch (default: master): ')

  local new_branch = vim.fn.input('Enter new branch name to create: ')
  if remote_branch == '' then
    remote_branch = 'master'
    -- print('No remote branch provided. Exiting...')
    return
  end

  if new_branch == "" then
    vscode.notify("No new branch provided. Exiting...")
    -- print('No new branch provided. Exiting...')
    return
  end

  local fetch_command = 'git fetch origin ' .. remote_branch .. ':' .. new_branch
  local fetch_result = os.execute(fetch_command)

  if fetch_result == 0 then
    local checkout_command = 'git checkout ' .. new_branch
    local checkout_result = os.execute(checkout_command)
    if checkout_result == 0 then
      vscode.notify('Fetch and Checkout to new branch from origin successful: ' .. remote_branch .. ' -> ' .. new_branch)
      -- print('Fetch and Checkout to new branch from origin successful: ' .. new_branch)
    else
      vscode.notify('Failed to checkout to new branch: ' .. new_branch)
      -- print('Failed to checkout to new branch: ' .. new_branch)
    end
  else
    vscode.notify('Failed to fetch from origin: ' .. remote_branch)
    -- print('Failed to fetch from origin: ' .. remote_branch)
  end
end

function Move_to_bottom_screen__center_screen()
  Move_to_bottom_screen()
  Center_screen()
end

function Move_to_bottom_screen()
  Cmd("call <SNR>3_moveCursor('bottom')")
end

function Move_to_top_screen__center_screen()
  Move_to_top_screen()
  Center_screen()
end

function Move_to_top_screen()
  Cmd("call <SNR>3_moveCursor('top')")
end

function Format()
  VSCodeCall("editor.action.formatDocument")
  print("formatted!")
end

function FormatPrettier()
  VSCodeCall("prettier.forceFormatDocument")
  print("formatted!")
end

function Outdent()
  ---@diagnostic disable-next-line: unused-local
  for i = 1, vim.v.count1 do
    VSCodeNotify("editor.action.outdentLines")
  end
end

function Indent()
  ---@diagnostic disable-next-line: unused-local
  for i = 1, vim.v.count1 do
    VSCodeNotify("editor.action.indentLines")
  end
end

-- Keymaps vscode

-- Angular
Map("", "<leader>ah", function() VSCodeNotify("extension.open.template") end, { desc = "Switch to HTML" })
Map("", "<leader>at", function() VSCodeNotify("extension.open.class") end, { desc = "Switch to TypeScript" })
Map("", "<leader>ac", function() VSCodeNotify("extension.open.style") end, { desc = "Switch to CSS" })
Map({ "n", "v" }, "<leader>jf", function() VSCodeNotify("json-i18n-key.findKey") end, { desc = "Find json i18n key" })
Map({ "n", "v" }, "<leader>jc", function() VSCodeNotify("json-i18n-key.checkExistKey") end,
  { desc = "Check json i18n key" })
Map({ "n", "v" }, "<leader>jr", function() VSCodeNotify("json-i18n-key.renameKey") end, { desc = "Rename json i18n key" })
Map({ "n", "v" }, "<leader>ja", function() VSCodeNotify("json-i18n-key.addKey") end, { desc = "Add json i18n key" })
Map({ "n", "v" }, "<leader>jd", function() VSCodeNotify("json-i18n-key.removeKey") end, { desc = "Remove json i18n key" })
Map({ "n", "v" }, "<leader>ju", function() VSCodeNotify("json-i18n-key.updateKey") end,
  { desc = "Update json i18n key value" })
Map({ "n", "v" }, "<leader>jc", function() VSCodeNotify("json-i18n-key.copyKey") end,
  { desc = "Copy json i18n key value" })
Map({ "n", "v" }, "<leader>ct", function() VSCodeNotify("converter.pasteAsCs2Ts") end, { desc = "C# to TypeScript" })

-- Core
Map("n", "gd", function()  VSCodeNotify("editor.action.revealDefinition") end, { desc = "Go to definition" })
Map("n", "gr", function()  VSCodeNotify("references-view.findReferences") end, { desc = "Find references" })
Map("n", "gR", function()  VSCodeNotify("editor.action.goToReferences") end, { desc = "Go to references" })
Map("n", "gI", function()  VSCodeNotify("editor.action.goToImplementation") end, { desc = "Go to implementation" })
Map("n", "gt", function()  VSCodeNotify("editor.action.goToTypeDefinition") end, { desc = "Go to type definition" })
Map("n", "gD", function()  VSCodeNotify("editor.action.revealDeclaration") end, { desc = "Go to declaration" })
Map("n", "<leader>sd", function()  VSCodeNotify("workbench.action.gotoSymbol") end, { desc = "Go to document symbol" })
Map("n", "<leader>sw", function()  VSCodeNotify("workbench.action.showAllSymbols") end,
  { desc = "Show all workspace symbols" })
Map("n", "<leader>rn", function()  VSCodeNotify("editor.action.rename") end, { desc = "Rename code" })
Map("n", ",r", function()  VSCodeNotify("editor.action.rename") end, { desc = "Rename symbol" })
Map("n", "<leader>ca", function()  VSCodeNotify("editor.action.quickFix") end, { desc = "Quick fix 'Code Action'" })
Map("n", "<leader>db", function()  VSCodeNotify("workbench.action.problems.focus") end,
  { desc = "Focus on problems 'diagnostics'" })
Map("n", "<leader>td", function()  VSCodeNotify("workbench.actions.view.problems") end,
  { desc = "Toggle problems 'diagnostics'" })
Map("n", "]d", function()  VSCodeNotify("editor.action.marker.next") end, { desc = "Next problem" })
Map("n", "[d", function()  VSCodeNotify("editor.action.marker.prev") end, { desc = "Previous problem" })
Map("n", "K", function() VSCodeNotify("editor.action.showHover") end, { desc = "Show documentation hover" })
Map("n", "<leader>ww", function()  VSCodeNotify("editor.action.toggleWordWrap") end, { desc = "Toggle word wrap" })
Map("n", "zy", function()  VSCodeNotify("editor.debug.action.toggleBreakpoint") end, { desc = "Toggle breakpoint" })

Map("v", "<C-S-c>", '"+y', { desc = "copy selection to system clipboard" })
Map("n", "<C-S-c>", '"+yy', { desc = "copy line to system clipboard" })
-- Map("i", "<C-S-c>", copy_from_insert, { desc = "Copy selection to system clipboard from insert mode" })
-- Map("i", "<C-S-c>", '<Esc>"+y`^i', { desc = "Copy selection to system clipboard from insert mode" })
-- Map("i", "<C-S-c>", '"+y', { desc = "copy selection to system clipboard" })

Map("v", "<C-S-v>", '"_dP', { desc = "Paste ,rom system clipboard over selection" })
Map("n", "<C-S-v>", '"+P', { desc = "Paste from system clipboard" })
-- Map("i", "<C-S-v>", '<C-r>+', { desc = "Paste from system clipboard in insert mode", noremap = true, silent = true })

-- Harpoon - VS Code Harpoon extension
Map("n", "<leader>a", function() VSCodeNotify("vscode-harpoon.addEditor") end, { desc = "Harpoon add file" })
Map("n", "<C-e>", function() VSCodeNotify("vscode-harpoon.editorQuickPick") end, { desc = "Harpoon quick menu" })
Map("n", "<leader>hh", function()  VSCodeNotify("vscode-harpoon.editEditors") end, { desc = "Harpoon Edit Editors" })
Map("n", "<C-j>", function() VSCodeNotify("vscode-harpoon.navigatePreviousEditor") end, { desc = "Harpoon previous" })
Map("n", "<C-S-j>", function() VSCodeNotify("vscode-harpoon.navigatePreviousEditor") end, { desc = "Harpoon previous" })
Map("n", "<C-k>", function() VSCodeNotify("vscode-harpoon.navigateNextEditor") end, { desc = "Harpoon next" })
Map("n", "<C-S-k>", function() VSCodeNotify("vscode-harpoon.navigateNextEditor") end, { desc = "Harpoon next" })
Map("n", "<leader>1", function() VSCodeNotify("vscode-harpoon.gotoEditor1") end, { desc = "Harpoon file 1" })
Map("n", "<leader>2", function() VSCodeNotify("vscode-harpoon.gotoEditor2") end, { desc = "Harpoon file 2" })
Map("n", "<leader>3", function() VSCodeNotify("vscode-harpoon.gotoEditor3") end, { desc = "Harpoon file 3" })
Map("n", "<leader>4", function() VSCodeNotify("vscode-harpoon.gotoEditor4") end, { desc = "Harpoon file 4" })
Map("n", "<leader>ra", function()  VSCodeNotify("vscode-harpoon.removeAllEditors") end, { desc = "Harpoon remove all" })

-- Bookmarks
Map("n", "mm", function() VSCodeNotify("bookmarks.toggle") end, { desc = "Toggle bookmark" })
Map("n", "mi", function() VSCodeNotify("bookmarks.toggleLabeled") end , { desc = "Toggle labeled bookmark" })
Map("n", "mc", function() VSCodeNotify("bookmarks.clear") end, { desc = "Clear bookmarks for current file" })
Map("n", "mC", function() VSCodeNotify("bookmarks.clearFromAllFiles") end, { desc = "Clear bookmarks for all files" })
Map("n", "mn", function() VSCodeNotify("bookmarks.jumpToNext") end, { desc = "Next bookmark" })
Map("n", "mp", function() VSCodeNotify("bookmarks.jumpToPrevious") end, { desc = "Previous bookmark" })
Map("n", "ml", function() VSCodeNotify("bookmarks.list") end, { desc = "List bookmarks for current file" })
Map("n", "mL", function() VSCodeNotify("bookmarks.listFromAllFiles") end, { desc = "List bookmarks for all files" })

-- Editor
Map("", "L", Move_to_bottom_screen, { desc = "Move to bottom screen" })
Map("", "H", Move_to_top_screen, { desc = "Move to top screen" })
-- Map("", "<Space>", Trim__save__no_highlight)
Map("n", "U", Trim__Save__FormatPrettier)
Map("n", "<leader>U", Trim__Save__Format)
Map("n", "<<", Outdent)
Map("n", ">>", Indent)
Map("v", "<", function() VSCodeNotify("editor.action.outdentLines", false) end, { desc = "Outdent selected lines" })
Map("v", ">", function() VSCodeNotify("editor.action.indentLines", false) end, { desc = "Indent selected lines" })
-- Map("n", "gcc", function()  VSCodeNotify("editor.action.commentLine") end, { desc = "Comment line" })
-- Map("", "<C-/>", function() VSCodeNotify("editor.action.commentLine") end, { desc = "Comment line" })
-- Map("v", "gc", function() VSCodeNotify("editor.action.commentLine", false) end, { desc = "Comment selected lines" })
Map("n", "=s", function()  VSCodeNotify("editor.action.indentationToSpaces") end, { desc = "Indentation to spaces" })
Map("n", "=t", function()  VSCodeNotify("editor.action.indentationToTabs") end, { desc = "Indentation to tabs" })
Map("n", "=d", function()  VSCodeNotify("editor.action.indentUsingSpaces") end, { desc = "Indent using spaces" })
Map("n", "=g", function()  VSCodeNotify("editor.action.indentUsingTabs") end, { desc = "Indent using tabs" })
Map("n", "<leader>K", function() VSCodeNotify("workbench.action.closeActiveEditor") end, { desc = "Close active editor" })
Map("n", "<leader>,K", function()  VSCodeNotify("workbench.action.reopenClosedEditor") end,
  { desc = "Reopen closed editor" })
Map("n", "yr", function()  VSCodeNotify("copyRelativeFilePath") end, { desc = "Copy relative file path" })
Map("n", "yR", function()  VSCodeNotify("copyFilePath") end, { desc = "Copy file path" })
Map("v", "gs", function()  VSCodeNotify("codesnap.start", true) end, { desc = "Start code snapshot" })
Map({ "n", "v" }, "zb", Vscode_ctrl_d, { desc = "Scroll down" })
Map({ "n", "v" }, "zt", Vscode_ctrl_u, { desc = "Scroll up" })
Map("n", "<leader>pp", function()  VSCodeNotify("projectManager.listProjects") end, { desc = "List projects" })
Map("n", "<leader>pn", function()  VSCodeNotify("projectManager.listProjectsNewWindow") end,
  { desc = "List projects in new window" })
Map("n", "<leader>ss", function()  VSCodeNotify("editor.action.toggleStickyScroll") end, { desc = "Toggle sticky scroll" })
Map('v', '<leader>tw', function()
  vim.cmd([['<,'>s/\(\S\)\([ \t]\{3,\}\)\(\/\/\|--\|#\|;\|\*\*\?\|\<REM\>\)/\1  \3/g]])
  print("Trimmed comment whitespace in selection")
end, { desc = "Trim excessive whitespace before comments in selection" })
Map('n', '<leader>tw',
  ':%s/\\(\\S\\)\\([ \\t]\\{3,\\}\\)\\(\\/\\/\\|--\\|#\\|;\\|\\*\\*\\?\\|\\<REM\\>\\)/\\1  \\3/g<CR>',
  { desc = "Trim whitespace before comments" })

-- ##### window management
-- Split window
Map("n", "<leader>vs", function()  VSCodeNotify("workbench.action.splitEditorRight") end,
  { desc = "Split window vertically" })                                                                                         -- split window vertically
Map("n", "<leader>hs", function()  VSCodeNotify("workbench.action.splitEditorDown") end,
  { desc = "Split window horizontally" })                                                                                       -- split window horizontally

-- Focusing around windows
Map({ "n", "t" }, "<A-h>", function()  VSCodeNotify("workbench.action.focusLeftGroup") end,
  { desc = "Move to window left" })                                                                                            -- move to window left
Map({ "n", "t" }, "<A-j>", function()  VSCodeNotify("workbench.action.focusBelowGroup") end,
  { desc = "Move to window down" })                                                                                            -- move to window down
Map({ "n", "t" }, "<A-k>", function()  VSCodeNotify("workbench.action.focusAboveGroup") end,
  { desc = "Move to window up" })                                                                                              -- move to window up
Map({ "n", "t" }, "<A-l>", function()  VSCodeNotify("workbench.action.focusRightGroup") end,
  { desc = "Move to window right" })                                                                                           -- move to window right

-- Resizing windows
Map("n", "<A-S-h>", function() VSCodeNotify("workbench.action.decreaseViewWidth") end, { desc = "Decrease window width" })   -- decrease window width
Map("n", "<A-S-l>", function() VSCodeNotify("workbench.action.increaseViewWidth") end, { desc = "Increase window width" })   -- increase window width
Map("n", "<A-S-j>", function() VSCodeNotify("workbench.action.decreaseViewHeight") end,
  { desc = "Decrease window height" })                                                                                       -- decrease window height
Map("n", "<A-S-k>", function() VSCodeNotify("workbench.action.increaseViewHeight") end,
  { desc = "Increase window height" })                                                                                       -- increase window height

-- Moving around splits
Map("n", "<C-S-h>", function() VSCodeNotify("workbench.action.moveActiveEditorGroupLeft") end,
  { desc = "Move split to the left" })                                                                                                -- move split to the left
Map("n", "<C-S-j>", function() VSCodeNotify("workbench.action.moveActiveEditorGroupDown") end,
  { desc = "Move split down" })                                                                                                       -- move split down
Map("n", "<C-S-k>", function() VSCodeNotify("workbench.action.moveActiveEditorGroupUp") end, { desc = "Move split up" })              -- move split up
Map("n", "<C-S-l>", function() VSCodeNotify("workbench.action.moveActiveEditorGroupRight") end,
  { desc = "Move split to the right" })                                                                                               -- move split to the right


-- telescope
-- Map("n", "<C-p>", function()  VSCodeNotify("workbench.action.quickOpen") end)
Map("n", "<leader>sb", function()  VSCodeNotify("workbench.action.showAllEditorsByMostRecentlyUsed") end,
  { desc = "List all buffers" })

Map("n", "<leader>pf", FindFiles, { desc = "Find files" })
Map("n", "<leader>pt", FindFilesWithType, { desc = "Find files with type" })
-- Map("n", "<leader>sg", FindInsideFiles, { desc = "Find inside files" })
Map("n", "<leader>sg", function()  VSCodeNotify("workbench.action.quickTextSearch") end, { desc = "Find inside files" })
Map("n", "<leader>sG", FindInsideFilesWithType, { desc = "Find inside files with type" })
-- Map("n","<leader>pr", ResumeSearch, { desc = "Resume search" }) -- not implemented with windows

-- Git
Map("n", "<leader>gS", Git_stage_file, { desc = "Stage file" })
Map("n", "<leader>gU", Git_unstage_file, { desc = "Unstage file" })
Map("n", "<leader>gR", Git_reset_file, { desc = "Reset file" })
Map({ "n", "v" }, "<leader>gs", Git_stage_selected_lines, { desc = "Stage selected lines" })
Map({ "n", "v" }, "<leader>gu", Git_unstage_selected_lines, { desc = "Unstage selected lines" })
Map({ "n", "v" }, "<leader>gr", Git_reset_selected_lines, { desc = "Reset selected lines" })
Map("n", "zi", function()  VSCodeNotify("git.openChange") end, { desc = "View changes for the current file " })
Map("n", "zI", function()  VSCodeNotify("git.viewChanges") end, { desc = "View changes for all files" })
Map("n", "zC", function()  VSCodeNotify("git.openAllChanges") end, { desc = "Open only changed files" })
-- Map("n", "zC", function() VSCodeNotify("gitlens.openOnlyChangedFiles") end, { desc = "Open only changed files" })
Map("n", "zg", function()  VSCodeNotify("workbench.view.scm") end, { desc = "Open Source Control" })
Map("n", "]h", function() VSCodeCall("editor.action.dirtydiff.next") end, { desc = "Preview Next Git Change" })
Map("n", "[h", function() VSCodeCall("editor.action.dirtydiff.previous") end, { desc = "Preview Previous Git Change" })
-- Map("n", "]h", function() VSCodeCall("workbench.action.editor.nextChange") end, { desc = "Next Git Change" })
-- Map("n", "[h", function() VSCodeCall("workbench.action.editor.previousChange") end, { desc = "Previous Git Change" })
Map("n", "<leader>gb", function()  VSCodeNotify("gitlens.toggleFileBlame") end, { desc = "Toggle Git Blame" })
Map("n", "<leader>ghh", function() VSCodeNotify("githd.viewHistory") end, { desc = "Git History" })
Map("n", "<leader>ghf", function() VSCodeNotify("githd.viewFileHistory") end, { desc = "Git History File" })
Map("n", "<leader>gtb", function() VSCodeNotify("gitlens.toggleLineBlame") end, { desc = "Toggle line blame" })
Map("n", "<leader>gk", function()  VSCodeNotify("git.checkout") end, { desc = "Checkout to" })
Map("n", "<leader>gtg", function() VSCodeNotify("gitlens.stashSave") end, { desc = "Stash All Changes" })
Map("n", "<leader>gtl,", function()  VSCodeNotify("git.pull") end, { desc = "Pull" })
Map("n", "<leader>gtp,", function()  VSCodeNotify("git.push") end, { desc = "Push" })
Map("n", "<leader>gnb", function() VSCodeNotify("git.branchFrom") end, { desc = "Create branch from" })
Map("n", "<leader>gfc", FetchAndCreateBranch)
Map({ "n", "t" }, "<leader>lg", function() VSCodeNotify("lazygit-vscode.toggle") end, { desc = "Toggle Lazygit" })
-- Map("n", "<leader>gg", function() VSCodeNotify("extension.conventionalCommits") end, { desc = "Conventional Commits" })
Map("n", "<leader>gg", function()  VSCodeNotify("gitSemanticCommit.semanticCommit") end, { desc = "Semantic Commits" })

-- Folding
Map("n", "za", function()  VSCodeNotify("fold.foldLevelDefault") end) -- https://marketplace.visualstudio.com/items?itemName=felicio.vscode-fold
Map("n", "zA", function()  VSCodeNotify("editor.unfoldAll") end)
Map("n", "zo", function()  VSCodeNotify("editor.fold") end)
Map("n", "zO", function()  VSCodeNotify("editor.unfold") end)
Map("n", "zr", function()  VSCodeNotify("editor.foldRecursively") end)
Map("n", "zR", function()  VSCodeNotify("editor.unfoldRecursively") end)
-- Map("n", "zt", function() VSCodeNotify("editor.toggleFold") end)
Map("n", "ze", function()  VSCodeNotify("editor.foldAllExcept") end)
Map("n", "z1", function()  VSCodeNotify("editor.foldLevel1") end)
Map("n", "z2", function()  VSCodeNotify("editor.foldLevel2") end)
Map("n", "z3", function()  VSCodeNotify("editor.foldLevel3") end)
Map("n", "z4", function()  VSCodeNotify("editor.foldLevel4") end)
Map("n", "z5", function()  VSCodeNotify("editor.foldLevel5") end)
Map("n", "z6", function()  VSCodeNotify("editor.foldLevel6") end)
Map("n", "z7", function()  VSCodeNotify("editor.foldLevel7") end)


-- Jumplist
-- register a jump after insert mode is left
-- Map({ 'i' }, '<escape>',
--   function()
--     nvim_feedkeys('<escape>')
--     register_jump()
--   end
-- )

-- register a jump whenever a forward search is started
-- Map({ 'n' }, '/',
--   function()
--     register_jump()
--     nvim_feedkeys('/')
--   end
-- )

-- Map("n", "<C-o>", jump_back, { desc = "Jump back" })
-- Map("n", "<C-i>", jump_forw, { desc = "Jump forward" })

-- Scrolling Center_screen
Map({ "n", "x" }, "<C-u>", function()
  local visibleRanges = require('vscode').eval("return vscode.window.activeTextEditor.visibleRanges")
  local height = visibleRanges[1][2].line - visibleRanges[1][1].line
  for i = 1, height * 2 / 3 do
    vim.api.nvim_feedkeys("k", "n", false)
  end
  require('vscode').action("neovim-ui-indicator.cursorCenter")
end)

Map({ "n", "x" }, "<C-d>", function()
  local visibleRanges = require('vscode').eval("return vscode.window.activeTextEditor.visibleRanges")
  local height = visibleRanges[1][2].line - visibleRanges[1][1].line
  for i = 1, height * 2 / 3 do
    vim.api.nvim_feedkeys("j", "n", false)
  end
  require('vscode').action("neovim-ui-indicator.cursorCenter")
end)

Map({ "n", "x" }, "<C-f>", function()
  local visibleRanges = require('vscode').eval("return vscode.window.activeTextEditor.visibleRanges")
  local height = visibleRanges[1][2].line - visibleRanges[1][1].line
  for i = 1, height do
    vim.api.nvim_feedkeys("j", "n", false)
  end
  require('vscode').action("neovim-ui-indicator.cursorCenter")
end)

Map({ "n", "x" }, "<C-b>", function()
  local visibleRanges = require('vscode').eval("return vscode.window.activeTextEditor.visibleRanges")
  local height = visibleRanges[1][2].line - visibleRanges[1][1].line
  for i = 1, height do
    vim.api.nvim_feedkeys("k", "n", false)
  end
  require('vscode').action("neovim-ui-indicator.cursorCenter")
end)
