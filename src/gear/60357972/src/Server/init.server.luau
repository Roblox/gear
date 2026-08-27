--Flaming hedgehog cannon
--Now featuring the blue blur at a 20% chance!

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle")

local Cannon = Tool.Handle

Tool.Enabled = true 

local Components = {
	Tip = Handle:WaitForChild("Tip"),
	Smoke = Handle:WaitForChild("Tip"):WaitForChild("Smoke"),
	MouseInput = (Tool:FindFirstChild("MouseInput") or Create("RemoteFunction"){
		Name = "MouseInput",
		Parent = Tool
	})
}

local Sounds = {
	Fire = Handle:WaitForChild("Fire")
}

local Properties = {
	HedgehogSpeed = 40,
	HedgehogAOE = 30,
	ReloadTime = 5
}

local Player,Character,Humanoid

local hedgehog = Create("Part"){
	Shape = "Block",
	Size = Vector3.new(1,1,1) * 2,
	Name = "Hedgehog",
	Locked = true,
	CanCollide = false,
	Anchored = false,
	
}

local hedgehogMesh = Create("SpecialMesh"){
	Parent = hedgehog,
	MeshId = "http://www.roblox.com/asset/?id=75931575",
	--TextureId = "http://www.roblox.com/asset/?id=60262165",
	Scale = Vector3.new(1,1,1) * 3.5
}

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = Services.Players:GetPlayerFromCharacter(Character)
end


function Activated()
	if not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 then return end
	Tool.Enabled = false
	local sucess,MousePosition = pcall(function() return Components.MouseInput:InvokeClient(Player) end)
	MousePosition = (sucess and MousePosition) or Vector3.new(0,0,0)
	local RNG = Random.new(tick())
	if RNG:NextInteger(1,5) == 5 then
		--You're too slow!
		local Hedgie = hedgehog:Clone()
		Hedgie.Name = "BlueBlur"
		if Hedgie:FindFirstChildOfClass("SpecialMesh") then
			Hedgie:FindFirstChildOfClass("SpecialMesh").TextureId = "rbxassetid://3149144093"
		end
		local HedgieScript = script:WaitForChild("BlueHedgehogScript"):Clone()
		HedgieScript.Parent = Hedgie
		
		Create("BodyVelocity"){
			Name = "HedgieVelocity",
			MaxForce = Vector3.new(1,1,1)*math.huge,
			Velocity = (MousePosition-Components.Tip.WorldPosition).Unit*(Properties.HedgehogSpeed*3),--Make em SUPER FAST!
			Parent = Hedgie
		}
		Create("ObjectValue"){
			Value = Player,
			Name = "Creator",
			Parent = HedgieScript
		}
		Hedgie.CFrame = CFrame.new(Components.Tip.WorldPosition) * CFrame.Angles(math.rad(RNG:NextNumber(0,360)),math.rad(RNG:NextNumber(0,360)),math.rad(RNG:NextNumber(0,360)))
		Hedgie.RotVelocity = Vector3.new(RNG:NextNumber(0,10),RNG:NextNumber(0,10),RNG:NextNumber(0,10))
		Hedgie.Parent = workspace
		Hedgie:SetNetworkOwner(nil)
		HedgieScript.Disabled = false
	else
		--Launch regular hedgehog
		
		local Hedgie = hedgehog:Clone()
		if Hedgie:FindFirstChildOfClass("SpecialMesh") then
			Hedgie:FindFirstChildOfClass("SpecialMesh").TextureId = "rbxassetid://75931783"
		end
		local HedgieScript = script:WaitForChild("HedgehogScript"):Clone()
		HedgieScript.Parent = Hedgie
		
		Create("BodyVelocity"){
			Name = "HedgieVelocity",
			MaxForce = Vector3.new(1,1,1)*math.huge,
			Velocity = (MousePosition-Components.Tip.WorldPosition).Unit*(Properties.HedgehogSpeed),
			Parent = Hedgie
		}
		Create("ObjectValue"){
			Value = Player,
			Name = "Creator",
			Parent = HedgieScript
		}
		Hedgie.CFrame = CFrame.new(Components.Tip.WorldPosition) * CFrame.Angles(math.rad(RNG:NextNumber(0,360)),math.rad(RNG:NextNumber(0,360)),math.rad(RNG:NextNumber(0,360)))
		Hedgie.RotVelocity = Vector3.new(RNG:NextNumber(0,10),RNG:NextNumber(0,10),RNG:NextNumber(0,10))
		Hedgie.Parent = workspace
		Hedgie:SetNetworkOwner(nil)
		HedgieScript.Disabled = false
	end
	Components.Smoke:Emit(Components.Smoke.Rate)
	Sounds.Fire:Play()
	wait(Properties.ReloadTime)
	Tool.Enabled = true
end

Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)

