--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

ProjectileScript = script:WaitForChild("ProjectileScript")

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

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseSnowBall = BasePart:Clone()
BaseSnowBall.Name = "Snowball"
BaseSnowBall.BrickColor = BrickColor.new("Institutional white")
BaseSnowBall.Material = Enum.Material.Concrete
BaseSnowBall.Shape = Enum.PartType.Ball
BaseSnowBall.Size = Vector3.new(1.125, 1.125, 1.125)

Anims = Tool:WaitForChild("Animations")
R6Anims = Anims:WaitForChild("R6")
R15Anims = Anims:WaitForChild("R15")

Sounds = {
	Throw = Handle:WaitForChild("Throw")
}

Animations = {
	R6HandsOut = {Animation = R6Anims:WaitForChild("HandsOut"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R6MakeSnow = {Animation = R6Anims:WaitForChild("MakeSnow"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 3},
	R6Throw = {Animation = R6Anims:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	R15HandsOut = {Animation = R15Anims:WaitForChild("HandsOut"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15MakeSnow = {Animation = R15Anims:WaitForChild("MakeSnow"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 3},
	R15Throw = {Animation = R15Anims:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},

}

Remotes = (Tool:FindFirstChild("Remotes") or Create("Folder"){
	Name = "Remotes",
	Parent = Tool,
})

ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

Handle.Transparency = 0
Tool.Enabled = true

function CreateGloves(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if Create and CheckIfAlive() then
		local Glove = BasePart:Clone()
		Glove.Size = Vector3.new(0.2, 0.2, 0.2)
		Glove.CanCollide = false
		local GloveMesh = Instance.new("SpecialMesh")
		GloveMesh.Name = "Mesh"
		GloveMesh.MeshType = Enum.MeshType.FileMesh
		GloveMesh.MeshId = ""
		GloveMesh.TextureId = Mesh.TextureId
		GloveMesh.Scale = Vector3.new(1.15, 1.15, 1.15)
		GloveMesh.VertexColor = Vector3.new(1, 1, 1)
		GloveMesh.Offset = Vector3.new(0, 0, 0)
		GloveMesh.Parent = Glove
		LeftGlove = Glove:Clone()
		LeftGlove.Name = "LeftGlove"
		LeftGlove.Mesh.MeshId = (BaseUrl .. "655155448")
		RightGlove = Glove:Clone()
		RightGlove.Name = "RightGlove"
		RightGlove.Mesh.MeshId = (BaseUrl .. "655155019")
		local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand")
		local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
		for i, v in pairs({LeftArm, RightArm}) do
			if v then
				local Glove = ((v == LeftArm and LeftGlove) or RightGlove)
				local Weld = Instance.new("Weld")
				Weld.Part0 = v
				Weld.Part1 = Glove
				if Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Weld.C0 = CFrame.new((0 * ((v == RightArm and 1) or -1)), -1, 0.075)
				else
					Weld.C0 = CFrame.new((0 * ((v == RightArm and 1) or -1)), -1.95, 0.075)
				end
				if v == RightArm then
					Weld.C0 = (Weld.C0 * CFrame.new(0, 0, 0))
				end
				Weld.C1 = (CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles((math.pi / 2), 0, 0))
				Weld.Parent = Glove
				Glove.Parent = Tool
			end
		end
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if SnowBall and SnowBall.Parent then
		local MouseData = InvokeClient("MouseData")
		if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
			Tool.Enabled = true
			return
		end
		local Animation = ((Humanoid.RigType == Enum.HumanoidRigType.R15 and Animations.R15Throw) or Animations.R6Throw)
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		wait(Animation.Duration / 2)
		if CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
			if SnowBall and SnowBall.Parent then
				SnowBall:Destroy()
			end
			Sounds.Throw:Play()
			local MousePos = MouseData.Position
			local Direction = CFrame.new(SnowBall.Position, MousePos).lookVector
			local launch = (Handle.CFrame + Direction * 10)
			local Projectile = BaseSnowBall:Clone()
			Projectile.Name = "Projectile"
			Projectile.CFrame = launch
			Projectile.Velocity = (Direction * 80)
			local force = Create("BodyForce"){
				Name = "BodyForce",
				force = Vector3.new(0, 40, 0),
				Parent = Projectile,
			}
			local Creator = Create("ObjectValue"){
				Name = "Creator",
				Value = Player,
				Parent = Projectile,
			}
			local ProjectileScriptCopy = ProjectileScript:Clone()
			ProjectileScriptCopy.Disabled = false
			ProjectileScriptCopy.Parent = Projectile
			Debris:AddItem(Projectile, 3)
			Projectile.Parent = game:GetService("Workspace")
			wait(2)
		end
	else
		local Animation = ((Humanoid.RigType == Enum.HumanoidRigType.R15 and Animations.R15MakeSnow) or Animations.R6MakeSnow)
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		wait(Animation.Duration / 2)
		if CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
			SnowBall = BaseSnowBall:Clone()
			SnowWeld = Create("Weld"){
				Name = "Weld",
				Part0 = RightGlove,
				Part1 = SnowBall,
				C0 = CFrame.new(-0.25, 0.25, -0.3),
				C1 = CFrame.new(0, 0, 0),
				Parent = RightGlove,
			}
			SnowBall.Parent = Tool
			wait(1.5)
		end
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		CreateGloves(true)
		local Animation = ((Humanoid.RigType == Enum.HumanoidRigType.R15 and Animations.R15HandsOut) or Animations.R6HandsOut)
		InvokeClient("PlayAnimation", Animation)
	end)
	Handle.Transparency = 1
	ToolEquipped = true
end

function Unequipped()
	CreateGloves(false)
	Handle.Transparency = 0
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Delay(0, (function()
	if ToolEquipped then
		return
	end
	CreateGloves(false)
end))

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)