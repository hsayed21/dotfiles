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
  -- ttimeoutlen=9999,                        -- time to wait for a mapped sequence to complete (in milliseconds)
  timeoutlen = 1000,                        -- time to wait for a mapped sequence to complete (in milliseconds)
  -- undodir = os.getenv("HOME") .. "/.vim/undodir", -- set an undo directory
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
  -- guifont = "monospace:h17",            -- the font used in graphical neovim applications
  -- guifont = { "monospace", ":h17" },       --(For Neovide) the font used in graphical neovim applications
  -- guifont = { "monaspace", ":h17" },       --(For Neovide) the font used in graphical neovim applications
  colorcolumn = "",
  syntax = "enable",                       -- syntax highlighting
  background = "dark",                     -- tell vim what the background color looks like
  breakindent = true,                      -- line-wrapping but keeps wrapped lines on same indentation level
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

-- vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
-- vim.opt.isfname:append("@-@")
-- vim.opt.shortmess:append "c"
-- vim.opt.formatoptions:append({ "r" }) -- Add asterisks in block comments

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Cmd "set whichwrap+=<,>,[,],h,l"
-- Cmd [[set iskeyword+=-]]
-- Cmd [[set formatoptions-=cro]] -- TODO: this doesn't seem to work

-- Basic folding settings
vim.o.foldcolumn             = '1' -- '0' is not bad
vim.o.foldlevel              = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart         = 99
vim.o.foldenable             = true


-- vim.g.icons_enabled = 1

-- vim.g.navic_silence = true

-- triggers CursorHold event faster
-- vim.opt.updatetime = 200


-- shell
vim.opt.shell = vim.fn.executable "pwsh" and "pwsh" or "powershell"
vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""


-- map <leader> to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- vim.g.camelcasemotion_key = "<leader>"
vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true, silent = true })


-- Global variables
-- Define a Map function with default options
-- local function _map(mode, lhs, rhs, opts)
--   opts = opts or {}  -- If opts is nil, set it to an empty table
--   opts.noremap = opts.noremap == nil and true or opts.noremap  -- Set noremap to true if not provided
--   opts.silent = opts.silent == nil and true or opts.silent  -- Set silent to true if not provided
--   vim.keymap.set(mode, lhs, rhs, opts)
-- end

local function _map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    if opts.desc and type(opts.desc) ~= "string" then
      opts.desc = tostring(opts.desc) -- Convert desc to string if it's not already
    end
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

Map = _map
Cmd = vim.cmd



