return {

	--#region For VSCode

	--#endregion


	-- Autocompletion
	{
		"hrsh7th/nvim-cmp", -- main plugin
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				-- build = function()
				-- 	-- Build Step is needed for regex support in snippets
				-- 	-- This step is not supported in many windows environments
				-- 	-- Remove the below condition to re-enable on windows
				-- 	if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
				-- 		return
				-- 	end

				-- 	return "make install_jsregexp"
				-- end,
			},
			"saadparwaiz1/cmp_luasnip", -- LuaSnip source for nvim-cmp
			"hrsh7th/cmp-buffer", -- source for text in buffer
			"hrsh7th/cmp-path", -- source for file system paths
			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp", -- Source for LSP completion
			"rafamadriz/friendly-snippets", -- useful snippets
			-- If you want to add a bunch of pre-configured snippets,
			--    you can use this plugin to help you. It even has snippets
			--    for various frameworks/libraries/etc. but you will have to
			--    set up the ones that are useful for you.
			-- 'rafamadriz/friendly-snippets',
			{
				"hrsh7th/cmp-cmdline", -- source for cmdline completion
				event = { "InsertEnter", "CmdLineEnter" },
				-- event = "VeryLazy",
			},
			{
				"zbirenbaum/copilot-cmp",
				config = function()
					require("copilot_cmp").setup()
				end,
			},
		},
		-- Configuration function for nvim-cmp and LuaSnip
		config = function(_, opts)
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local neogen = require("neogen")
			-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = { -- configure how nvim-cmp interacts with snippet engine
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,preview,noinsert" },
				mapping = cmp.mapping.preset.insert({
					-- Select the [n]ext item
					-- ["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-j>"] = cmp.mapping.select_next_item(), -- next suggesion
					-- Select the [p]revious item
					-- ["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					-- Accept ([y]es) the completion.
					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					-- Manually trigger a completion from nvim-cmp.
					--  Generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					["<C-Space>"] = cmp.mapping.complete({}),
					["<C-e>"] = cmp.mapping.abort(), -- close completion window
					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						elseif neogen.jumpable() then
							neogen.jump_next()
						end

						-- if cmp.visible() then
						-- 	cmp.select_next_item()
						-- elseif luasnip.expand_or_jumpable() then
						-- 	luasnip.expand_or_jump()
						-- elseif neogen.jumpable() then
						-- 	neogen.jump_next()
						-- elseif has_words_before() then
						-- 	cmp.complete()
						-- else
						-- 	fallback()
						-- end
					end, { "i", "s", "c" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						elseif neogen.jumpable() then
							neogen.jump_prev()
						end
					end, { "i", "s", "c" }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<Tab>"] = cmp.mapping.confirm({ select = false }),
				}),
				-- sources for auto-completion
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- LSP completion
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" }, -- text within current buffer
					{ name = "path" }, -- file system paths
					{ name = "copilot" }, -- Copilot completion
				}),
				formatting = {
					fields = { "menu", "abbr", "kind" },
					format = function(entry, item)
						local menu_icon = {
							nvim_lsp = "λ",
							luasnip = "⋗",
							buffer = "Ω",
							path = "🖫",
							copilot = "",
						}
						item.menu = menu_icon[entry.source.name]
						return item
					end,
				},
			})

			-- Setup for cmdline completion

			local mapping = {
				["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
				["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
				["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
				["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
				["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
				["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
				["<CR>"] = cmp.mapping(cmp.mapping.confirm({ select = false }), { "i", "c" }),
				["<C-y"] = cmp.mapping(cmp.mapping.confirm({ select = true }), { "i", "c" }),
				["<C-e>"] = cmp.mapping(cmp.mapping.abort(), { "i", "c" }),
			}

			-- Use buffer source for `/`.
			cmp.setup.cmdline("/", {
				preselect = "none",
				completion = {
					completeopt = "menu,preview,menuone,noselect",
				},
				mapping = mapping,
				-- mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
				experimental = {
					ghost_text = true,
					native_menu = false,
				},
			})

			-- Use cmdline & path source for ':'.
			cmp.setup.cmdline(":", {
				preselect = "none",
				completion = {
					completeopt = "menu,preview,menuone,noselect",
				},
				mapping = mapping,
				-- mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				experimental = {
					ghost_text = true,
					native_menu = false,
				},
			})
		end,
		enabled = not vim.g.vscode
	},
	-- Copilot AI
	{
		-- Copilot AI code completion
		{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			event = "InsertEnter",
			-- event = "BufRead",
			config = function()
				require("copilot").setup({
					suggestion = {
						enabled = true,
						auto_trigger = true,
						debounce = 75,
						keymap = {
							accept = "<C-a>",
							-- accept = "<Tab>",
							-- accept_word = false,
							-- accept_line = false,
							-- next = "<M-]>",
							-- prev = "<M-[>",
							-- dismiss = "<C-]>",
						},
					},
					panel = {
						enabled = true,
						auto_refresh = false,
						keymap = {
							-- jump_prev = "[[",
							-- jump_next = "]]",
							-- accept = "<CR>",
							-- refresh = "gr",
							open = "<M-CR>",
						},
						layout = {
							position = "bottom", -- | top | left | right
							ratio = 0.4,
						},
					},
				})
			end,
			enabled = not vim.g.vscode
			-- after installed run :Copilot auth
		},
		-- Copilot Chat
		{
			"CopilotC-Nvim/CopilotChat.nvim",
			-- event = "VeryLazy",
			branch = "canary",
			dependencies = {
				{ "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
				{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
			},
			opts = {
				show_help = "yes",
				prompts = {
					-- Code related prompts
					Explain = "Please explain how the following code works.",
					Review = "Please review the following code and provide suggestions for improvement.",
					Tests = "Please explain how the selected code works, then generate unit tests for it.",
					Refactor = "Please refactor the following code to improve its clarity and readability.",
					FixCode = "Please fix the following code to make it work as intended.",
					Documentation = "Please provide documentation for the following code.",
					-- Text related prompts
					Summarize = "Please summarize the following text.",
					Spelling = "Please correct any grammar and spelling errors in the following text.",
					Wording = "Please improve the grammar and wording of the following text.",
					Concise = "Please rewrite the following text to make it more concise.",
				},
				debug = false, -- Set to true to see response from Github Copilot API. The log file will be in ~/.local/state/nvim/CopilotChat.nvim.log.
			},
			config = function()
				vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
			end,
			keys = {
				-- Code related commands
				{ "<leader>cce", "<cmd>CopilotChatExplain<cr>",       desc = "CopilotChat - Explain code" },
				{ "<leader>cct", "<cmd>CopilotChatTests<cr>",         desc = "CopilotChat - Generate tests" },
				{ "<leader>ccr", "<cmd>CopilotChatReview<cr>",        desc = "CopilotChat - Review code" },
				{ "<leader>ccR", "<cmd>CopilotChatRefactor<cr>",      desc = "CopilotChat - Refactor code" },
				{ "<leader>ccf", "<cmd>CopilotChatFixCode<cr>",       desc = "CopilotChat - Fix code" },
				{ "<leader>ccd", "<cmd>CopilotChatDocumentation<cr>", desc = "CopilotChat - Add documentation for code" },
				-- Text related commands
				{ "<leader>ccs", "<cmd>CopilotChatSummarize<cr>",     desc = "CopilotChat - Summarize text" },
				{ "<leader>ccS", "<cmd>CopilotChatSpelling<cr>",      desc = "CopilotChat - Correct spelling" },
				{ "<leader>ccw", "<cmd>CopilotChatWording<cr>",       desc = "CopilotChat - Improve wording" },
				{ "<leader>ccc", "<cmd>CopilotChatConcise<cr>",       desc = "CopilotChat - Make text concise" },
				-- Chat with Copilot in visual mode
				{
					"<leader>ccv",
					":CopilotChatVisual",
					mode = "x",
					desc = "CopilotChat - Open in vertical split",
				},
				{
					"<leader>ccx",
					":CopilotChatInPlace<cr>",
					mode = "x",
					desc = "CopilotChat - Run in-place code",
				},
				-- Custom input for CopilotChat
				{
					"<leader>cci",
					function()
						local input = vim.fn.input("Ask Copilot: ")
						if input ~= "" then
							vim.cmd("CopilotChat " .. input)
						end
					end,
					desc = "CopilotChat - Ask input",
				},
			},
			enabled = not vim.g.vscode
		},
	},
	-- Code documentation
	{
		"danymat/neogen",
		-- config = true,
		-- Uncomment next line if you want to follow only stable versions
		-- version = "*"
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			-- require("config.neogen").setup()
			require("neogen").setup({
				snippet_engine = "luasnip",
				enabled = true,
				input_after_comment = true,
				languages = {
					lua = {
						template = {
							annotation_convention = "ldoc",
						},
					},
					python = {
						template = {
							annotation_convention = "google_docstrings",
						},
					},
					rust = {
						template = {
							annotation_convention = "rustdoc",
						},
					},
					javascript = {
						template = {
							annotation_convention = "jsdoc",
						},
					},
					typescript = {
						template = {
							annotation_convention = "tsdoc",
						},
					},
					typescriptreact = {
						template = {
							annotation_convention = "tsdoc",
						},
					},
					cs = {
						template = {
							annotation_convention = "xmldoc",
						},
					},
				},
			})

			-- Code documentation Keymaps
			-- Map('n', '<leader>ahk', ':lua M.insert_function_comments()<CR>')
			-- Map("n", "<leader>gn", "<cmd>Neogen<CR>", { noremap = true, silent = true })
			Map("n", "<Leader>nd", ":lua require('neogen').generate()<CR>")
		end,
		enabled = not vim.g.vscode
	},
	-- Project navigation
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			-- REQUIRED
			harpoon:setup()

			Map("n", "<leader>a", function()
				harpoon:list():add()
			end)
			Map("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)
			Map("n", "<C-J>", function()
				harpoon:list():prev()
			end)
			Map("n", "<C-S-J>", function()
				harpoon:list():prev()
			end)
			Map("n", "<C-K>", function()
				harpoon:list():next()
			end)
			Map("n", "<C-S-K>", function()
				harpoon:list():next()
			end)
			Map("n", "<leader>ra", function()
				harpoon:list():clear()
			end)
			-- vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
			-- vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
			-- vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
			-- vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)
		end,
		enabled = not vim.g.vscode
	},
	-- LuaSnip Snippets
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		config = function()
			local ls = require("luasnip")

			local extras = require("luasnip.extras")
			local fmt = require("luasnip.extras.fmt").fmt
			local fmta = require("luasnip.extras.fmt").fmta

			local s = ls.snippet
			local t = ls.text_node
			local i = ls.insert_node
			local f = ls.function_node
			local rep = extras.rep
			local single = function(node)
				return node[1]
			end

			-- [[ See docs @https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md ]]
			local all_snippets = {
				s("wd", {
					---@diagnostic disable-next-line: param-type-mismatch
					f(function()
						return string.lower(os.date("%A"))
					end),
				}),
				s("Wd", {
					f(function()
						return os.date("%A")
					end),
				}),
				s("dt", {
					f(function()
						return os.date("%y.%m.%d")
					end),
				}),
				s("tm", {
					f(function()
						return os.date("%H:%M")
					end),
				}),
			}
			ls.add_snippets("all", all_snippets)

			local lua_snippets = {
				s("map", {
					t("vim.keymap.set('"),
					i(1, "n"),
					t("', '"),
					i(2),
					t("', "),
					i(0),
					t(")"),
				}),
				s("function inline", {
					t("function"),
					i(1),
					t("("),
					i(2),
					t(") "),
					i(0),
					t(" end"),
				}),
			}
			ls.add_snippets("lua", lua_snippets)

			local git_commit_snippets = {
				s("fish", { t("fish: ") }),
				s("astro", { t("astro: ") }),
				s("awesome", { t("awesome: ") }),
				s("compose", { t("compose: ") }),
				s("xremap", { t("xremap: ") }),
				s("alacritty", { t("alacritty: ") }),
				s("stylus(youtube)", { t("stylus(youtube): ") }),
				s("stylus(discord)", { t("stylus(discord): ") }),
			}
			ls.add_snippets("gitcommit", git_commit_snippets)

			local css_snippets = {
				s("!important", { t("!important") }),
			}
			ls.add_snippets("css", css_snippets)

			local rust_snippets = {
				s("Result<(), Box<dyn Error>>", {
					t("Result<"),
					i(1, "()"),
					t(", Box<dyn Error>>"),
				}),
			}
			ls.add_snippets("rust", rust_snippets)

			local markdown_snippets = {
				s("inline link", {
					t("["),
					i(1),
					t("]("),
					i(2),
					t(")"),
				}),
			}
			ls.add_snippets("markdown", markdown_snippets)

			local typescript_snippets = {
				s("cn", {
					t('className="'),
					i(1, "class"),
					t('"'),
				}),
				s(
					"cmp",
					fmt(
						[[
                type `1~Props = {};

                export const `2~ = (props: `3~Props) => {
                  return (
              <div>
                <h1>Hello World!</h1>
              </div>
                  )
                }
              ]],
						{
							i(1, "ComponentName"),
							rep(1),
							rep(1),
						},
						{
							delimiters = "`~",
						},
						{
							delimiters = "`~",
						}
					)
				),
				s(
					"cmpdf",
					fmt(
						[[
                type `2~Props = {};

                export function `1~(props: `3~Props) {
                  return (
              <div>
                <h1>Hello World!</h1>
              </div>
                  )
                }
              ]],
						{
							i(1, "ComponentName"),
							rep(1),
							rep(1),
						},
						{
							delimiters = "`~",
						},
						{
							delimiters = "`~",
						}
					)
				),
				s(
					"cmpf",
					fmt(
						[[
                import { forwardRef } from "react";

                type `1~Props = React.HTMLAttributes<HTMLElement> & {};

                const `2~ = forwardRef<HTMLElement, `3~Props>(
                  ({ ...props }, ref) => {
              return (
                <div
                  ref={ref}
                  {...props}
                >
                  <h1>Hello World!</h1>
                </div>
              );
                  },
                );

                `4~.displayName = "`5~";

                export `6~;
              ]],
						{
							i(1, "ComponentName"),
							rep(1),
							rep(1),
							rep(1),
							rep(1),
							rep(1),
						},
						{
							delimiters = "`~",
						}
					)
				),
				s(
					"form-item",
					fmt(
						[[
                <FormField
                  control={form.control}
                  name="email"
                  render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>

                <FormControl>
                  <Input type="email" {...field} />
                </FormControl>

                <FormMessage />
              </FormItem>
                  )}
                />
              ]],
						{},
						{
							delimiters = "`~",
						}
					)
				),
				s(
					"shadcn-dialog-imports",
					fmt(
						[[
              import {
                Dialog,
                DialogContent,
                DialogDescription,
                DialogHeader,
                DialogTitle,
                DialogTrigger,
              } from "@/components/ui/dialog"

              ]],
						{},
						{
							delimiters = "`~",
						}
					)
				),
				s(
					"shadcn-dialog",
					fmt(
						[[
            <Dialog>
              <DialogTrigger>Open</DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Are you absolutely sure?</DialogTitle>
                  <DialogDescription>
              This action cannot be undone. This will permanently delete your account
              and remove your data from our servers.
                  </DialogDescription>
                </DialogHeader>
              </DialogContent>
            </Dialog>
                  ]],
						{},
						{
							delimiters = "`~",
						}
					)
				),
				s(
					"shadcn-dropdownmenu-imports",
					fmt(
						[[
              import {
                DropdownMenu,
                DropdownMenuContent,
                DropdownMenuItem,
                DropdownMenuTrigger,
              } from "@/components/ui/dropdown-menu";
            ]],
						{},
						{
							delimiters = "`~",
						}
					)
				),
				s(
					"shadcn-dropdownmenu",
					fmt(
						[[
            <DropdownMenu>
              <DropdownMenuTrigger>Open</DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem>Item 1</DropdownMenuItem>
                <DropdownMenuItem>Item 2</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
                  ]],
						{},
						{
							delimiters = "`~",
						}
					)
				),
			}
			ls.add_snippets("typescriptreact", typescript_snippets)
		end,
		enabled = not vim.g.vscode
	},
	-- Debugging
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
			{
				"mxsdev/nvim-dap-vscode-js",
				config = function()
						require("dap-vscode-js").setup({
                -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
							debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug", -- Path to vscode-js-debug installation.
							-- debugger_cmd = { "extension" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
							adapters = {
								"node",
								"chrome",
								"pwa-node",
								"pwa-chrome",
								"pwa-msedge",
								"node-terminal",
								"pwa-extensionHost",
							}, -- which adapters to register in nvim-dap
							-- log_file_path = vim.fn.stdpath('data') .. "/lazy/vscode-js-debug/" .. "src/dap_vscode_js.log" -- Path for file logging
							-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
							-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
						})
				end,
			},
			{
				"microsoft/vscode-js-debug",
				opt = true,
				run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
			},
		},
		config = function()
			local dap = require("dap")
			local ui = require("dapui")
			local widgets = require("dap.ui.widgets")

			require("dapui").setup()

			dap.adapters.autohotkey = {
				type = "executable",
				-- https://github.com/helsmy/autohotkey-debug-adapter
				command = os.getenv("USERPROFILE")
					.. "/.vscode/extensions/helsmy.autohotkey-debug-0.7.3/bin/debugAdapter.exe",
				args = {},
			}

			dap.configurations.autohotkey = {
				{
					name = "AutoHotkey Debug",
					type = "autohotkey",
					request = "launch",
					program = "${file}",
					AhkExecutable = "C:/Program Files/Autohotkey/v2/AutoHotkey64.exe",
					stopOnEntry = false,
					-- args = [],
					-- "port": "9002-9010",
					port = 9005,
					variableCategories = "recommend",
					useDebugDirective = true,
					useAutoJumpToError = true,
				},
			}

			local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
					local vscode = require("dap.ext.vscode")
			vscode.type_to_filetypes["node"] = js_filetypes
			vscode.type_to_filetypes["pwa-node"] = js_filetypes

			for _, language in ipairs(js_filetypes) do
				if not dap.configurations[language] then
					dap.configurations[language] = {
						{
							type = "pwa-node",
							request = "launch",
							name = "Launch file",
							program = "${file}",
							cwd = "${workspaceFolder}",
						},
						{
							type = "pwa-node",
							request = "attach",
							name = "Attach",
							processId = require("dap.utils").pick_process,
							cwd = "${workspaceFolder}",
						},
					}
				end
			end




            -- Debugging Keymaps

			-- Key mappings
			-- Map({'n', 'v'}, '<Leader>dh', function()
			--   widgets.hover()
			-- end)
			-- Map({'n', 'v'}, '<Leader>dp', function()
			--   widgets.preview()
			-- end)
			-- Map('n', '<Leader>df', function()
			--   widgets.centered_float(widgets.frames)
			-- end)
			-- Map('n', '<Leader>ds', function()
			--   widgets.centered_float(widgets.scopes)
			-- end)

			-- Define custom highlight groups for DAP signs
			vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "🟦", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "⭐️", texthl = "", linehl = "", numhl = "" })
			-- vim.fn.sign_define('DapBreakpoint', { text='🔴', texthl='', linehl='', numhl='' })
			-- vim.fn.sign_define('DapStopped', { text='🟢', texthl='', linehl='', numhl= '' })

			Map("n", "<F2>", dap.toggle_breakpoint)
			Map("n", "<F5>", dap.continue)
			Map("n", "<F6>", dap.terminate)
			Map("n", "<F7>", dap.restart)
			Map("n", "<F9>", dap.step_into)
			Map("n", "<F10>", dap.step_over)
			Map("n", "<F11>", dap.step_out)
			Map("n", "<F12>", dap.step_back)
			Map("n", "<Leader>dt", dap.run_to_cursor)
			Map("n", "<leader>dR", dap.clear_breakpoints)
			Map("n", "<leader>dk", ':lua require"dap".up()<CR>zz')
			Map("n", "<leader>dj", ':lua require"dap".down()<CR>zz')
			Map("n", "<leader>du", ':lua require"dapui".toggle()<CR>')
			Map("n", "<leader>dr", ':lua require"dapui".open({reset = true})<CR>')

			-- Eval var under cursor
			Map("n", "<Leader>?", function()
				require("dapui").eval(nil, { enter = true })
			end)

			-- vim.keymap.set('n', '<leader>dH', ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
			-- vim.keymap.set('n', '<leader>de', function() require"dap".set_exception_breakpoints({"all"}) end)
			-- vim.keymap.set('n', '<leader>d?', function()
			--     local widgets = require "dap.ui.widgets";
			--     widgets.centered_float(widgets.scopes)
			-- end)
			-- vim.keymap.set('n', '<leader>dr', ':lua require"dap".repl.toggle({}, "vsplit")<CR><C-w>l')

			-- Open and close dapui automatically
			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
		end,
		enabled = not vim.g.vscode
	},
	-- Refactoring tool
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("refactoring").setup()

			-- Refactoring Keymaps
			Map({ "n", "x" }, "<Leader>re", "<cmd>lua require('refactoring').select_refactor()<CR>")
		end,
		enabled = not vim.g.vscode
	},
	-- bookmarks management
	{
		"tomasky/bookmarks.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			local bm = require("bookmarks")
			local telescope = require("telescope")

			bm.setup({
				-- save_file = vim.fn.expand "$HOME/.bookmarks", -- bookmarks save file path
				keywords = {
					["@t"] = "☑️ ", -- mark annotation startswith @t ,signs this icon as `Todo`
					["@w"] = "⚠️ ", -- mark annotation startswith @w ,signs this icon as `Warn`
					["@f"] = "⛏ ", -- mark annotation startswith @f ,signs this icon as `Fix`
					["@n"] = "📝 ", -- mark annotation startswith @n ,signs this icon as `Note`
				},
			})
			telescope.load_extension("bookmarks")

			-- Bookmarks Keymaps
			Map("n", "mm", bm.bookmark_toggle) -- add or remove bookmark at current line
			Map("n", "mi", bm.bookmark_ann) -- add or edit mark annotation at current line
			Map("n", "mc", bm.bookmark_clean) -- clean all marks in local buffer
			Map("n", "mn", bm.bookmark_next) -- jump to next mark in local buffer
			Map("n", "mp", bm.bookmark_prev) -- jump to previous mark in local buffer
			Map("n", "ml", telescope.extensions.bookmarks.list) -- show all marked file list in telescope window
			Map("n", "mL", bm.bookmark_list) -- show marked file list in quickfix window
			Map("n", "mx", bm.bookmark_clear_all) -- removes all bookmarks
		end,
		enabled = not vim.g.vscode
	},
	-- Session management
	{
		{
			"rmagatti/auto-session",
			config = function()
				local auto_session = require("auto-session")
				auto_session.setup({
					-- auto_restore_enabled = false,
					auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
				})

				-- Session Keymaps
				Map("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
				Map("n", "<leader>ww", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
				Map("n", "<leader>wl", require("auto-session.session-lens").search_session, { desc = "Search session" }) -- search session
			end,
			enabled = false,
		},
		{
			"natecraddock/sessions.nvim",
			config = function()
				require("sessions").setup({
					session_filepath = vim.fn.stdpath("data") .. "/sessions",
					absolute = true,
				})
			end,
			enabled = not vim.g.vscode
		},
	},
	-- Project management
	{
		{
			"ahmedkhalf/project.nvim",
			-- event = { "CursorHold", "CursorHoldI" },
			config = function()
				require("project_nvim").setup({
					-- ignore_lsp = { "null-ls", "copilot" },
				})
			end,
			enabled = not vim.g.vscode
		},
		{
			"natecraddock/workspaces.nvim",
			config = function()
				require("workspaces").setup({
					hooks = {
						open_pre = {
							"SessionsSave",
							"silent %bdelete!",
						},
						open = {
							"SessionsLoad",
							"NvimTreeOpen",
						},
					},
				})
			end,
			enabled = not vim.g.vscode
		},
	},

	-- Web Dev
	{
		--nx Angular
		{
			"Equilibris/nx.nvim",
			event = "VeryLazy",
			config = function()
				require("nx").setup({})

				Map("n", "<leader>nxa", "<cmd>Telescope nx actions<CR>")
				Map("n", "<leader>nxg", "<cmd>Telescope nx generators<CR>")
			end,
			enabled = not vim.g.vscode
		},
		-- ng
		{
			"joeveiga/ng.nvim",
			config = function()
				local ng = require("ng")
				-- ng.setup()
				Map("n", "<leader>at", ng.goto_template_for_component, opts)
				Map("n", "<leader>ac", ng.goto_component_with_template_file, opts)
				Map("n", "<leader>aT", ng.get_template_tcb, opts)
			end,
			enabled = not vim.g.vscode
		},
	},
}
