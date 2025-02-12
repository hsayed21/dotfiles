-- Map("n", ",dl", 'dil\'_dd', { remap = true }) -- Take the contents of the line, but delete the line too
-- Map("n", ",di", '"_ddddpvaB<Esc>') -- Push line of code after block into block

Map("n", ",m", "?\\V$0<cr>cgn")

Map("", "_", function() FeedKeysInt(vim.v.count1 .. "k$") end)

local function multiply() FeedKeysInt("yl" .. vim.v.count1 .. "p") end
Map("n", "@", multiply)

local function multiply_visual() FeedKeysInt("ygv<Esc>" .. vim.v.count1 .. "p") end
Map("v", "@@", multiply_visual)

local function simplify_gM() FeedKeys(vim.v.count * 10 .. "gM") end
Map("", "gm", simplify_gM)

Map("n", "J", function()
	for i = 1, vim.v.count1 do
		FeedKeys("J")
	end
end)

local function remove_highlighting__escape()
	Remove_highlighting()
	FeedKeysInt("<Esc>")
end
Map("n", "<Esc>", remove_highlighting__escape)

local function dd_count()
	for i = 1, vim.v.count1 do
		FeedKeys("dd")
	end
end
Map("n", "du", dd_count)




Map("v", "*", function() Search_for_selection('/', '') end)
Map("v", ",*", function() Search_for_selection('/', '/e') end)
Map("v", "#", function() Search_for_selection('?', '') end)
Map("v", ",#", function() Search_for_selection('?', '?e') end)

-- Map("", ",f", function() Search_for_register('/', '') end)
-- Map("", ",F", function() Search_for_register('?', '') end)
-- Map("", ",,f", function() Search_for_register('/', '/e') end)
-- Map("", ",,F", function() Search_for_register('?', '?e') end)

Map("n", ",g", Move_default_to_other)

Map("n", "*", function() Search_for_current_word('/', '') end)
Map("n", ",*", function() Search_for_current_word('/', '/e') end)
Map("n", "#", function() Search_for_current_word('?', '') end)
Map("n", ",#", function() Search_for_current_word('?', '?e') end)