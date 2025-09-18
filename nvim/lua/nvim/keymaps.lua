-- Neovim-specific keymaps (only for native Neovim, not VSCode)
local nvim_keymaps = {
  -- Movement with centering (only for native nvim)
  { "", "<C-d>", "6+zz", { desc = "Scroll down and center" } },
  { "", "<C-u>", "6-zz", { desc = "Scroll up and center" } },
  { "", "<C-f>", "10+zz", { desc = "Page down and center" } },
  { "", "<C-b>", "10-zz", { desc = "Page up and center" } },

  -- Large jumps with centering
  { "n", "G", "Gzz", { desc = "Go to end and center" } },
  { "n", "gg", "ggzz", { desc = "Go to beginning and center" } },
  { "n", "{", "{zz", { desc = "Previous paragraph centered" } },
  { "n", "}", "}zz", { desc = "Next paragraph centered" } },

  -- Screen position jumps with centering
  { "n", "H", "Hzz", { desc = "Top of screen centered" } },
  { "n", "L", "Lzz", { desc = "Bottom of screen centered" } },
  { "n", "M", "Mzz", { desc = "Middle of screen" } },

  -- Search with centering
  { "n", "*", "*zzzv", { desc = "Search word under cursor centered" } },
  { "n", "#", "#zzzv", { desc = "Search word under cursor backward centered" } },
  { "n", "n", "nzzzv", { desc = "Next search result centered" } },
  { "n", "N", "Nzzzv", { desc = "Previous search result centered" } },

  -- Jump list navigation with centering
  { "n", "<C-o>", "<C-o>zz", { desc = "Jump back centered" } },
  { "n", "<C-i>", "<C-i>zz", { desc = "Jump forward centered" } },

  -- Paste operations (nvim-specific)
  { "n", ",p", "Pv`[o`]do<c-r><c-p>\"<esc>", { desc = "Paste (down) a characterwise register on a new line" } },
  { "n", ",P", "Pv`[o`]dO<c-r><c-p>\"<esc>", { desc = "Paste (up) a characterwise register on a new line" } },

  -- Remove search highlighting
  { "n", "<leader><space>", ":nohlsearch<CR>", { desc = "Clear search highlight" } },

  -- Focusing around windows
  { { "n", "t" }, "<A-h>", "<C-w>h", { desc = "Move to window left" } },  -- move to window left
  { { "n", "t" }, "<A-j>", "<C-w>j", { desc = "Move to window down" } },  -- move to window down
  { { "n", "t" }, "<A-k>", "<C-w>k", { desc = "Move to window up" } },    -- move to window up
  { { "n", "t" }, "<A-l>", "<C-w>l", { desc = "Move to window right" } }, -- move to window right

  -- Resizing windows
  {"n", "<A-S-h>", "<C-w><", { desc = "Decrease window width" } },  -- decrease window width
  {"n", "<A-S-l>", "<C-w>>", { desc = "Increase window width" } },  -- increase window width
  {"n", "<A-S-j>", "<C-w>-", { desc = "Decrease window height" } }, -- decrease window height
  {"n", "<A-S-k>", "<C-w>+", { desc = "Increase window height" } }, -- increase window height

  -- Moving around splits
  {"n", "<C-S-h>", "<C-w>H", { desc = "Move split to the left" } },  -- move split to the left
  {"n", "<C-S-j>", "<C-w>J", { desc = "Move split down" } },         -- move split down
  {"n", "<C-S-k>", "<C-w>K", { desc = "Move split up" } },           -- move split up
  {"n", "<C-S-l>", "<C-w>L", { desc = "Move split to the right" } }, -- move split to the right
  {"n", "<C-S-r>", "<C-w>r", { desc = "Swap splits" } },             -- swap splits

  -- Navigate buffers
  { "n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" } },
  { "n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" } },

  -- Better terminal navigation
  -- { "t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Terminal go to left window" } },
  -- { "t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Terminal go to bottom window" } },
  -- { "t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Terminal go to top window" } },
  -- { "t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Terminal go to right window" } },

  -- Close window
  -- Map("n", "<leader>wc", "<cmd>q<CR>", { desc = "Close window" }) -- close window
  { { "n", "t" }, "<leader>K", "<cmd>q!<CR>", { desc = "Close window" } },

  -- Tab management
  { "n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" } },
  { "n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab" } },
  { "n", "<leader>tn", ":tabn<CR>", { desc = "Go to next tab" } },
  { "n", "<leader>tp", ":tabp<CR>", { desc = "Go to previous tab" } },

  -- Split management
  { "n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" } },
  { "n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" } },
  { "n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" } },
  { "n", "<leader>sx", ":close<CR>", { desc = "Close current split" } },

  -- File operations
  { "n", "<leader>w", ":w<CR>", { desc = "Save file" } },
  { "n", "<leader>q", ":q<CR>", { desc = "Quit" } },
  { "n", "<leader>Q", ":qa<CR>", { desc = "Quit all" } },

  -- Command mode improvements
  { "c", "<C-j>", "<Down>", { desc = "Next command in history" } },
  { "c", "<C-k>", "<Up>", { desc = "Previous command in history" } },

  -- Insert mode improvements
  { "i", "<C-a>", "<Home>", { desc = "Go to beginning of line" } },
  { "i", "<C-e>", "<End>", { desc = "Go to end of line" } },
  { "i", "<C-d>", "<Delete>", { desc = "Delete character under cursor" } },

  -- Visual mode improvements
  { "x", "<leader>p", [["_dP]], { desc = "Paste without yanking" } },

  -- System clipboard operations
  { { "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" } },
  { "n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" } },
  { { "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from system clipboard" } },
  { { "n", "v" }, "<leader>P", [["+P]], { desc = "Paste before from system clipboard" } },

  -- Quick fix and location list
  { "n", "<leader>qo", ":copen<CR>", { desc = "Open quickfix list" } },
  { "n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix list" } },
  { "n", "]q", ":cnext<CR>", { desc = "Next quickfix item" } },
  { "n", "[q", ":cprev<CR>", { desc = "Previous quickfix item" } },
  { "n", "<leader>lo", ":lopen<CR>", { desc = "Open location list" } },
  { "n", "<leader>lc", ":lclose<CR>", { desc = "Close location list" } },
  { "n", "]l", ":lnext<CR>", { desc = "Next location list item" } },
  { "n", "[l", ":lprev<CR>", { desc = "Previous location list item" } },

  -- Toggle options
  { "n", "<leader>tn", ":set number!<CR>", { desc = "Toggle line numbers" } },
  { "n", "<leader>tr", ":set relativenumber!<CR>", { desc = "Toggle relative numbers" } },
  { "n", "<leader>ts", ":set spell!<CR>", { desc = "Toggle spell check" } },
  { "n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle word wrap" } },

  -- Search and replace
  { "n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and replace word under cursor" } },
  { "v", "<leader>sr", [[:s/\%V]], { desc = "Search and replace in visual selection" } },

  -- Miscellaneous
  { "n", "<leader>x", ":!chmod +x %<CR>", { desc = "Make file executable", silent = false } },
  { "n", "<leader>so", ":source %<CR>", { desc = "Source current file" } },
}

-- Apply nvim-specific keymaps
for _, keymap in ipairs(nvim_keymaps) do
  Map(keymap[1], keymap[2], keymap[3], keymap[4])
end

return {
  keymaps = nvim_keymaps
}
