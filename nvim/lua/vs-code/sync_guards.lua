-- vscode-neovim 1.20.1 can abort layout sync when VS Code sends a selection
-- or text change for a line that does not exist in the nvim buffer yet.
-- That surfaces as:
--   vim.str_byteindex: string expected, got nil   (internal.lua:294)
--   Invalid 'start_row': out of range             (internal.lua:67)
--   nvim_win_set_cursor: Cursor position outside buffer
-- and the UI sticks on "Syncing layout: Syncing visible editors".

local M = {}

local api = vim.api

local function pad_buffer_to(bufnr, max_row)
  if not api.nvim_buf_is_valid(bufnr) or type(max_row) ~= "number" or max_row < 0 then
    return
  end
  local line_count = api.nvim_buf_line_count(bufnr)
  if max_row < line_count then
    return
  end
  local pad = {}
  for _ = line_count, max_row do
    pad[#pad + 1] = ""
  end
  pcall(api.nvim_buf_set_lines, bufnr, line_count, line_count, false, pad)
end

function M.apply()
  local ok_util, util = pcall(require, "vscode.util")
  if ok_util and type(util.get_line) == "function" and not util._dotfiles_nil_line_guard then
    local orig_get_line = util.get_line
    util.get_line = function(bufnr, row)
      local line = orig_get_line(bufnr, row)
      if type(line) == "string" then
        return line
      end
      return ""
    end
    util._dotfiles_nil_line_guard = true
  end

  local ok_internal, internal = pcall(require, "vscode.internal")
  if not ok_internal then
    return
  end

  if type(internal.start_visual) == "function" and not internal._dotfiles_start_visual_guard then
    local orig_start_visual = internal.start_visual
    internal.start_visual = function(buf, anchor, active)
      if type(anchor) ~= "table" or type(active) ~= "table" then
        return
      end
      if type(buf) ~= "number" or not api.nvim_buf_is_valid(buf) then
        return
      end
      local line_count = api.nvim_buf_line_count(buf)
      if
        type(anchor.line) ~= "number"
        or type(active.line) ~= "number"
        or anchor.line < 0
        or active.line < 0
        or anchor.line >= line_count
        or active.line >= line_count
      then
        return
      end
      return orig_start_visual(buf, anchor, active)
    end
    internal._dotfiles_start_visual_guard = true
  end

  if type(internal.handle_changes) == "function" and not internal._dotfiles_handle_changes_guard then
    local orig_handle_changes = internal.handle_changes
    internal.handle_changes = function(bufnr, changes)
      if type(bufnr) ~= "number" or not api.nvim_buf_is_valid(bufnr) then
        return 0
      end
      if type(changes) == "table" then
        local max_row = -1
        for _, change in ipairs(changes) do
          if type(change) == "table" then
            max_row = math.max(max_row, tonumber(change[1]) or -1, tonumber(change[3]) or -1)
          end
        end
        pad_buffer_to(bufnr, max_row)
      end
      local ok, tick = pcall(orig_handle_changes, bufnr, changes)
      if ok then
        return tick
      end
      return api.nvim_buf_get_changedtick(bufnr)
    end
    internal._dotfiles_handle_changes_guard = true
  end
end

return M
