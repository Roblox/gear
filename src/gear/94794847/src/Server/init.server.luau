--Revamped by TakeoHonorable
--Now has the ability to actually vanquish all things vampire
-- + 33% dasmage resistance

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

local Effect = Handle:WaitForChild("Effects"):WaitForChild("Flare")
Effect.Enabled = true

local Remote = (Tool:FindFirstChildOfClass("RemoteEvent") or Create("RemoteEvent"){
	Name = "Remote",
	Parent = Tool
})

local Animations = {}

local Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Sprint = Handle:WaitForChild("Sprint"),
	SwordHit = Handle:WaitForChild("SwordHit"),
	Equip = Handle:WaitForChild("Equip"),
	CoffinStrike = Handle:WaitForChild("CoffinStrike")
}

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Player,Character,Humanoid

local Special = true

local Events = {}

local Deletables = {}

local lastArmWeldRemovedConnection = nil

local function CreateArmWeld(Shield)
	--if ArmShieldWeld then return end
	if Character and (Character:FindFirstChild('Left Arm') or Character:FindFirstChild('LeftUpperArm')) then
		if lastArmWeldRemovedConnection then
			lastArmWeldRemovedConnection:Disconnect()
			lastArmWeldRemovedConnection = nil
		end
		
		Events[#Events+1] = (Character:FindFirstChild('Left Arm') or Character:FindFirstChild('LeftUpperArm')).ChildRemoved:Connect(function(child) if Humanoid and Humanoid.Health ~= 0 and Tool.Parent == Character and child.Name == 'ArmWeld' then CreateArmWeld(Shield) end end)
		
		lastArmWeldRemovedConnection = Events[#Events]
		
		Deletables[#Deletables+1] = Create('Weld'){
			Name = "ArmWeld",
			Part0 = (Character:FindFirstChild('Left Arm') or Character:FindFirstChild('LeftUpperArm')),
			Part1 = Shield,
			C0 = CFrame.new() * CFrame.Angles(math.rad(-90), math.rad(90), 0),
			C1 = CFrame.new() + Vector3.new(0, 0, 0.6),
			Parent = (Character:FindFirstChild('Left Arm') or Character:FindFirstChild('LeftUpperArm'))
		}
		
		Shield.Parent = Tool
	else
		--print('CreateArmWeld: you have no character or no left arm.')
	end
end

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

local function HasFinisher(Hum) -- Quick check to see if they're not stunned
	local Children = Services.ServerScriptService:GetChildren()
	for i=1, #Children do
		if Children[i]:IsA("Script") and Children[i].Name == "Finisher" and Children[i]:FindFirstChild("Target") and Children[i]:FindFirstChild("Target").Value == Hum.Parent then
			return true
		end
	end
	return false
end

function Touched(hit)
	if not hit or not hit.Parent then return end
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	if Hum and Hum ~= Humanoid and Hum.Health > 0 and not FF and not IsTeamMate(Player, Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		if (Hum.Health/Hum.MaxHealth)*100 <= 30 then
			if not HasFinisher(Hum)  then
				--Cue the finisher instead
				local Finisher = script:WaitForChild("Finisher"):Clone()
				Create("ObjectValue"){
					Name = "Target",
					Value = Hum.Parent,
					Parent = Finisher
				}
				Create("ObjectValue"){
					Name = "Creator",
					Value = Character,
					Parent = Finisher
				}
				Finisher.Parent = Services.ServerScriptService
				Finisher.Disabled = false
			end
		else
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Player)
			Hum:TakeDamage(20)
			
		end 
	end
end


function Vanquish()
	Animations.ExecuteAnim:Play()
	delay(.5, function()
		local VanquishScript = script:WaitForChild("Vanquish"):Clone()
		VanquishScript.Parent = Services.ServerScriptService
		
		Create("Vector3Value"){
			Name = "Position",
			Value = (Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")).Position,
			Parent = VanquishScript
		}
		Create("ObjectValue"){
			Name = "Creator",
			Value = Player,
			Parent = VanquishScript
		}
		
		VanquishScript.Disabled = false
		Sounds.CoffinStrike:Play()
	end)
end

function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	Sounds.Slash:Play()
	Animations.SwingAnim:Play(nil,nil,2)
	wait(.5)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 or not Character then return end
	
	Animations = Tool:WaitForChild("Animations")
	Animations = {
		EquipAnim = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("EquipAnim")),
		ExecuteAnim = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("ExecuteAnim")),
		IdleAnim = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("IdleAnim")),
		SwingAnim = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("SwingAnim"))
	}
	
	local Shield = Create("Part"){
		Size = Vector3.new(2.4, 5.2, 0.8)*(Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")).Size.Z,
		Massless = true,
		Locked = true,
		Parent = Tool
	}
	Create('SpecialMesh'){
		MeshId = 'http://www.roblox.com/asset/?id=94752182',
		TextureId = 'http://www.roblox.com/asset/?id=94752144',
		Scale = Vector3.new(2.3,2.3,2.3),
		Parent = Shield,
	}
	CreateArmWeld(Shield)
	Deletables[#Deletables+1] = Shield
	
	local IgnoreHealthChange = false
	local CurrentHealth = Humanoid.Health
	Events[#Events+1] = Humanoid.Changed:Connect(function(Property)
		local NewHealth = Humanoid.Health
		if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth and NewHealth > 0 then
			if NewHealth < CurrentHealth then
				local DamageDealt = (CurrentHealth - NewHealth)
				IgnoreHealthChange = true
				Humanoid.Health = Humanoid.Health + (DamageDealt * .67)
				IgnoreHealthChange = false
			end
		end
		CurrentHealth = NewHealth
	end) 

	Events[#Events+1] = Tool.Activated:Connect(Activated)
	Events[#Events+1] = Handle.Touched:Connect(Touched)
	Sounds.Equip:Play()
	Animations.EquipAnim:Play()
	Animations.IdleAnim:Play()
	
	Events[#Events+1] = Remote.OnServerEvent:Connect(function(client,Key)
		if not Tool.Enabled or client ~= Player or not Key or Humanoid.Health <= 0 or not Special then return end
		Tool.Enabled = false
		Special = false
		Effect.Enabled = false
		
		delay(2,function()
			Tool.Enabled = true
		end)
		
		Vanquish()
		
		delay(30,function()
			Effect.Enabled = true
			Special = true
		end)
	end)
end

function Unequipped()
	
	for _,anim in pairs(Animations) do
		if anim then
			anim:Stop()
		end
	end
	Animations = {}
	
	for i=1,#Events do
		if Events[i] then Events[i]:Disconnect();Events[i] = nil end
	end
	Events = {}
	
	for i=1,#Deletables do
		if Deletables[i] then Deletables[i]:Destroy() end
	end
	Deletables = {}
end


Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)