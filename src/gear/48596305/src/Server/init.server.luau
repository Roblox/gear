local Self = script

local Tool = Self.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Character,Humanoid,Player

local Instant,Pairs,Type,Tick,wrap,Delay,Wait,Pcall = Instance.new,pairs,type,tick,coroutine.wrap,delay,wait,pcall

local Cframe,rad,Angles,Vec3,huge = CFrame.new,math.rad,CFrame.Angles,Vector3.new,math.huge

function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in Pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local MouseInput = (Tool:FindFirstChild("MousePos") or Create("RemoteFunction"){
	Name = "MousePos",
	Parent = Tool
})

local Sounds = {
	Fire = Handle:WaitForChild("Fire")
}

local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Players = (game:FindService("Players") or game:GetService("Players"))
}

local Events = {}



part = Create("Part"){
	Size = Vec3(0.8, 0.8, 0.8),
	Transparency = 0.6,
	Anchored = false,
	CanCollide = false,
	Locked = true,
	Shape = Enum.PartType.Ball,
}

local fieldMesh = Create("SpecialMesh"){
	MeshType = "FileMesh",
	Name = "Mesh",
	MeshId = "http://www.roblox.com/asset/?id=48423624",
	TextureId = "http://www.roblox.com/asset/?id=48578045",
	Scale = Vector3.new(0.02, 0.02, 0.02),
	Parent = part,
}

local Spirals = Self:WaitForChild("Spirals"):Clone()
Spirals.Parent = part
Spirals.Enabled = false

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = Services.Players:GetPlayerFromCharacter(Character)
	
	if not Humanoid or Humanoid.Health <= 0 or Humanoid.Health == huge or not Tool.Enabled then return end
	
	Events[#Events+1] = Tool.Activated:Connect(function()
		
		if not Humanoid or Humanoid.Health <= 0 or Humanoid.Health == huge or not Tool.Enabled then return end
		
		Tool.Enabled = false
		Delay(1.5,function()
			Tool.Enabled = true
		end)
		local sucess,MousePosition = Pcall(function() return MouseInput:InvokeClient(Player) end)
		MousePosition = (sucess and MousePosition) or Vec3(0,0,0)
		
		local proj = part:Clone()
		
		Services.Debris:AddItem(proj,5)
		
		local lookAt = (MousePosition - Handle.Position).Unit	
		
		local spawnPos = Handle.Position
		spawnPos = spawnPos + lookAt * 5.0
		
		proj.CFrame = Cframe(spawnPos, spawnPos + lookAt) 
		
		Create("BodyVelocity"){
			MaxForce = Vec3(huge,huge,huge),
			Velocity = lookAt * 60,
			Parent = proj
		}
		
		local ConfuseScript = Self:WaitForChild("ConfuseScript"):Clone()
		
		
		Create("ObjectValue"){
			Value = Player,
			Name = "Creator",
			Parent = ConfuseScript
		}
		ConfuseScript.Parent = proj
		ConfuseScript.Disabled = false
		
		proj.Parent = workspace
		Sounds.Fire:Play()
		
		local Particle = proj:FindFirstChildOfClass("ParticleEmitter")
		if Particle then
			Particle.Enabled = true
		end
		
		if proj:CanSetNetworkOwnership() then
			proj:SetNetworkOwner(nil)
		end
		
	end)
	
end

function Unequipped()
	
	for i=1,#Events,1 do
		if Events[i] then
			Events[i]:Disconnect()
		end
	end
	Events = {}
	
	for i,v in Pairs(Sounds) do
		if v and v:IsA("Sound") then
			v:Stop()
		end
	end
	
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
