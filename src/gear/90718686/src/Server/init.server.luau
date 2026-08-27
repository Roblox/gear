--Rescripted by TakeoHonorable

local Tool = script.Parent
Tool.Enabled = true

local MouseLoc = Tool:WaitForChild("MouseLoc",10)

local Handle = Tool:WaitForChild("Handle",10)

local RockFistScript = script:WaitForChild("RockFist",10)

local Sounds = {
	Summon = Handle:WaitForChild("Summon",10),
}

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local Properties = {
	StaffCooldown = 6,
	MeteorLifeTime = 5,
	BaseUrl = "http://www.roblox.com/asset/?id="
}

local Player,Character,Humanoid,Root

local Animations

local RockFist = Instance.new("Part")
RockFist.Anchored = false
RockFist.Size = Vector3.new(18,24,15)
RockFist.TopSurface = Enum.SurfaceType.Smooth
RockFist.BottomSurface = Enum.SurfaceType.Smooth
RockFist.Material = Enum.Material.Concrete


local RockFistMesh = Instance.new("SpecialMesh")
RockFistMesh.MeshId = Properties.BaseUrl.."90718752"
RockFistMesh.TextureId = Properties.BaseUrl.."90718949"
RockFistMesh.Scale = Vector3.new(1,1,1)*60
RockFistMesh.VertexColor = Vector3.new(1,1,1)
RockFistMesh.Parent = RockFist


function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart",10)
	
	if not Humanoid then return end
	
	Player = Services.Players:GetPlayerFromCharacter(Character)
	
	Animations = {
		StaffIdle = Tool:WaitForChild(Humanoid.RigType.Name):WaitForChild("StaffIdle"),
		StaffSlam = Tool:WaitForChild(Humanoid.RigType.Name):WaitForChild("StaffSlam")
	}
	
	for name,anim in pairs(Animations) do
		Animations[name] = Humanoid:LoadAnimation(anim)
	end
	Animations.StaffIdle:Play()
end

function Activated()
	if not Player or not Root or not Tool.Enabled then return end
	Tool.Enabled = false
	local sucess,MousePos = pcall(function() return MouseLoc:InvokeClient(Player) end)
	MousePos = (sucess and MousePos) or Vector3.new(0,0,0)
	
	Sounds.Summon:Play()
	
	if Animations and Animations.StaffSlam then
		Animations.StaffSlam:Play()
	end
	
	wait(1)
	local RockFistClone = RockFist:Clone()
	RockFistClone.Locked = true
	RockFistClone.Name = "RockFist"
	Services.Debris:AddItem(RockFistClone,Properties.MeteorLifeTime)
	local aX,aY,aZ = Root.CFrame:toEulerAnglesXYZ()
	RockFistClone.CFrame = CFrame.Angles(aX,aY,aZ) + (MousePos + Vector3.new(0,150,0))
	
	local RockFistGyro = Instance.new("BodyGyro")
	RockFistGyro.MaxTorque = Vector3.new(1,1,1)*math.huge
	RockFistGyro.CFrame = CFrame.Angles(aX,aY,aZ)
	RockFistGyro.Parent = RockFistClone
	
	--[[local RockFistVelo = Instance.new("BodyVelocity")
	RockFistVelo.MaxForce = Vector3.new(1,1,1)*math.huge
	RockFistVelo.Velocity = (MousePos-RockFistClone.CFrame.p).unit*150
	RockFistVelo.Parent = RockFistClone]]
	
	spawn(function()
		local ScriptClone = RockFistScript:Clone()
		ScriptClone.Parent = RockFistClone
		local CreatorTag = Instance.new("ObjectValue")
		CreatorTag.Value = Player
		CreatorTag.Name = "Creator"
		CreatorTag.Parent = ScriptClone
		ScriptClone.Disabled = false
	end)
	
	
	RockFistClone.Parent = workspace
	RockFistClone:SetNetworkOwner(nil)
	
	wait(Properties.StaffCooldown)
	Tool.Enabled = true
end

function Unequipped()
	for names,anim in pairs(Animations) do
		anim:Stop()
		Animations[names] = nil
	end
end


Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)
Tool.Unequipped:Connect(Unequipped)
