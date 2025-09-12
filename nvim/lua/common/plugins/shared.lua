-- Common plugins shared between Neovim and VSCode
return {
	-- Treesitter for syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			-- for windows set clang as a compiler
			-- require("nvim-treesitter.install").compilers = { "clang" }
			require("nvim-treesitter.install").compilers = { "zig" }

			-- Configure the autohotkey parser
			-- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
			-- parser_config.autohotkey = {
			-- 	install_info = {
			-- 		url = "c:/Users/hsayed/OneDrive/Desktop/test/tree-sitter-autohotkey/autohotkey.dll",
			-- 		files = { "c:/Users/hsayed/OneDrive/Desktop/test/tree-sitter-autohotkey/src/parser.c" },
			-- 	},
			-- 	filetype = "ahk",
			-- }

			require("nvim-treesitter.configs").setup({
				-- A list of parser names, or "all" (the five listed parsers should always be installed)
				ensure_installed = { "javascript", "typescript", "lua", "luadoc", "markdown", "c_sharp",
					"markdown_inline", "html", "css", "json", "yaml", "scss", "python", "toml" },
				-- "vim", "vimdoc"},
				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,
				-- Automatically install missing parsers when entering buffer
				-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
				auto_install = true,
				highlight = {
					enable = true,
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
				fold = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				refactor = {
					highlight_definitions = { enable = true },
					highlight_current_scope = { enable = false },
					smart_rename = {
						enable = true,
						keymaps = {
							smart_rename = "grr",
						},
					},
					-- navigation = {
					-- 	enable = true,
					-- 	keymaps = {
					-- 		goto_definition = "gnd",
					-- 		list_definitions = "gnD",
					-- 		list_definitions_toc = "gO",
					-- 		goto_next_usage = "<a-*>",
					-- 		goto_previous_usage = "<a-#>",
					-- 	},
					-- },
				},
			})

			-- vim.api.nvim_exec([[
			-- 	set foldmethod=expr
			-- 	set foldexpr=nvim_treesitter#foldexpr()
			-- ]], true)
		end,
		-- for windows follow these to work:
		-- npm install -g tree-sitter-cli
		-- https://github.com/vscode-neovim/vscode-neovim/issues/715
	},
-- Text objects
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		lazy = true,
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,
						include_surrounding_whitespace = false,
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["as"] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
							["is"] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
							["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
							["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
							-- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
							["af"] = { query = "@function.outer", desc = "Select outer part of a method/function definition", },
							["if"] = { query = "@function.inner", desc = "Select inner part of a method/function definition", },
							["ag"] = { query = "@block.outer" },
							["ig"] = { query = "@block.inner" },
							["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
							["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
							["ac"] = { query = "@call.outer", desc = "Select outer part of a function call" },
							["ic"] = { query = "@call.inner", desc = "Select inner part of a function call" },
							["a/"] = { query = "@comment.outer" },
							["i/"] = { query = "@comment.inner" },
							["ar"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
							["ir"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
							["ao"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
							["io"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
							["at"] = { query = "@return.outer" },
							["it"] = { query = "@return.inner" },
							["ax"] = { query = "@class.outer", desc = "Select outer part of a class" },
							["ix"] = { query = "@class.inner", desc = "Select inner part of a class" },

							-- ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
							-- ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
							-- ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
							-- ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["]]f"] = "@function.inner",
							["]]F"] = "@function.outer",
							["]]s"] = "@assignment.inner",
							["]]S"] = "@assignment.outer",
							["]]g"] = "@block.inner",
							["]]G"] = "@block.outer",
							["]]A"] = "@parameter.outer",
							["]]a"] = "@parameter.inner",
							["]]c"] = "@call.inner",
							["]]C"] = "@call.outer",
							["]]/"] = "@comment.inner",
							["]]?"] = "@comment.outer",
							["]]r"] = "@conditional.inner",
							["]]R"] = "@conditional.outer",
							["]]o"] = "@loop.inner",
							["]]O"] = "@loop.outer",
							["]]t"] = "@return.inner",
							["]]T"] = "@return.outer",
							["]]x"] = "@class.inner",
							["]]X"] = "@class.outer",
						},
						swap_previous = {
							["[[f"] = "@function.inner",
							["[[F"] = "@function.outer",
							["[[s"] = "@assignment.inner",
							["[[S"] = "@assignment.outer",
							["[[g"] = "@block.inner",
							["[[G"] = "@block.outer",
							["[[a"] = "@parameter.inner",
							["[[A"] = "@parameter.outer",
							["[[c"] = "@call.inner",
							["[[C"] = "@call.outer",
							["[[/"] = "@comment.inner",
							["[[?"] = "@comment.outer",
							["[[r"] = "@conditional.inner",
							["[[R"] = "@conditional.outer",
							["[[o"] = "@loop.inner",
							["[[O"] = "@loop.outer",
							["[[t"] = "@return.inner",
							["[[T"] = "@return.outer",
							["[[x"] = "@class.inner",
							["[[X"] = "@class.outer",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]f"] = "@function.outer",
							["]s"] = "@assignment.inner",
							["]g"] = "@block.outer",
							["]a"] = "@parameter.outer",
							["]c"] = "@call.outer",
							["]/"] = "@comment.outer",
							["]r"] = "@conditional.outer",
							["]o"] = "@loop.outer",
							["]t"] = "@return.outer",
							["]x"] = "@class.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]S"] = "@assignment.inner",
							["]G"] = "@block.outer",
							["]A"] = "@parameter.outer",
							["]C"] = "@call.outer",
							["]?"] = "@comment.outer",
							["]R"] = "@conditional.outer",
							["]O"] = "@loop.outer",
							["]T"] = "@return.outer",
							["]X"] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[s"] = "@assignment.inner",
							["[g"] = "@block.outer",
							["[a"] = "@parameter.outer",
							["[c"] = "@call.outer",
							["[/"] = "@comment.outer",
							["[r"] = "@conditional.outer",
							["[o"] = "@loop.outer",
							["[t"] = "@return.outer",
							["[x"] = "@class.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[S"] = "@assignment.inner",
							["[G"] = "@block.outer",
							["[A"] = "@parameter.outer",
							["[C"] = "@call.outer",
							["[?"] = "@comment.outer",
							["[R"] = "@conditional.outer",
							["[O"] = "@loop.outer",
							["[T"] = "@return.outer",
							["[X"] = "@class.outer",
						},
					},
				},
			})

			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

			-- vim way: ; goes to the direction you were moving.
			Map({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
			Map({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

			-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
			Map({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
			Map({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F, { expr = true })
			Map({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
			Map({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
		end,
	},
		-- Various text objects
	{
		"chrisgrieser/nvim-various-textobjs",
		-- event = "UIEnter",
		-- opts = { useDefaultKeymaps = true },
		keys = {
			{
				mode = { "o", "x" },
				"ii",
				function()
					require("various-textobjs").indentation("inner", "inner")
				end,
			},
			{
				mode = { "o", "x" },
				"ai",
				function()
					require("various-textobjs").indentation("outer", "inner")
				end,
			},
			{
				mode = { "o", "x" },
				"iI",
				function()
					require("various-textobjs").indentation("inner", "inner")
				end,
			},
			{
				mode = { "o", "x" },
				"aI",
				function()
					require("various-textobjs").indentation("outer", "outer")
				end,
			},
			{
				mode = { "o", "x" },
				"R",
				function()
					require("various-textobjs").restOfIndentation()
				end,
			},
			{
				mode = { "o", "x" },
				"iE",
				function()
					require("various-textobjs").entireBuffer()
				end,
			},
			{
				mode = { "o", "x" },
				".",
				function()
					require("various-textobjs").nearEoL()
				end,
			},
			{
				mode = { "o", "x" },
				"iC",
				function()
					require("various-textobjs").mdFencedCodeBlock("inner")
				end,
			},
			{
				mode = { "o", "x" },
				"aC",
				function()
					require("various-textobjs").mdFencedCodeBlock("outer")
				end,
			},
			-- { mode = { 'o', 'x' }, 'i|', function() require('various-textobjs').shellPipe('inner') end },
			-- { mode = { 'o', 'x' }, 'a|', function() require('various-textobjs').shellPipe('outer') end },
			-- { mode = { 'o', 'x' }, 'ix', function() require('various-textobjs').htmlAttribute(true) end },
			-- { mode = { 'o', 'x' }, 'ax', function() require('various-textobjs').htmlAttribute(false) end },
			{ mode = { "x" }, "im", "viiok" },
			{ mode = { "x" }, "am", "viijok" },
			{ mode = { "x" }, "iM", "viio2k" },
			{ mode = { "x" }, "aM", "viijo2k" },
			{
				mode = { "o" },
				"im",
				function()
					Cmd("normal viiok")
				end,
			},
			{
				mode = { "o" },
				"am",
				function()
					Cmd("normal viijok")
				end,
			},
			{
				mode = { "o" },
				"iM",
				function()
					Cmd("normal viio2k")
				end,
			},
			{
				mode = { "o" },
				"aM",
				function()
					Cmd("normal viijo2k")
				end,
			},
			-- CamelCase
			{
				mode = { "o", "x" },
				"iS",
				function()
					require("various-textobjs").subword("inner")
				end,
			},
			{
				mode = { "o", "x" },
				"aS",
				function()
					require("various-textobjs").subword("outer")
				end,
			},
			-- value of key-value pairs
			{
				mode = { "o", "x" },
				"iv",
				function()
					require("various-textobjs").value("inner")
				end,
			},
			{
				mode = { "o", "x" },
				"av",
				function()
					require("various-textobjs").value("outer")
				end,
			},
			-- key of key-value pairs
			{
				mode = { "o", "x" },
				"ik",
				function()
					require("various-textobjs").key("inner")
				end,
			},
			{
				mode = { "o", "x" },
				"ak",
				function()
					require("various-textobjs").key("outer")
				end,
			},
			-- numbers (conflict with tartgets.vim)
			-- {
			-- 	mode = { "o", "x" },
			-- 	"in",
			-- 	function()
			-- 		require("various-textobjs").number("inner")
			-- 	end,
			-- },
			-- {
			-- 	mode = { "o", "x" },
			-- 	"an",
			-- 	function()
			-- 		require("various-textobjs").number("outer")
			-- 	end,
			-- },
			{
				mode = { "o", "x" },
				"gl",
				function()
					require("various-textobjs").url()
				end,
			},
			-- line (conflict with tartgets.vim)
			-- {
			-- 	mode = { "o", "x" },
			-- 	"il",
			-- 	function()
			-- 		require("various-textobjs").lineCharacterwise("inner")
			-- 	end,
			-- },
			-- {
			-- 	mode = { "o", "x" },
			-- 	"al",
			-- 	function()
			-- 		require("various-textobjs").lineCharacterwise("outer")
			-- 	end,
			-- },

			{
				"gx",
				function()
					-- select URL
					require("various-textobjs").url()

					-- plugin only switches to visual mode when textobj found
					local foundURL = vim.fn.mode():find("v")

					-- if not found, search whole buffer via urlview.nvim instead
					if not foundURL then
						Cmd.UrlView("buffer")
						return
					end

					-- retrieve URL with the z-register as intermediary
					Cmd.normal({ '"' .. THROWAWAY_REGISTER .. "y", bang = true })
					local url = vim.fn.getreg(THROWAWAY_REGISTER)

					-- open with the OS-specific shell command
					local opener
					if vim.fn.has("macunix") == 1 then
						opener = "open"
					elseif vim.fn.has("linux") == 1 then
						opener = "xdg-open"
					elseif vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 then
						opener = "start"
					end
					local openCommand = string.format("%s '%s' >/dev/null 2>&1", opener, url)
					os.execute(openCommand)
				end,
			},
			{
				"dsi",
				function()
					-- select inner indentation
					require("various-textobjs").indentation("inner", "inner")

					-- plugin only switches to visual mode when a textobj has been found
					local notOnIndentedLine = vim.fn.mode():find("V") == nil
					if notOnIndentedLine then
						return
					end

					-- dedent indentation
					Cmd.normal({ "<", bang = true })

					-- delete surrounding lines
					local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1] + 1
					local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
					Cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
					Cmd(tostring(startBorderLn) .. " delete")
				end,
			},
			{ "<Leader>dl", "dil'_dd", { remap = true } },
		},
		opts = {
			lookForwardSmall = 2,
			lookForwardBig = 0,
			useDefaultKeymaps = false,
		},

		-- ## chrisgrieser/nvim-various-textobjs
		-- aI => indent with full block outer
		-- ii => indent with inner
		-- R => restOfIndent (select to bottom)
		-- . => select to before last char
		-- iS => subword inner CamelCase
		-- aS => subword outer CamelCase
		-- iv => inner value of key-value pairs
		-- av => outer value of key-value pairs
		-- ik => inner key of key-value pairs
		-- ak => outer key of key-value pairs
	},
	-- Additional text objects
	{
		"wellle/targets.vim",
		init = function()
			vim.g.targets_nl = "nh"
		end,

		-- addtional texto object keymaps
		-- https://github.com/wellle/targets.vim/blob/master/cheatsheet.md
	},
	-- Commenting
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("Comment").setup({
				-- pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})

			-- Basic Mappings | Comment Keymaps
			-- `gcc` - Toggles the current line using linewise comment
			-- `gbc` - Toggles the current line using blockwise comment
			-- `[count]gcc` - Toggles the number of line given as a prefix-count using linewise
			-- `[count]gbc` - Toggles the number of line given as a prefix-count using blockwise
			-- `gc[count]{motion}` - (Op-pending) Toggles the region using linewise comment
			-- `gb[count]{motion}` - (Op-pending) Toggles the region using blockwise comment
		end,
	},
	{
		'vscode-neovim/vscode-multi-cursor.nvim',
		event = 'VeryLazy',
		opts = {},
		config = function()
			-- vscode-multi-cursor
			vim.api.nvim_set_hl(0, 'VSCodeCursor', {
				bg = '#542fa4',
				fg = 'white',
				default = true
			})

			vim.api.nvim_set_hl(0, 'VSCodeCursorRange', {
				bg = '#542fa4',
				fg = 'white',
				default = true
			})

			local cursors = require('vscode-multi-cursor')
			Map({ 'n', 'x', 'i' }, '<cs-,>', function()
				cursors.addSelectionToNextFindMatch()
			end)
			Map({ 'n', 'x', 'i' }, '<cs-.>', function()
				cursors.addSelectionToPreviousFindMatch()
			end)
			Map({ 'n', 'x', 'i' }, '<cs-m>', function()
				cursors.selectHighlights()
			end)
			-- Map('n', "<cs-m>", 'mciw*:nohl<cr>')
			-- Map('n', "<cs-n>", 'mciw*:nohl<cr>', {
			-- 	remap = true
			-- })
		end,
		-- Keymaps
		-- k({ 'n', 'x' }, 'mc', cursors.create_cursor, { expr = true, desc = 'Create cursor' })
		-- k({ 'n' }, 'mcc', cursors.cancel, { desc = 'Cancel/Clear all cursors' })
		-- k({ 'n', 'x' }, 'mi', cursors.start_left, { desc = 'Start cursors on the left' })
		-- k({ 'n', 'x' }, 'mI', cursors.start_left_edge, { desc = 'Start cursors on the left edge' })
		-- k({ 'n', 'x' }, 'ma', cursors.start_right, { desc = 'Start cursors on the right' })
		-- k({ 'n', 'x' }, 'mA', cursors.start_right, { desc = 'Start cursors on the right' })
		-- k({ 'n' }, '[mc', cursors.prev_cursor, { desc = 'Goto prev cursor' })
		-- k({ 'n' }, ']mc', cursors.next_cursor, { desc = 'Goto next cursor' })
		-- k({ 'n' }, 'mcs', cursors.flash_char, { desc = 'Create cursor using flash' })
		-- k({ 'n' }, 'mcw', cursors.flash_word, { desc = 'Create selection using flash' })
	},
	-- Surround text
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			-- Surround Keymaps
			-- works with tags, brackets, quotes, stars, etc.
			--
			-- Shortcuts:
			--
			-- cs: change surround
			--      cs"'  -> "hello" to 'hello'
			--      cs"<q> -> "hello" to <q>hello</q>
			--      csth1 -> "hello" to <h1>hello</h1>
			--
			-- ds: delete surround
			--      ds"   -> "hello" to hello
			--      dsth1 -> <h1>hello</h1> to hello
			--      dsb   -> (hello) to hello
			--      dsf   -> foo(hello) to foo
			--
			-- ys: add surround
			--      ysiw" -> hello to "hello"
			--      yss"  -> hello to "hello"
			--      yss)  -> hello to (hello)
			--      yssb  -> hello to { hello }

			require("nvim-surround").setup({})
		end,
	},
	-- Increment/decrement plugin - works in both environments
	{
		"nat-418/boole.nvim",
		config = function()
			require("boole").setup({
				mappings = {
					increment = "<C-a>",
					decrement = "<C-x>",
				},
				additions = {
					{ "enable", "disable" },
					{ "true", "false" },
					{ "yes", "no" },
					{ "on", "off" },
					{ "left", "right" },
					{ "up", "down" },
					{ "before", "after" },
					{ "first", "last" },
					{ "start", "end" },
					{ "primary", "secondary" },
				},
				allow_caps_additions = {
					{ "enable", "disable" },
					{ "True", "False" },
					{ "YES", "NO" },
					{ "ON", "OFF" },
				},
			})
		end,
	},

	-- Multiple cursors - works in both environments
	{
		"mg979/vim-visual-multi",
		keys = {
			{ "<C-n>", mode = { "n", "v" }, desc = "Multi cursor" },
			{ "<C-Down>", mode = { "n", "v" }, desc = "Multi cursor down" },
			{ "<C-Up>", mode = { "n", "v" }, desc = "Multi cursor up" },
		},
	},

	-- Enhanced vim repeat - works in both environments
	{
		"tpope/vim-repeat",
		event = "VeryLazy",
	},

--[[ 	-- Indentation
	{
		-- Auto indentation
		{
			"vidocqh/auto-indent.nvim",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			opts = {
				-- (Optional) Set the indentexpr function to get the current line's indentation
				indentexpr = function(lnum)
					return require("nvim-treesitter.indent").get_indent(lnum)
				end,
			},
			-- enabled = not vim.g.vscode
		},
		-- Indentation guessing
		{
			"NMAC427/guess-indent.nvim",
			cmd = "GuessIndent",
			opts = {
				auto_cmd = true,
				buftype_exclude = {
					"help",
					"nofile",
					"terminal",
					"prompt",
				},
			},
			-- enabled = not vim.g.vscode
		},
		-- Automatic indentation detection
		{
			"tpope/vim-sleuth",
			enabled = true
		},
	}, ]]

	-- Dial (increment/decrement) - Enhanced increment/decrement functionality
	{
		"monaqa/dial.nvim",
		keys = {
			"<C-a>",
			"<C-x>",
			"g<C-a>",
			"g<C-x>",
			"<Leader>d;",
			{ mode = "x", "<C-a>" },
			{ mode = "x", "<C-x>" },
			{ mode = "x", "g<C-a>" },
			{ mode = "x", "g<C-x>" },
			{ mode = "x", "<Leader>d;" },
		},
		config = function()
			local augend = require("dial.augend")
			require("dial.config").augends:register_group({
				default = {
					augend.integer.alias.decimal_int,
					augend.hexcolor.new({ case = "upper" }),
					augend.semver.alias.semver,
					augend.date.new({
						pattern = "%y/%m/%d",
						default_kind = "day",
						only_valid = true,
					}),
					augend.date.alias["%H:%M"],
					augend.date.new({ pattern = "%B", default_kind = "day" }),
					augend.constant.new({
						elements = { "january", "february", "march", "april", "may", "june",
							"july", "august", "september", "october", "november", "december" },
						word = true, cyclic = true,
					}),
					augend.constant.new({
						elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
						word = true, cyclic = true,
					}),
					augend.constant.new({
						elements = { "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday" },
						word = true, cyclic = true,
					}),
				},
				toggles = {
					augend.constant.alias.bool,
					augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
					augend.constant.new({ elements = { "AND", "OR" }, word = true, cyclic = true }),
					augend.constant.new({ elements = { "&&", "||" }, word = false, cyclic = true }),
					augend.constant.new({ elements = { "yes", "no" }, word = true, cyclic = true }),
				},
				visual = {
					augend.integer.alias.decimal_int,
					augend.integer.alias.hex,
					augend.integer.alias.octal,
					augend.constant.alias.alpha,
					augend.constant.alias.Alpha,
				},
			})

			-- Keymaps
			Map("n", "<C-a>", function() require("dial.map").manipulate("increment", "normal") end)
			Map("n", "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end)
			Map("n", "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end)
			Map("n", "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end)
			Map("x", "<C-a>", require("dial.map").inc_visual("visual"))
			Map("x", "<C-x>", require("dial.map").dec_visual("visual"))
			Map("x", "g<C-a>", require("dial.map").inc_gvisual("visual"))
			Map("x", "g<C-x>", require("dial.map").dec_visual("visual"))
			Map("n", "<Leader>d;", require("dial.map").inc_normal("toggles"))
			Map("x", "<Leader>d;", require("dial.map").inc_visual("toggles"))
		end,
	},

	-- Text alignment
	{
		"junegunn/vim-easy-align",
		keys = {
			{ mode = "", "ga", "<Plug>(EasyAlign)" },
		},

		-- such as <Space>, =, :, ., |, &, #, and ,
		-- = Around the 1st occurrences
		-- 2= Around the 2nd occurrences
		-- *= Around all occurrences
		-- **= Left/Right alternating alignment around all occurrences
		-- <Enter> Switching between left/right/center alignment modes
	},

	-- Repeat plugin commands
	{
		"tpope/vim-repeat",
	},
	-- Remember cursor position
	{
		"farmergreg/vim-lastplace",
	},
	-- CamelCase motion - works in both environments
	{
		"bkad/CamelCaseMotion",
		init = function()
			vim.g.camelcasemotion_key = ""
		end,
		config = function()
			local modes = { "n", "o", "x" }
			-- Map motions (w/e/b/ge) to camelCase navigation
			Map(modes, "w", "<Plug>CamelCaseMotion_w", { desc = "CamelCase forward" })
			Map(modes, "b", "<Plug>CamelCaseMotion_b", { desc = "CamelCase backward" })
			Map(modes, "e", "<Plug>CamelCaseMotion_e", { desc = "CamelCase end" })
			Map(modes, "ge", "<Plug>CamelCaseMotion_ge", { desc = "CamelCase prev end" })

			-- Map text objects for camelCase
			Map({ "o", "x" }, "iw", "<Plug>CamelCaseMotion_iw", { desc = "Inner camelCase word" })
			Map({ "o", "x" }, "ib", "<Plug>CamelCaseMotion_ib", { desc = "Inner camelCase block" })
			Map({ "o", "x" }, "ie", "<Plug>CamelCaseMotion_ie", { desc = "Inner camelCase end" })

			-- Custom shortcuts
			Map("n", "vw", "v<Plug>CamelCaseMotion_ib", { desc = "Visual camelCase word" })
			Map("n", "dw", 'd<Plug>CamelCaseMotion_ib', { desc = "Delete camelCase word" })
			Map("n", "cw", '"_c<Plug>CamelCaseMotion_ib', { desc = "Change camelCase word" })
			Map("n", "yw", 'y<Plug>CamelCaseMotion_ib', { desc = "Yank camelCase word" })
			-- For entire word
			Map("n", "vW", "viw", { desc = "Select current word" })
			Map("n", "dW", 'diw', { desc = "Delete word" })
			Map("n", "cW", '"_ciw', { desc = "Change word" })
			Map("n", "yW", 'yiw', { desc = "Yank word" })
		end
	},

	-- Highlighting current word - works in both environments
	{
		"RRethy/vim-illuminate",
	},
	-- Split and join code blocks
	{
		"Wansmer/treesj",
		-- keys = {
		-- 	{ '<Leader>dj', function() require('treesj').join() end },
		-- 	{ '<Leader>dk', function() require('treesj').split() end },
		-- 	{ '<Leader>dJ', function() require('treesj').join({ split = { recursive = true } }) end },
		-- 	{ '<Leader>dK', function() require('treesj').split({ split = { recursive = true } }) end },
		-- },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"AndrewRadev/splitjoin.vim",
		},
		config = function()
			require("treesj").setup({
				use_default_keymaps = false,
			})

			local langs = require("treesj.langs")["presets"]

			vim.api.nvim_create_autocmd({ "FileType" }, {
				pattern = "*",
				callback = function()
					-- Join and split Keymaps
					local opts = { buffer = true }
					if langs[vim.bo.filetype] then
						Map("n", "gS", "<Cmd>TSJSplit<CR>", opts)
						Map("n", "gJ", "<Cmd>TSJJoin<CR>", opts)
					else
						Map("n", "gS", "<Cmd>SplitjoinSplit<CR>", opts)
						Map("n", "gJ", "<Cmd>SplitjoinJoin<CR>", opts)
					end
				end,
			})
		end,
   },
	-- Flash Motion plugin
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		-- stylua: ignore
		-- Flash Keymaps
		keys = {
			{ "<leader>fs", mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "<leader>ff", mode = { "n", "x", "o" },
			function()
				require("flash").jump({
					search = {
						mode = function(str)
							return "\\<" .. str
						end,
					},
				})
			end, desc = "Match beginning of words only" },
			{ "<leader>ft", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "<leader>fr", mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "<leader>fT", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			-- { "<c-s>",      mode = { "c" }, function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
			-- f => flash search char forward before cursor (f, F to move between results)
			-- F => flash search char backward after cursor (f, F to move between results)
			-- t => flash search char forward before cursor (t, T to move between results)
			-- T => flash search char backward after cursor (t, T to move between results)
			-- ; => repeat last flash search
			-- , => repeat last flash search in opposite direction



		},
		config = function()
			-- flash
			vim.api.nvim_set_hl(0, 'FlashLabel', {
				bg = '#e11684',
				fg = 'white'
			})

			vim.api.nvim_set_hl(0, 'FlashMatch', {
				bg = '#7c634c',
				fg = 'white'
			})

			vim.api.nvim_set_hl(0, 'FlashCurrent', {
				bg = '#7c634c',
				fg = 'white'
			})

			require("flash").setup({
				modes = {
					-- options used when flash is activated through
					-- a regular search with `/` or `?`
					search = {
						-- when `true`, flash will be activated during regular search by default.
						-- You can always toggle when searching with `require("flash").toggle()`
						enabled = true,
						highlight = { backdrop = false },
						jump = { history = true, register = true, nohlsearch = true },
						search = {
							-- `forward` will be used in flash.jump, `backward` in flash.treesitter_search
							mode = "search",
							max_length = false,
							multi_window = true,
							wrap = true,
							incremental = false,
						},
					},
				},
			})
		end,
	},
}
