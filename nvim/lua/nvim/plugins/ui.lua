return {
	-- catppuccin Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		-- high proirity to make sure theme is loaded first
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				background = {
					light = "latte",
					dark = "mocha",
				},
				color_overrides = {
					latte = {
						rosewater = "#c14a4a",
						flamingo = "#c14a4a",
						red = "#c14a4a",
						maroon = "#c14a4a",
						pink = "#945e80",
						mauve = "#945e80",
						peach = "#c35e0a",
						yellow = "#b47109",
						green = "#6c782e",
						teal = "#4c7a5d",
						sky = "#4c7a5d",
						sapphire = "#4c7a5d",
						blue = "#45707a",
						lavender = "#45707a",
						text = "#654735",
						subtext1 = "#73503c",
						subtext0 = "#805942",
						overlay2 = "#8c6249",
						overlay1 = "#8c856d",
						overlay0 = "#a69d81",
						surface2 = "#bfb695",
						surface1 = "#d1c7a3",
						surface0 = "#e3dec3",
						base = "#f9f5d7",
						mantle = "#f0ebce",
						crust = "#e8e3c8",
					},
					mocha = {
						rosewater = "#ea6962",
						flamingo = "#ea6962",
						red = "#ea6962",
						maroon = "#ea6962",
						pink = "#d3869b",
						mauve = "#d3869b",
						peach = "#e78a4e",
						yellow = "#d8a657",
						green = "#a9b665",
						teal = "#89b482",
						sky = "#89b482",
						sapphire = "#89b482",
						blue = "#7daea3",
						lavender = "#7daea3",
						text = "#ebdbb2",
						subtext1 = "#d5c4a1",
						subtext0 = "#bdae93",
						overlay2 = "#a89984",
						overlay1 = "#928374",
						overlay0 = "#595959",
						surface2 = "#4d4d4d",
						surface1 = "#404040",
						surface0 = "#292929",
						base = "#1d2021",
						mantle = "#191b1c",
						crust = "#141617",
					},
				},
				transparent_background = false,
				show_end_of_buffer = false,
				integration_default = false,
				integrations = {
					barbecue = { dim_dirname = true, bold_basename = true, dim_context = false, alt_background = false },
					cmp = true,
					gitsigns = true,
					hop = true,
					illuminate = { enabled = true },
					native_lsp = { enabled = true, inlay_hints = { background = true } },
					neogit = true,
					neotree = true,
					semantic_tokens = true,
					treesitter = true,
					treesitter_context = true,
					vimwiki = true,
					which_key = true,
				},
				highlight_overrides = {
					all = function(colors)
						return {
							CmpItemMenu = { fg = colors.surface2 },
							CursorLineNr = { fg = colors.text },
							FloatBorder = { bg = colors.base, fg = colors.surface0 },
							GitSignsChange = { fg = colors.peach },
							LineNr = { fg = colors.overlay0 },
							LspInfoBorder = { link = "FloatBorder" },
							NeoTreeDirectoryIcon = { fg = colors.subtext1 },
							NeoTreeDirectoryName = { fg = colors.subtext1 },
							NeoTreeFloatBorder = { link = "TelescopeResultsBorder" },
							NeoTreeGitConflict = { fg = colors.red },
							NeoTreeGitDeleted = { fg = colors.red },
							NeoTreeGitIgnored = { fg = colors.overlay0 },
							NeoTreeGitModified = { fg = colors.peach },
							NeoTreeGitStaged = { fg = colors.green },
							NeoTreeGitUnstaged = { fg = colors.red },
							NeoTreeGitUntracked = { fg = colors.green },
							NeoTreeIndent = { fg = colors.surface1 },
							NeoTreeNormal = { bg = colors.mantle },
							NeoTreeNormalNC = { bg = colors.mantle },
							NeoTreeRootName = { fg = colors.subtext1, style = { "bold" } },
							NeoTreeTabActive = { fg = colors.text, bg = colors.mantle },
							NeoTreeTabInactive = { fg = colors.surface2, bg = colors.crust },
							NeoTreeTabSeparatorActive = { fg = colors.mantle, bg = colors.mantle },
							NeoTreeTabSeparatorInactive = { fg = colors.crust, bg = colors.crust },
							NeoTreeWinSeparator = { fg = colors.base, bg = colors.base },
							NormalFloat = { bg = colors.base },
							Pmenu = { bg = colors.mantle, fg = "" },
							PmenuSel = { bg = colors.surface0, fg = "" },
							TelescopePreviewBorder = { bg = colors.crust, fg = colors.crust },
							TelescopePreviewNormal = { bg = colors.crust },
							-- TelescopePreviewTitle = { fg = colors.crust, bg = colors.crust },
							TelescopePreviewTitle = { fg = colors.yellow},
							TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
							TelescopePromptCounter = { fg = colors.mauve, style = { "bold" } },
							TelescopePromptNormal = { bg = colors.surface0 },
							TelescopePromptPrefix = { bg = colors.surface0 },
							-- TelescopePromptTitle = { fg = colors.surface0, bg = colors.surface0 },
							TelescopePromptTitle = { fg = colors.yellow, bg = colors.mantle},
							TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
							TelescopeResultsNormal = { bg = colors.mantle },
							-- TelescopeResultsTitle = { fg = colors.mantle, bg = colors.mantle },
							TelescopeResultsTitle = { fg = colors.yellow, bg = colors.crust },
							TelescopeSelection = { bg = colors.surface0 },
							VertSplit = { bg = colors.base, fg = colors.surface0 },
							WhichKeyFloat = { bg = colors.mantle },
							YankHighlight = { bg = colors.surface2 },
							FidgetTask = { fg = colors.subtext2 },
							FidgetTitle = { fg = colors.peach },

							IblIndent = { fg = colors.surface0 },
							IblScope = { fg = colors.overlay0 },

							Boolean = { fg = colors.mauve },
							Number = { fg = colors.mauve },
							Float = { fg = colors.mauve },

							PreProc = { fg = colors.mauve },
							PreCondit = { fg = colors.mauve },
							Include = { fg = colors.mauve },
							Define = { fg = colors.mauve },
							Conditional = { fg = colors.red },
							Repeat = { fg = colors.red },
							Keyword = { fg = colors.red },
							Typedef = { fg = colors.red },
							Exception = { fg = colors.red },
							Statement = { fg = colors.red },

							Error = { fg = colors.red },
							StorageClass = { fg = colors.peach },
							Tag = { fg = colors.peach },
							Label = { fg = colors.peach },
							Structure = { fg = colors.peach },
							Operator = { fg = colors.peach },
							Title = { fg = colors.peach },
							Special = { fg = colors.yellow },
							SpecialChar = { fg = colors.yellow },
							Type = { fg = colors.yellow, style = { "bold" } },
							Function = { fg = colors.green, style = { "bold" } },
							Delimiter = { fg = colors.subtext2 },
							Ignore = { fg = colors.subtext2 },
							Macro = { fg = colors.teal },

							TSAnnotation = { fg = colors.mauve },
							TSAttribute = { fg = colors.mauve },
							TSBoolean = { fg = colors.mauve },
							TSCharacter = { fg = colors.teal },
							TSCharacterSpecial = { link = "SpecialChar" },
							TSComment = { link = "Comment" },
							TSConditional = { fg = colors.red },
							TSConstBuiltin = { fg = colors.mauve },
							TSConstMacro = { fg = colors.mauve },
							TSConstant = { fg = colors.text },
							TSConstructor = { fg = colors.green },
							TSDebug = { link = "Debug" },
							TSDefine = { link = "Define" },
							TSEnvironment = { link = "Macro" },
							TSEnvironmentName = { link = "Type" },
							TSError = { link = "Error" },
							TSException = { fg = colors.red },
							TSField = { fg = colors.blue },
							TSFloat = { fg = colors.mauve },
							TSFuncBuiltin = { fg = colors.green },
							TSFuncMacro = { fg = colors.green },
							TSFunction = { fg = colors.green },
							TSFunctionCall = { fg = colors.green },
							TSInclude = { fg = colors.red },
							TSKeyword = { fg = colors.red },
							TSKeywordFunction = { fg = colors.red },
							TSKeywordOperator = { fg = colors.peach },
							TSKeywordReturn = { fg = colors.red },
							TSLabel = { fg = colors.peach },
							TSLiteral = { link = "String" },
							TSMath = { fg = colors.blue },
							TSMethod = { fg = colors.green },
							TSMethodCall = { fg = colors.green },
							TSNamespace = { fg = colors.yellow },
							TSNone = { fg = colors.text },
							TSNumber = { fg = colors.mauve },
							TSOperator = { fg = colors.peach },
							TSParameter = { fg = colors.text },
							TSParameterReference = { fg = colors.text },
							TSPreProc = { link = "PreProc" },
							TSProperty = { fg = colors.blue },
							TSPunctBracket = { fg = colors.text },
							TSPunctDelimiter = { link = "Delimiter" },
							TSPunctSpecial = { fg = colors.blue },
							TSRepeat = { fg = colors.red },
							TSStorageClass = { fg = colors.peach },
							TSStorageClassLifetime = { fg = colors.peach },
							TSStrike = { fg = colors.subtext2 },
							TSString = { fg = colors.teal },
							TSStringEscape = { fg = colors.green },
							TSStringRegex = { fg = colors.green },
							TSStringSpecial = { link = "SpecialChar" },
							TSSymbol = { fg = colors.text },
							TSTag = { fg = colors.peach },
							TSTagAttribute = { fg = colors.green },
							TSTagDelimiter = { fg = colors.green },
							TSText = { fg = colors.green },
							TSTextReference = { link = "Constant" },
							TSTitle = { link = "Title" },
							TSTodo = { link = "Todo" },
							TSType = { fg = colors.yellow, style = { "bold" } },
							TSTypeBuiltin = { fg = colors.yellow, style = { "bold" } },
							TSTypeDefinition = { fg = colors.yellow, style = { "bold" } },
							TSTypeQualifier = { fg = colors.peach, style = { "bold" } },
							TSURI = { fg = colors.blue },
							TSVariable = { fg = colors.text },
							TSVariableBuiltin = { fg = colors.mauve },

							["@annotation"] = { link = "TSAnnotation" },
							["@attribute"] = { link = "TSAttribute" },
							["@boolean"] = { link = "TSBoolean" },
							["@character"] = { link = "TSCharacter" },
							["@character.special"] = { link = "TSCharacterSpecial" },
							["@comment"] = { link = "TSComment" },
							["@conceal"] = { link = "Grey" },
							["@conditional"] = { link = "TSConditional" },
							["@constant"] = { link = "TSConstant" },
							["@constant.builtin"] = { link = "TSConstBuiltin" },
							["@constant.macro"] = { link = "TSConstMacro" },
							["@constructor"] = { link = "TSConstructor" },
							["@debug"] = { link = "TSDebug" },
							["@define"] = { link = "TSDefine" },
							["@error"] = { link = "TSError" },
							["@exception"] = { link = "TSException" },
							["@field"] = { link = "TSField" },
							["@float"] = { link = "TSFloat" },
							["@function"] = { link = "TSFunction" },
							["@function.builtin"] = { link = "TSFuncBuiltin" },
							["@function.call"] = { link = "TSFunctionCall" },
							["@function.macro"] = { link = "TSFuncMacro" },
							["@include"] = { link = "TSInclude" },
							["@keyword"] = { link = "TSKeyword" },
							["@keyword.function"] = { link = "TSKeywordFunction" },
							["@keyword.operator"] = { link = "TSKeywordOperator" },
							["@keyword.return"] = { link = "TSKeywordReturn" },
							["@label"] = { link = "TSLabel" },
							["@math"] = { link = "TSMath" },
							["@method"] = { link = "TSMethod" },
							["@method.call"] = { link = "TSMethodCall" },
							["@namespace"] = { link = "TSNamespace" },
							["@none"] = { link = "TSNone" },
							["@number"] = { link = "TSNumber" },
							["@operator"] = { link = "TSOperator" },
							["@parameter"] = { link = "TSParameter" },
							["@parameter.reference"] = { link = "TSParameterReference" },
							["@preproc"] = { link = "TSPreProc" },
							["@property"] = { link = "TSProperty" },
							["@punctuation.bracket"] = { link = "TSPunctBracket" },
							["@punctuation.delimiter"] = { link = "TSPunctDelimiter" },
							["@punctuation.special"] = { link = "TSPunctSpecial" },
							["@repeat"] = { link = "TSRepeat" },
							["@storageclass"] = { link = "TSStorageClass" },
							["@storageclass.lifetime"] = { link = "TSStorageClassLifetime" },
							["@strike"] = { link = "TSStrike" },
							["@string"] = { link = "TSString" },
							["@string.escape"] = { link = "TSStringEscape" },
							["@string.regex"] = { link = "TSStringRegex" },
							["@string.special"] = { link = "TSStringSpecial" },
							["@symbol"] = { link = "TSSymbol" },
							["@tag"] = { link = "TSTag" },
							["@tag.attribute"] = { link = "TSTagAttribute" },
							["@tag.delimiter"] = { link = "TSTagDelimiter" },
							["@text"] = { link = "TSText" },
							["@text.danger"] = { link = "TSDanger" },
							["@text.diff.add"] = { link = "diffAdded" },
							["@text.diff.delete"] = { link = "diffRemoved" },
							["@text.emphasis"] = { link = "TSEmphasis" },
							["@text.environment"] = { link = "TSEnvironment" },
							["@text.environment.name"] = { link = "TSEnvironmentName" },
							["@text.literal"] = { link = "TSLiteral" },
							["@text.math"] = { link = "TSMath" },
							["@text.note"] = { link = "TSNote" },
							["@text.reference"] = { link = "TSTextReference" },
							["@text.strike"] = { link = "TSStrike" },
							["@text.strong"] = { link = "TSStrong" },
							["@text.title"] = { link = "TSTitle" },
							["@text.todo"] = { link = "TSTodo" },
							["@text.todo.checked"] = { link = "Green" },
							["@text.todo.unchecked"] = { link = "Ignore" },
							["@text.underline"] = { link = "TSUnderline" },
							["@text.uri"] = { link = "TSURI" },
							["@text.warning"] = { link = "TSWarning" },
							["@todo"] = { link = "TSTodo" },
							["@type"] = { link = "TSType" },
							["@type.builtin"] = { link = "TSTypeBuiltin" },
							["@type.definition"] = { link = "TSTypeDefinition" },
							["@type.qualifier"] = { link = "TSTypeQualifier" },
							["@uri"] = { link = "TSURI" },
							["@variable"] = { link = "TSVariable" },
							["@variable.builtin"] = { link = "TSVariableBuiltin" },

							["@lsp.type.class"] = { link = "TSType" },
							["@lsp.type.comment"] = { link = "TSComment" },
							["@lsp.type.decorator"] = { link = "TSFunction" },
							["@lsp.type.enum"] = { link = "TSType" },
							["@lsp.type.enumMember"] = { link = "TSProperty" },
							["@lsp.type.events"] = { link = "TSLabel" },
							["@lsp.type.function"] = { link = "TSFunction" },
							["@lsp.type.interface"] = { link = "TSType" },
							["@lsp.type.keyword"] = { link = "TSKeyword" },
							["@lsp.type.macro"] = { link = "TSConstMacro" },
							["@lsp.type.method"] = { link = "TSMethod" },
							["@lsp.type.modifier"] = { link = "TSTypeQualifier" },
							["@lsp.type.namespace"] = { link = "TSNamespace" },
							["@lsp.type.number"] = { link = "TSNumber" },
							["@lsp.type.operator"] = { link = "TSOperator" },
							["@lsp.type.parameter"] = { link = "TSParameter" },
							["@lsp.type.property"] = { link = "TSProperty" },
							["@lsp.type.regexp"] = { link = "TSStringRegex" },
							["@lsp.type.string"] = { link = "TSString" },
							["@lsp.type.struct"] = { link = "TSType" },
							["@lsp.type.type"] = { link = "TSType" },
							["@lsp.type.typeParameter"] = { link = "TSTypeDefinition" },
							["@lsp.type.variable"] = { link = "TSVariable" },
						}
					end,
					latte = function(colors)
						return {
							IblIndent = { fg = colors.mantle },
							IblScope = { fg = colors.surface1 },

							LineNr = { fg = colors.surface1 },
						}
					end,
				},
			})

			vim.api.nvim_command("colorscheme catppuccin")
		end,
		enabled = not vim.g.vscode
	},
	-- Colorizer for color codes
	{
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				filetypes = { "*" },
				user_default_options = {
					RGB = true, -- #RGB hex codes
					RRGGBB = true, -- #RRGGBB hex codes
					names = true, -- "Name" codes like Blue or blue
					RRGGBBAA = true, -- #RRGGBBAA hex codes
					AARRGGBB = true, -- 0xAARRGGBB hex codes
					rgb_fn = true, -- CSS rgb() and rgba() functions
					hsl_fn = true, -- CSS hsl() and hsla() functions
					css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
					css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn

					-- Available modes for `mode`: foreground, background,  virtualtext
					mode = "background", -- Set the display mode.
					-- Available methods are false / true / "normal" / "lsp" / "both"
					-- True is same as normal
					tailwind = true, -- Enable tailwind colors

					-- parsers can contain values used in |user_default_options|
					sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
					virtualtext = "■",
					-- update color values even if buffer is not focused
					-- example use: cmp_menu, cmp_docs
					always_update = true,
				},
				-- all the sub-options of filetypes apply to buftypes
			buftypes = {},
			})
		end,
		enabled = not vim.g.vscode
	},
	-- UI enhancements
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		enabled = not vim.g.vscode
	},
	-- barbar "Buffer Tabs"
	{
		'romgrk/barbar.nvim',
		dependencies = { 
			'nvim-tree/nvim-web-devicons', -- Optional dependency for icons
			{
				"kazhala/close-buffers.nvim",
				event = "BufRead",
				-- Commands:
				-- :Bdelete this | other | all | hidden | modified
				-- add bang (!) to force delete
				--     Map("n", "<leader>k", ":BDelete this<CR>")
				--     Map("n", "<leader>ko", ":BDelete other<CR>")
				--     Map("n", "<leader>kA", ":BDelete all<CR>")
			}
		}, 
		init = function() vim.g.barbar_auto_setup = false end,
		config = function()
			require'barbar'.setup({
				-- Enable/disable auto-hiding the tab bar when there is a single buffer
				auto_hide = false,
				-- Enable/disable current/total tabpages indicator (top right corner)
				tabpages = true,
				-- Enables/disable clickable tabs
				--  - left-click: go to buffer
				--  - middle-click: delete buffer
				clickable = true,

				-- Excludes buffers from the tabline
				-- exclude_ft = {'javascript'},
				-- exclude_name = {'package.json'},

				-- A buffer to this direction will be focused (if it exists) when closing the current buffer.
				-- Valid options are 'left' (the default), 'previous', and 'right'
				focus_on_close = 'left',
				-- Hide inactive buffers and file extensions. Other options are `alternate`, `current`, and `visible`.
				hide = {extensions = false, inactive = false},
				-- Disable highlighting alternate buffers
				highlight_alternate = false,
				-- Disable highlighting file icons in inactive buffers
				highlight_inactive_file_icons = false,
				-- Enable highlighting visible buffers
				highlight_visible = true,
				-- Other settings
				maximum_length = 30,
				maximum_padding = 1,
				semantic_letters = true,
				-- If true, new buffers will be inserted at the start/end of the list.
				-- Default is to insert after current buffer.
				insert_at_end = false,
				insert_at_start = false,

				-- New buffer letters are assigned in this order. This order is
				-- optimal for the qwerty keyboard layout but might need adjustment
				-- for other layouts.
				letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',
				-- Sets the name of unnamed buffers. By default format is "[Buffer X]"
				-- where X is the buffer number. But only a static string is accepted here.
				no_name_title = nil,

				-- Set the filetypes which barbar will offset itself for
				sidebar_filetypes = {
					-- Use the default values: {event = 'BufWinLeave', text = '', align = 'left'}
					NvimTree = true,
					-- Or, specify the text used for the offset:
					undotree = {
						text = 'undotree',
						align = 'center', -- *optionally* specify an alignment (either 'left', 'center', or 'right')
					},
					-- Or, specify the event which the sidebar executes when leaving:
					['neo-tree'] = {event = 'BufWipeout'},
					-- Or, specify all three
					Outline = {event = 'BufWinLeave', text = 'symbols-outline', align = 'right'},
				},

				icons = {
					-- Configure the base icons on the bufferline.
					-- Valid options to display the buffer index and -number are `true`, 'superscript' and 'subscript'
					buffer_index = false,
					buffer_number = false,
					button = '',
					-- -- Enables / disables diagnostic symbols
					-- diagnostics = {
					-- 	[vim.diagnostic.severity.ERROR] = {enabled = true, icon = 'ﬀ'},
					-- 	[vim.diagnostic.severity.WARN] = {enabled = false},
					-- 	[vim.diagnostic.severity.INFO] = {enabled = false},
					-- 	[vim.diagnostic.severity.HINT] = {enabled = true},
					-- },
					gitsigns = {
						added = {enabled = true, icon = '+'},
						changed = {enabled = true, icon = '~'},
						deleted = {enabled = true, icon = '-'},
					},
					filetype = {
						-- Sets the icon's highlight group.
						-- If false, will use nvim-web-devicons colors
						custom_colors = false,

						-- Requires `nvim-web-devicons` if `true`
						enabled = true,
					},
					separator = {left = '▎', right = ''},

					-- If true, add an additional separator at the end of the buffer list
					separator_at_end = true,

					-- Configure the icons on the bufferline when modified or pinned.
					-- Supports all the base icon options.
					modified = {button = '●'},
					pinned = {button = '', filename = true},

					-- Use a preconfigured buffer appearance— can be 'default', 'powerline', or 'slanted'
					preset = 'default',

					-- Configure the icons on the bufferline based on the visibility of a buffer.
					-- Supports all the base icon options, plus `modified` and `pinned`.
					alternate = {filetype = {enabled = false}},
					current = {buffer_index = true},
					inactive = {button = '×'},
					visible = {modified = {buffer_number = false}},
				},

			})

			-- barbar Keymaps
			-- Navigate buffers
			-- map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
			-- map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
			Map('n', '<Tab>', ':BufferNext<CR>')
			Map('n', '<S-Tab>', ':BufferPrevious<CR>')
			Map('n', ']b', ':BufferNext<CR>')
			Map('n', '[b', ':BufferPrevious<CR>')

			-- Goto buffer in position
			Map('n', '<A-1>', ':BufferGoto 1<CR>')
			Map('n', '<A-2>', ':BufferGoto 2<CR>')
			Map('n', '<A-3>', ':BufferGoto 3<CR>')
			Map('n', '<A-4>', ':BufferGoto 4<CR>')
			Map('n', '<A-5>', ':BufferGoto 5<CR>')
			Map('n', '<A-6>', ':BufferGoto 6<CR>')
			Map('n', '<A-7>', ':BufferGoto 7<CR>')
			Map('n', '<A-8>', ':BufferGoto 8<CR>')
			Map('n', '<A-9>', ':BufferGoto 9<CR>')
			Map('n', '<A-$>', ':BufferLast<CR>')

			-- Pin/unpin buffer
			Map('n', '<leader>bp', ':BufferPin<CR>')
			Map('n', '<A-S-p>', ':BufferPin<CR>')

			-- Close buffer
			-- Map('n', '<leader>bc', ':BufferClose<CR>')
			-- Map('n', '<leader>ba', ':BufferCloseAll<CR>')
			Map('n', '<A-q>', ':BufferClose<CR>')
			Map("n", "<A-Q>", ":BDelete all<CR>")
			Map('n', '<leader>bac', ':BufferCloseAllButCurrent<CR>')
			Map('n', '<leader>bap', ':BufferCloseAllButPinned<CR>')
			-- Close commands
			--                 :BufferClose
			--                 :BufferCloseAll
			--                 :BufferCloseAllButCurrent
			--                 :BufferCloseAllButPinned
			--                 :BufferCloseAllButCurrentOrPinned
			--                 :BufferCloseBuffersLeft
			--                 :BufferCloseBuffersRight

			-- Sort automatically by...
			Map('n', '<leader>bb', ':BufferOrderByBufferNumber<CR>')
			Map('n', '<leader>bd', ':BufferOrderByDirectory<CR>')
			Map('n', '<leader>bl', ':BufferOrderByLanguage<CR>')
			Map('n', '<leader>be', ':BufferOrderByExtension<CR>')
			-- Map('n', '<leader>bw', ':BufferOrderByWindowNumber<CR>')

			-- Re-order buffers
			-- Map('n', '<leader>bn', ':BufferMoveNext<CR>')
			-- Map('n', '<leader>bp', ':BufferMovePrevious<CR>')
			Map('n', '<A-.>', ':BufferMoveNext<CR>')
			Map('n', '<A-,>', ':BufferMovePrevious<CR>')

			-- -- Magic buffer-picking mode
			-- map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)

		end,
		enabled = not vim.g.vscode
	},
	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		-- event = 'UIEnter',
		dependencies = 
			{ 
				{
					-- icons
					-- https://www.nerdfonts.com/cheat-sheet 
					"nvim-tree/nvim-web-devicons"
					-- , Lazy = true
				},
				{
					"SmiteshP/nvim-navic",
					dependencies = {"neovim/nvim-lspconfig"}
				},
				-- {
				-- 	"folke/trouble.nvim",
				-- 	branch = "dev",
				-- }
				-- {
				-- 	'nvimdev/lspsaga.nvim',
				-- 	dependencies = {
				-- 		'nvim-treesitter/nvim-treesitter', -- optional
				-- 		'nvim-tree/nvim-web-devicons',     -- optional
				-- 	}
				-- }
				-- {
				-- 	"nvimdev/lspsaga.nvim",
				-- 	-- lazy = true,
				-- 	event = { "LspAttach" },
				-- 	dependencies = {
				-- 		"neovim/nvim-lspconfig",
				-- 		"nvim-treesitter/nvim-treesitter",
				-- 	},
				-- },
		},
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status") -- to configure lazy pending updates count
			-- local navic = require("nvim-navic")

			-- local trouble = require("trouble")
			-- if not trouble.statusline then
			-- 	print("You have enabled the **trouble-v3** extra,\nbut still need to update it with `:Lazy`")
			-- end
			-- local symbols = trouble.statusline({
			-- 	mode = "lsp_document_symbols",
			-- 	-- mode = "symbols",
			-- 	groups = {},
			-- 	title = false,
			-- 	filter = { range = true },
			-- 	format = "{kind_icon}{symbol.name:Normal}",
			-- 	-- The following line is needed to fix the background color
			-- 	-- Set it to the lualine section you want to use
			-- 	hl_group = "lualine_c_normal",
			-- })

			local function lspClients()
				local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
				local clients = vim.lsp.get_clients()
				if next(clients) == nil then
					return ''
				end
				for _, client in ipairs(clients) do
					local filetypes = client.config.filetypes
					if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
						return client.name
					end
				end
				return ''
			end

			-- local item_navic = {
			-- 	function()
			-- 		return require('nvim-navic').get_location()
			-- 	end,
			-- 	cond = function()
			-- 		return require('nvim-navic').is_available()
			-- 	end,
			-- }

			local lspsaga = require('lspsaga')
			lspsaga.setup({})
			local lspsaga_bar = require("lspsaga.symbol.winbar")

			local function breadcrumbs()
				local bar = lspsaga_bar.get_bar()
				-- local bar = require('nvim-navic').get_location()
				if bar == nil then
					return ""
				end
				return bar
			end


			lualine.setup({
				options = {
					theme = "catppuccin",
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = ""},
					disabled_filetypes = {
						"NvimTree",
						"toggleterm",
					}
				},
				icons_enabled = true,
				tabline = {},
				globalstatus = true,
				sections = {
					lualine_a = { 'mode',
						{
							-- function()
							-- 		return navic.get_location()
							-- end,
							-- cond = function()
							-- 		return navic.is_available()
							-- end
						}
					},
					lualine_b = { 'branch', 'diff', 'diagnostics' },
					lualine_c = 
						{ 
							-- {
							-- 	"navic",

							-- 	-- Component specific options
							-- 	color_correction = nil, -- Can be nil, "static" or "dynamic". This option is useful only when you have highlights enabled.
							-- 													-- Many colorschemes don't define same backgroud for nvim-navic as their lualine statusline backgroud.
							-- 													-- Setting it to "static" will perform a adjustment once when the component is being setup. This should
							-- 													--   be enough when the lualine section isn't changing colors based on the mode.
							-- 													-- Setting it to "dynamic" will keep updating the highlights according to the current modes colors for
							-- 													--   the current section.

							-- 	navic_opts = nil  -- lua table with same format as setup's option. All options except "lsp" options take effect when set here.
							-- },
							{
								'filename',
								-- path = 0,
							},
							-- {
							-- 	symbols.get,
							-- 	cond = symbols.has,
							-- }
							-- symbols = {
							-- 	-- modified = "[+]",
							-- 	-- readonly = "[-]",
							-- 	unnamed = "Empty Buffer",
							-- 	newfile = "New File",
							-- }
					},
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
							color = { fg = "#ff9e64" }
						},
						{
							lspClients,
							icon = ' ',
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
					lualine_y = { 'progress', 'searchcount' },
					lualine_z = { 
						'location',
						-- function() return navic.get_location() end 
					}
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { 'filename' },
					lualine_x = { 'location' },
					lualine_y = {},
					lualine_z = {}
				},
				winbar = {
					lualine_a = {
						-- function() return navic.get_location() end
						-- {
						-- 	'filename',
						-- 	path = 1,
						-- }
					},
					lualine_b = {

					},
					lualine_c = {
						{
							breadcrumbs
						},
						-- {
						-- 	-- function()
						-- 	-- 		return navic.get_location()
						-- 	-- end,
						-- 	-- cond = function()
						-- 	-- 		return navic.is_available()
						-- 	-- end
						-- }
					},
					lualine_x = {
						{
							'datetime',
							style = '%a %d-%m-%Y %I:%M:%S %p',
						}
					},
					lualine_y = {

					},
					lualine_z = {
					}
				},
				inactive_winbar = {
					lualine_a = {
						-- function() return navic.get_location() end
					},
					lualine_b = {
						-- {
						-- 	breadcrumbs
						-- },
					},
					lualine_c = {
						{
							breadcrumbs
						},
						-- {
						-- 	'filename',
						-- 	path = 1,
						-- }
						-- {
						-- 	-- function()
						-- 	-- 		return navic.get_location()
						-- 	-- end,
						-- 	-- cond = function()
						-- 	-- 		return navic.is_available()
						-- 	-- end
						-- }
					},
					lualine_x = {
						{
							'datetime',
							style = '%a %d-%m-%Y %I:%M:%S %p',
						}
					},
					lualine_y = {

					},
					lualine_z = {

					}
				},
				extensions = {}
				}
			)
		end,
		enabled = not vim.g.vscode
	},
	-- Indentation guides
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPre", "BufNewFile" },
		main = "ibl",
		opts = {
			indent = { char = "┊" },
		},
		enabled = not vim.g.vscode
	},
	-- Dashboard
	{
		'nvimdev/dashboard-nvim',
		event = 'VimEnter',
		config = function()
			require('dashboard').setup({
				theme = 'hyper',
				config = {
					week_header = {
						enable = true,
					},
					shortcut = {
						{ desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
						{
							icon = ' ',
							icon_hl = '@variable',
							desc = 'Files',
							group = 'Label',
							action = 'Telescope find_files',
							key = 'f',
						},
						{
							desc = ' Apps',
							group = '@method',
							-- action = 'Telescope app',
							key = 'a',
						},
						{
							desc = ' dotfiles',
							group = 'Number',
							action = 'Telescope find_files cwd=~/.config/nvim',
							key = 'd',
						},
					},
					-- show how many plugins neovim loaded
					-- packages = { enable = true },
					-- footer = {}, -- footer
				},
			})
		end,
		dependencies = { {'nvim-tree/nvim-web-devicons'}},
		enabled = not vim.g.vscode
	},
	-- noice Enhanced UI notifications
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			{
				"rcarriga/nvim-notify",
				opts = {
					timeout = 1000,
					-- background_colour = "#292828",
				},
			}
		},
		config = function ()
			local function myMiniView(pattern, kind)
				kind = kind or ""
				return {
					view = "mini",
					filter = {
						event = "msg_show",
						kind = kind,
						find = pattern,
					},
				}
			end

			local function hiddenView(pattern)
				return {
					filter = {
						event = "msg_show",
						kind = "",
						find = pattern,
					},
					opts = { skip = true },
				}
			end

			local noice = require("noice")

			noice.setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
						["vim.lsp.handlers['textDocument/signatureHelp']"] = true,
					},
					signature = { enabled = false },
				},
				messages = {
					enabled = true, -- enables the Noice messages UI
					view = "mini", -- default view for messages
					view_error = "mini", -- view for errors
					view_warn = "mini", -- view for warnings
					view_history = "messages", -- view for :messages
					view_search = "mini", -- view for search count messages. Set to `false` to disable
				},
				presets = {
					bottom_search = false,
					command_palette = false, 
					long_message_to_split = true,
					inc_rename = false,
					lsp_doc_border = false, 
				},
				routes = {
					{
						filter = {
							event = "msg_show",
							kind = "search_count",
						},
						opts = { skip = true },
					},
					myMiniView("written"),
					hiddenView("yanked"),
					hiddenView("Already at .* change"),
					hiddenView("more lines?"),
					hiddenView("fewer lines?"),
					hiddenView("change; before"),
					hiddenView("change; after"),
					hiddenView("line less"),
					hiddenView("lines indented"),
					hiddenView("No lines in buffer"),
					myMiniView("search hit .*, continuing at", "wmsg"),
					myMiniView("E486: Pattern not found", "emsg"),
					-- filter = {
					-- 	event = "msg_show",
					-- 	any = {
					-- 		{ find = "%d+L, %d+B" },
					-- 		{ find = "; after #%d+" },
					-- 		{ find = "; before #%d+" },
					-- 		},
					-- },
					-- opts = { skip = true },
				},
				views = {
					mini = {
						zindex = 100,
						win_options = { winblend = 0 },
					},
					cmdline_popup = {
						position = {
							row = 20,
							col = "50%",
						},
						size = {
							width = 60,
							height = "auto",
						},
					},
				},
			})
		end,
		enabled = not vim.g.vscode
	},
	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		-- cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function() vim.fn["mkdp#util#install"]() end,
		enabled = not vim.g.vscode

		-- Commands
		-- " Start the preview
		-- :MarkdownPreview

		-- " Stop the preview"
		-- :MarkdownPreviewStop
	},
	-- Show code context (Pin start methods when scrolling)
	{
		'nvim-treesitter/nvim-treesitter-context',
		--   config = true -- (basic config)
		config = function()
            local ts_context = require('treesitter-context')
			ts_context.setup({
				enable = false, -- Enable this plugin (Can be enabled/disabled later via commands)
				max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
				trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				min_window_height = 10, -- Minimum height of the window, content will be truncated if necessary.
				line_numbers = true,
				multiline_threshold = 20,
				patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
					-- For all filetypes
					-- Note that setting an entry here replaces all other patterns for this entry.
					-- By setting the 'default' entry below, you can control which nodes you want to
					-- appear in the context window.
					default = {
						'class',
						'function',
						'method',
						-- 'for', -- These won't appear in the context
						-- 'while',
						-- 'if',
						-- 'switch',
						-- 'case',
					},
					-- Example for a specific filetype.
					-- If a pattern is missing, *open a PR* so everyone can benefit.
					--   rust = {
					--       'impl_item',
					--   },
				},
				exact_patterns = {
					-- Example for a specific filetype with Lua patterns
					-- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
					-- exactly match "impl_item" only)
					-- rust = true,
				},

				-- [!] The options below are exposed but shouldn't require your attention,
				--     you can safely ignore them.

				zindex = 20, -- The Z-index of the context window
				mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
				separator = '-', -- Separator between context and content. Should be a single character string, like '-'.
			})
            
            -- Treesitter context keymaps
            Map('n', '<leader>ct', ts_context.toggle, { desc = 'Toggle Treesitter Context' })
		end,
		enabled = not vim.g.vscode
	},
}
