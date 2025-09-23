-- A simple killring implementation inspired by Emacs
local killring = setmetatable({}, {__index = table})

local function killring_push_tail()
	local register_contents = vim.fn.getreg('"')
	if register_contents == '' then
		print("default register is empty")
		return
	end
	killring:insert(1, register_contents)
	print("pushed")
end
Map("n", "'R", killring_push_tail)

local function killring_push()
	local register_contents = vim.fn.getreg('"')
	if register_contents == '' then
		print("default register is empty")
		return
	end
	killring:insert(register_contents)
	print("pushed")
end
Map("n", "'r", killring_push)

local function killring_pop_tail()
	if #killring <= 0 then
		print("killring empty")
		return
	end
	local first_index = killring:remove(1)
	vim.fn.setreg('"', first_index)
	print("got tail")
end
Map("n", "'E", killring_pop_tail)

local function killring_pop()
	if #killring <= 0 then
		print("killring empty")
		return
	end
	local first_index = killring:remove(#killring)
	vim.fn.setreg('"', first_index)
	print("got nose")
end
Map("n", "'e", killring_pop)

local function killring_kill()
	killring = setmetatable({}, { __index = table })
	print("ring killed")
end
Map({"n", "v"}, ",z", killring_kill)

local function killring_compile()
	local compiled_killring = killring:concat('')
	vim.fn.setreg('"', compiled_killring)
	killring = setmetatable({}, { __index = table })
	print("killring compiled")
end
Map({"n", "v"}, "'t", killring_compile)

local function killring_compile_reversed()
	local reversed_killring = ReverseTable(killring)
	local compiled_killring = reversed_killring:concat('')
	vim.fn.setreg('"', compiled_killring)
	killring = setmetatable({}, { __index = table })
	print("killring compiled in reverse")
end
Map({"n", "v"}, "'T", killring_compile_reversed)


-- Numbered registers implementation
local numbered = setmetatable({'', '', '', '', '', '', '', '', '', ''}, {__index = table})

local function numbered_get(index)
	if numbered[index] == '' then
		print(index .. ' is empty')
		return
	end
	-- vim.fn.setreg('"', numbered[index])
	vim.fn.setreg('+', numbered[index])
	print("grabbed")
end

local function numbered_set(index)
	local register_contents = vim.fn.getreg('"')
	if register_contents == '' then
		print("default register empty")
		return
	end
	numbered[index] = register_contents
	print("stabbed")
end

Map({'n', 'v'}, "'1", function() numbered_get(1) end)
Map({'n', 'v'}, "'2", function() numbered_get(2) end)
Map({'n', 'v'}, "'3", function() numbered_get(3) end)
Map({'n', 'v'}, "'4", function() numbered_get(4) end)
Map({'n', 'v'}, "'5", function() numbered_get(5) end)
Map({'n', 'v'}, "'6", function() numbered_get(6) end)
Map({'n', 'v'}, "'7", function() numbered_get(7) end)
Map({'n', 'v'}, "'8", function() numbered_get(8) end)
Map({'n', 'v'}, "'9", function() numbered_get(9) end)
Map({'n', 'v'}, "'0", function() numbered_get(10) end)

Map({'n', 'v'}, ",1", function() numbered_set(1) end)
Map({'n', 'v'}, ",2", function() numbered_set(2) end)
Map({'n', 'v'}, ",3", function() numbered_set(3) end)
Map({'n', 'v'}, ",4", function() numbered_set(4) end)
Map({'n', 'v'}, ",5", function() numbered_set(5) end)
Map({'n', 'v'}, ",6", function() numbered_set(6) end)
Map({'n', 'v'}, ",7", function() numbered_set(7) end)
Map({'n', 'v'}, ",8", function() numbered_set(8) end)
Map({'n', 'v'}, ",9", function() numbered_set(9) end)
Map({'n', 'v'}, ",0", function() numbered_set(10) end)


-- Remap some default registers
Map("", "S", '"_S')
Map("", "s", '"_s')
Map("", "''S", 'S')
Map("", "''s", 's')
Map("", "C", '"_C')
Map("", "c", '"_c')
Map("", "''C", 'C')
Map("", "''c", 'c')

Map("", "M[", "`[")
Map("", "M]", "`]")
Map("", "M.", "`>")
Map("", "M,", "`<")
Map("", "M/", "`^")

Map("", "'q", '"+')
Map("", "'w", '"0')
Map("", "'i", '"_')
Map("", "';", '":')

Map("!", "<C-v>", "<C-r><C-p>+")
Map("!", "<C-r>w", "<C-r><C-p>0")
Map("!", "<C-r>;", "<C-r><C-p>:")
Map("!", "<C-b>", '<C-r><C-p>"')
