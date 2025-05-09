--[[ Modes:
  normal_mode = "n",
  insert_mode = "i",
  visual_mode+selection_mode = "v",
  global_mode = "",
  operator_mode = "o", --[operator-pending mode] Map keys in operator-pending mode run after Trigger Operator (d for delete, y for yank, etc.))
  visual_block_mode = "x",
  term_mode = "t",
  command_mode = "c",
  select_mode = "s",
--]]

local opts = { noremap = true, silent = true }

--##### [Movement] #####
-- Navigation & Jumping
Map("", "<C-d>", "6+zz")
Map("", "<C-u>", "6-zz")
Map("", "<C-f>", "10+")
Map("", "<C-b>", "10-")
Map("", "gM", "Mzz") -- middle of the screen
-- skip folds (down, up)
Cmd('nmap j gj')
Cmd('nmap k gk')
-- Map("n", "j", "gj")
-- Map("n", "k", "gk")

-- Find & Search
Map("", ",s", "/\\V") -- (Forward) Auto escape special characters in the search pattern. (often search for plain text)
Map("", "/", "/\\v")  -- (Forward) make regular expressions more concise and easier to read This is the opposite of `\V`
Map("", ",S", "?\\V") -- (Backward) Auto escape special characters in the search pattern. (often search for plain text)
Map("", "?", "?\\v")  -- (Backward) make regular expressions more concise and easier to read This is the opposite of `\V`

-- Sort selected lines when visual mode is active
Map("v", ",t", ":sort<CR>")

-- Swap lines
Map("n", "dp", "ddp")                -- swap line down
Map("n", "dP", "ddkP")               -- swap line up
Map("x", "J", ":move '>+1<CR>gv-gv") -- swap selected line down
Map("x", "K", ":move '<-2<CR>gv-gv") -- swap selected line up

-- Indentation
Map("v", "<", "<gv")
Map("v", ">", ">gv")

--##### [Modification] #####
-- Undo
-- Map("v", "u", "<Esc>u") -- Map 'u' in visual mode to '<Esc>u'

-- Copy & Paste & Delete
Map("n", "yp", "yyp")                        -- copy line down
Map("n", "yP", "yyP")                        -- copy line up
Map("n", ",p", "Pv`[o`]do<c-r><c-p>\"<esc>") -- Paste (down) a characterwise register on a new line
Map("n", ",P", "Pv`[o`]dO<c-r><c-p>\"<esc>") -- Paste (up) a characterwise register on a new line
Map({ "v" }, "p", '"_dp')                    -- paste after current char without yanking
Map({ "v" }, "P", '"_dP')                    -- paste before current char without yanking
Map('n', 'x', '"_x')                         -- delete char without yanking
Map('v', 'x', '"_x')
Map('n', 'c', '"_c')                         -- change text without yanking
Map('v', 'c', '"_c')
Map('n', 's', '"_s')                         -- change text without yanking
Map('v', 's', '"_s')
-- Map("n", "d", '"_d')
-- Map("v", "d", '"_d')

-- Changes & Insert & Delete
Map("o", "{", "V{")              -- action up to the top of the paragraph
Map("o", "}", "V}")              -- action down to the bottom of the paragraph
Map("o", "+", "v+")              -- action to the end of the line
Map("o", "-", "v-")              -- action to the beginning of the line
Map("i", "<C-k>", "<C-o>O")      -- add a new line above the current line in insert mode
Map("n", "<C-k>", "O<Esc>")
Map("i", "<C-j>", "<C-o>o")      -- add a new line below the current line in insert mode
Map("n", "<C-j>", "o<Esc>")
Map("i", "<C-e>", "<Backspace>") -- delete the character under the cursor and enter insert mode
Map("i", "<C-r>", "<Delete>")    -- delete the character under the cursor and enter insert mode
Map("i", "<C-y>", "<C-o>C")      -- delete from the cursor to the end of the line and enter insert mode

-- change o in normal mode to also auto indent using VSCode
Map( 'n', 'o', "o<Cmd>call VSCodeNotifyRange('editor.action.reindentselectedlines', line('.'), line('.'), 1)<CR>")
Map( 'n', 'O', "O<Cmd>call VSCodeNotifyRange('editor.action.reindentselectedlines', line('.'), line('.'), 1)<CR>")


-- Store original cursor position before yanking
Map('v', 'y', function()
  -- Save current cursor position
  local pos = vim.fn.getpos('.')
  -- Perform yank
  vim.cmd('normal! y')
  -- Return to original position
  vim.fn.setpos('.', pos)
end, { desc = 'Yank and preserve cursor position' })

Map("n", "~", "~h")              -- Lower/Upper case the character under the cursor

----##### [Shortcuts] #####
Map("", '"', ":")
Map("", "'", '"') -- Map single quote to double quote in normal mode

--##### [Text Objects] #####
Map("n", "vW", "viw") -- Select the current word
Map("n", "dW", 'diw')   -- Delete a word
Map("n", "cW", '"_ciw') -- Change a word
Map("n", "yW", 'yiw') -- Yank a word

if vim.g.vscode == false then
  -- ##### window management
  -- Split window
  Map("n", "<leader>vs", "<C-w>v", { desc = "Split window vertically" })     -- split window vertically
  Map("n", "<leader>hs", "<C-w>s", { desc = "Split window horizontally" })   -- split window horizontally
  Map("n", "<leader>es", "<C-w>=", { desc = "Make splits equal size" })      -- make split windows equal width & height
  Map("n", "<leader>xs", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window
  Map("n", "<leader>xo", "<C-w>o", { desc = "Close current split" })         -- close current split window

  -- Focusing around windows
  Map({ "n", "t" }, "<A-h>", "<C-w>h", { desc = "Move to window left" })  -- move to window left
  Map({ "n", "t" }, "<A-j>", "<C-w>j", { desc = "Move to window down" })  -- move to window down
  Map({ "n", "t" }, "<A-k>", "<C-w>k", { desc = "Move to window up" })    -- move to window up
  Map({ "n", "t" }, "<A-l>", "<C-w>l", { desc = "Move to window right" }) -- move to window right

  -- Resizing windows
  Map("n", "<A-S-h>", "<C-w><", { desc = "Decrease window width" })  -- decrease window width
  Map("n", "<A-S-l>", "<C-w>>", { desc = "Increase window width" })  -- increase window width
  Map("n", "<A-S-j>", "<C-w>-", { desc = "Decrease window height" }) -- decrease window height
  Map("n", "<A-S-k>", "<C-w>+", { desc = "Increase window height" }) -- increase window height

  -- Moving around splits
  Map("n", "<C-S-h>", "<C-w>H", { desc = "Move split to the left" })  -- move split to the left
  Map("n", "<C-S-j>", "<C-w>J", { desc = "Move split down" })         -- move split down
  Map("n", "<C-S-k>", "<C-w>K", { desc = "Move split up" })           -- move split up
  Map("n", "<C-S-l>", "<C-w>L", { desc = "Move split to the right" }) -- move split to the right
  Map("n", "<C-S-r>", "<C-w>r", { desc = "Swap splits" })             -- swap splits

  -- Close window
  -- Map("n", "<leader>wc", "<cmd>q<CR>", { desc = "Close window" }) -- close window
  Map({ "n", "t" }, "<leader>K", "<cmd>q!<CR>", { desc = "Close window" })

  -- Tabs
  -- Map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
  -- Map("n", "<leader>tq", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
  -- Map("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Go to next tab" }) --  go to next tab
  -- Map("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Go to previous tab" }) --  go to previous tab
end

-- [[ quickfix list shortcuts ]]
-- 1. open / close
Map("n", "<leader>co", ":copen<CR>", { desc = "Open quickfix list" })
Map("n", "<leader>cc", ":cclose<CR>", { desc = "Open quickfix list" })

-- 2. next and prev items
Map("n", "<leader>;", ":cnext<CR>", { desc = "go to next quickfix item" })
Map("n", "<leader>,", ":cprevious<CR>", { desc = "go to previous quickfix item" })



---- ============================================================================

---- Unknown
-- Map("i", "<CR>", "<ESC>zzo") -- Insert a newline below the current line

---- Need it Later
-- Fix register copy/pasting
-- Map('n', 'DD', '"*dd', { noremap = true })
-- Map('n', 'D', '"*d', { noremap = true })
-- Map('v', 'D', '"*d', { noremap = true })

-- Map('n', 'd', '"_d', { noremap = true })
-- Map('n', 'dd', '"_dd', { noremap = true })
-- Map('v', 'd', '"_d', { noremap = true })

-- Map('n', 's', '"_s', { noremap = true })
-- Map('v', 's', '"_s', { noremap = true })

-- Map('n', 'c', '"_c', { noremap = true })
-- Map('v', 'c', '"_c', { noremap = true })

-- Map('n', 'x', '"_x', { noremap = true })
-- Map('v', 'x', '"_x', { noremap = true })

-- Map('v', 'p', '"_c<C-r>*<Esc>', { noremap = true })

-- ({"n", "v"}, "<C-v>", '"_dP') -- paste  yanking
-- Map({"n", "v"}, "<C-c>", '"+y') -- copy to system clipboard

-- Map({'n', 'v'}, 'p', '"0p') -- Remap p to paste from the 0 register
-- Map({'n','v'}, 'P', '"0P') -- Remap P to paste from the 0 register
-- Map({"n", "v"}, "<C-v>", "'0P") -- Paste from the system clipboard
-- Map('n', '<C-v>', '"+p')  -- paste from the system clipboard
-- Map('v', '<C-v>', '"+p')  -- paste from the system clipboard
-- Map("n", "p", "'0p")            -- Paste from the system clipboard
-- Map("n", "P", "'0P")            -- Paste from the system clipboard

-- fomat whole file
-- Map("n", "U", "gg=G<C-o><C-o>")

-- Map("v", "&", ":s`\\V") -- Replace the selected text with the last search pattern
-- Map("n", "&", ":%s`\\V") -- Replace all occurrences of the last search pattern
-- Map("v", "&", ":s ///g<Left><Left>") -- Replace the selected text with the last search pattern
-- Map("n", "&", ":%s ///g<Left><Left>") -- Replace all occurrences of the last search pattern

-- Map("n", "<C-i>", "^i", {noremap=true}) -- insert at the beginning of the line

-- Map("n", "gJ", "j0d^kgJ") -- Join current line with the next line with no space in between, *also* discarding any leading whitespace of the next line. Because gJ would include indentation. Stupidly.
-- Map("i", "<C-h>", '<C-o>"_S<Esc><C-o>gI<BS>') -- Delete from the current position to the last character on the previous line
-- Map("n", "dw", 'vb"_d') -- Delete a word backwards

----##### [Debug] #####
-- Map("", "<leader>e", ":source <CR>") -- Compile lua files (For ing purposes)
--

-- toggle search highlight
-- Map("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlights" })
--
-- -- resize panes more easily
-- vim.keymap.set("n", "<C-Left>", ":vertical resize +3<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "<C-Right>", ":vertical resize -3<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "<C-Up>", ":resize +3<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "<C-Down>", ":resize -3<CR>", { silent = true, noremap = true })

-- if !vim.g.vscode then
--     Map("n", "<Esc>", ":nohlsearch<CR><Esc>", { desc = "Clear search highlights" })
-- end

-- -- crazydog
-- -- Do things without affecting the registers
-- Map("n", "<Leader>p", '"wp')
-- Map("n", "p", '"wp', { noremap = true, silent = true })
-- Map('n', 'p', ':put 0<CR>')
-- keymap.set("n", "<Leader>P", '"0P')
-- keymap.set("v", "<Leader>p", '"0p')
-- keymap.set("n", "<Leader>c", '"_c')
-- keymap.set("n", "<Leader>C", '"_C')
-- keymap.set("v", "<Leader>c", '"_c')
-- keymap.set("v", "<Leader>C", '"_C')
-- keymap.set("n", "<Leader>d", '"_d')
-- keymap.set("n", "<Leader>D", '"_D')
-- keymap.set("v", "<Leader>d", '"_d')
-- keymap.set("v", "<Leader>D", '"_D')

-- -- Save with root permission (not working for now)
-- --vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- -- Disable continuations
-- keymap.set("n", "<Leader>o", "o<Esc>^Da")
-- keymap.set("n", "<Leader>O", "O<Esc>^Da")

-- -- Jumplist
-- keymap.set("n", "<C-m>", "<C-i>")

-- -- New tab
-- keymap.set("n", "te", ":tabedit")

-- -- crazydog


-- --[[ my custom macros ]]

-- -- 1. escape html
-- vim.keymap.set("n", "<leader>cme", "diwi{`<Esc>pa`}<Esc>", { desc = "Escape html" })

-- -- 2. convert className to use cn util
-- vim.keymap.set("n", "<leader>cmcn", 'da"i{cn(<Esc>pa)}<Esc>', { desc = 'Convert className="" to className={cn(...)}' })

------------
-- -- save file
-- map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w!<cr><esc>")

-- -- Clear search with <esc>
-- map({ "i", "n" }, "<esc>", "<cmd>noh|NoiceDismiss<cr><esc>", { desc = "Escape and clear hlsearch" })

-- -- better up/down
-- map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- -- Move Lines
-- map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
-- map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
-- map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
-- map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
-- map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
-- map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })
