local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")

local function is_function_node(node)
  if not node then return false end
  local node_type = node:type()
  return node_type == "function_declaration" or
         node_type == "function_definition" or
         node_type == "method_definition" or
         node_type == "method_declaration"
end

local function get_parser_tree()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then return nil, nil end
  return parser, parser:parse()[1]
end

local function find_function_by_direction(direction)
  local _, tree = get_parser_tree()
  if not tree then return false end

  local root = tree:root()
  local current_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local current_function = M.get_function()
  local start_row = current_function and select(1, current_function:range()) or current_row

  local target_function = nil
  local min_distance = math.huge

  local function find_function(node)
    if M.is_top_level_function(node) then
      local fn_start_row = node:range()
      local condition = direction == "next" and fn_start_row > start_row or
                       direction == "prev" and fn_start_row < start_row

      if condition then
        local distance = direction == "next" and (fn_start_row - start_row) or (start_row - fn_start_row)
        if distance < min_distance then
          min_distance = distance
          target_function = node
        end
      end
    end

    for child in node:iter_children() do
      if child then find_function(child) end
    end
  end

  find_function(root)

  if target_function then
    local start_row, start_col = target_function:range()
    vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
    M.print_details()
    return true
  end

  print(string.format("❌ No %s function found", direction))
  return false
end

function M.register_queries()
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
end

function M.next_function()
  return find_function_by_direction("next")
end

function M.prev_function()
  return find_function_by_direction("prev")
end

function M.select_function_name()
  local cursor_node = ts_utils.get_node_at_cursor()
  if not cursor_node then return false end

  local function_node = cursor_node
  while function_node do
    if is_function_node(function_node) then break end
    function_node = function_node:parent()
  end

  if not function_node then return false end

  local name_node = M.get_name_node(function_node)
  if not name_node then return false end

  local start_row, start_col, end_row, end_col = name_node:range()

  vim.cmd("normal! \27")
  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })

  return true
end

function M.select_function_call()
  local cursor_node = ts_utils.get_node_at_cursor()
  if not cursor_node then return false end

  local function_call_node = cursor_node
  while function_call_node do
    local node_type = function_call_node:type()
    if node_type == "function_call" or
       node_type == "method_call" or
       node_type == "call_expression" then
      break
    end
    function_call_node = function_call_node:parent()
  end

  if not function_call_node then return false end

  -- Find the function name/expression part (before the arguments)
  local function_name_node = nil

  -- For function_call, look for the function field or first child
  if function_call_node:type() == "function_call" then
    local function_fields = function_call_node:field("function")
    if function_fields and function_fields[1] then
      function_name_node = function_fields[1]
    else
      -- Fallback to first child if no function field
      function_name_node = function_call_node:child(0)
    end
  else
    -- For other call types, try to find the callable part
    for i = 0, function_call_node:child_count() - 1 do
      local child = function_call_node:child(i)
      if child and child:type() ~= "arguments" then
        function_name_node = child
        break
      end
    end
  end

  if not function_name_node then
    -- Fallback: select the entire call if we can't find the name part
    local start_row, start_col, end_row, end_col = function_call_node:range()
    vim.cmd("normal! \27")
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
    return true
  end

  local start_row, start_col, end_row, end_col = function_name_node:range()

  vim.cmd("normal! \27")
  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })

  return true
end

function M.is_top_level_function(node)
  if not node then return false end
  return is_function_node(node) and M.get_name_node(node) ~= nil
end

function M.get_name_node(function_node)
  if not function_node then return nil end
  local name_fields = function_node:field("name")
  return name_fields and name_fields[1] or nil
end

function M.get_function()
  local node = ts_utils.get_node_at_cursor()
  if not node then return nil end

  local current = node
  while current do
    if is_function_node(current) then
      return current
    end
    current = current:parent()
  end

  return nil
end

function M.print_details()
  local function_node = M.get_function()

  if not function_node then
    print("❌ Not inside a function")
    return
  end

  print("📋 FUNCTION DETAILS:")

  local name_node = M.get_name_node(function_node)
  if name_node then
    local ok, name_text = pcall(vim.treesitter.get_node_text, name_node, 0)
    print(string.format("   Name: %s", ok and name_text or "unknown"))
  else
    print("   Name: anonymous function")
  end

  local start_row, start_col, end_row, end_col = function_node:range()
  print(string.format("   Type: %s", function_node:type()))
  print(string.format("   Range: lines %d-%d (cols %d-%d)",
    start_row + 1, end_row + 1, start_col, end_col))

  local ok, function_text = pcall(vim.treesitter.get_node_text, function_node, 0)
  if ok and function_text then
    local lines = vim.split(function_text, "\n")
    print(string.format("   Lines: %d", #lines))

    local first_line = lines[1]:gsub("^%s+", "")
    if #first_line > 60 then
      first_line = first_line:sub(1, 57) .. "..."
    end
    print(string.format("   Preview: %s", first_line))
  end

  print(string.format("   Top-level: %s", M.is_top_level_function(function_node)))

  local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local relative_line = cursor_row - start_row + 1
  print(string.format("   Cursor at line: %d (relative: %d)", cursor_row + 1, relative_line))
end

function M.debug_treesitter_full()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    print("No node at cursor")
    return
  end

  print("=================== TREESITTER DEBUG ===================")

  local parents = {}
  local current = node
  while current do
    table.insert(parents, 1, current)
    current = current:parent()
  end

  print("\n📁 PARENT HIERARCHY (root → current):")
  for i, parent in ipairs(parents) do
    local indent = string.rep("  ", i - 1)
    local is_current = (parent == node)
    local marker = is_current and "👉 " or "   "
    local start_row, start_col = parent:range()
    local ok, text = pcall(vim.treesitter.get_node_text, parent, 0)
    local preview = ok and string.gsub(text:sub(1, 50), "\n", "\\n") or "no text"
    if #preview > 50 then preview = preview .. "..." end

    print(string.format("%s%s[%d] %s (line %d:%d) - %s",
      indent, marker, i, parent:type(), start_row + 1, start_col, preview))
  end

  print("\n🎯 CURRENT NODE:")
  local start_row, start_col, end_row, end_col = node:range()
  local ok, text = pcall(vim.treesitter.get_node_text, node, 0)
  print(string.format("   Type: %s", node:type()))
  print(string.format("   Range: (%d:%d) to (%d:%d)", start_row + 1, start_col, end_row + 1, end_col))
  print(string.format("   Text: %s", ok and text or "no text available"))

  local field_names = {}
  for field_name, _ in pairs(node:field() or {}) do
    table.insert(field_names, field_name)
  end
  if #field_names > 0 then
    print("   Fields: " .. table.concat(field_names, ", "))
  end

  print("\n🌳 CHILD HIERARCHY:")
  local function print_children(parent, depth)
    local child_count = parent:child_count()
    if child_count == 0 then return end

    for i = 0, child_count - 1 do
      local child = parent:child(i)
      if child then
        local indent = string.rep("  ", depth)
        local start_row, start_col = child:range()
        local ok, text = pcall(vim.treesitter.get_node_text, child, 0)
        local preview = ok and string.gsub(text:sub(1, 30), "\n", "\\n") or "no text"
        if #preview > 30 then preview = preview .. "..." end

        print(string.format("%s├─ [%d] %s (line %d:%d) - %s",
          indent, i, child:type(), start_row + 1, start_col, preview))

        local child_fields = {}
        for field_name, _ in pairs(child:field() or {}) do
          table.insert(child_fields, field_name)
        end
        if #child_fields > 0 then
          print(string.format("%s   Fields: %s", indent, table.concat(child_fields, ", ")))
        end

        if depth < 3 then
          print_children(child, depth + 1)
        elseif child:child_count() > 0 then
          print(string.format("%s   ... (%d more children)", indent, child:child_count()))
        end
      end
    end
  end

  print_children(node, 1)

  print("\n🔍 FUNCTION DETECTION:")
  print(string.format("   is_function_node: %s", is_function_node(node)))
  print(string.format("   is_top_level_function: %s", M.is_top_level_function(node)))
  local name_node = M.get_name_node(node)
  if name_node then
    local ok, name_text = pcall(vim.treesitter.get_node_text, name_node, 0)
    print(string.format("   function name: %s", ok and name_text or "no text"))
  else
    print("   function name: none")
  end

  print("======================================================")
end

function M.setup()
  vim.keymap.set("n", ",]", M.next_function, { desc = "Go to next function" })
  vim.keymap.set("n", ",[", M.prev_function, { desc = "Go to previous function" })
  vim.keymap.set({"n", "x", "o"}, "iF", M.select_function_name, { desc = "Select function name" })
  vim.keymap.set({"n", "x", "o"}, "iC", M.select_function_call, { desc = "Select function call" })
  -- vim.keymap.set("n", "<leader>fd", M.print_details, { desc = "Print function details" })
end

return M
