--Revamped by TakeoHonorable

--They'll never know when it's coming

local Properties = {
	Range = 800,
	Reload = 20
}

local Self = script

local Tool = Self.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local instance,Type,Pcall,Vec3,Rays,world,FindPartOnRay,cframe,fromRGB,Angles = Instance.new,type,pcall,Vector3.new,Ray.new,workspace,workspace.FindPartOnRayWithIgnoreList,CFrame.new,Color3.fromRGB,CFrame.Angles

local rad,Material,PartType = math.rad,Enum.Material,Enum.PartType

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Components = {
	Tip = Handle:WaitForChild("Tip"),
	Smoke = Handle:WaitForChild("Tip"):WaitForChild("Smoke")
}

function Create(ty)
	return function(data)
		local obj = instance(ty)
		for k, v in pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local function VisualizeRay(ray,RayLength,Color,DisplayTime)
	local RayCast = Create("Part"){
		Material = Material.Neon,
		Color = Color or Color3.new(0,1,0),
		Size = Vec3((RayLength or 5),1,1),
		Shape = PartType.Cylinder,
		CFrame = cframe(ray.Origin, ray.Origin+ray.Direction) * cframe(0, 0, -(RayLength or 5) / 2) * Angles(0,rad(90),0),
		Anchored = true,
		CanCollide = false,
		Parent = world
	}
	Services.Debris:AddItem(RayCast,DisplayTime or 1)
end

local MouseLoc = (Tool:FindFirstChildOfClass("RemoteFunction") or Create("RemoteFunction"){
	Name = "MouseLoc",
	Parent = Tool
})

local Sounds = {
	Fire = Handle:WaitForChild("Fire")
}

local Animations = {}

local Player,Character,Humanoid
local Events = {}
local Debounce = true
function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 or Humanoid.Health == math.huge or Humanoid.MaxHealth == math.huge then return end
	
	Animations = {
		Shoot = Humanoid:LoadAnimation(Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name):WaitForChild("Shoot"))
	}
	
	Events[#Events+1] = Tool.Activated:Connect(function()
		if not Debounce or not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 or Humanoid.Health == math.huge or Humanoid.MaxHealth == math.huge then return end
		
		Debounce = false
		
		local Sucess,Pos = Pcall(function() return MouseLoc:InvokeClient(Player)end)
		Pos = (Sucess and Pos) or Vec3(0,0,0)
		
		local ray = Rays(Components.Tip.WorldPosition , (Pos - Components.Tip.WorldPosition).Unit * Properties.Range)
		
		local hit,pos,nor = FindPartOnRay(world,ray,{Character})
		
		if hit and hit.CanCollide then
			Tool.Enabled = false
			
			Animations.Shoot:Play()
			
			delay(Properties.Reload,function()
				Tool.Enabled = true
			end)
			
			local SharkScript = Self:WaitForChild("SharkScript"):Clone()
			
			Create("ObjectValue"){
				Name = "Creator",
				Value = Player,
				Parent = SharkScript
			}
			
			Create("CFrameValue"){
				Name = "Location",
				Value = cframe(pos , pos+nor),
				Parent = SharkScript
			}
			
			Create("ObjectValue"){
				Name = "PartRef",
				Value = hit,
				Parent = SharkScript
			}
			
			
			SharkScript.Parent = Services.ServerScriptService
			
			SharkScript.Disabled = false
			
			Components.Smoke:Emit(Components.Smoke.Rate)
			VisualizeRay(ray,(pos-Handle.Position).Magnitude,fromRGB(159, 173, 192),.1)
			
			Sounds.Fire:Play()
		end
		
		Debounce = true
	end)
end

function Unequipped()
	
	for i=1,#Events,1 do
		if Events[i] then
			Events[i]:Disconnect()
		end
	end
	Events = {}

end

Tool.Equipped:Connect(Equipped)
--Tool.Unequipped:Connect(Unequipped)
