-- Duplicate English mappings onto the Arabic 101 layout.
-- langmap only remaps builtin keys; plugin maps like ie/iq need explicit copies.
-- Keep in sync with vim.opt.langmap in common/opts.lua. `b` is omitted (لا).

local M = {}

local en_to_ar = {
  q = "ض",
  w = "ص",
  e = "ث",
  r = "ق",
  t = "ف",
  y = "غ",
  u = "ع",
  i = "ه",
  o = "خ",
  p = "ح",
  ["["] = "ج",
  ["]"] = "د",
  a = "ش",
  s = "س",
  d = "ي",
  f = "ب",
  g = "ل",
  h = "ا",
  j = "ت",
  k = "ن",
  l = "م",
  [";"] = "ك",
  ["'"] = "ط",
  z = "ئ",
  x = "ء",
  c = "ؤ",
  v = "ر",
  n = "ى",
  m = "ة",
  [","] = "و",
  ["."] = "ز",
  ["/"] = "ظ",
  H = "أ",
  Y = "إ",
  N = "آ",
}

local skip_modes = {
  i = true,
  t = true,
  R = true,
}

-- targets.vim maps `i`/`a` as expr maps that getchar() the next key (no langmap).
-- Copying those 1-char maps to Arabic makes ciq/ciw feed ض/ص instead of q/w.
local textobject_prefixes = { i = true, a = true, I = true, A = true }
local textobject_modes = { o = true, x = true, v = true, s = true }

local orig_set = vim.keymap.set
local orig_api_set = vim.api.nvim_set_keymap
local orig_buf_set = vim.api.nvim_buf_set_keymap

local function translate_lhs(lhs)
  if type(lhs) ~= "string" or lhs == "" then
    return nil
  end
  local lower = lhs:lower()
  if lower:find("<plug>", 1, true) or lower:find("<sid>", 1, true) or lower:find("<snr>", 1, true) then
    return nil
  end

  local out = {}
  local changed = false
  local i = 1
  while i <= #lhs do
    local ch = lhs:sub(i, i)
    if ch == "<" then
      local close = lhs:find(">", i, true)
      if close then
        table.insert(out, lhs:sub(i, close))
        i = close + 1
      else
        table.insert(out, ch)
        i = i + 1
      end
    else
      local tr = en_to_ar[ch]
      if tr then
        changed = true
        table.insert(out, tr)
      else
        table.insert(out, ch)
      end
      i = i + 1
    end
  end
  if not changed then
    return nil
  end
  return table.concat(out)
end

local function each_mode(mode)
  if type(mode) == "table" then
    return mode
  end
  if mode == "" then
    return { "n", "v", "o" }
  end
  return { mode }
end

local function should_translate_mode(mode)
  return mode and not skip_modes[mode]
end

local function is_textobject_prefix(mode, lhs)
  return type(lhs) == "string" and #lhs == 1 and textobject_prefixes[lhs] and textobject_modes[mode]
end

local function copy_map(set_fn, mode, lhs, rhs, opts)
  local ar = translate_lhs(lhs)
  if not ar then
    return
  end
  for _, m in ipairs(each_mode(mode)) do
    if should_translate_mode(m) and not is_textobject_prefix(m, lhs) then
      pcall(set_fn, m, ar, rhs, opts)
    end
  end
end

-- Two-key inner/around objects so Arabic q/w do not go through targets getchar().
local function map_letter_textobjects()
  for en, ar in pairs(en_to_ar) do
    if en:match("^%a$") then
      pcall(orig_set, { "o", "x" }, "ه" .. ar, "i" .. en, { remap = true, silent = true })
      pcall(orig_set, { "o", "x" }, "ش" .. ar, "a" .. en, { remap = true, silent = true })
    end
  end
end

function M.enable()
  vim.keymap.set = function(mode, lhs, rhs, opts)
    orig_set(mode, lhs, rhs, opts)
    copy_map(orig_set, mode, lhs, rhs, opts)
  end

  vim.api.nvim_set_keymap = function(mode, lhs, rhs, opts)
    orig_api_set(mode, lhs, rhs, opts)
    if should_translate_mode(mode) then
      copy_map(orig_api_set, mode, lhs, rhs, opts)
    end
  end

  vim.api.nvim_buf_set_keymap = function(buffer, mode, lhs, rhs, opts)
    orig_buf_set(buffer, mode, lhs, rhs, opts)
    local ar = translate_lhs(lhs)
    if ar and should_translate_mode(mode) then
      pcall(orig_buf_set, buffer, mode, ar, rhs, opts)
    end
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      M.automap_existing()
      map_letter_textobjects()
    end,
  })
  map_letter_textobjects()
end

function M.automap_existing()
  for _, mode in ipairs({ "n", "v", "x", "s", "o" }) do
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      local ar = translate_lhs(km.lhs)
      if ar and not is_textobject_prefix(mode, km.lhs) then
        local opts = {
          silent = km.silent == 1,
          noremap = km.noremap == 1,
          expr = km.expr == 1,
          nowait = km.nowait == 1,
          desc = km.desc,
        }
        if km.callback then
          pcall(orig_set, mode, ar, km.callback, opts)
        elseif km.rhs and km.rhs ~= "" then
          pcall(orig_api_set, mode, ar, km.rhs, opts)
        end
      end
    end
  end
end

M.translate_lhs = translate_lhs

return M
