local Object: Object<{ [any]: any }> = {}

local function IndexFunction(t, i)
	local Parent = getmetatable(t).__parent
	local ParentValue, __Index

	if Parent then
		ParentValue = Parent[i]
		__Index = Parent.__index
	end

	if ParentValue then
		return ParentValue
	elseif type(__Index) == "function" then
		return __Index(t, i)
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
			ConstructorList[#ConstructorList + 1] = Constructor
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

function Object:Is(Other: Object<{ [any]: any }> | any, Recursive: boolean?)
	if type(Other) ~= "table" then
		return false
	end

	if Recursive then
		local Current = Other

		while Current ~= Object and Current ~= nil do
			if Current == self then
				return true
			end

			local mt = getmetatable(Current)

			Current = if mt then mt.__parent else nil
		end

		return false
	else
		local mt = getmetatable(Other :: any)
		return if mt then mt.__parent == self else false
	end
end

export type Object<P, A...> = {
	New: (self: Object<P, A...>, A...) -> (Object<P, A...>),
	Extend: (self: Object<P, A...>) -> (Object<P, A...>),
	Is: (self: Object<P, A...>, Other: Object<P, A...> | any, Recursive: boolean?) -> (boolean),

	Constructor: (self: Object<P, A...>, A...) -> (),
} & P

return Object
