function FeedKeys(keys)
	vim.api.nvim_feedkeys(keys, "n", false)
end

function FeedKeysInt(keys)
	local feedable_keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
	vim.api.nvim_feedkeys(feedable_keys, "n", true)
end

function EscapeForLiteralSearch(input)
	input = string.gsub(input, '\\', '\\\\')
	input = string.gsub(input, '\n', '\\n')
	input = string.gsub(input, '/', '\\/')
	return input
end

function EscapeFromLiteralSearch(input)
	if string.sub(input, 1, 2) ~= "\\V" then return input end
	input = string.sub(input, 3)
	input = string.gsub(input, '\\/', '/')
	input = string.gsub(input, '\\\\', '\\')
	return input
end

function EscapeFromRegexSearch(input)
	if string.sub(input, 1, 2) ~= '\\v' then return input end
	return string.sub(input, 3)
end

function GetChar(prompt)
	vim.api.nvim_echo({ { prompt, "Input" } }, true, {})
	local char = vim.fn.getcharstr()
	-- That's the escape character (<Esc>). Not sure how to specify it smarter
	-- In other words, if you pressed escape, we return nil
	if char == '' then
		char = nil
	end
	return char
end

function Validate_register(register)
	if register == 'q' then
		return '+'
	elseif register == 'w' then
		return '0'
	elseif register == "'" then
		return '"'
	else
		return register
	end
end

function GetBool(message)
	local char = GetChar(message .. " (f/d):")
	local bool
	if char == 'f' then
		bool = true
	elseif char == 'd' then
		bool = false
	else
		print("press f for true, d for false")
		return nil
	end
	return bool
end

function Remove_highlighting() Cmd("noh") end

function Toggle_highlight_search() Cmd("set hlsearch!") end

function ReverseTable(table)
	local reversed = setmetatable({}, { __index = table })
	local length = #table

	for i = length, 1, -1 do
		table.insert(reversed, table[i])
	end

	return reversed
end

-- I call it death because that's where we end up in. Just like /e or no /e
function Search_for_selection(direction, death)
	FeedKeys('y')
	vim.schedule(function()
		local escaped_selection = EscapeForLiteralSearch(vim.fn.getreg('"'))
		FeedKeys(direction .. '\\V' .. escaped_selection .. death)
		FeedKeysInt('<cr>')
	end)
end

function Search_for_register(direction, death)
	local char = GetChar("register: ")
	if not char then return end
	local register = Validate_register(char)
	local escaped_register = EscapeForLiteralSearch(vim.fn.getreg(register))
	FeedKeys(direction .. '\\V' .. escaped_register .. death)
	FeedKeysInt('<cr>')
end

function Move_default_to_other()
	local char = GetChar("register: ")
	if not char then return end
	local register = Validate_register(char)
	local default_contents = vim.fn.getreg('"')
	vim.fn.setreg(register, default_contents)
end

function Search_for_current_word(direction, death)
	FeedKeys('yiw')
	vim.schedule(function()
		local escaped_word = EscapeForLiteralSearch(vim.fn.getreg('"'))
		FeedKeys(direction .. '\\V' .. escaped_word .. death)
		FeedKeysInt('<cr>')
	end)
end


function Get_vertical_line_diff(is_top)
	local winid = vim.api.nvim_get_current_win()
	local function get_visible_lines()
		local compared_line = 0
		if is_top then
			compared_line = vim.fn.line('w0')
		else
			compared_line = vim.fn.line('w$')
		end
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		local line_count = math.abs(compared_line - current_line)
		return line_count
	end
	local line_count = vim.api.nvim_win_call(winid, get_visible_lines)
	return line_count
end

local function harp_set()
	local dir = vim.fn.expand('~/.local/share/harp')
	ensure_dir_exists(dir)
	local register = Get_char('harp: ')
	if register == nil then return end
	local full_path = vim.api.nvim_buf_get_name(0)
	local file = io.open(dir .. '/' .. register, 'w')
	if file then
		file:write(full_path)
		file:close()
		print('prah ' .. register)
	end
end

local function harp_get(edit_command)
	local dir = vim.fn.expand('~/.local/share/harp')
	ensure_dir_exists(dir)
	local register = Get_char('harp: ')
	if register == nil then return end
	local file = io.open(dir .. '/' .. register, 'r')
	if file then
		local output = file:read('l')
		if #output > 0 then
			Cmd((edit_command or 'edit') .. ' ' .. output)
			print('harp ' .. register)
		else
			print(register .. ' is empty')
		end
		file:close()
	else
		print(register .. ' is empty')
	end
end

local function ensure_dir_exists(path)
	local stat = vim.loop.fs_stat(path)
	if not stat then
		vim.loop.fs_mkdir(path, 511) -- 511 corresponds to octal 0777
	elseif stat.type ~= 'directory' then
		error(path .. ' is not a directory')
	end
end

function numbered_get(index, insert)
	if numbered[index] == '' then
		print(index .. ' is empty')
		return
	end
	vim.fn.setreg('"', numbered[index])
	if insert then
		if insert == 'command' then
			FeedKeysInt('<c-r>"')
		else
			FeedKeysInt('<c-r><c-p>"')
		end
	end
	print('grabbed')
end

function numbered_set(index)
	local register_contents = vim.fn.getreg('"')
	if register_contents == '' then
		print('default register empty')
		return
	end
	numbered[index] = register_contents
	print('stabbed')
end


local function numbered_insert(index) numbered_get(index, true) end
local function numbered_command(index) numbered_get(index, 'command') end

function killring_compile_reversed()
	local reversed_killring = ReverseTable(killring)
	local compiled_killring = reversed_killring:concat('')
	vim.fn.setreg('"', compiled_killring)
	killring = setmetatable({}, { __index = table })
	print('killring compiled in reverse')
end

function killring_compile()
	local compiled_killring = killring:concat('')
	vim.fn.setreg('"', compiled_killring)
	killring = setmetatable({}, { __index = table })
	print('killring compiled')
end


function killring_push_tail()
	local register_contents = vim.fn.getreg('"')
	if register_contents == '' then
		print('default register is empty')
		return
	end
	killring:insert(1, register_contents)
	print('pushed')
end

function killring_push()
	local register_contents = vim.fn.getreg('"')
	if register_contents == '' then
		print('default register is empty')
		return
	end
	killring:insert(register_contents)
	print('pushed')
end

function killring_pop_tail(insert)
	if #killring <= 0 then
		print('killring empty')
		return
	end
	local first_index = killring:remove(1)
	vim.fn.setreg('"', first_index)
	if insert then
		if insert == 'command' then
			FeedKeysInt('<C-r>"')
		else
			FeedKeysInt('<C-r><C-p>"')
		end
	end
	print('got tail')
end

function killring_pop(insert)
	if #killring <= 0 then
		print('killring empty')
		return
	end
	local first_index = killring:remove(#killring)
	vim.fn.setreg('"', first_index)
	if insert then
		if insert == 'command' then
			FeedKeysInt('<c-r>"')
		else
			FeedKeysInt('<c-r><c-p>"')
		end
	end
	print('got nose')
end

local function another_quickfix_entry(to_next, buffer)
	local qflist = vim.fn.getqflist()
	if #qflist == 0 then
		print('quickfix list is empty')
		return
	end

	if vim.v.count > 0 then
		Cmd('cc ' .. vim.v.count)
		return
	end

	local qflist_index = vim.fn.getqflist({ idx = 0 }).idx
	local current_buffer = vim.api.nvim_get_current_buf()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]

	if
		qflist_index == 1 and (qflist[1].bufnr ~= current_buffer or qflist[1].lnum ~= current_line)
	then -- If you do have a quickfix list, the first index is automatically selected, meaning that the first time you try to `cnext`, you go to the second quickfix entry, even though you have never actually visited the first one. This is what I mean when I say vim has a bad foundation and is terrible to build upon. We need a modal editor with a better foundation, with no strange behavior like this!
		Cmd('cfirst')
		return
	end

	local status = true
	if to_next then
		if buffer then
			status, _ = pcall(Cmd, 'cnfile')
		else
			status, _ = pcall(Cmd, 'cnext')
		end
		if not status then Cmd('cfirst') end
	else
		if buffer then
			status, _ = pcall(Cmd, 'cpfile')
		else
			status, _ = pcall(Cmd, 'cprev')
		end
		if not status then Cmd('clast') end
	end
end


local function save()
	trim_trailing_whitespace()
	Cmd('nohl')
	if vim.bo.modified then pcall(Cmd, 'write') end
end

local function trim_trailing_whitespace()
	local search = vim.fn.getreg('/')
	pcall(Cmd, '%s`\\v\\s+$')
	vim.fn.setreg('/', search)
end

local function close_try_save()
	if vim.bo.modified then pcall(Cmd, 'write') end
	Cmd('q!')
end

local function move_to_blank_line(to_next)
	local search_opts = to_next and '' or 'b'
	vim.fn.search('^\\s*$', search_opts)
end

local function edit_magazine()
	local register = Get_char('magazine: ')
	if register == nil then return end
	Cmd('edit ' .. vim.fn.expand('~/.local/share/magazine/') .. register)
	print('shoot ' .. register)
end

local function copy_full_path()
	local full_path = vim.api.nvim_buf_get_name(0)
	local home = os.getenv('HOME')
	if not home then return end
	local friendly_path = string.gsub(full_path, home, '~')
	vim.fn.setreg('+', friendly_path)
	print('full path: ' .. friendly_path)
end

local function copy_file_name()
	local file_name = vim.fn.expand('%:t')
	vim.fn.setreg('+', file_name)
	print('name: ' .. file_name)
end

local function copy_cwd_relative()
	local relative_path = vim.fn.expand('%:p:.')
	vim.fn.setreg('+', relative_path)
	print('cwd relative: ' .. relative_path)
end

local function copy_git_relative()
	local full_path = vim.api.nvim_buf_get_name(0)
	local git_root = Get_repo_root()
	local relative_path = string.gsub(full_path, '^' .. git_root .. '/', '')
	vim.fn.setreg('+', relative_path)
	print('repo relative: ' .. relative_path)
end



