return function()
	local Object = require(script.Parent)

	describe("classes", function()
		it("should make a valid instance", function()
			expect(Object:New()).to.be.ok()
		end)

		it("should make a valid class", function()
			expect(Object:Extend()).to.be.ok()
		end)

		it("should inherit values", function()
			local bigClass = Object:Extend()
			bigClass.a = 1
			bigClass.hello = "world"

			local smallClass = bigClass:Extend()

			expect(smallClass.a).to.equal(1)
			expect(smallClass.hello).to.equal("world")
		end)
	end)

	describe("instances", function()
		it("should inherit values", function()
			local class = Object:Extend()
			class.a = 1
			class.hello = "world"

			local instance = class:Extend()

			expect(instance.a).to.equal(1)
			expect(instance.hello).to.equal("world")
		end)

		it("should use the __index method", function()
			local class = Object:Extend()
			function class:__index(i)
				return i
			end

			local instance = class:New()

			expect(instance.hello).to.equal("hello")
		end)
	end)

	describe("constructors", function()
		it("should call multiple in the correct order", function()
			local value = Object
			for i = 0, 10 do
				value = value:Extend()
				function value:Constructor()
					self[i] = tick()
					task.wait()
				end
			end

			value = value:New()

			local lastTime = 0
			for i = 0, 10 do
				expect(value[i] > lastTime).to.equal(true)
				lastTime = value[i]
			end
		end)
	end)

	describe(":Is", function()
		it("should return true for instances", function()
			local class = Object:Extend()
			local instance = class:New()

			expect(class:Is(instance)).to.equal(true)
		end)

		it("should return false for non-instances", function()
			local class = Object:Extend()

			expect(class:Is(class)).to.equal(false)
			expect(class:Is(nil)).to.equal(false)
			expect(class:Is(true)).to.equal(false)
			expect(class:Is(false)).to.equal(false)
			expect(class:Is(0)).to.equal(false)
			expect(class:Is(1)).to.equal(false)
			expect(class:Is("")).to.equal(false)
			expect(class:Is({})).to.equal(false)
			expect(class:Is(function() end)).to.equal(false)
		end)

		it("should return true for subclasses", function()
			local class = Object:Extend()
			local subclass = class:Extend()

			expect(class:Is(subclass)).to.equal(true)
		end)

		it("should return false for subclass instances", function()
			local class = Object:Extend()
			local subclass = class:Extend()
			local instance = subclass:New()

			expect(class:Is(instance)).to.equal(false)
		end)

		it("should return true for subclass instances when recursive is true", function()
			local class = Object:Extend()
			local subclass = class:Extend()
			local instance = subclass:New()

			expect(class:Is(instance, true)).to.equal(true)
		end)
	end)
end
