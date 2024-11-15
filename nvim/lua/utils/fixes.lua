-- Mark fix
for c = string.byte("a"), string.byte("z") do
	local char = string.char(c)
	local upper_char = string.upper(char)
	Map("n", "m" .. char, "m" .. upper_char)
	Map("n", "M" .. char, "`" .. upper_char)
end