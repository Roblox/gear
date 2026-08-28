--Rescripted by Luckymaxer
--[[
	Fixed by ArceusInator
--]]
local GLib = require(206209239)

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = 22

Tool.Enabled = true

ScytheAOE = Vector3.new(22.5, 22.5, 22.5)

LastKeyDown = 0
DashTime = 0
LastSlash = 0

Equipped = false

Sounds = {
	EvilLaugh = Handle:WaitForChild("EvilLaugh"),
	Slash = Handle:WaitForChild("Slash")
}

Animations = {
	Slash = Tool:WaitForChild("Slash"),
	Equip = Tool:WaitForChild("Equip")
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "Click" and Value then
		Activated()
	elseif Mode == "KeyPress" and Value.Key == "w" and Value.Down then
		local NewTick = tick()
		if (NewTick - LastKeyDown < 0.2) then
			DashTime = NewTick
		end 
		LastKeyDown = NewTick
	end
end)

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
	end)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Blow(Hit)
	local ownerPlayer, targetPlayer = GLib.GetPlayerFromPart(script), GLib.GetPlayerFromPart(Hit)
	
	if not GLib.IsTeammate(ownerPlayer, targetPlayer) then
		if not Hit or not Hit.Parent or not Equipped or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 then
			return
		end
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		if not humanoid or humanoid == Humanoid then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip and (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
			return
		end
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)					
		humanoid:TakeDamage(Damage)
	end
end

function SlashIt(myHumanoid, Torso)	
	local OriginalDamage = Damage
	
	Damage = 17

	InvokeClient("PlaySound", Sounds.EvilLaugh)
	
	Humanoid.WalkSpeed = 0

	local BVs = {}
	
	local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new((Torso.Position - ScytheAOE), (Torso.Position + ScytheAOE)), {Character}, 100)
	for i, v in pairs(Parts) do
		if v and v.Parent then
			local character = v.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso")
			if character ~= Character and humanoid and humanoid.Health > 0 and torso then
				if not torso:FindFirstChild("ScytheBV") then
					local BV = Instance.new("BodyVelocity")
					BV.Name = "ScytheBV"
					BV.P = 100000
					BV.maxForce = Vector3.new(BV.P, BV.P, BV.P)
					local Distance = (torso.Position - Torso.Position).magnitude
					BV.velocity = (Torso.Position - torso.Position).unit * 50 / Distance
					table.insert(BVs, BV)
					Debris:AddItem(BV, 5)
					BV.Parent = torso
				end
			end
		end
	end

	local BG = Instance.new("BodyGyro")
	BG.P = 100000
	BG.maxTorque = Vector3.new(BG.P, BG.P, BG.P)
	BG.Name = "BG"
	
	local TorsoCFrame = {
		Torso.CFrame * CFrame.Angles(0, (1 * (math.pi / 3)), 0),
		Torso.CFrame * CFrame.Angles(0, (2 * (math.pi / 3)), 0),
		Torso.CFrame * CFrame.Angles(0, math.pi, 0),
		Torso.CFrame * CFrame.Angles(0, (4 * (math.pi / 3)), 0),
		Torso.CFrame * CFrame.Angles(0, (5 * (math.pi / 3)), 0),
		Torso.CFrame
	}

	BG.Parent = Torso
	
	for i = 1, 84 do 
		local c = ((i % 6) + 1)
		if BG then
			BG.cframe = TorsoCFrame[c]
		end
		wait(0.025)
	end	

	for i, v in pairs(BVs) do
		if v and v.Parent then
			v:Destroy()
		end
	end

	if BG and BG.Parent then
		BG:Destroy()
	end
	
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end

	wait(5.0)
	
	Damage = OriginalDamage
	
end

function SetTransparency(Parent, Transparency)
	local function SetTransparent(Parent, Transparency)
		for i, v in pairs(Parent:GetChildren()) do
			pcall(function()
				if v.Name ~= "HumanoidRootPart" then
					v.Transparency = Transparency
				end
			end)
			SetTransparency(v)
		end
	end
	SetTransparent(Parent, Transparency)
end

function Activated()
	if not Tool.Enabled or not Humanoid.Parent or Humanoid.Health == 0 or not Torso.Parent then
		return
	end
	
	Tool.Enabled = false
	
	if (tick() - DashTime) < 0.2 then
		SlashIt(Humanoid, Torso)			
	else
		InvokeClient("PlayAnimation", Animations.Slash)
		InvokeClient("PlaySound", Sounds.Slash)
	end

	wait(1)

	Tool.Enabled = true 

end

function Equipped()
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	SetTransparency(Character, 0.5)
	InvokeClient("PlayAnimation", Animations.Equip)
end

function Unequipped()
	
	Equipped = false

	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	
	if Torso and Torso.Parent then
		for i, v in pairs(Torso:GetChildren()) do
			if v:IsA("BodyGyro") and v.Name == "BG" then
				v:Destroy()
			end
		end
	end
	

	SetTransparency(Character, 0)

end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)