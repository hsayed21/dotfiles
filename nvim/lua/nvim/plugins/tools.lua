return
{
  -- File explorer
  {
    -- nvim-tree File explorer
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        -- disable netrw to avoid conflicts
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        local function find_directory_and_focus()
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          local function open_nvim_tree(prompt_bufnr, _)
            actions.select_default:replace(function()
              local api = require("nvim-tree.api")

              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              api.tree.open()
              api.tree.find_file(selection.cwd .. "/" .. selection.value)
            end)
            return true
          end

          require("telescope.builtin").find_files({
            find_command = { "fd", "--type", "directory", "--hidden", "--exclude", ".git/*" },
            attach_mappings = open_nvim_tree,
          })
        end

        -- nvim-tree File explorer Keymaps

        -- Main Shortcuts:
        -- <leader><C-e> - toggle tree with current file selected
        -- a - create a file or directory
        -- d - remove a file or directory
        -- r - rename a file or directory
        -- e - rename without extension
        -- u - rename full path
        -- c - copy
        -- x - cut
        -- p - paste

        -- <CR> - expand dir / open file
        -- W - collapse
        -- E - expand recursively
        -- <tab> - expand dir / preview file
        -- P - parent directory
        -- t - close parent directory for current file
        -- h - Horizontal split
        -- v - Vertical split
        -- L - Vsplit preview
        -- - - Up a directory to the parebt
        -- C / <C-]> - cd to the focus directory
        -- l - edit or open file then close tree
        -- s - open dir or open file as external

        -- ? - help

        -- Map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
        Map("n", "<leader>ee", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" })
        -- Map("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
        Map("n", "<leader>fd", find_directory_and_focus, { desc = "Find directory with telescope and focus in NvimTree" })

        local function my_on_attach(bufnr)
          local api = require("nvim-tree.api")

          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- open as vsplit on current node
          local function vsplit_preview()
            local node = api.tree.get_node_under_cursor()

            if node.nodes ~= nil then
              -- expand or collapse folder
              api.node.open.edit()
            else
              -- open file as vsplit
              api.node.open.vertical()
            end

            -- Finally refocus on tree if it was lost
            api.tree.focus()
          end

          local function edit_or_open()
            local node = api.tree.get_node_under_cursor()

            if node.nodes ~= nil then
              -- expand or collapse folder
              api.node.open.edit()
            else
              -- open file
              api.node.open.edit()
              -- Close the tree if file was opened
              api.tree.close()
            end
          end

          -- default mappings
          api.config.mappings.default_on_attach(bufnr)

          -- custom mappings
          vim.keymap.set('n', '?',     api.tree.toggle_help,                  opts('Help'))
          vim.keymap.set('n', 't', api.node.navigate.parent_close, opts('Close Directory'))
          -- vertical split, horizontal split
          -- vim.keymap.set('n', '<C-v>',   api.node.open.vertical,              opts('Open: Vertical Split'))
          -- vim.keymap.set('n', '<C-x>',   api.node.open.horizontal,            opts('Open: Horizontal Split'))
          vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
          vim.keymap.set('n', 'h', api.node.open.horizontal, opts('Open: Horizontal Split'))
          vim.keymap.set("n", "L", vsplit_preview,        opts("Vsplit Preview"))
          vim.keymap.set("n", "l", edit_or_open,          opts("Edit Or Open"))
          vim.keymap.set("n", "C", api.tree.change_root_to_node, opts "CD")
        end

        require("nvim-tree").setup({
          disable_netrw = true,
          hijack_netrw = true,
          update_cwd = true,
          sync_root_with_cwd = true, -- from project.nvim
          respect_buf_cwd = true, -- from project.nvim
          sort_by = "case_sensitive",
          view = {
            cursorline = true,
            side = "left",
            width = {
              padding = 0,
              min = 30,
            },
            relativenumber = true,
          },
          filters = {
            dotfiles = false,
          },
          renderer = {
            highlight_opened_files = "name",
            highlight_modified = "name",
            full_name = true,
            indent_markers = {
              enable = true,
            },
            icons = {
              glyphs = {
                default = "",
                  symlink = "",
                  git = {
                    unstaged = "",
                    staged = "S",
                    unmerged = "",
                    renamed = "➜",
                    deleted = "",
                    untracked = "U",
                    ignored = "◌",

                    -- unstaged = "✗",
                    -- staged = "✓",
                    -- unmerged = "",
                    -- renamed = "➜",
                    -- untracked = "★",
                    -- deleted = "",
                    -- ignored = "◌",
                  },
                  folder = {
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                  },
                -- folder = {
                --   arrow_closed = "", -- arrow when folder is closed
                --   arrow_open = "", -- arrow when folder is open
                -- },
              },
            },
          },
          git = {
            enable = true,
            ignore = false,
            timeout = 500,
          },
          update_focused_file = {
            enable = true,
            update_cwd = true,
            update_root = true, -- from project.nvim
            ignore_list = {},
          },
          diagnostics = {
            enable = true,
            icons = {
              hint = "",
              info = "",
              warning = "",
              error = "",
            },
          },
          on_attach = my_on_attach,
        })

      end,
      enabled = not vim.g.vscode
    },
    -- oil File explorer
    {
      "stevearc/oil.nvim",
      -- Optional dependencies
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("oil").setup({
          -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
          -- Set to false if you still want to use netrw.
          default_file_explorer = false,
          -- Id is automatically added at the beginning, and name at the end
          -- See :help oil-columns
          columns = {
            "icon",
            -- "permissions",
            -- "size",
            -- "mtime",
          },
          -- Buffer-local options to use for oil buffers
          buf_options = {
            buflisted = false,
            bufhidden = "hide",
          },
          -- Window-local options to use for oil buffers
          win_options = {
            wrap = false,
            signcolumn = "no",
            cursorcolumn = false,
            foldcolumn = "0",
            spell = false,
            list = false,
            conceallevel = 3,
            concealcursor = "nvic",
          },
          -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
          delete_to_trash = false,
          -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
          skip_confirm_for_simple_edits = false,
          -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
          -- (:help prompt_save_on_select_new_entry)
          prompt_save_on_select_new_entry = true,
          -- Oil will automatically delete hidden buffers after this delay
          -- You can set the delay to false to disable cleanup entirely
          -- Note that the cleanup process only starts when none of the oil buffers are currently displayed
          cleanup_delay_ms = 2000,
          lsp_file_methods = {
            -- Time to wait for LSP file operations to complete before skipping
            timeout_ms = 1000,
            -- Set to true to autosave buffers that are updated with LSP willRenameFiles
            -- Set to "unmodified" to only save unmodified buffers
            autosave_changes = false,
          },
          -- Constrain the cursor to the editable parts of the oil buffer
          -- Set to `false` to disable, or "name" to keep it on the file names
          constrain_cursor = "editable",
          -- Set to true to watch the filesystem for changes and reload oil
          experimental_watch_for_changes = false,
          -- Keymaps in oil buffer. Can be any value that `Map` accepts OR a table of keymap
          -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
          -- Additionally, if it is a string that matches "actions.<name>",
          -- it will use the mapping at require("oil.actions").<name>
          -- Set to `false` to remove a keymap
          -- See :help oil-actions for a list of all available actions
          keymaps = {
            ["g?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["<C-s>"] = "actions.select_vsplit",
            ["<C-h>"] = "actions.select_split",
            ["<C-t>"] = "actions.select_tab",
            ["<C-p>"] = "actions.preview",
            ["<C-c>"] = "actions.close",
            ["<C-l>"] = "actions.refresh",
            ["-"] = "actions.parent",
            ["_"] = "actions.open_cwd",
            ["`"] = "actions.cd",
            ["~"] = "actions.tcd",
            ["gs"] = "actions.change_sort",
            ["gx"] = "actions.open_external",
            ["g."] = "actions.toggle_hidden",
            ["g\\"] = "actions.toggle_trash",
          },
          -- Configuration for the floating keymaps help window
          keymaps_help = {
            border = "rounded",
          },
          -- Set to false to disable all of the above keymaps
          use_default_keymaps = true,
          view_options = {
            -- Show files and directories that start with "."
            show_hidden = false,
            -- This function defines what is considered a "hidden" file
            is_hidden_file = function(name, bufnr)
              return vim.startswith(name, ".")
            end,
            -- This function defines what will never be shown, even when `show_hidden` is set
            is_always_hidden = function(name, bufnr)
              return false
            end,
            -- Sort file names in a more intuitive order for humans. Is less performant,
            -- so you may want to set to false if you work with large directories.
            natural_order = true,
            sort = {
              -- sort order can be "asc" or "desc"
              -- see :help oil-columns to see which columns are sortable
              { "type", "asc" },
              { "name", "asc" },
            },
          },
          -- Configuration for the floating window in oil.open_float
          float = {
            -- Padding around the floating window
            padding = 2,
            max_width = 0,
            max_height = 0,
            border = "rounded",
            win_options = {
              winblend = 0,
            },
            -- This is the config that will be passed to nvim_open_win.
            -- Change values here to customize the layout
            override = function(conf)
              return conf
            end,
          },
          -- Configuration for the actions floating preview window
          preview = {
            -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_width and max_width can be a single value or a list of mixed integer/float types.
            -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
            max_width = 0.9,
            -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
            min_width = { 40, 0.4 },
            -- optionally define an integer/float for the exact width of the preview window
            width = nil,
            -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_height and max_height can be a single value or a list of mixed integer/float types.
            -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
            max_height = 0.9,
            -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
            min_height = { 5, 0.1 },
            -- optionally define an integer/float for the exact height of the preview window
            height = nil,
            border = "rounded",
            win_options = {
              winblend = 0,
            },
            -- Whether the preview window is automatically updated when the cursor is moved
            update_on_cursor_moved = true,
          },
          -- Configuration for the floating progress window
          progress = {
            max_width = 0.9,
            min_width = { 40, 0.4 },
            width = nil,
            max_height = { 10, 0.9 },
            min_height = { 5, 0.1 },
            height = nil,
            border = "rounded",
            minimized_border = "none",
            win_options = {
              winblend = 0,
            },
          },
          -- Configuration for the floating SSH window
          ssh = {
            border = "rounded",
          },
        })

        -- Oil File explorer Keymaps
        Map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      end,
      enabled = not vim.g.vscode
    },
  },
  -- Telescope Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        -- cond = function()
        -- 	return vim.fn.executable("make") == 1
        -- end,
      },
      {
        "nvim-telescope/telescope-ui-select.nvim",
      },
      {
        "jvgrootveld/telescope-zoxide",
      },
      {
        "folke/trouble.nvim",
      },
      {
        "aaronhallaert/advanced-git-search.nvim"
      },
      {
        "natecraddock/workspaces.nvim",
      },
      {
        "nvim-telescope/telescope-project.nvim",
        dependencies = {"nvim-telescope/telescope-file-browser.nvim"}

        -- telescope-project.nvim keymaps
        -- virual mode i
        -- <c-s>	search inside files within your project
        -- <c-b>	browse inside files within your project

        -- normal mode
        -- s   search inside files within your project
        -- b   browse inside files within your project
      },
      {
        "ahmedkhalf/project.nvim"
      }
    },
    config = function()

      -- Documentation for telescope options with pickers and buildin functions
      -- https://github.com/nvim-telescope/telescope.nvim/blob/c392f1b78eaaf870ca584bd698e78076ed301b26/doc/telescope.txt

      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local trouble = require("trouble.providers.telescope")
      local action_layout = require("telescope.actions.layout")
      local action_state = require("telescope.actions.state")
      local project_actions = require("telescope._extensions.project.actions")

      -- Custom action to reveal file or folder in File Explorer on Windows
      local function reveal_in_file_explorer(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry or not entry.path then
          print("No file or folder selected.")
          return
        end
        local path = entry.path:gsub('/', '\\')
        local is_directory = vim.loop.fs_stat(path).type == "directory"

        -- Use PowerShell to open the file or folder in File Explorer
        local command
        if is_directory then
          command = 'powershell.exe -NoProfile -Command "Invoke-Item -Path \'' .. path .. '\'"'
        else
          local dir = path:match("(.*)\\")
          command = 'powershell.exe -NoProfile -Command "Invoke-Item -Path \'' .. dir .. '\'"'
        end
        os.execute(command)
      end

      local telescope_custom_actions = {}

      function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
          local picker = action_state.get_current_picker(prompt_bufnr)
          local selected_entry = action_state.get_selected_entry()
          local num_selections = #picker:get_multi_selection()
          if not num_selections or num_selections <= 1 then
              actions.add_selection(prompt_bufnr)
          end
          actions.send_selected_to_qflist(prompt_bufnr)
          vim.cmd("cfdo " .. open_cmd)
      end
      function telescope_custom_actions.multi_selection_open_vsplit(prompt_bufnr)
          telescope_custom_actions._multiopen(prompt_bufnr, "vsplit")
      end
      function telescope_custom_actions.multi_selection_open_split(prompt_bufnr)
          telescope_custom_actions._multiopen(prompt_bufnr, "split")
      end
      function telescope_custom_actions.multi_selection_open_tab(prompt_bufnr)
          telescope_custom_actions._multiopen(prompt_bufnr, "tabe")
      end
      function telescope_custom_actions.multi_selection_open(prompt_bufnr)
          telescope_custom_actions._multiopen(prompt_bufnr, "edit")
      end

      telescope.setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          advanced_git_search = {
            git_flags = { "-c", "delta.side-by-side=false", "-c", "core.pager=delta", "-c", "delta.pager='less -RS'" },
            git_diff_flags = {},
            show_builtin_git_pickers = true,
            diff_plugin = "diffview",
            layout_config = {
              horizontal = {
                preview_width = 0.6,
              },
            },
          },
          project = {
            base_dirs = {
              vim.env.SystemDrive .. "/Posbank_Projects/POPs Restaurant 6.0.0.000",
              vim.env.SystemDrive .. "/Posbank_Projects/POPs Retail Git",
              vim.env.SystemDrive .. "/Posbank_Projects/POPs Public API",
              vim.env.SystemDrive .. "/Posbank_Projects/MenuTree-Git",
              os.getenv("SystemDrive") .. "/Posbank_Projects/MenuTree-Frontend",
              vim.env.SystemDrive .. "/Posbank_Projects/POPs KDS",
              vim.env.LOCALAPPDATA .. "/nvim",
              "G:/My Drive/_MyAutohotkey",

              -- {path = '~/dev/src5', max_depth = 2},
            },
            hidden_files = true, -- default: false
            theme = "dropdown",
            order_by = "asc",
            -- order_by = "recent",
            -- search_by = "title",
            display_type = "full",
            sync_with_nvim_tree = true, -- default false
            -- default for on_project_selected = find project files
            on_project_selected = function(prompt_bufnr)
              -- Do anything you want in here. For example:
              project_actions.change_working_directory(prompt_bufnr, false)
              -- require("harpoon.ui").nav_file(1)
            end
          }
        },
        defaults = {
          -- dynamic_preview_title = true,
          file_sorter = require("telescope.sorters").get_fzy_sorter,
          generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
          -- prompt_prefix = "  ", -- seach icon
          selection_caret = "  ",
          selection_strategy = "reset",
          -- rg => the best Text Searching
          vimgrep_arguments = {
              "rg",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
              "--hidden",
              "--trim",
              "--glob=!.git/*",
              '--glob=!node_modules/*',
          },
          sorting_strategy = "descending",
          layout_strategy = "flex",
          layout_config = {
              flex = {
                  flip_columns = 161, -- half 27" monitor, scientifically calculated
              },
              horizontal = {
                  preview_cutoff = 0,
                  preview_width = 0.6,
              },
              vertical = {
                  preview_cutoff = 0,
                  preview_height = 0.65,
              },
          },
          path_display = { "smart" },
          -- path_display = { truncate = 3 },
          color_devicons = true,
          winblend = 5,
          set_env = { ["COLORTERM"] = "truecolor" },
          file_ignore_patterns = {
            "node_modules/",
            "vendor/",
            ".git/"
          },
          border = {},
          borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
          mappings = {
              i = {
                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,
                  ["<C-l>"] = action_layout.toggle_preview,
                  ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist, -- open in simple list view
                  ["<Esc>"] = actions.close,
                  ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                  ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
                  ["<C-]>"] = reveal_in_file_explorer,
                  ["<C-u>"] = false,
                  ["<C-s>"] = actions.cycle_previewers_next, -- Mapping <C-s>/<C-a> to cycle previewer for git commits to show full message
                  ["<C-a>"] = actions.cycle_previewers_prev,
                  -- ["<c-t>"] = actions.select_tab,
                  -- ["<CR>"] = telescope_custom_actions.multi_selection_open,
                  -- ["<C-V>"] = telescope_custom_actions.multi_selection_open_vsplit,
                  -- ["<C-S>"] = telescope_custom_actions.multi_selection_open_split,
                  -- ["<C-T>"] = telescope_custom_actions.multi_selection_open_tab,
              },
              n = {
                ["<C-l>"] = action_layout.toggle_preview,
                ["<C-]>"] = reveal_in_file_explorer,
                -- ["<c-t>"] = actions.select_tab,
              }
          },
        },
        pickers = {
          find_files = {
            -- find_command = {"rg", "--files", "--hidden", "--ignore", "-u", "--glob=!**/.git/*", "--glob=!**/node_modules/*", "--glob=!**/.next/*"},
            -- fd => the Best for "File Searching" finding files and directories
            find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git", "--exclude", "node_modules" }
          },
          buffers = {
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
              }
            }
          },
          advanced_git_search = {
            layout_config = {
              horizontal = {
                preview_width = 0.8,
              },
            },
          },
        }
      })

      -- enabling installed extensions
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("zoxide")
      telescope.load_extension("notify")
      telescope.load_extension("bookmarks")
      telescope.load_extension("advanced_git_search")
      telescope.load_extension("workspaces")
      telescope.load_extension("project") -- telescope-project.nvim
      -- telescope.load_extension('projects') -- ahmedkhalf/project.nvim

      local builtin = require("telescope.builtin")
      -- Function to disable previewer for all built-in pickers
      for key, _ in pairs(builtin) do
        telescope.setup{
          pickers = {
            [key] = {
              previewer = false,
            }
          }
        }
      end

      local function find_files()
        builtin.find_files({
          previewer = false,
          hidden = true,
          file_ignore_patterns = { "node_modules", "dist", "build", "target" },
          prompt_title = "Find Files",
          -- shorten_path = true,
          -- layout_strategy = "horizontal",
          -- cwd = require('lspconfig.util').root_pattern(".git")(vim.fn.expand("%:p")),
        })
      end

      local function find_git_project_files()
        local is_inside_work_tree =  false
        local opts = {} -- define here if you want to define something
        vim.fn.system("git rev-parse --is-inside-work-tree")
        is_inside_work_tree = vim.v.shell_error == 0
        local dot_git_path = vim.fn.finddir(".git", ".;")
        local get_git_root = vim.fn.fnamemodify(dot_git_path, ":h")
        if is_inside_work_tree then
          builtin.git_files({
            previewer = false,
            show_untracked = true,
            prompt_title = "Find Project Git Files",
            cwd = get_git_root
          })
        else
          find_files()
        end
      end

      local function list_buffers()
        builtin.buffers({
          sort_lastused = true,
          previewer = false,
          initial_mode = "normal",
          ignore_current_buffer = true,
        })
      end

      local function find_recent_files()
        builtin.oldfiles({
          sort_lastused = true,
          previewer = false,
          shorten_path = true,
          prompt_title = "Find Recent Files",
        })
      end

      local function grep_string_in_cwd()
        builtin.grep_string({
          search = vim.fn.input("Grep > "),
        })
      end

      local function search_in_open_files()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end

      local function search_in_neovim_config()
        builtin.find_files({
          cwd = vim.fn.stdpath("config"),
          previewer = false,
          search_file = "*.lua",
          prompt_title = "Find Files in Neovim Config",
        })
      end

      local function search_treesitter_symbols()
        -- local ts_lsp_symbols = {
        --   Class = true,
        --   Constant = true,
        --   Constructor = true,
        --   Enum = true,
        --   EnumMember = true,
        --   Function = true,
        --   Interface = true,
        --   Method = true,
        --   Module = true,
        --   Reference = true,
        --   Snippet = true,
        --   Struct = true,
        --   TypeParameter = true,
        --   Unit = true,
        --   Value = true,
        -- }

        -- local ts_treesitter_symbols = { 'Type', 'Method', 'Function', 'Constant', 'Field' }
        local treesitter_symbols = { 'Method', 'Function'}

        local treesitter_highlights = {}

        for _, name in ipairs(treesitter_symbols) do
          treesitter_highlights[name:lower()] = 'Comment'
        end

        builtin.treesitter({
          prompt_title = "Treesitter Symbols",
          show_line = false,
          symbols = treesitter_symbols,
          symbol_highlights = treesitter_highlights,
        })
      end

      local function list_bookmarks()
        telescope.extensions.bookmarks.list({
          prompt_title = "Bookmarks",
          previewer = false,
        })
      end

      local function find_files_in_explorer()
        builtin.find_files({
          prompt_title = "Find Files in Explorer",
          file_ignore_patterns = { "node_modules", "dist", "build", "target" },
          -- cwd = "C:\\",  -- Change this to the directory you want to search
          -- cwd = "C:/Users/hsayed/Downloads/",
          -- cwd = "C:\\Users\\hsayed\\Downloads",
          cwd = "C:\\",
          previewer = false,
          find_command = {
            "fd",
            "--type=f",
            "--ignore-case",
            "--no-ignore",
            "--hidden",
            "--color=never",
            -- '--glob=!node_modules/*',
            -- "--full-path='C:\\'",
            "-e=txt", "-e=lua", "-e=cs", "-e=js", "-e=ts", "-e=html", "-e=css", "-e=scss", "-e=md",
            "-e=yaml", "-e=yml", "-e=ini", "-e=conf",  "-e=xml", "-e=json", "-e=java", "-e=kt", "-e=swift",
            "-e=php", "-e=sql", "-e=sh", "-e=bat", "-e=ps1", "-e=py", "-e=cpp",  "-e=toml", "-e=c", "-e=csv",
            "-e=rb", "-e=go", "-e=pl", "-e=perl", "-e=jsx", "-e=tsx", "-e=vue", "-e=php", "-e=twig", "-e=twig",
          },
          -- hidden = true  -- Show hidden files
        })
      end

      -- Telescope keymaps

      -- to close telescope Ctrl-c / esc

      -- finding files
      Map("n", "<C-p>", find_files, { desc = "Find all files" })
      Map("n", "<leader>pf", find_git_project_files, { desc = "Find all files in git project" })
      Map("n", "<leader>sb", list_buffers, { desc = "List all buffers" })
      Map("n", "<leader>s.", find_recent_files, { desc = "Find recent files" })
      Map("n", "<leader>sn", search_in_neovim_config, { desc = "Search in neovim config" })
      Map("n", "<leader>se", find_files_in_explorer, { desc = "Find files in explorer" })

      -- finding text in files
      Map("n", "<leader>sw", grep_string_in_cwd, { desc = "Grep string in current working directory" })
      Map("n", "<leader>sg", builtin.live_grep, { desc = "Live grep string in current working directory" })
      Map("n", "<leader>sf", builtin.current_buffer_fuzzy_find, { desc = "Search in current file" })
      -- Map("n", "<leader>s/", search_in_open_files, { desc = "Search in Open Files" })

      -- telescope builtins
      Map("n", "<leader>sh", builtin.help_tags, { desc = "Search help tags neovim and plugins" })
      Map("n", "<leader>sk", builtin.keymaps, { desc = "Search keymaps" })
      Map("n", "<leader>ss", builtin.builtin, { desc = "Search and Run telescope builtin " })
      Map("n", "<leader>sd", function() builtin.diagnostics({ bufnr = 0 }) end, { desc = "Search diagnostics in current buffer" })
      Map("n", "<leader>sD", builtin.diagnostics, { desc = "Search diagnostics" })
      Map("n", "<leader>sr", builtin.resume, { desc = "Re-open last telescope picker" })
      Map('n', '<Leader>s:', builtin.commands, { desc = "Search Commands" })
      Map('n', '<Leader>s?', builtin.man_pages, { desc = "Seach in Man Pages" })

      Map('n', '<leader>st', builtin.treesitter, { desc = "Search Treesitter Symbols" })
      Map('n', '<leader>sc', builtin.git_commits, { desc = "Search Git Commits" })
      Map('n', '<leader>sC', builtin.git_bcommits, { desc = "Search Git BCommits" })
      Map('n', '<leader>sx', builtin.git_branches, { desc = "Search Git Branches" })
      -- Map('n', '<leader>se', builtin.git_status, { desc = "Search Git Status" })
      Map('n', '<Leader>sa', builtin.git_stash, { desc = "Search Git Stash" })
      Map('n', '<leader>si', list_bookmarks, { desc = "Search Bookmarks" })
      Map('n', '<Leader>sH', builtin.highlights, { desc = "Search Highlights Color" })

      -- Map('n', '<leader>si', builtin.marks) -- default marks
      -- Map('n', "<Leader>j'", builtin.registers)
      -- Map('n', '<Leader>jj', builtin.quickfix)

      Map("n", "<leader>so", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

      Map('n', '<Leader>jz', telescope.extensions.zoxide.list)
      Map('n', '<Leader>jn', telescope.extensions.notify.notify)

      Map({ "n", "x", "o", "v" }, "<Leader>gda", telescope.extensions.advanced_git_search.show_custom_functions, { desc = "Advanced Git Search" })

      Map('n', '<leader>pw', telescope.extensions.workspaces.workspaces, { desc = "Workspaces" })
      Map('n', '<leader>pp', telescope.extensions.project.project, { desc = "Projects" })
      -- Map('n', '<leader>ps', telescope.extensions.projects.projects, { desc = "Projects" })
      -- oneline command
      -- vim.keymap.set('n',"<leader>;;",":lua require('telescope.builtin').treesitter({show_line=true}) <cr>",{})

    end,
    enabled = not vim.g.vscode
  },
  -- Terminal integration
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    dependencies = {
      'chomosuke/term-edit.nvim',
      -- lazy = false, -- or ft = 'toggleterm' if you use toggleterm.nvim
      ft = 'toggleterm',
      version = '1.*',
    },
    config = function()
      local status_ok, toggleterm = pcall(require, "toggleterm")
      if not status_ok then
        return
      end
      require 'term-edit'.setup({
        -- Mandatory option:
        -- Set this to a lua pattern that would match the end of your prompt.
        -- Or a table of multiple lua patterns where at least one would match the
        -- end of your prompt at any given time.
        -- For most bash/zsh user this is '%$ '.
        -- For most powershell/fish user this is '> '.
        -- For most windows cmd user this is '>'.
        prompt_end = '%$ ',
        -- How to write lua patterns: https://www.lua.org/pil/20.2.html
      })

      toggleterm.setup({
        -- size = 40,
        size = function(term)
          if term.direction == "horizontal" then
            return math.floor(vim.o.lines * 0.3)  -- 30% of screen height
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.4)  -- 40% of screen width
          else
            return 20  -- Default size
          end
        end,
        -- open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = false,
        insert_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "float",  -- 'vertical' | 'horizontal' | 'tab' | 'float',
        close_on_exit = true,
        -- hidden = false -- key is set to true, this terminal will not be toggled by normal toggleterm commands
        shell = vim.o.shell,
        -- shell = "powershell.exe",
        -- shell = "pwsh.exe",
        -- function to run on opening the terminal
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
        -- function to run on closing the terminal
        on_close = function(term)
          vim.cmd("startinsert!")
        end,
        float_opts = {
          border = 'curved',  -- Customize border style if needed
          width = math.floor(vim.o.columns * 0.85),  -- 85% of screen width
          height = math.floor(vim.o.lines * 0.85),   -- 85% of screen height
          -- width = vim.o.columns,  -- 85% of screen width
          -- height = vim.o.lines,   -- 85% of screen height
          winblend = 0,  -- Adjust transparency level (0-100)
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })

      -- Terminal edit keymaps
      function _G.set_terminal_keymaps()
        local opts = {noremap = true}

        local bufname = vim.api.nvim_buf_get_name(0)
        -- vim.b[buf].is_lazygit_terminal
        -- if vim.b.is_lazygit then
        if string.match(bufname, "lazygit") then
          vim.api.nvim_buf_set_keymap(0, 't', '<ESC>', '<ESC>', { silent = true })
          vim.api.nvim_buf_set_keymap(0, 't', '<C-v><ESC>', [[<C-\><C-n>]], { silent = true })
        else
          -- switch to normal mode
          vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-o>', [[<C-\><C-n>]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', 'jj', [[<C-\><C-n>]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)

          -- move between terminals
          vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
          vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)

          vim.api.nvim_buf_set_keymap(0, 'n', '<C-f>', "G$?#<CR>:nohlsearch<CR>$", opts) -- set cursor at the beginning of line input
        end
        -- utils
        Map({"n", "t"}, "<leader>tQ", "<cmd>ToggleTermToggleAll<CR>") -- close all terminals that have hidden=false

        -- Supported Actions - chomosuke/term-edit.nvim
        -- Enter insert: i, a, A, I.
        -- Delete: d<motion>, dd, D, x, X.
        -- Change: c<motion>, cc, C, s, S.
        -- Visual change: c in visual mode.
        -- Visual delete: d, D, x, X in visual mode.
        -- Paste: p P "<register>p "<register>P
        -- Replace: r in normal mode
        -- Enter insert as if this plugin doesn't exist: <C-i>
        -- Paste as if this plugin doesn't exist: <C-p> & <C-P>
      end

      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
          cmd = "lazygit",
          hidden = true,
          float_opts = {
              width = math.floor(vim.o.columns),  -- 85% of screen width
              height = math.floor(vim.o.lines),   -- 85% of screen height
            },
      })
      local pwsh = Terminal:new({ cmd = "pwsh" })

      -- Function to change the direction of an existing terminal
      -- function _CHANGE_DIRECTION(term, new_direction)
      --   -- Close the current terminal
      --   term:close()
      --   -- Create a new terminal with the updated direction and dynamic size
      --   local updated_term = Terminal:new({
      --     cmd = term.cmd,
      --     direction = new_direction,
      --     size = function(new_direction)
      --       if new_direction == "horizontal" then
      --         return math.floor(vim.o.lines * 0.3)  -- 30% of screen height
      --       elseif new_direction == "vertical" then
      --         return math.floor(vim.o.columns * 0.4)  -- 40% of screen width
      --       else
      --         return 20  -- Default size
      --       end
      --     end,
      --     hidden = term.hidden
      --   })
      --   -- Toggle (open) the newly created terminal
      --   updated_term:toggle()
      --   return updated_term
      -- end

      -- function _PWSH_CHANGE_DIRECTION_TO_HORIZONTAL()
      --   pwsh = _CHANGE_DIRECTION(pwsh, "horizontal")
      -- end

      function _PWSH_NEW(direction)
        local new_pwsh = Terminal:new({
          cmd = "pwsh",
          direction = direction,
        })
        new_pwsh:toggle()
      end

      -- Terminal Keymaps
      Map("n", "<leader>tt", function() pwsh:toggle() end, { desc = 'Toggle Global float terminal' })
      Map("n", "<leader>tv", function() _PWSH_NEW('vertical') end, { desc = 'Create new terminal vertical' })
      Map("n", "<leader>th", function() _PWSH_NEW('horizontal') end, { desc = 'Create new terminal horizontal' })
      Map("n", "<leader>lg", function() lazygit:toggle() end, { desc = 'Toggle LAZYGIT terminal' })
      -- Map("n", "<leader>tc", "<cmd>lua _PWSH_CHANGE_DIRECTION_TO_HORIZONTAL()<CR>")

    end,
    enabled = not vim.g.vscode
  },
  -- TODO comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- FIXME: something needs fixing!
      -- TODO: do something!
      -- HACK: do something!
      -- WARN: do something!
      -- PERF: do something!
      -- NOTE: do something!!
      -- TEST: do something!

      -- NOTE:
      -- The `TodoTelescope` command should be ran with cwd=. so the complete command is `:TodoTelescope cwd=.`.

      require("todo-comments").setup({
        signs = true, -- show icons in the signs column
        sign_priority = 8, -- sign priority
        -- keywords recognized as todo comments
        keywords = {
          FIX = {
            icon = " ", -- icon used for the sign, and in search results
            color = "error", -- can be a hex color, or a named color (see below)
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
          },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning",alt = { "WARNING", "XXX" } },
          PERF = { icon = "⏲ ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
          TEST = { icon = "󰙨 ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
        gui_style = {
          fg = "NONE", -- The gui style to use for the fg highlight group.
          bg = "BOLD", -- The gui style to use for the bg highlight group.
        },
        merge_keywords = true, -- when true, custom keywords will be merged with the defaults
        -- highlighting of the line containing the todo comment
        -- * before: highlights before the keyword (typically comment characters)
        -- * keyword: highlights of the keyword
        -- * after: highlights after the keyword (todo text)
        highlight = {
          multiline = true, -- enable multine todo comments
          multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
          multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
          before = "", -- "fg" or "bg" or empty
          keyword = "bg", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
          after = "fg", -- "fg" or "bg" or empty
          pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
          comments_only = true, -- uses treesitter to match keywords in comments only
          max_line_len = 400, -- ignore lines longer than this
          exclude = {}, -- list of file types to exclude highlighting
        },
        -- list of named colors where we try to extract the guifg from the
        -- list of highlight groups or use the hex color if hl not found as a fallback
        colors = {
          error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
          warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
          info = { "DiagnosticInfo", "#2563EB" },
          hint = { "DiagnosticHint", "#10B981" },
          default = { "Identifier", "#7C3AED" },
          test = { "Identifier", "#FF00FF" },
        },
        search = {
          command = "rg",
          args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
          -- regex that will be used to match keywords.
          -- don't replace the (KEYWORDS) placeholder
          pattern = [[\b(KEYWORDS):]], -- ripgrep regex
          -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
        },
      })
    end,
    enabled = not vim.g.vscode
  },
  -- trouble Diagnostic list
  {
    "folke/trouble.nvim",
    -- branch = "dev",
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
    -- init = function()
    --   local Config = require("neoverse.config")
    --   for _, other in ipairs({ "aerial", "outline" }) do
    --     local extra = "neoverse.extras.editor." .. other
    --     if vim.tbl_contains(Config.json.data.extras, extra) then
    --       other = other:gsub("^%l", string.upper)
    --       print({
    --         "**Trouble v3** includes support for document symbols.",
    --         ("You currently have the **%s** extra enabled."):format(other),
    --         "Please disable it in your config.",
    --       })
    --     end
    --   end
    -- end,
    keys = {
      -- trouble Keymaps
      { "<leader>xx", "<cmd>TroubleToggle<CR>", desc = "Open/close trouble list" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", desc = "Open trouble workspace diagnostics" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", desc = "Open trouble document diagnostics" },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<CR>", desc = "Open trouble quickfix list" },
      { "<leader>xl", "<cmd>TroubleToggle loclist<CR>", desc = "Open trouble location list" },
      { "<leader>xt", "<cmd>TodoTrouble<CR>", desc = "Open todos in trouble" },
      -- { "<leader>xo", "<cmd>TroubleToggle lsp_outline<CR>", desc = "Open trouble lsp outline" },
      -- { "<leader>xD", "<cmd>TroubleToggle lsp_definitions<CR>", desc = "Open trouble lsp definitions" },
      -- { "<leader>xi", "<cmd>TroubleToggle lsp_implementations<CR>", desc = "Open trouble lsp implementations" },
      -- { "<leader>xs", "<cmd>TroubleToggle lsp_document_symbols<CR>", desc = "Open trouble lsp document symbols" },
      -- { "<leader>xh", "<cmd>TroubleToggle help<CR>", desc = "Open trouble help" },
      -- { "<leader>xv", "<cmd>TroubleToggle lsp_workspace_diagnostics<CR>", desc = "Open trouble lsp workspace diagnostics" },
      -- { "<leader>xe", "<cmd>TroubleToggle lsp_document_diagnostics<CR>", desc = "Open trouble lsp document diagnostics" },
      -- { "<leader>xf", "<cmd>TroubleToggle lsp_references<CR>", desc = "Open trouble lsp references" },

      -- ? => show help navigate trouble
    },
    enabled = not vim.g.vscode
  },
  -- Zen mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      -- plugins = {
      -- 	gitsigns = true,
      -- },
    },
    -- Zen mode keymaps
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    enabled = not vim.g.vscode
  },
  -- Git
  {
    -- Lazygit integration
    {
      'kdheepak/lazygit.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
      },
      cmd = {
        'LazyGit',
        'LazyGitConfig',
        'LazyGitCurrentFile',
        'LazyGitFilter',
        'LazyGitFilterCurrentFile',
      },
      keys = {
        -- { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
      },
      enabled = not vim.g.vscode
      -- Delta For highlighting and side by side
      -- [Installation - delta](https://dandavison.github.io/delta/installation.html)

      -- lazygit Keymaps
      -- ? => show help commands lazygit

      -- to see more https://github.com/jesseduffield/lazygit/tree/master/docs
    },
    -- Git vim-fugitive blame, split
    {
      "tpope/vim-fugitive",
      cmd = {
        "G",
        "Git",
        "Gdiff",
        "Gdiffsplit",
        "Gvdiffsplit",
        "Gblame",
        "Gbrowse",
      },
      keys = {
        -- blame, split vim-fugitive Keymaps
        -- { "<leader>go", "<cmd>Git browse<cr>", desc = "Open Repo GitHub" },
        { "<leader>gb", "<cmd>Git blame -M -C -w<cr>", desc = "Git Blame" },
        { "<leader>gdh", "<cmd>Gdiffsplit<cr>", desc = "Git Diff horizontal" },
        { "<leader>gdv", "<cmd>Gvdiffsplit<cr>", desc = "Git Diff vertical" },
      },
      enabled = not vim.g.vscode
    },
    -- gitsigns Git signs
    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      opts = {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        -- signs = {
        --   add = { hl = "GitSignsAdd", text = "▌", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
        --   change = { hl = "GitSignsChange", text = "▌", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
        --   delete = { hl = "GitSignsDelete", text = "▌", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
        --   topdelete = { hl = "GitSignsDelete", text = "▌", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
        --   changedelete = { hl = "GitSignsChange", text = "▌", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
        --   untracked = { hl = "GitSignsAdd", text = "▌", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
        -- },
        -- signs = {
        --   add          = { text = '┃' },
        --   change       = { text = '┃' },
        --   delete       = { text = '_' },
        --   topdelete    = { text = '‾' },
        --   changedelete = { text = '~' },
        --   untracked    = { text = '┆' },
        -- },
        signs_staged = {
          add = { text = 's' },
          change = { text = 's' },
          delete = { text = '_', show_count = true },
          topdelete = { text = '‾', show_count = true },
          changedelete = { text = 's', show_count = true },
        },
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false,   -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 500,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        -- current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        current_line_blame_formatter = '<author>, <summary> - <author_time>',
        current_line_blame_formatter_opts = {
          relative_time = true,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
        yadm = {
          enable = false,
        },
        diff_opts = {
          vertical = true,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function _map(mode, l, r, desc)
            Map(mode, l, r, { buffer = bufnr, desc = desc })
          end

          -- local function schedule_repeat(func)
          --   for _ = 1, vim.v.count1 do
          --     vim.schedule(func)
          --   end
          -- end

          -- gitsigns Keymaps

          -- Navigation
          _map("n", "]h", function()
            if vim.wo.diff then
              return "]h"
            end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Next Git Change Hunk" })

          _map("n", "[h", function()
            if vim.wo.diff then
              return "[h"
            end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Previous Git Change Hunk" })

          -- Actions
          _map("n", "<leader>gs", gs.stage_hunk, "Stage/Unstage hunk")
          _map("n", "<leader>gu", gs.undo_stage_hunk, "Undo last stage hunk (Undo the last call of stage_hunk())")
          _map("n", "<leader>gr", gs.reset_hunk, "Reset hunk (Discards changes)")
          _map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
          _map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk (Discards changes)")
          _map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
          _map("n", "<leader>gU", gs.reset_buffer_index, "Unstage buffer")
          _map("n", "<leader>gR", gs.reset_buffer, "Reset buffer (Discards all changes)")
          _map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          _map("n", "<leader>gB", gs.toggle_current_line_blame, " Toggle Current Line Blame")
          _map("n", "<leader>gtd", gs.toggle_deleted, { desc = "Toggle Deleted" })
          -- _map("n", "<leader>gd", gs.diffthis, "Diff this")
          -- _map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff this ~")
          -- _map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")

          -- Text object
          _map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")

          -- _map('n', '<Leader>cs', ':Gitsigns show ')
                -- _map('n', ']d', function() schedule_repeat(gs.next_hunk) end)
          -- _map('n', '[d', function() schedule_repeat(gs.prev_hunk) end)

        end,
      },
      enabled = not vim.g.vscode
    },
    -- Git diff
    {
      'sindrets/diffview.nvim',
      dependencies = { "nvim-lua/plenary.nvim" },
      cmd = {
        'DiffviewOpen',
        'DiffviewClose',
        'DiffviewToggleFiles',
        'DiffviewFocusFiles',
        'DiffviewRefresh',
        'DiffviewToggleFile',
        'DiffviewNextFile',
        'DiffviewPrevFile',
        'DiffviewFileHistory',
        'DiffviewToggleOption',
      },
      keys = {
        -- diffview Keymaps
        { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diff Open" },
        { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Diff Close" },
        { "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
        { "<leader>gdm", "<cmd>DiffviewOpen master<cr>", desc = "Diff Master" },
        { "<leader>gdM", "<cmd>DiffviewOpen main<cr>", desc = "Diff Main" },
      },
      config = function()
        local actions = require("diffview.actions")
        require('diffview').setup({
          diff_binaries = false,    -- Show diffs for binaries
          enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
          icons = {
            folder_closed = "",
            folder_open = "",
          },
          view = {
            diff_view = {
              winbar_info = true,
              layout = "diff2_horizontal",
            },
            merge_tool = {
              winbar_info = true,
              layout = "diff3_mixed",
            },
          },
          signs = {
            fold_closed = "",
            fold_open = "",
          },
          file_panel = {
            win_config = {
              position = "right",
              width = 35,
            },
          },
          file_history_panel = {
            win_config = {
              position = "bottom",
              height = 10,
            },
          },
          commit_log_panel = {
            win_config = {},
          },
          default_args = {
            DiffviewOpen = {},
            DiffviewFileHistory = {},
          },
          hooks = {
            diff_buf_read = function(bufnr)
              -- Disable some performance heavy stuff in long files.
              if vim.api.nvim_buf_line_count(bufnr) >= 2500 then
                vim.cmd("IndentBlanklineDisable")
              end
            end,
          },
          keymaps = {
            view = {
              ["gf"] = actions.goto_file_edit,
              ["-"] = actions.toggle_stage_entry,
            },
            file_panel = {
              ["<cr>"] = actions.focus_entry,
              ["s"] = actions.toggle_stage_entry,
              ["gf"] = actions.goto_file_edit,
              ["?"] = "<Cmd>h diffview-maps-file-panel<CR>",
            },
            file_history_panel = {
              ["<cr>"] = actions.focus_entry,
              ["gf"] = actions.goto_file_edit,
              ["?"] = "<Cmd>h diffview-maps-file-history-panel<CR>",
            },
          },
        })
      end,
      enabled = not vim.g.vscode
    },
    -- Git conflict
    {
      'akinsho/git-conflict.nvim',
      version = "*",
      config = function ()
        -- override the following default highlight groups for ease of viewing of merge conflicts
        vim.cmd("highlight DiffAdd guibg = '#405d7e'")
        vim.cmd("highlight DiffText guibg = '#314753'")

        require'git-conflict'.setup ({
          default_mappings = true, -- disable buffer local mapping created by this plugin
          default_commands = true, -- disable commands created by this plugin
          disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
          list_opener = 'copen', -- command or function to open the conflicts list
          highlights = { -- They must have background color, otherwise the default color will be used
            incoming = 'DiffAdd',
            current  = 'DiffText',
          },
        })

        vim.api.nvim_create_autocmd('User', {
          pattern = 'GitConflictDetected',
          callback = function()
            vim.notify('Conflict detected in file '..vim.api.nvim_buf_get_name(0))
            vim.cmd('LspStop')
          end
        })

        vim.api.nvim_create_autocmd('User', {
          pattern = 'GitConflictResolved',
          callback = function()
            vim.cmd('LspRestart')
          end
        })

        -- git-conflict Keymaps
        -- co — choose ours
        -- ct — choose theirs
        -- cb — choose both
        -- c0 — choose none
        -- ]x — move to previous conflict
        -- [x — move to next conflict

        -- git-conflict commands
        -- GitConflictChooseOurs — Select the current changes.
        -- GitConflictChooseTheirs — Select the incoming changes.
        -- GitConflictChooseBoth — Select both changes.
        -- GitConflictChooseNone — Select none of the changes.
        -- GitConflictNextConflict — Move to the next conflict.
        -- GitConflictPrevConflict — Move to the previous conflict.
        -- GitConflictListQf — Get all conflict to quickfix
      end,
      enabled = not vim.g.vscode
    }
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      fzf = require "fzf-lua"
      fzf.setup({})
      Map("n", "<leader>,f", fzf.files, { desc = "Fzf Files" })
    end,
    enabled = not vim.g.vscode
  },
  {
    "chentoast/marks.nvim",
    event = "BufRead",
    config = function()
      require("marks").setup({
        default_mappings = true,
        -- which builtin marks to show. default {}, example below:
        -- builtin_marks = {".", "<", ">", "^"},
        -- whether movements cycle back to the beginning/end of buffer. default true
        cyclic = true,
        -- whether the shada file is updated after modifying uppercase marks. default false
        force_write_shada = false,
        -- how often (in ms) to redraw signs/recompute mark positions.
        -- higher values will have better performance but may cause visual lag,
        -- while lower values may cause performance penalties. default 150.
        refresh_interval = 150,
        -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
        -- marks, and bookmarks.
        -- can be either a table with all/none of the keys, or a single number, in which case
        -- the priority applies to all marks.
        -- default 10.
        sign_priority = {
          lower = 10,
          upper = 15,
          builtin = 8,
          bookmark = 20,
        },
        excluded_filetypes = {},
        mappings = {},
      })

      -- Bindings:
      --
      -- mx              Set mark x
      -- m,              Set the next available alphabetical (lowercase) mark
      -- m;              Toggle the next available mark at the current line
      -- dmx             Delete mark x
      -- dm-             Delete all marks on the current line
      -- dm<space>       Delete all marks in the current buffer
      -- m]              Move to next mark
      -- m[              Move to previous mark
      -- m:              Preview mark. This will prompt you for a specific mark to preview; press <cr> to preview the next mark.
      -- m[0-9]          Add a bookmark from bookmark group[0-9].
      -- dm[0-9]         Delete all bookmarks from bookmark group[0-9].
      -- m}              Move to the next bookmark having the same type as the bookmark under the cursor. Works across buffers.
      -- m{              Move to the previous bookmark having the same type as the bookmark under the cursor. Works across buffers.
      -- dm=             Delete the bookmark under the cursor.
    end,
    enabled = not vim.g.vscode,
  }
}
