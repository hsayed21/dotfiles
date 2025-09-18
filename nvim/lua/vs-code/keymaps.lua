local vscode_utils = require('vs-code.vscode-utils')

-- Legacy support - keeping these for any existing code that might use them
VSCodeNotify = vscode_utils.notify
VSCodeCall = vscode_utils.call

local vscode_keymaps = {

  --[Movement and Navigation]--
  -- scrolling with centering
  { { "n", "x" }, "<C-u>", vscode_utils.navigation.scroll_up_and_center, { desc = "Scroll up and center" } },
  { { "n", "x" }, "<C-d>", vscode_utils.navigation.scroll_down_and_center, { desc = "Scroll down and center" } },
  { { "n", "x" }, "<C-f>", vscode_utils.navigation.page_down_and_center, { desc = "Page down and center" } },
  { { "n", "x" }, "<C-b>", vscode_utils.navigation.page_up_and_center, { desc = "Page up and center" } },

  -- Large jumps with centering
  { "n", "G", vscode_utils.navigation.go_to_end_and_center, { desc = "Go to end and center" } },
  { "n", "gg", vscode_utils.navigation.go_to_beginning_and_center, { desc = "Go to beginning and center" } },
  { "n", "{", vscode_utils.navigation.prev_paragraph_and_center, { desc = "Previous paragraph centered" } },
  { "n", "}", vscode_utils.navigation.next_paragraph_and_center, { desc = "Next paragraph centered" } },

  -- Screen position jumps
  { "n", "M", vscode_utils.navigation.middle_of_screen_and_center, { desc = "Middle of screen" } },

  -- Jump list navigation with centering
  { "n", "<C-o>", vscode_utils.navigation.jump_back_and_center, { desc = "Jump back centered" } },
  { "n", "<C-i>", vscode_utils.navigation.jump_forward_and_center, { desc = "Jump forward centered" } },

  -- Scroll and center
  { { "n", "v" }, "zb", vscode_utils.navigation.scroll_down_and_center, { desc = "Scroll down and center" } },
  { { "n", "v" }, "zt", vscode_utils.navigation.scroll_up_and_center, { desc = "Scroll up and center" } },


  --[Formatting & Saving]--
  -- Save and format
  { "n", "U", vscode_utils.editor.save_and_format_prettier, { desc = "Trim, save and format with Prettier" } },
  { "n", "<leader>U", vscode_utils.editor.save_and_format, { desc = "Trim, save and format" } },
  -- Indentation
  { "n", "<<", vscode_utils.editor.outdent, { desc = "Outdent line" } },
  { "n", ">>", vscode_utils.editor.indent, { desc = "Indent line" } },
  { "v", "<", vscode_utils.editor.outdent_lines, { desc = "Outdent selected lines" } },
  { "v", ">", vscode_utils.editor.indent_lines, { desc = "Indent selected lines" } },
  { "n", "=s", "editor.action.indentationToSpaces", { desc = "Indentation to spaces" } },
  { "n", "=t", "editor.action.indentationToTabs", { desc = "Indentation to tabs" } },
  { "n", "=S", "editor.action.indentUsingSpaces", { desc = "Indent using spaces" } },
  { "n", "=T", "editor.action.indentUsingTabs", { desc = "Indent using tabs" } },


--[Search & Find]--
-- Search in text
  { "n", "*", vscode_utils.navigation.search_word_forward_and_center, { desc = "Search word under cursor centered" } },
  { "n", "#", vscode_utils.navigation.search_word_backward_and_center, { desc = "Search word under cursor backward centered" } },
  { "n", "n", vscode_utils.navigation.search_next_and_center, { desc = "Next search result centered" } },
  { "n", "N", vscode_utils.navigation.search_prev_and_center, { desc = "Previous search result centered" } },

  -- Search in files
  { "n", "<leader>sb", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "List all buffers" } },
  { "n", "<leader>pf", vscode_utils.search.find_files_with_sidebar_closed, { desc = "Find files" } },
  { "n", "<leader>pt", vscode_utils.search.find_files_with_type_sidebar_closed, { desc = "Find files with type" } },
  { "n", "<leader>sg", "workbench.action.quickTextSearch", { desc = "Find inside files" } },
  { "n", "<leader>sG", vscode_utils.search.find_inside_files_with_type, { desc = "Find inside files with type" } },


  --[Editor operations]--
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

  -- Additional editor operations
  { "n", "<leader>K", "workbench.action.closeActiveEditor", { desc = "Close active editor" } },
  { "n", "<leader>,K", "workbench.action.reopenClosedEditor", { desc = "Reopen closed editor" } },
  { "n", "yr", "copyRelativeFilePath", { desc = "Copy relative file path" } },
  { "n", "yR", "copyFilePath", { desc = "Copy file path" } },
  { "v", "gs", vscode_utils.utils.codesnap_start, { desc = "Start code snapshot" } },
  { "n", "<leader>pp", "projectManager.listProjects", { desc = "List projects" } },
  { "n", "<leader>pn", "projectManager.listProjectsNewWindow", { desc = "List projects in new window" } },
  { "n", "<leader>ss", "editor.action.toggleStickyScroll", { desc = "Toggle sticky scroll" } },

  --[Utility operations]--
  { 'v', '<leader>tw', function()
	vim.cmd([['<,'>s/\(\S\)\([ \t]\{3,\}\)\(\/\/\|--\|#\|;\|\*\*\?\|\<REM\>\)/\1  \3/g]])
	print("Trimmed comment whitespace in selection")
  end, { desc = "Trim excessive whitespace before comments in selection" } },
  { 'n', '<leader>tw', ':%s/\\(\\S\\)\\([ \\t]\\{3,\\}\\)\\(\\/\\/\\|--\\|#\\|;\\|\\*\\*\\?\\|\\<REM\\>\\)/\\1  \\3/g<CR>',
	{ desc = "Trim whitespace before comments" } },

  { "n", "C-r", "redo", { desc = "Redo" } },
  { "n", "<leader>sk", "neovim-keymaps-list.searchKeymaps", { desc = "Search keymaps" } },
  { "n", "<leader>ru", "typescript.removeUnusedImports", { desc = "Remove unused imports" } },
  { "n", "<leader>rc", "csharpOrganizeUsings.organize", { desc = "Remove unused Usings" } },


  --[Window Management]--
  -- Window splits
  { "n", "<leader>vs", vscode_utils.window.split_right, { desc = "[Window] Split window vertically" } },
  { "n", "<leader>hs", vscode_utils.window.split_down, { desc = "[Window] Split window horizontally" } },

  -- Focus around windows
  { { "n", "t" }, "<A-h>", vscode_utils.window.focus_left, { desc = "[Window] Move to window left" } },
  { { "n", "t" }, "<A-j>", vscode_utils.window.focus_below, { desc = "[Window] Move to window down" } },
  { { "n", "t" }, "<A-k>", vscode_utils.window.focus_above, { desc = "[Window] Move to window up" } },
  { { "n", "t" }, "<A-l>", vscode_utils.window.focus_right, { desc = "[Window] Move to window right" } },

  -- Resizing windows
  { "n", "<A-S-h>", vscode_utils.window.decrease_width, { desc = "[Window] Decrease window width" } },
  { "n", "<A-S-l>", vscode_utils.window.increase_width, { desc = "[Window] Increase window width" } },
  { "n", "<A-S-j>", vscode_utils.window.decrease_height, { desc = "[Window] Decrease window height" } },
  { "n", "<A-S-k>", vscode_utils.window.increase_height, { desc = "[Window] Increase window height" } },

  -- Moving around splits
  { "n", "<C-S-h>", "workbench.action.moveActiveEditorGroupLeft", { desc = "[Window] Move split to the left" } },
  { "n", "<C-S-j>", "workbench.action.moveActiveEditorGroupDown", { desc = "[Window] Move split down" } },
  { "n", "<C-S-k>", "workbench.action.moveActiveEditorGroupUp", { desc = "[Window] Move split up" } },
  { "n", "<C-S-l>", "workbench.action.moveActiveEditorGroupRight", { desc = "[Window] Move split to the right" } },


  --[Git operations]--
  -- Stage/unstage/reset
  { "n", "<leader>gS", vscode_utils.git.stage_file_with_save, { desc = "[Git] Stage file" } },
  { "n", "<leader>gU", vscode_utils.git.unstage_file_with_save, { desc = "[Git] Unstage file" } },
  { "n", "<leader>gR", vscode_utils.git.reset_file, { desc = "[Git] Reset file" } },
  { { "n", "v" }, "<leader>gs", vscode_utils.git.stage_selected, { desc = "[Git] Stage selected lines" } },
  { { "n", "v" }, "<leader>gu", vscode_utils.git.unstage_selected, { desc = "[Git] Unstage selected lines" } },
  { { "n", "v" }, "<leader>gr", vscode_utils.git.reset_selected_lines, { desc = "[Git] Reset selected lines" } },

	-- View changes and navigate
  { "n", "zi", vscode_utils.git.show_changes, { desc = "[Git] View changes for the current file " } },
  { "n", "zI", "git.viewChanges", { desc = "[Git] View changes for all files" } },
  { "n", "zC", "git.openAllChanges", { desc = "[Git] Open only changed files" } },
  { "n", "zg", vscode_utils.git.show_source_control, { desc = "[Git] Open Source Control" } },
  { "n", "]h", vscode_utils.git.next_change, { desc = "[Git] Preview Next Git Change" } },
  { "n", "[h", vscode_utils.git.prev_change, { desc = "[Git] Preview Previous Git Change" } },

  -- Git operations
  { "n", "<leader>gpl,", "git.pull", { desc = "[Git] Pull" } },
  { "n", "<leader>gps,", "git.push", { desc = "[Git] Push" } },
  { "n", "<leader>gch", "git.checkout", { desc = "[Git] Checkout to" } },
  { "n", "<leader>gbf", "git.branchFrom", { desc = "[Git] Create branch from" } },
  { "n", "<leader>gfcb", vscode_utils.git.fetch_and_create_branch, { desc = "[Git] Fetch and create branch" } },

  -- GitLens and other Git extensions
  { "n", "<leader>gvh", "githd.viewHistory", { desc = "[Git] Git History" } },
  { "n", "<leader>gvfh", "githd.viewFileHistory", { desc = "[Git] Git History File" } },
  { "n", "<leader>gtfb", "gitlens.toggleFileBlame", { desc = "[Git] Toggle Git Blame" } },
  { "n", "<leader>gtlb", "gitlens.toggleLineBlame", { desc = "[Git] Toggle line blame" } },
  { "n", "<leader>gtfc", "gitlens.toggleFileChanges", { desc = "[Git] Toggle line blame" } },
  { "n", "<leader>gss", "gitlens.stashSave", { desc = "[Git] Stash All Changes" } },
  { "n", "<leader>gdp", "gitlens.diffWithPrevious", { desc = "[Git] Open Changes with Previous Revision" } },
  { "n", "<leader>gdn", "gitlens.diffWithNext", { desc = "[Git] Open Changes with Next Revision" } },
  { "n", "<leader>gdr", "gitlens.diffWithRevision", { desc = "[Git] Open Changes with Revision" } },
  { "n", "<leader>gsc", "gitlens.showCommitSearch", { desc = "[Git] Search Commits" } },
  { "n", "<leader>gg", "gitlens.showGraphPage", { desc = "[Git] Show Commit Graph" } },
  { { "n", "t" }, "<leader>lg", "lazygit-vscode.toggle", { desc = "[Git] Toggle Lazygit" } },
  { "n", "<leader>gc", "gitSemanticCommit.semanticCommit", { desc = "[Git] Semantic Commits" } },


  --[Folding]--
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


  --[My Development]--
  -- For Angular
  { "", "<leader>ah", "extension.open.template", { desc = "Switch to HTML" } },
  { "", "<leader>at", "extension.open.class", { desc = "Switch to TypeScript" } },
  { "", "<leader>ac", "extension.open.style", { desc = "Switch to CSS" } },

  -- Code conversion
  { { "n", "v" }, "<leader>ct", "converter.pasteAsCs2Ts", { desc = "C# to TypeScript" } },

  -- JSON i18n keys
  { { "n", "v" }, "<leader>jf", "json-i18n-key.findKey", { desc = "Find json i18n key" } },
  { { "n", "v" }, "<leader>jc", "json-i18n-key.checkExistKey", { desc = "Check json i18n key" } },
  { { "n", "v" }, "<leader>jr", "json-i18n-key.renameKey", { desc = "Rename json i18n key" } },
  { { "n", "v" }, "<leader>ja", "json-i18n-key.addKey", { desc = "Add json i18n key" } },
  { { "n", "v" }, "<leader>jd", "json-i18n-key.removeKey", { desc = "Remove json i18n key" } },
  { { "n", "v" }, "<leader>ju", "json-i18n-key.updateKey", { desc = "Update json i18n key value" } },


  --[Extensions]--
  -- Harpoon - VS Code Harpoon extension
  { "n", "<leader>a", "vscode-harpoon.addEditor", { desc = "Harpoon add file" } },
  { "n", "<C-e>", "vscode-harpoon.editorQuickPick", { desc = "Harpoon quick menu" } },
  { "n", "<leader>hh", "vscode-harpoon.editEditors", { desc = "Harpoon Edit Editors" } },
  { "n", "<C-j>", "vscode-harpoon.navigatePreviousEditor", { desc = "Harpoon previous" } },
  { "n", "<C-k>", "vscode-harpoon.navigateNextEditor", { desc = "Harpoon next" } },
--   { "n", "<C-S-j>", "vscode-harpoon.navigatePreviousEditor", { desc = "Harpoon previous" } },
--   { "n", "<C-S-k>", "vscode-harpoon.navigateNextEditor", { desc = "Harpoon next" } },
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

}


-- change o in normal mode to also auto indent using VSCode
Map( 'n', 'o', "o<Cmd>call VSCodeNotifyRange('editor.action.reindentselectedlines', line('.'), line('.'), 1)<CR>")
Map( 'n', 'O', "O<Cmd>call VSCodeNotifyRange('editor.action.reindentselectedlines', line('.'), line('.'), 1)<CR>")



-- Apply all VSCode keymaps using a for loop
for _, keymap in ipairs(vscode_keymaps) do
  local rhs = keymap[3]

  -- If rhs is a string, check if it's a VSCode command or Vim command
  if type(rhs) == "string" then
    -- VSCode commands typically contain dots (e.g., "editor.action.something")
    -- Vim commands start with special characters like "+, ", etc.
    if string.match(rhs, "^['\"+]") or string.match(rhs, "^:%s") or string.match(rhs, "^redo$") then
      -- This is a Vim command, use it directly
      Map(keymap[1], keymap[2], rhs, keymap[4])
    else
      -- This is a VSCode command, wrap it in VSCodeNotify
      local cmd = rhs
      Map(keymap[1], keymap[2], function() VSCodeNotify(cmd) end, keymap[4])
    end
  else
    -- This is a function, use it directly
    Map(keymap[1], keymap[2], rhs, keymap[4])
  end
end

return {
  keymaps = vscode_keymaps
}
