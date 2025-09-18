-- Common options shared between Neovim and VSCode
local options = {
  backup = false,                          -- creates a backup file
  clipboard = "unnamedplus",               -- allows neovim to access the system clipboard
  cmdheight = 2,                           -- more space in the neovim command line for displaying messages
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  conceallevel = 0,                        -- so that `` is visible in markdown files
  fileencoding = "utf-8",                  -- the encoding written to a file
  encoding = "utf-8",                      -- the encoding displayed
  hlsearch = true,                         -- highlight all matches on previous search pattern
  incsearch = true,                        -- incremental search
  ignorecase = true,                       -- ignore case in search patterns
  mouse = "a",                             -- allow the mouse to be used in neovim
  pumheight = 10,                          -- pop up menu height
  showmode = true,                        -- we don't need to see things like -- INSERT -- anymore
  showtabline = 2,                         -- always show tabs
  smartcase = true,                        -- smart case
  smartindent = true,                      -- make indenting smarter again
  autoindent = true,                       -- automatically indent code
  splitbelow = true,                       -- force all horizontal splits to go below current window
  splitright = true,                       -- force all vertical splits to go to the right of current window
  swapfile = false,                        -- creates a swapfile
  termguicolors = true,                    -- set term gui colors (most terminals support this)
  timeout = false,                         -- time out on key sequences
  timeoutlen = 1000,                       -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true,                         -- enable persistent undo
  updatetime = 300,                        -- faster completion (4000ms default)
  writebackup = false,                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  shiftwidth = 4,                          -- the number of spaces inserted for each indentation
  tabstop = 4,                             -- insert N spaces for a tab
  softtabstop = 4,                         -- insert N spaces for a tab
  expandtab = true,                       -- convert tabs to spaces
  smarttab = true,                         -- make tabbing smarter will realize you have 2 vs 4
  cursorline = true,                       -- highlight the current line
  number = true,                           -- set numbered lines
  relativenumber = true,                  -- set relative numbered lines
  numberwidth = 2,                         -- set number column width to 2 {default 4}
  signcolumn = "yes",                      -- always show the sign column, otherwise it would shift the text each time
  wrap = false,                            -- display lines as one long line
  scrolloff = 8,                           -- is one of my fav
  sidescrolloff = 8,
  colorcolumn = "",
  syntax = "enable",                       -- syntax highlighting
  background = "dark",                     -- tell vim what the background color looks like
    breakindent = true, -- line-wrapping but keeps wrapped lines on same indentation level

  -- guicursor = "",                          -- set cursor to be a block
  inccommand = "split",                    -- preview substitutions live
  title = true,                            -- set the title of window to the value of the titlestring
  showcmd = true,                          -- display incomplete commands
  laststatus = 2,                          -- always show the status line
  -- shell = "fish",                          -- set shell to fish
  -- shell = "wt",                          -- set shell to fish
  backspace = { "start", "eol", "indent" }, -- allow backspacing over everything in insert mode
  splitkeep = "cursor",                    -- when opening a new split keep the cursor in the current window

}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Additional common settings
vim.opt.shortmess:append "c"
vim.opt.iskeyword:append "-"
vim.opt.formatoptions:remove({ "c", "r", "o" }) -- don't insert current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode.
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles") -- separate vim plugins from neovim in case vim still in use

-- Basic folding settings
vim.o.foldcolumn             = '1' -- '0' is not bad
vim.o.foldlevel              = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart         = 99
vim.o.foldenable             = true

-- shell
vim.opt.shell = vim.fn.executable "pwsh" and "pwsh" or "powershell"
vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.opt.shellquote = ""
vim.opt.shellxquote  = ""

-- map <leader> to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- vim.g.camelcasemotion_key = "<leader>"
vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true, silent = true })

-- Cmd function to execute vim commands
function Cmd(command)
  vim.cmd(command)
end

-- Global helper functions
-- These functions are used in both nvim and vscode contexts
function Map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    if opts.desc and type(opts.desc) ~= "string" then
      opts.desc = tostring(opts.desc) -- Convert desc to string if it's not already
    end
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Common keymaps that work in both environments
-- Movement & navigation (shared between nvim and vscode)
local common_keymaps = {
  -- Skip folds (down, up)
  -- { "n", "j", "gj", { desc = "Move down (display lines)" } },
  -- { "n", "k", "gk", { desc = "Move up (display lines)" } },
  { cmd = "vim.cmd('nmap j gj')", desc = "Map j to gj for display line movement" },
  { cmd = "vim.cmd('nmap k gk')", desc = "Map k to gk for display line movement" },

  -- Search
  { "", ",s", "/\\V", { desc = "Search (literal)" } },
  { "", "/", "/\\v", { desc = "Search (regex)" } },
  { "", ",S", "?\\V", { desc = "Backward search (literal)" } },
  { "", "?", "?\\v", { desc = "Backward search (regex)" } },

  -- Copy & Paste & Delete
  { "n", "yp", "yyp", { desc = "Copy line down" } },
  { "n", "yP", "yyP", { desc = "Copy line up" } },
  { "v", "p", '"_dp', { desc = "Paste without yanking" } },
  { "v", "P", '"_dP', { desc = "Paste before without yanking" } },
  { "n", "x", '"_x', { desc = "Delete char without yanking" } },
  { "v", "x", '"_x', { desc = "Delete selection without yanking" } },
  { "n", "c", '"_c', { desc = "Change without yanking" } },
  { "v", "c", '"_c', { desc = "Change selection without yanking" } },
  { "n", "s", '"_s', { desc = "Substitute without yanking" } },
  { "v", "s", '"_s', { desc = "Substitute selection without yanking" } },

  -- Indentation
  { "v", "<", "<gv", { desc = "Indent left and reselect" } },
  { "v", ">", ">gv", { desc = "Indent right and reselect" } },

  -- Sort selected lines
  { "v", ",t", ":sort<CR>", { desc = "Sort selected lines" } },

  -- Swap lines
  { "n", "dp", "ddp", { desc = "Swap line down" } },
  { "n", "dP", "ddkP", { desc = "Swap line up" } },
  { "x", "J", ":move '>+1<CR>gv-gv", { desc = "Move selection down" } },
  { "x", "K", ":move '<-2<CR>gv-gv", { desc = "Move selection up" } },

  -- Text objects for operator mode
  { "o", "{", "V{", { desc = "Select to paragraph start" } },
  { "o", "}", "V}", { desc = "Select to paragraph end" } },
  { "o", "+", "v+", { desc = "Select to line end" } },
  { "o", "-", "v-", { desc = "Select to line start" } },

  -- Insert mode helpers
  { "i", "<C-k>", "<C-o>O", { desc = "New line above" } },
  { "i", "<C-j>", "<C-o>o", { desc = "New line below" } },
  { "i", "<C-e>", "<Backspace>", { desc = "Delete previous char" } },
  { "i", "<C-r>", "<Delete>", { desc = "Delete next char" } },
  { "i", "<C-y>", "<C-o>C", { desc = "Delete to line end" } },

  -- Normal mode line creation
  -- { "n", "<C-k>", "O<Esc>", { desc = "Create line above" } },
	-- { "n", "<C-j>", "o<Esc>", { desc = "Create line below" } },

	-- General
	{ "n", "~", "~h", { desc = "Lower/Upper case the character under the cursor" } },

	{ "",  '"', ":" },
	{ "",  "'",     '"' },   -- Map single quote to double quote in normal mode

	-- Store original cursor position before yanking
	{ 'v', 'y', function()
		-- Save current cursor position
		local pos = vim.fn.getpos('.')
		-- Perform yank
		vim.cmd('normal! y')
		-- Return to original position
		vim.fn.setpos('.', pos)
	end, { desc = 'Yank and preserve cursor position' } }

}

-- Apply common keymaps
for _, keymap in ipairs(common_keymaps) do
  if type(keymap) == "string" then
    -- Handle direct command strings like "vim.cmd('nmap j gj')"
    local func, err = load(keymap)
    if func then
      func()
    else
      vim.notify("Error executing command: " .. keymap .. " - " .. (err or "unknown error"), vim.log.levels.ERROR)
    end
  elseif type(keymap) == "table" then
    if keymap.cmd then
      -- Handle command objects with descriptions: { cmd = "vim.cmd('nmap j gj')", desc = "Move down visually" }
      local func, err = load(keymap.cmd)
      if func then
        func()
        if keymap.desc then
          -- Store description for reference (could be used by documentation tools)
          -- For now, just print it as a comment in verbose mode
        end
      else
        vim.notify("Error executing command: " .. keymap.cmd .. " - " .. (err or "unknown error"), vim.log.levels.ERROR)
      end
    elseif #keymap >= 3 then
      -- Handle standard keymap table format [mode, lhs, rhs, opts]
      Map(keymap[1], keymap[2], keymap[3], keymap[4])
    else
      vim.notify("Invalid keymap entry: " .. vim.inspect(keymap), vim.log.levels.WARN)
    end
  elseif type(keymap) == "function" then
    -- Handle function entries - execute them
    keymap()
  else
    vim.notify("Invalid keymap entry: " .. vim.inspect(keymap), vim.log.levels.WARN)
  end
end

return {
  options = options,
  keymaps = common_keymaps
}
