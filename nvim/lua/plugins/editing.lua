return {
	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = { "InsertEnter" },
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
		config = function()
			-- import nvim-autopairs
			local autopairs = require("nvim-autopairs")

			-- configure autopairs
			autopairs.setup({
				check_ts = true,                 -- enable treesitter
				ts_config = {
					lua = { "string" },            -- don't add pairs in lua string treesitter nodes
					javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
					java = false,                  -- don't check treesitter on java
				},
			})

			-- import nvim-autopairs completion functionality
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")

			-- import nvim-cmp plugin (completions plugin)
			local cmp = require("cmp")

			-- make autopairs and completion work together
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
		enabled = not vim.g.vscode
	},
	-- Increment/decrement
	{
		{
			"nat-418/boole.nvim",
			config = function()
				require("boole").setup({
					mappings = {
						increment = "<C-a>",
						decrement = "<C-x>",
					},
					-- User defined loops
					additions = {
						{ "Foo", "Bar" },
						{ "tic", "tac", "toe" },
					},
					allow_caps_additions = {
						{ "enable", "disable" },
					},
				})
			end,
		},
		-- Dial (increment/decrement)
		{
			"monaqa/dial.nvim",
			keys = {
				"<C-a>",
				"<C-x>",
				"g<C-a>",
				"g<C-x>",
				"<Leader>d;",
				{
					mode = "x",
					"<C-a>",
				},
				{
					mode = "x",
					"<C-x>",
				},
				{
					mode = "x",
					"g<C-a>",
				},
				{
					mode = "x",
					"g<C-x>",
				},
				{
					mode = "x",
					"<Leader>d;",
				},
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
						augend.date.new({
							pattern = "%B", -- titlecased month names
							default_kind = "day",
						}),
						augend.constant.new({
							elements = {
								"january",
								"february",
								"march",
								"april",
								"may",
								"june",
								"july",
								"august",
								"september",
								"october",
								"november",
								"december",
							},
							word = true,
							cyclic = true,
						}),
						augend.constant.new({
							elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
							word = true,
							cyclic = true,
						}),
						augend.constant.new({
							elements = { "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday" },
							word = true,
							cyclic = true,
						}),
					},
					toggles = {
						augend.constant.alias.bool,
						augend.constant.new({
							elements = { "and", "or" },
							word = true, -- if false, 'sand' is incremented into 'sor', 'doctor' into 'doctand', etc.
							cyclic = true,
						}),
						augend.constant.new({
							elements = { "AND", "OR" },
							word = true,
							cyclic = true,
						}),
						augend.constant.new({
							elements = { "&&", "||" },
							word = false,
							cyclic = true,
						}),
						augend.constant.new({
							elements = { "yes", "no" },
							word = true,
							cyclic = true,
						}),
					},
					visual = {
						augend.integer.alias.decimal_int,
						augend.integer.alias.hex,
						augend.integer.alias.octal,
						augend.constant.alias.alpha,
						augend.constant.alias.Alpha,
					},
				})

				-- Increment Keymaps
				Map("n", "<C-a>", function()
					require("dial.map").manipulate("increment", "normal")
				end)
				Map("n", "<C-x>", function()
					require("dial.map").manipulate("decrement", "normal")
				end)
				Map("n", "g<C-a>", function()
					require("dial.map").manipulate("increment", "gnormal")
				end)
				Map("n", "g<C-x>", function()
					require("dial.map").manipulate("decrement", "gnormal")
				end)

				Map("x", "<C-a>", require("dial.map").inc_visual("visual"))
				Map("x", "<C-x>", require("dial.map").dec_visual("visual"))
				Map("x", "g<C-a>", require("dial.map").inc_gvisual("visual"))
				Map("x", "g<C-x>", require("dial.map").dec_visual("visual"))

				Map("n", "<Leader>d;", require("dial.map").inc_normal("toggles"))
				Map("x", "<Leader>d;", require("dial.map").inc_visual("toggles"))
			end,
		},
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
	-- Escape key enhancement
	{
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup({
				keys = function()
					vim.api.nvim_input("<Esc>")
					local current_line = vim.api.nvim_get_current_line()
					if current_line:match("^%s+j$") then
						vim.schedule(function()
							vim.api.nvim_set_current_line("")
						end)
					end
				end,
				timeout = vim.o.timeoutlen, -- Keeps using timeoutlen for timing
			})
		end,
		enabled = not vim.g.vscode
	},
	-- Indentation
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
	},
	-- Formating
	{
		"mhartington/formatter.nvim",
		config = function()
			-- Utilities for creating configurations
			local util = require("formatter.util")

			-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
			require("formatter").setup({
				-- Enable or disable logging
				logging = true,
				-- Set the log level
				log_level = vim.log.levels.WARN,
				-- All formatter configurations are opt-in
				filetype = {
					-- Formatter configurations for filetype "lua" go here
					-- and will be executed in order
					lua = {
						-- "formatter.filetypes.lua" defines default configurations for the
						-- "lua" filetype
						require("formatter.filetypes.lua").stylua,

						-- You can also define your own configuration
						function()
							-- -- Supports conditional formatting
							-- if util.get_current_buffer_file_name() == "special.lua" then
							--   return nil
							-- end

							-- Full specification of configurations is down below and in Vim help
							-- files
							return {
								exe = "stylua",
								args = {
									"--search-parent-directories",
									"--stdin-filepath",
									util.escape_path(util.get_current_buffer_file_path()),
									"--",
									"-",
								},
								stdin = true,
							}
						end,
					},

					-- Use the special "*" filetype for defining formatter configurations on
					-- any filetype
					["*"] = {
						-- "formatter.filetypes.any" defines default configurations for any
						-- filetype
						require("formatter.filetypes.any").remove_trailing_whitespace,
					},
				},
			})

			Map("n", "<leader>ff", "<cmd>Format<CR>")
		end,
		enabled = false,
	},
	-- Conformance and formatting
	{
		"stevearc/conform.nvim",
		-- event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("conform").setup({
				notify_on_error = false,

				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					svelte = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					graphql = { "prettier" },
					lua = { "stylua" },
					python = { "isort", "black" },
					csharp = { "csharpier" },
				},
			})

			-- format shortcut
			-- Map("n", "<leader>ff", "<cmd>lua require('conform').format()<CR>", { desc = "Format with Conform" })
			Map({ "n", "v" }, "<leader>rr", function()
				require("conform").format({
					lrr_fallback = true,
					async = false,
					timeout_ms = 500,
				})
			end, { desc = "Format file or range (in visual mode)" })
		end,
		enabled = not vim.g.vscode
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
	-- CamelCase motion
	{
		"bkad/CamelCaseMotion",
		init = function()
			-- Bind directly to w/e/b (no prefix)
			vim.g.camelcasemotion_key = ""
		end,
		config = function()
			local modes = { "n", "o", "x" }
			-- Map motions (w/e/b/ge) to camelCase navigation
			-- [CamelCase motions]
			Map(modes, "w", "<Plug>CamelCaseMotion_w", { desc = "CamelCase forward" })
			Map(modes, "b", "<Plug>CamelCaseMotion_b", { desc = "CamelCase backward" })
			Map(modes, "e", "<Plug>CamelCaseMotion_e", { desc = "CamelCase end" })
			Map(modes, "ge", "<Plug>CamelCaseMotion_ge", { desc = "CamelCase prev end" })

			-- Map text objects (iw/ib/ie) for camelCase
			-- [CamelCase text object motions]
			Map({ "o", "x" }, "iw", "<Plug>CamelCaseMotion_iw", { desc = "Inner camelCase word" })
			Map({ "o", "x" }, "ib", "<Plug>CamelCaseMotion_ib", { desc = "Inner camelCase block" })
			Map({ "o", "x" }, "ie", "<Plug>CamelCaseMotion_ie", { desc = "Inner camelCase end" })

			-- [Custom Shortcuts]
			-- for camelcase
			Map("n", "vw", "v<Plug>CamelCaseMotion_ib", { desc = "Visual camelCase word" })
			Map("n", "dw", 'd<Plug>CamelCaseMotion_ib', { desc = "Delete camelCase word" })
			Map("n", "cw", '"_c<Plug>CamelCaseMotion_ib', { desc = "Change camelCase word" })
			Map("n", "yw", 'y<Plug>CamelCaseMotion_ib', { desc = "Yank camelCase word" })
			-- for entire word
			Map("n", "vW", "viw") -- Select the current word
			Map("n", "dW", 'diw') -- Delete a word
			Map("n", "cW", '"_ciw') -- Change a word
			Map("n", "yW", 'yiw') -- Yank a word
		end
	},
	-- Window maximizer
	{
		"szw/vim-maximizer",
		-- Window Maximizer Keymaps
		keys = {
			{ "<leader>sm", "<cmd>MaximizerToggle<CR>", desc = "Maximize/minimize a split" },
		},
		enabled = not vim.g.vscode
	},
	-- Tmux navigation
	{
		"christoomey/vim-tmux-navigator",
		config = function() end,
		enabled = not vim.g.vscode
	},
	-- Highlighting other uses of the current word
	{
		"RRethy/vim-illuminate",
	},
	-- Key binding hints
	{
		"folke/which-key.nvim",
		event = "BufRead",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 1000
			require("which-key").setup({})
		end,
		enabled = not vim.g.vscode
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
	-- Smart window splits
	{
		"mrjones2014/smart-splits.nvim",
		config = function()
			-- Smart Splits Keymaps
			-- recommended mappings
			-- resizing splits
			-- these keymaps will also accept a range,
			-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
			Map("n", "<A-h>", require("smart-splits").resize_left)
			Map("n", "<A-j>", require("smart-splits").resize_down)
			Map("n", "<A-k>", require("smart-splits").resize_up)
			Map("n", "<A-l>", require("smart-splits").resize_right)
			-- moving between splits
			Map("n", "<C-h>", require("smart-splits").move_cursor_left)
			Map("n", "<C-j>", require("smart-splits").move_cursor_down)
			Map("n", "<C-k>", require("smart-splits").move_cursor_up)
			Map("n", "<C-l>", require("smart-splits").move_cursor_right)
			Map("n", "<C-\\>", require("smart-splits").move_cursor_previous)
			-- swapping buffers between windows
			Map("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
			Map("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
			Map("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
			Map("n", "<leader><leader>l", require("smart-splits").swap_buf_right)
		end,
		enabled = not vim.g.vscode
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
			Map({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
			Map({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
			Map({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
		end,
		-- enabled = not vim.g.vscode
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
	-- Text objects for quotes
	-- {
	-- 	"beloglazov/vim-textobj-quotes",
	-- 	dependencies = {
	-- 		"kana/vim-textobj-user",
	-- 	},
	-- 	enabled = not vim.g.vscode
	-- },
	-- Multiple cursors
	{
		"mg979/vim-visual-multi",
		-- event = "BufRead",
		branch = "master",
		enabled = not vim.g.vscode
		-- init = function ()
		--   vim.g.VM_default_mappings = 0
		--   vim.g.VM_maps = {
		--     ['Find Under'] = ''
		--   }
		--   vim.g.VM_add_cursor_at_pos_no_mappings = 1
		-- end
		-- Keymaps
		-- select words with Ctrl-N (like Ctrl-d in Sublime Text/VS Code)
		-- create cursors vertically with Ctrl-Down/Ctrl-Up
		-- select one character at a time with Shift-Arrows
		-- press n/N to get next/previous occurrence
		-- press [/] to select next/previous cursor
		-- press q to skip current and get next occurrence
		-- press Q to remove current cursor/selection
		-- start insert mode with i,a,I,A
	},
	{
		'vscode-neovim/vscode-multi-cursor.nvim',
		event = 'VeryLazy',
		cond = not not vim.g.vscode,
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
	-- Repeat plugin commands
	{
		"tpope/vim-repeat",
	},
	-- Extended matching
	{
		"adelarsq/vim-matchit",
		enabled = not vim.g.vscode -- fix vscode neovim repeat text
	},
	{
		"andymass/vim-matchup",
		config = function()
			-- may set any options here
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
		enabled = not vim.g.vscode -- fix vscode neovim repeat text
	},
	-- Remember cursor position
	{
		"farmergreg/vim-lastplace",
	},
	-- Replace with register
	{
		"vim-scripts/ReplaceWithRegister",
		keys = {
			{ "grr", "<Plug>ReplaceWithRegisterLine" },
		},
		enabled = false
	},
	-- Undo history visualizer
	{
		"mbbill/undotree",
		event = "BufRead",
		config = function()
			-- UndoTree Keymaps
			Map("n", "<leader>u", Cmd.UndotreeToggle)
			-- Map("n", "<leader>t", "<cmd>lua require('undotree').toggle()<CR>")
		end,
		enabled = not vim.g.vscode
	},
	-- Substitution plugin
	{
		"gbprod/substitute.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local substitute = require("substitute")

			substitute.setup()
			-- Substitute Keymaps
			Map("n", "s", substitute.operator, { desc = "Substitute with motion" })
			Map("n", "ss", substitute.line, { desc = "Substitute line" })
			Map("n", "S", substitute.eol, { desc = "Substitute to end of line" })
			Map("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
		end,
		-- enabled = not vim.g.vscode
	},
	-- Find and replace
	{
		-- NOTE: install sed and ripgrep for this to work
		"nvim-pack/nvim-spectre",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local spectre = require("spectre")
			-- Find and Replace Keymaps
			-- Map("n", "<leader>S", ":Spectre<CR>", { desc = "Toggle global find and replace" })
			Map(
				"n",
				"<leader>S",
				'<cmd>lua require("spectre").toggle()<CR>',
				{ desc = "Toggle global find and replace" }
			)
			Map(
				"n",
				"<leader>sp",
				'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
				{ desc = "Search on current file" }
			)
			-- For Other using key ? for more help
			-- <leader>R => Replace all
			-- <leader>rc => Replace current
		end,
		enabled = not vim.g.vscode
	},
	-- Folding enhancement
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			-- Tell the server the capability of foldingRange,
			-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
			for _, ls in ipairs(language_servers) do
				require("lspconfig")[ls].setup({
					capabilities = capabilities,
					-- you can add other fields for setting up lsp server in this table
				})
			end

			-- Function to toggle folding of methods
			local function toggle_folds()
				local parsers = require("nvim-treesitter.parsers")
				local query = require("nvim-treesitter.query")

				-- Check if the Python parser is available
				-- if parsers.has_parser "python" then
				-- Define the Treesitter query to capture method declarations
				local method_query = [[
            [
              (method_declaration)
            ] @fold
          ]]

				local bufnr = vim.api.nvim_get_current_buf()
				local parser = parsers.get_parser(bufnr)

				if not parser then
					print("Treesitter parser not found for buffer")
					return
				end

				local root = parser:parse()[1]:root()
				-- local matches = query.get_capture_matches(root, method_query, bufnr, 0, -1)
				local matches = query.get_capture_matches_recursively(bufnr, function(lang)
					if query.has_folds(lang) then
						return "@fold", "folds"
					elseif query.has_locals(lang) then
						return "@scope", "locals"
					end
				end)

				for _, match in ipairs(matches) do
					print(match)
					local start_row, _, end_row, _ = match.node:range()
					local current_fold_level = vim.fn.foldlevel(start_row + 1)
					-- Calculate the correct fold command based on current fold state
					local fold_cmd
					if current_fold_level > 0 then
						fold_cmd = string.format("%d,%dfoldopen", start_row + 1, end_row)
					else
						fold_cmd = string.format("%d,%dfoldclose", start_row + 1, end_row)
					end

					-- Execute the fold command
					vim.cmd(fold_cmd)
				end
				-- end
			end

			-- Keymap for toggling folding
			-- Map('n', '<leader>tf', toggle_folds)

			local ufo = require("ufo")
			-- ufo.setup()
			ufo.setup({
				provider_selector = function(bufnr, filetype, buftype)
					-- return {'lsp', 'treesitter', 'indent'}
					return { "treesitter", "indent" }
				end,
			})

			-- Folding Keymaps
			Map("n", "zR", ufo.openAllFolds)
			Map("n", "zM", ufo.closeAllFolds)
			Map("n", "zr", ufo.openFoldsExceptKinds)
			Map("n", "zm", ufo.closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
			Map("n", "z1", function()
				ufo.closeFoldsWith(1)
			end)
			Map("n", "z2", function()
				ufo.closeFoldsWith(2)
			end)
			Map("n", "z3", function()
				ufo.closeFoldsWith(3)
			end)
			Map("n", "z4", function()
				ufo.closeFoldsWith(4)
			end)
			Map("n", "z5", function()
				ufo.closeFoldsWith(5)
			end)
			Map("n", "z6", function()
				ufo.closeFoldsWith(6)
			end)

			Map("n", "zK", function()
				local winid = ufo.peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end)

			-- zA => toggle fold all
			-- za => toggle fold
			-- zc => close fold sequentially
			-- zo => open fold sequentially
		end,
		enabled = not vim.g.vscode
	},
	-- Motion plugin
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		-- stylua: ignore
		-- Flash Keymaps
		keys = {
			{ "<leader>fs", mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
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
		end,
	},
	-- EasyClip
	-- {
	-- 	-- After copying a visual selection, return to original location
	-- 	'svermeulen/vim-easyclip',
	-- 	init = function()
	-- 		-- Disable all mappings; we'll opt-in manually
	-- 		vim.g.EasyClipUseSubstituteMappings = 1
	-- 		vim.g.EasyClipUseCutDefaults = 1
	-- 		vim.g.EasyClipUsePasteDefaults = 1
	-- 		vim.g.EasyClipUseEmacsDefaults = 0
	-- 		vim.g.EasyClipPreserveCursorPositionAfterYank = 1
	-- 	end,
	-- 	event = "VeryLazy"
	-- }

}
