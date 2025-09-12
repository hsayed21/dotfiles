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

	-- Text case conversion - nvim only (requires telescope)
	{
		"johmsalas/text-case.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("textcase").setup({})
		end,
		keys = {
			{ "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "v" }, desc = "Telescope text case" },
		},
		enabled = not vim.g.vscode
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
	-- Text objects for quotes
	-- {
	-- 	"beloglazov/vim-textobj-quotes",
	-- 	dependencies = {
	-- 		"kana/vim-textobj-user",
	-- 	},
	-- 	enabled = not vim.g.vscode
	-- },
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

			substitute.setup({
				modifiers = function(state)
					local mods = {}
					-- Always reindent for linewise operations
					if state.vmode == 'line' then
						table.insert(mods, 'reindent')
					end

					-- Trim whitespace for characterwise operations
					if state.vmode == 'char' then
						table.insert(mods, 'trim')
					end

					return mods
				end,
			})

			-- Smart substitute functions with conditional modifiers
			local function smart_substitute_operator()
				return require('substitute').operator({
					modifiers = function(state)
						local mods = {}
						if state.vmode == 'line' then
							table.insert(mods, 'reindent')
						elseif state.vmode == 'char' then
							table.insert(mods, 'trim')
						end
						return mods
					end
				})
			end

			local function smart_substitute_line()
				return require('substitute').line({
					modifiers = { 'reindent' }
				})
			end

			local function smart_substitute_eol()
				return require('substitute').eol({
					modifiers = { 'trim' }
				})
			end

			local function smart_substitute_visual()
				return require('substitute').visual({
					modifiers = function(state)
						local mods = {}
						if state.vmode == 'line' then
							table.insert(mods, 'reindent')
						elseif state.vmode == 'char' then
							table.insert(mods, 'trim')
						end
						return mods
					end
				})
			end
			-- Basic substitute keymaps with smart modifiers
			vim.keymap.set("n", "s", smart_substitute_operator, { noremap = true, desc = "Smart substitute with motion" })
			vim.keymap.set("n", "ss", smart_substitute_line, { noremap = true, desc = "Smart substitute line (reindent)" })
			vim.keymap.set("n", "S", smart_substitute_eol, { noremap = true, desc = "Smart substitute to EOL (trim)" })
			vim.keymap.set("x", "s", smart_substitute_visual, { noremap = true, desc = "Smart substitute in visual mode" })
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
