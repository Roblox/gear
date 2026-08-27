--Rescripted by TakeoHonorable
--The glory days of head-shotting people

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

local Tool = script.Parent

Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local MousePos = (Tool:FindFirstChild("MousePos") or Create("RemoteFunction"){
	Name = "MousePos",
	Parent = Tool
});

local Sounds = {
	Fire = Handle:WaitForChild("GunSound"),
}

local Components = {
	Tip = Handle:WaitForChild("Tip"),
	PhaserSpray = Handle:WaitForChild("Tip"):WaitForChild("PhaserSpray"),
	PhaserTravel = script:WaitForChild("PhaserTravel")
}

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Player,Character,Humanoid,Root


function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end


function GunUp()
	Tool.GripForward = Vector3.new(0, 1, 0);
	Tool.GripPos = Vector3.new(0, -0.5, -0.5);
	Tool.GripRight = Vector3.new(1, 0, 0);
	Tool.GripUp = Vector3.new(0, 0, 1);
end

local ray = Create("Part"){
	Shape = Enum.PartType.Ball,
	Size = Vector3.new(1,1,1)*.5,
	CanCollide = false,
	Name = "PhaserProjectile",
	Transparency = 0
} 
Create("SpecialMesh"){
	MeshId = "http://www.roblox.com/asset/?id=57810032",
	TextureId = "http://www.roblox.com/asset/?id=57809568",
	Parent = ray,
	Scale = Vector3.new(0.05, 0.05, 0.05),
}

function Activated()
	if not Humanoid or Humanoid.Health <= 0 or not Player or not Tool.Enabled then return end
	Tool.Enabled = false
	
	local sucess,MousePosition = pcall(function() return MousePos:InvokeClient(Player) end)
	MousePosition = (sucess and MousePosition) or Vector3.new(0,0,0)
	
	Sounds.Fire:Play()
	

	Components.PhaserSpray:Emit(Components.PhaserSpray.Rate)
	
	local dir = (MousePosition - Components.Tip.WorldPosition).Unit
	
	local proj = ray:Clone()
	
	proj.CFrame = CFrame.new(Components.Tip.WorldPosition,MousePosition)
	
	Create("BodyVelocity"){
		Velocity = dir * 450,
		Parent = proj
	}
	
	local travelparticle = Components.PhaserTravel:Clone()
	travelparticle.Parent = proj
	travelparticle.Enabled = true
	
	proj.Parent = workspace
	proj:SetNetworkOwner(nil)
	
	Services.Debris:AddItem(proj,4)
	
	local shotRay = Ray.new(Components.Tip.WorldPosition,dir*800)
	
	local hit,pos = workspace:FindPartOnRayWithIgnoreList(shotRay,{Character},false,true)
	
	Tool.Grip = Tool.Grip * CFrame.Angles(math.rad(-30),0,0)
	
	if hit and hit.Parent then
		local damage = 30
		if hit.Parent:IsA("Accoutrement") then
			hit = hit.Parent
			damage = 100
		end
		if hit.Name == "Head" then
			damage = 100
		end
		local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
			if Hum and not FF and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
				UntagHumanoid(Hum)
				TagHumanoid(Hum,Player)
				Hum:TakeDamage(damage)
				if Hum.Health > 0 and not Hum.Parent:FindFirstChild("PhaserKnockback") then
					local Clone = script:WaitForChild("PhaserKnockback"):Clone()
					Clone.Parent = Hum.Parent
					Create("ObjectValue"){
						Name = "GunChar",
						Value = Character,
						Parent = Clone
					}
					Create("Vector3Value"){
						Name = "Pos",
						Value = Root.CFrame.p,
						Parent = Clone
					}
					Clone.Disabled = false
				end
			end
	end
	
	delay(.2,function()
		GunUp()
	end)
	wait(.75)
	
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:FindFirstChild("HumanoidRootPart")
end

function Unequipped()
	for _,sound in pairs(Sounds) do
		if sound then
			sound:Stop()
		end
	end
end

Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)