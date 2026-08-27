--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	--return the proxy function that gives us the nice Create'string'{data} syntax
	--The first function call is a function call using Lua's single-string-argument syntax
	--The second function call is using Lua's single-table-argument syntax
	--Both can be chained together for the nice effect.
	return function(dat)
		--default to nothing, to handle the no argument given case
		dat = dat or {}

		--make the object to mutate
		local obj = Instance.new(objectType)
		local parent = nil

		--stored constructor function to be called after other initialization
		local ctor = nil

		for k, v in pairs(dat) do
			--add property
			if type(k) == 'string' then
				if k == 'Parent' then
					-- Parent should always be set last, setting the Parent of a new object
					-- immediately makes performance worse for all subsequent property updates.
					parent = v
				else
					obj[k] = v
				end


			--add child
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj


			--event connect
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
							got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)


			--define constructor function
			elseif k == t.Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
							got: "..tostring(v), 2)
				elseif ctor then
					--ctor already exists, only one allowed
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v


			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end

		--apply constructor function if it exists
		if ctor then
			ctor(obj)
		end

		if parent then
			obj.Parent = parent
		end

		--return the completed object
		return obj
	end
end

--now, create the functor:
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})

--and create the "Event.E" syntax stub. Really it's just a stub to construct a table which our Create
--function can recognize as special.
Create.E = function(eventName)
	return {__eventname = eventName}
end


BaseUrl = "http://www.roblox.com/asset/?id="

Gravity = 196.20

Rate = (1 / 60)

Sparkle = script:WaitForChild("Sparkle")
SparkleScript = script:WaitForChild("SparkleScript")

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseSparklePart = BasePart:Clone()
BaseSparklePart.Name = "Effect"
BaseSparklePart.Transparency = 1
BaseSparklePart.Size = Vector3.new(1, 1, 1)
BaseSparklePart.CanCollide = false
BaseSparklePart.Anchored = true

Sounds = {
	LightUp = Handle:WaitForChild("LightUp"),
	Spark = Handle:WaitForChild("Spark")
}

Colors = {
	Color3.new(1, 0, 0),
	Color3.new(1, 1, 1),
	Color3.new(0, 0, 1),
}

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function CreateSparks()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local ModelName = (Player.Name .. "'s Sparkles")
	local MainSparkleModel = game:GetService("Workspace"):FindFirstChild(ModelName)
	if not MainSparkleModel then
		MainSparkleModel = Create("Model"){
			Name = ModelName,
		}
		local SparkleScriptCopy = SparkleScript:Clone()
		SparkleScriptCopy.Disabled = false
		SparkleScriptCopy.Parent = MainSparkleModel
	end

	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	local CurrentlyEquipped = true
	
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)

	local NumberOfSparkles = 35
	local DelayedNumber = 3
	
	for i = 1, NumberOfSparkles, DelayedNumber do
		
		if not CurrentlyEquipped then
			return
		end
		
		for ii = 1, DelayedNumber do
			
			if not CurrentlyEquipped then
				return
			end
		
			local SparklePart = BaseSparklePart:Clone()
			SparklePart.CFrame = (Handle.CFrame * CFrame.new((math.random(-250, 250) * 0.001), ((Handle.Size.Y / 2) + (math.random(-250, 250) * 0.001)), (math.random(-250, 250) * 0.001)))
			
			local Color = Colors[math.random(1, #Colors)]
			local SparkleEffect = Sparkle:Clone()
			SparkleEffect.Adornee = SparklePart
			local SparkleImage = SparkleEffect:FindFirstChild("Image")
			SparkleImage.ImageColor3 = Color
			SparkleEffect.Parent = SparklePart
			SparkleEffect.Enabled = true
			
			local Light = Create("PointLight"){
				Name = "Light",
				Range = 3,
				Brightness = 100,
				Color = Color,
				Enabled = true,
				Parent = SparklePart,
			}
			
			local Velocity = math.random(5, 15)
			local Direction = (SparklePart.CFrame * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0)).lookVector
			local Values = {
				{Name = "Direction", Class = "Vector3Value", Value = Vector3.new(Direction.X, 1, Direction.Z)},
				{Name = "AccelerationVelocity", Class = "Vector3Value", Value = Vector3.new(0, (5 + math.random(0, 10)), (3 + math.random(0, 5)))},
				{Name = "DecelerationVelocity", Class = "Vector3Value", Value = Vector3.new(0, -25, 0)},
				{Name = "Velocity", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = SparklePart,
				}
			end
	
			SparklePart.Velocity = Vector3.new(0, 0, 0)
			SparklePart.RotVelocity = Vector3.new(0, 0, 0)
			
			Debris:AddItem(SparklePart, 1.5)
			
			SparklePart.Parent = MainSparkleModel
			
		end
		
		wait(Rate)
		
	end

	if not MainSparkleModel.Parent and MainSparkleModel.Name == ModelName then
		MainSparkleModel.Parent = game:GetService("Workspace")
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Sounds.Spark:Play()
	CreateSparks()
	wait(0.5)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.LightUp:Play()
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)