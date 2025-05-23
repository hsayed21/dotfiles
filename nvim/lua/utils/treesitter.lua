-- utils/treesitter.lua
-- Custom Treesitter configurations, queries, and utility functions

local M = {}

-- Function to register custom treesitter queries
function M.register_queries()
  -- Lua custom queries
  vim.treesitter.query.set("lua", "textobjects", [[
    ;; Standard function declaration
    (function_declaration
      name: (identifier) @function.name) @function.outer

    ;; Function assigned to a variable
    (assignment_statement
      (variable_list
        (identifier) @function.name)
      (expression_list
        (function_definition))) @function.outer

    ;; Function in a table
    (field
      name: (identifier) @function.name
      value: (function_definition)) @function.outer

    ;; The function definition itself (for outer selection)
    (function_definition) @function.outer

    ;; The body of the function (for inner selection)
    (function_declaration
      body: (block) @function.inner)
    (function_definition
      body: (block) @function.inner)
  ]])

  -- JavaScript/TypeScript custom queries
  vim.treesitter.query.set("javascript", "textobjects", [[
    ;; Function declarations
    (function_declaration
      name: (identifier) @function.name) @function.outer

    ;; Arrow functions with block
    (arrow_function
      body: (statement_block) @function.inner) @function.outer

    ;; Function expressions
    (function_expression) @function.outer

    ;; Method definitions
    (method_definition
      name: (property_identifier) @function.name) @function.outer

    ;; Class declarations
    (class_declaration
      name: (identifier) @class.name) @class.outer
  ]])

  -- TypeScript queries (extends JavaScript)
  vim.treesitter.query.set("typescript", "textobjects", [[
    ;; Function declarations
    (function_declaration
      name: (identifier) @function.name) @function.outer

    ;; Arrow functions with block
    (arrow_function
      body: (statement_block) @function.inner) @function.outer

    ;; Function expressions
    (function_expression) @function.outer

    ;; Method definitions
    (method_definition
      name: (property_identifier) @function.name) @function.outer

    ;; Class declarations
    (class_declaration
      name: (type_identifier) @class.name) @class.outer

    ;; Interface declarations
    (interface_declaration
      name: (type_identifier) @interface.name) @interface.outer
  ]])

  -- Python custom queries
  vim.treesitter.query.set("python", "textobjects", [[
    ;; Function definitions
    (function_definition
      name: (identifier) @function.name) @function.outer

    ;; Function body
    (function_definition
      body: (block) @function.inner)

    ;; Class definitions
    (class_definition
      name: (identifier) @class.name) @class.outer

    ;; Class body
    (class_definition
      body: (block) @class.inner)
  ]])
end

-- Function to get the function under the current cursor position
function M.goto_function_under_cursor()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local cursor_node = ts_utils.get_node_at_cursor()

  if not cursor_node then return end

  -- Walk up the tree to find a function node
  local current_node = cursor_node
  while current_node do
    local node_type = current_node:type()
    if node_type == "function_declaration" or
       node_type == "function_definition" or
       node_type == "method_definition" or
       node_type == "arrow_function" or
       node_type == "function_expression" or
       (node_type == "field" and current_node:field("value")[1] and
        current_node:field("value")[1]:type() == "function_definition") or
       (node_type == "assignment_statement" and current_node:field("expression_list")[1] and
        current_node:field("expression_list")[1]:type() == "function_definition") then
      -- Found a function node, jump to the start of it
      local start_row, start_col, _, _ = current_node:range()
      vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
      return true
    end
    current_node = current_node:parent()
  end

  -- If not found in parent nodes, try to find the next function
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then return false end

  local tree = parser:parse()[1]
  if not tree then return false end

  local root = tree:root()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1 -- Convert to 0-indexed

  local next_function = nil
  local min_distance = math.huge

  local function find_functions(node)
    local node_type = node:type()
    if node_type == "function_declaration" or
       node_type == "function_definition" or
       node_type == "method_definition" or
       node_type == "arrow_function" or
       node_type == "function_expression" or
       (node_type == "field" and node:field("value")[1] and
        node:field("value")[1]:type() == "function_definition") or
       (node_type == "assignment_statement" and node:field("expression_list")[1] and
        node:field("expression_list")[1]:type() == "function_definition") then
      local fn_start_row, _, _, _ = node:range()
      -- Only consider functions after the cursor
      if fn_start_row > row and (fn_start_row - row) < min_distance then
        min_distance = fn_start_row - row
        next_function = node
      end
    end

    for child, _ in node:iter_children() do
      if child then
        find_functions(child)
      end
    end
  end

  find_functions(root)

  if next_function then
    local start_row, start_col, _, _ = next_function:range()
    vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
    return true
  end

  print("No function found")
  return false
end

-- Jump to the previous function
function M.goto_prev_function()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local cursor_node = ts_utils.get_node_at_cursor()

  if not cursor_node then return end

  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then return false end

  local tree = parser:parse()[1]
  if not tree then return false end

  local root = tree:root()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1 -- Convert to 0-indexed

  local prev_function = nil
  local max_distance = -1

  local function find_prev_functions(node)
    local node_type = node:type()
    if node_type == "function_declaration" or
       node_type == "function_definition" or
       node_type == "method_definition" or
       node_type == "arrow_function" or
       node_type == "function_expression" or
       (node_type == "field" and node:field("value")[1] and
        node:field("value")[1]:type() == "function_definition") or
       (node_type == "assignment_statement" and node:field("expression_list")[1] and
        node:field("expression_list")[1]:type() == "function_definition") then
      local fn_start_row, _, _, _ = node:range()
      -- Only consider functions before the cursor
      if fn_start_row < row and (row - fn_start_row) > max_distance then
        max_distance = row - fn_start_row
        prev_function = node
      end
    end

    for child, _ in node:iter_children() do
      if child then
        find_prev_functions(child)
      end
    end
  end

  find_prev_functions(root)

  if prev_function then
    local start_row, start_col, _, _ = prev_function:range()
    vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
    return true
  end

  print("No previous function found")
  return false
end

-- Define a function to get the mode and apply the appropriate operation
function M.current_function_name()
  -- Position cursor at the function name
  local ts_utils = require("nvim-treesitter.ts_utils")
  local cursor_node = ts_utils.get_node_at_cursor()

  if not cursor_node then return false end

  -- Walk up the tree to find a function node
  local function_node = cursor_node
  while function_node do
    local node_type = function_node:type()
    if node_type == "function_declaration" or
       node_type == "function_definition" or
       node_type == "method_definition" or
       node_type == "arrow_function" or
       node_type == "function_expression" or
       (node_type == "field" and function_node:field("value")[1] and
        function_node:field("value")[1]:type() == "function_definition") or
       (node_type == "assignment_statement" and function_node:field("expression_list")[1] and
        function_node:field("expression_list")[1]:type() == "function_definition") then
      -- Found a function node
      break
    end
    function_node = function_node:parent()
  end

  if not function_node then
    print("No function found")
    return false
  end

  -- Now find the name node based on the function node type
  local name_node = nil
  local node_type = function_node:type()

  if node_type == "function_declaration" then
    -- Standard function declaration
    name_node = function_node:field("name")[1]
  elseif node_type == "method_definition" then
    -- Method definition
    name_node = function_node:field("name")[1]
  elseif node_type == "assignment_statement" then
    -- Function assigned to a variable
    local var_list = function_node:field("variable_list")[1]
    if var_list then
      name_node = var_list:field("")[1] -- Get the first child which should be the identifier
    end
  elseif node_type == "field" then
    -- Function in a table
    name_node = function_node:field("name")[1]
  end

  if not name_node then
    print("Couldn't find function name")
    return false
  end

  -- Get the range of the name node
  local start_row, start_col, end_row, end_col = name_node:range()

  -- Get the current mode
  -- local mode = vim.api.nvim_get_mode().mode
    -- Get the operator or mode that was used
  local mode = vim.fn.mode()

  -- Check if we're in operator-pending mode
  if mode:match("^o") or mode:match("no") then
  -- if mode == "o" then
    -- We're in operator-pending mode - set marks for the operator
    vim.api.nvim_buf_set_mark(0, '[', start_row + 1, start_col, {})
    vim.api.nvim_buf_set_mark(0, ']', end_row + 1, end_col - 1, {})
  elseif mode:match("^v") or mode:match("^V") or mode:match("^\\22") then
    -- We're already in visual mode
    -- Exit visual mode first to avoid issues
    vim.cmd("normal! \27") -- ESC key to exit visual mode
    -- Then re-enter visual mode with the correct selection
    vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, {end_row + 1, end_col - 1})
  else
    -- We're in normal mode - start visual selection
    vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, {end_row + 1, end_col - 1})
  end

  return true
end

-- Setup keybindings for function navigation
function M.setup_keybindings()
  -- Register keymaps for function navigation
  vim.keymap.set("n", "]f", function() M.goto_function_under_cursor() end,
    { desc = "Go to function under cursor or next function" })

  vim.keymap.set("n", "[f", function() M.goto_prev_function() end,
    { desc = "Go to previous function" })

  -- Setup function name text object that works in normal, visual, and operator-pending modes
  vim.keymap.set({"n", "x", "o"}, "iF", function() M.current_function_name() end,
    { desc = "Select function name" })
end

-- Initialize the module
function M.setup()
  -- M.register_queries()
  M.setup_keybindings()

  -- Make the functions available globally
  _G.goto_function_under_cursor = M.goto_function_under_cursor
  _G.goto_prev_function = M.goto_prev_function
  _G.current_function_name = M.current_function_name
end


return M
