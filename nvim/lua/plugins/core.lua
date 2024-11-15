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
				ensure_installed = { "javascript", "typescript", "lua", "diff", "luadoc", "markdown", "latex", "query", "c_sharp",
					"markdown_inline", "html", "css", "json", "yaml", "regex", "yaml", "python", "toml" },
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
		-- enabled = not vim.g.vscode
		-- for windows follow these to work:
		-- npm install -g tree-sitter-cli
		-- https://github.com/vscode-neovim/vscode-neovim/issues/715
	},
	-- LSP configurations
	{
		"neovim/nvim-lspconfig",
		-- lazy = true,
		-- event = { "VeryLazy" },
		dependencies = {
			{
				-- Package Manager for LSP
				"williamboman/mason.nvim",
				config = function()
				require("mason").setup({
						ui = {
							icons = {
								package_installed = "✓",
								package_pending = "➜",
								package_uninstalled = "✗"
							}
						}
					})
				end,
			},
			{
				-- mason-lspconfig bridges mason.nvim with the nvim-lspconfig plugin
				"williamboman/mason-lspconfig.nvim",
			},
			{
				"hrsh7th/cmp-nvim-lsp",
			},
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
			},
			{
				-- for showing lsp load progress
				"j-hui/fidget.nvim",
				-- tag = "v1.0.0",
				tag = "legacy",
				event = "BufRead",
				config = function()
					require("fidget").setup({})
				end,
			},
			{
				"antosha417/nvim-lsp-file-operations",
				config = true,
				-- config = function()
				-- 	require("lsp-file-operations").setup()
				-- end,
			},
			{
				"folke/neodev.nvim",
				opts = {}
			},
			{
				"ray-x/lsp_signature.nvim",
				event = "VeryLazy",
				opts = {},
				config = function(_, opts) require'lsp_signature'.setup(opts) end
			},
			{
				"nvimdev/lspsaga.nvim",
				-- lazy = true,
				event = { "LspAttach" },
				dependencies = {
					-- "neovim/nvim-lspconfig",
					"nvim-treesitter/nvim-treesitter",
				},
			},
			{
				'linrongbin16/lsp-progress.nvim',
			}
		},
		config = function()
			-- import lspconfig plugin
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({})
			lspconfig.tsserver.setup({})
			lspconfig.html.setup({})
			lspconfig.cssls.setup({})
			lspconfig.csharp_ls.setup({})
			lspconfig.pyright.setup({})


			require('lsp-progress').setup()


			-- require("barbecue").setup({
			-- 	attach_navic = true, -- prevent barbecue from automatically attaching nvim-navic
			-- 	create_autocmd = false, -- prevent barbecue from updating itself automatically
			-- 	theme = {
			-- 		-- this highlight is used to override other highlights
			-- 		-- you can take advantage of its `bg` and set a background throughout your winbar
			-- 		-- (e.g. basename will look like this: { fg = "#c0caf5", bold = true })
			-- 		normal = { fg = "#c0caf5" },

			-- 		-- these highlights correspond to symbols table from config
			-- 		ellipsis = { fg = "#737aa2" },
			-- 		separator = { fg = "#737aa2" },
			-- 		modified = { fg = "#737aa2" },

			-- 		-- these highlights represent the _text_ of three main parts of barbecue
			-- 		dirname = { fg = "#737aa2" },
			-- 		basename = { bold = true },
			-- 		context = {},

			-- 		-- these highlights are used for context/navic icons
			-- 		context_file = { fg = "#ac8fe4" },
			-- 		context_module = { fg = "#ac8fe4" },
			-- 		context_namespace = { fg = "#ac8fe4" },
			-- 		context_package = { fg = "#ac8fe4" },
			-- 		context_class = { fg = "#ac8fe4" },
			-- 		context_method = { fg = "#ac8fe4" },
			-- 		context_property = { fg = "#ac8fe4" },
			-- 		context_field = { fg = "#ac8fe4" },
			-- 		context_constructor = { fg = "#ac8fe4" },
			-- 		context_enum = { fg = "#ac8fe4" },
			-- 		context_interface = { fg = "#ac8fe4" },
			-- 		context_function = { fg = "#ac8fe4" },
			-- 		context_variable = { fg = "#ac8fe4" },
			-- 		context_constant = { fg = "#ac8fe4" },
			-- 		context_string = { fg = "#ac8fe4" },
			-- 		context_number = { fg = "#ac8fe4" },
			-- 		context_boolean = { fg = "#ac8fe4" },
			-- 		context_array = { fg = "#ac8fe4" },
			-- 		context_object = { fg = "#ac8fe4" },
			-- 		context_key = { fg = "#ac8fe4" },
			-- 		context_null = { fg = "#ac8fe4" },
			-- 		context_enum_member = { fg = "#ac8fe4" },
			-- 		context_struct = { fg = "#ac8fe4" },
			-- 		context_event = { fg = "#ac8fe4" },
			-- 		context_operator = { fg = "#ac8fe4" },
			-- 		context_type_parameter = { fg = "#ac8fe4" },
			-- 	},
			-- })

			-- vim.api.nvim_create_autocmd({
			-- 	"CursorHoldI",
			-- 	"CursorHold",
			-- 	"BufWinEnter",
			-- 	"BufFilePost",
			-- 	"InsertEnter",
			-- 	"BufWritePost",
			-- 	"TabClosed",
			-- 	"TabEnter",

			-- 	-- "WinScrolled", -- or WinResized on NVIM-v0.9 and higher
			-- 	-- "BufWinEnter",
			-- 	-- "CursorHold",
			-- 	-- "InsertLeave",

			-- 	-- -- include this if you have set `show_modified` to `true`
			-- 	-- "BufModifiedSet",
			-- }, {
			-- 	group = vim.api.nvim_create_augroup("barbecue.updater", {}),
			-- 	callback = function()
			-- 		require("barbecue.ui").update()
			-- 	end,
			-- })

			-- lspconfig.csharp_ls.setup({
			-- 	on_attach = function(client, bufnr)
			-- 		if client.server_capabilities["documentSymbolProvider"] then
			-- 			require("nvim-navic").attach(client, bufnr)
			-- 		end
			-- 	end,
			-- })
			-- lspconfig.lua_ls.setup({
			-- 	on_attach = function(client, bufnr)
			-- 		if client.server_capabilities["documentSymbolProvider"] then
			-- 			require("nvim-navic").attach(client, bufnr)
			-- 		end
			-- 	end,
			-- })

			-- local breadcrumb = require("breadcrumb")
			-- require("breadcrumb").init()

			-- local on_attach = function(client, bufnr)
			-- 		if client.server_capabilities.documentSymbolProvider then
			-- 				breadcrumb.attach(client, bufnr)
			-- 		end
			-- end
			-- lspconfig.csharp_ls.setup({ on_attach = on_attach})
			-- lspconfig.lua_ls.setup({ on_attach = on_attach})


			-- local breadcrumb = require("nvim-navic")
			-- require("nvim-navic").setup({
			-- 	-- lsp = {
			-- 	-- 	auto_attach = true,
			-- 	-- },
			-- })
			-- -- require("nvim-navic").init()

			-- local on_attach = function(client, bufnr)
			-- 		if client.server_capabilities.documentSymbolProvider then
			-- 				breadcrumb.attach(client, bufnr)
			-- 		end
			-- end
			-- lspconfig.csharp_ls.setup({ on_attach = on_attach})
			-- lspconfig.lua_ls.setup({ on_attach = on_attach})


			-- local navic = require("nvim-navic")

			-- require("lspconfig").csharp_ls.setup {
			-- 		on_attach = function(client, bufnr)
			-- 				navic.attach(client, bufnr)
			-- 		end
			-- }

			-- require("lspconfig").lua_ls.setup {
			-- 	on_attach = function(client, bufnr)
			-- 			navic.attach(client, bufnr)
			-- 	end
			-- -- }




			-- require("nvim-navic").setup({
			-- 	lsp = {
			-- 		auto_attach = true,
			-- 	},
			-- })
			-- nvim-navic configuration
			-- require("nvim-navic").setup {
			-- 	highlight = true,
			-- 	separator = " > ",
			-- 	depth_limit = 0,
			-- 	depth_limit_indicator = ".."
			-- }

			-- Function to attach nvim-navic to all LSP servers
			-- local navic = require('nvim-navic')

			-- local on_attach = function(client, bufnr)
			-- 	if client.server_capabilities.documentSymbolProvider then
			-- 		navic.attach(client, bufnr)
			-- 	end
			-- end

			-- lspconfig.csharp_ls.setup({ on_attach = on_attach})
			-- lspconfig.omnisharp_mono.setup({ on_attach = on_attach})
			-- lspconfig.lua_ls.setup({ on_attach = on_attach})

			-- delegate server specific setup to lsp-servers
			-- local servers = require 'plugins.config.lsp-servers'(setup_default, node_root)
			-- local lspconfig = require 'lspconfig'
			-- for server, setup in pairs(servers) do
			-- 	lspconfig[server].setup(setup)
			-- end


			-- local on_attach = function(client, bufnr)
			-- 	local function buf_set_option(...)
			-- 		vim.api.nvim_buf_set_option(bufnr, ...)
			-- 	end

			-- 	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

			-- -- ---@diagnostic disable-next-line: undefined-field
			-- -- 	if _G.format_on_save then
			-- -- 		format.attach(client)
			-- -- 	end
			-- 	-- cursor_diagnostics.attach(bufnr)
			-- 	-- mappings.attach_mapping(bufnr)
			-- 	navic.attach(client, bufnr)
			-- 	-- colorizer.attach_to_buffer(bufnr)
			-- end


			-- lspconfig.csharp_ls.setup({ on_attach = on_attach})

			-- Automatically setup all installed LSP servers
			-- for server_name, _ in pairs(lspconfig) do
			-- 	lspconfig[server_name].setup {
			-- 		on_attach = on_attach,
			-- 		-- other configurations can be added here if needed
			-- 	}
			-- end

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- ahkv2
			local function custom_attach(client, bufnr)
				require("lsp_signature").on_attach({
					bind = true,
					use_lspsaga = false,
					floating_window = true,
					fix_pos = true,
					hint_enable = true,
					hi_parameter = "Search",
					handler_opts = { "double" },
				})
			end

			function list_directories(path)
				local i, t, popen = 0, {}, io.popen
				local pfile, err = popen('dir "'..path..'" /b /ad')
				if not pfile then
					return nil, "Error opening pipe: " .. err
				end
				for filename in pfile:lines() do
					i = i + 1
					local clean_path = string.gsub(path .. '\\' .. filename, "thqby%.vscode%-autohotkey2%-lsp%-.+", "")
					t[i] = clean_path .. filename
				end
			pfile:close()
				return t
			end

			local directories = list_directories(os.getenv("USERPROFILE").."\\.vscode\\extensions\\thqby.vscode-autohotkey2-lsp-*")

			-- AHK2 LSP configuration
			local ahk2_configs = {
				autostart = true,
				cmd = {
					"node",
					vim.fn.expand(directories[1].."/server/dist/server.js"),
					"--stdio"
				},
				filetypes = { "ahk", "autohotkey", "ah2" },
				init_options = {
					locale = "en-us",
					InterpreterPath = "C:/Program Files/AutoHotkey/v2/AutoHotkey.exe",
					AutoLibInclude = "Disabled",
					CommentTags = "^;;\\s*(?<tag>.+)",
					CompleteFunctionParens = false,
					Diagnostics = {
						ClassStaticMemberCheck = true,
						ParamsCheck = true
					},
					DisableV1Script = true,
					FormatOptions = {
						break_chained_methods = false,
						ignore_comment = false,
						indent_string = "\t",
						keep_array_indentation = true,
						max_preserve_newlines = 2,
						one_true_brace = "1",
						preserve_newlines = true,
						space_before_conditional = true,
						space_in_empty_paren = false,
						space_in_other = true,
						space_in_paren = false,
						wrap_line_length = 0
					},
					SymbolFoldingFromOpenBrace = false
					-- Same as initializationOptions for Sublime Text4, convert json literal to lua dictionary literal
				},
				single_file_support = true,
				flags = { debounce_text_changes = 500 },
				capabilities = capabilities,
				on_attach = custom_attach,

			}

			local configs = require "lspconfig.configs"
			configs["ahk2"] = { default_config = ahk2_configs }
			lspconfig.ahk2.setup({})


			-- import mason_lspconfig plugin
			local mason_lspconfig = require("mason-lspconfig")

			-- Language Servers
			local servers = {
				lua_ls = {
					-- capabilities = {},
					settings = {
						Lua = {
							-- make the language server recognize "vim" global
							diagnostics = {
								globals = { "vim" },
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
			}

			-- Change the Diagnostic symbols in the sign column (gutter)
			local signs = { Error = "✘ ", Warn = "▲ ", Hint = "⚑ ", Info = "» " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end


			local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- used to enable autocompletion (assign to every lsp server config)
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			mason_lspconfig.setup({
				ensure_installed = {
					"tsserver",
					"html",
					"cssls",
					"lua_ls",
					"pyright",
					"csharp_ls",
				},
				handlers = {
					-- function(server_name)
					-- 	local server = servers[server_name] or {}
					-- 	server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					-- 	require("lspconfig")[server_name].setup(server)
					-- end,
					function(server_name)
						local server = lspconfig[server_name] or {}
						local _capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						lspconfig[server_name].setup({
							capabilities = _capabilities,
							-- on_attach = on_attach,
						})
					end,
				},
				automatic_installation = true
			})


			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				-- group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(event)

					local builtin = require("telescope.builtin")

					local function search_treesitter_symbols()

						-- local ts_treesitter_symbols = { 'Type', 'Method', 'Function', 'Constant', 'Field' }
						local treesitter_symbols = { 'Method', 'Function'}

						local treesitter_highlights = {}

						for _, name in ipairs(treesitter_symbols) do
							treesitter_highlights[name:lower()] = 'Comment'
						end

						builtin.lsp_document_symbols({
							-- prompt_title = "LSP Document Symbols",
							-- symbols = treesitter_symbols,
							-- symbol_highlights = treesitter_highlights,
						})
					end

					local function toggle_diagnostic_hints()
						if vim.g.diagnostic_hints_enabled == nil then
							vim.g.diagnostic_hints_enabled = true
						end

						if vim.g.diagnostic_hints_enabled then
							vim.diagnostic.disable()
							vim.g.diagnostic_hints_enabled = false
						else
							vim.diagnostic.enable()
							vim.g.diagnostic_hints_enabled = true
						end
					end


					-- LSP Keymaps
					-- Telescope Keymaps

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					-- local opts = { buffer = ev.buf, silent = true }
					-- opts.desc = "Show LSP references"
					-- keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

					-- Adds a keymap to the buffer with the desc prefixed with "LSP: " for clarity
					local _map = function(keys, func, desc)
						Map("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-T>.
					_map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					_map("gr", builtin.lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					_map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					_map("gt", builtin.lsp_type_definitions, "Type [D]efinition")
					-- _map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header
					_map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					_map("<leader>ds", search_treesitter_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace
					--  Similar to document symbols, except searches over your whole project.
					_map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

					-- Rename the variable under your cursor
					--  Most Language Servers support renaming across files, etc.
					_map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					_map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

					-- Show buffer diagnostics option bufnr=0 for current buffer
					_map("<leader>db",function() builtin.diagnostics({ bufnr = 0 }) end, "[D]iagnostics [B]uffer")

					-- Show line diagnostics
					_map("<leader>dl", vim.diagnostic.open_float, "[D]ocument [L]ine Diagnostics")

					-- Go to previous diagnostic
					_map("[d", vim.diagnostic.goto_prev, "Previous [D]iagnostic")

					-- Go to next diagnostic
					_map("]d", vim.diagnostic.goto_next, "Next [D]iagnostic")

					-- Toggle diagnostics
					_map("<leader>td", toggle_diagnostic_hints, "Toggle [D]iagnostics")

					-- Opens a popup that displays documentation about the word under your cursor
					--  See `:help K` for why this keymap
					_map("K", vim.lsp.buf.hover, "Hover Documentation")

					-- keymap to restart lsp since some like to crash
					_map("<leader><leader>r", function()
						Cmd("LspRestart")
						end, "Restart LspServer")
				end,

			})

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format lua code
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		end,
		enabled = not vim.g.vscode
	},
	--  Neovim Development Plugin
	{
		"folke/neodev.nvim",
		opts = {},
		enabled = not vim.g.vscode
	}
}
