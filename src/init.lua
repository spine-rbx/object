local Object: Object<{[any]: any}> = {}

local function IndexFunction(t, i)
	local Parent = getmetatable(t).__parent

	if Parent[i] then
		return Parent[i]
	elseif type(t.__index) == "function" then
		return t.__index(t, i)
	end

	return nil
end

function Object:New(...)
	local New = setmetatable({}, { __parent = self, __index = IndexFunction })

	local ConstructorList = {}

	local Current = self
	while Current ~= Object do
		local Constructor = rawget(Current, "Constructor")

		if type(Constructor) == "function" then
			ConstructorList[#ConstructorList+1] = Constructor
		end

		Current = getmetatable(Current).__parent
	end

	-- starts with the "oldest" constructors
	for i = #ConstructorList, 1, -1 do
		ConstructorList[i](New, ...)
	end

	return New
end

function Object:Extend()
	return setmetatable({}, { __index = self, __parent = self })
end

export type Object<P, A...> = {
	New: (self: Object<P, A...>, A...) -> (Object<P, A...>),
	Extend: (self: Object<P, A...>) -> (Object<P, A...>),

	Constructor: (self: Object<P, A...>, A...) -> ()?,
} & P

return Object