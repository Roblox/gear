--Scripted by TakeoHonorable

--Forecast is nothing but SHEER COLD!

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



local Seed = Random.new()

local Handle = Tool:WaitForChild("Handle")

local FrostSparkles = Handle:WaitForChild("FrostSparkles")
FrostSparkles.Enabled = true

local Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	Swing = Handle:WaitForChild("Swing"),
	IceCrack = Handle:WaitForChild("IceCrack"),
	--Shatter = Handle:WaitForChild("Shatter")
}

local Remote = (Tool:FindFirstChildOfClass("RemoteEvent") or Create("RemoteEvent"){
	Name = "Remote",
	Parent = Tool
})

local Animations = {}

local Events = {}

local Player,Character,Center


local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}


function PlantIceStalagmite(Position)
	local StalagmiteScript = script:WaitForChild("StalagmiteScript"):Clone()
	StalagmiteScript.Parent = Services.ServerScriptService
	
	Create("Vector3Value"){
		Name = "Pos",
		Value = Position,
		Parent = StalagmiteScript
	}
	
	Create("ObjectValue"){
		Name = "Creator",
		Value = Character,
		Parent = StalagmiteScript
	}
	
	StalagmiteScript.Disabled = false -- Go get em' tiger!
end


function GetHumanoidsInRange(CenterPos,Range)--Returns all non-teammate humanoids that are alive
	
	local CapHum = {}
	
	local world = workspace
	
	local Vec3 = Vector3.new
	
	local Region = Region3.new
	
	local FindPartsInRegion = world.FindPartsInRegion3WithIgnoreList --Micro-optimization techniques C:
	
	local Neg,Pos = CenterPos - Vec3(1,1,1) * (Range*.5), CenterPos + Vec3(1,1,1) * (Range*.5)
	
	local Parts = FindPartsInRegion(world,Region(Neg,Pos),{Character},math.huge) --Always specify the original object to call the function
	
	for i=1,#Parts do
		
		if Parts[i] and (Parts[i].Position-CenterPos).Magnitude <= Range then --It's within range
			
			local Hum,FF = Parts[i].Parent:FindFirstChildOfClass("Humanoid"),Parts[i].Parent:FindFirstChildOfClass("ForceField")
			
			if Hum  and not FF and Hum.Parent and Hum.Health ~= 0 and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not IsInTable(CapHum,Hum) then
				
				CapHum[#CapHum+1] = Hum
				
			end
			
			
		end
		
	end
	
	return CapHum
end

local Abilities = {
	[Enum.KeyCode.Q] = {
		Ready = true,
		Reload = 35,
		Function = function()
			--warn("Activated Ice Stalagmites")
			FrostSparkles.Enabled = false
			Animations.Summon:Play(nil,nil,2.5)
			Sounds.IceCrack:Play()
			
			wait(1.5)
			
			local TargetHums = GetHumanoidsInRange(Center.Position,180)
			local world = workspace
			local Vec3 = Vector3.new
			local FindPartOnRay = world.FindPartOnRayWithIgnoreList
			local ray = Ray.new
			
			local MaxHeightFromGround = 100
	
			for i=1,#TargetHums do
				if TargetHums[i] and TargetHums[i].Parent then
					local Torso = TargetHums[i].Parent:FindFirstChild("Torso") or TargetHums[i].Parent:FindFirstChild("UpperTorso")
					
					if Torso then
						--Secondary check to see if the target is at enough height from the ground
						
						local hit,pos,nor = FindPartOnRay(world,ray(Torso.Position,(Torso.Position + Vec3(0,-MaxHeightFromGround,0))-Torso.Position ),{Character,TargetHums[i].Parent})
						
						if hit and hit.CanCollide and (pos-Torso.Position).Magnitude <= MaxHeightFromGround then
							
							--TargetHums[i]:TakeDamage(TargetHums[i].MaxHealth*.5) --shred away half of their total health
							
							PlantIceStalagmite(pos)
							--warn(TargetHums[i])
							
						end
						
						
					end
				
				end
			end
			--Sounds.Shatter:Play()
			
		end
	},
--[[	[Enum.KeyCode.E] = {
		Ready = true,
		Reload = 15,
		Function = function()

		end
	}]]
}

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
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

function Activated()
	if not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 then return end
	Tool.Enabled = false
	Sounds.Swing:Play()
	local Anim = {Animations.OverHeadSwing,Animations.LeftSlash}
	Anim = Anim[Seed:NextInteger(1,#Anim)]:Play()
	wait(.75)
	Tool.Enabled = true
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

function Touched(hit,damage)
	if not hit or not hit.Parent then return end
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	if Hum and Hum ~= Humanoid and Hum.Health > 0 and not FF and not IsTeamMate(Player, Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		if (Hum.Health/Hum.MaxHealth)*100 <= 25 then
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
					Value = Player,
					Parent = Finisher
				}
				Finisher.Parent = Services.ServerScriptService
				Finisher.Disabled = false
			end
		else
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Player)
			Hum:TakeDamage(damage or 0)
			
		end 
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Center = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
	if not Humanoid or Humanoid.Health <= 0 or not Character or not Center then return end
	
	Animations = Tool:WaitForChild("Animations")
	Animations = {
		OverHeadSwing = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("OverHeadSwing")),
		LeftSlash = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("LeftSlash")),
		--RightSlash = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("RightSlash")),
		Summon = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("Summon")),
	}
	Events[#Events+1] = Tool.Activated:Connect(Activated)
	Events[#Events+1] = Remote.OnServerEvent:Connect(function(client,Key)
		if not Tool.Enabled or client ~= Player or not Key or Humanoid.Health <= 0 then return end
		if not Abilities[Key] or not Abilities[Key].Ready then return end
		Tool.Enabled = false
		Abilities[Key].Ready = false
		delay(Abilities[Key].Reload,function() FrostSparkles.Enabled = true Abilities[Key].Ready = true end)
		Abilities[Key].Function()--Execute the respective ability
		Tool.Enabled = true
	end)
	Events[#Events+1] = Handle.Touched:Connect(function(hit)
		Touched(hit,14)
	end)
	Sounds.Equip:Play()
end

function Unequipped()
	for _,anim in pairs(Animations) do
		if anim then
			anim:Stop()
		end
	end
	for _,sound in pairs(Sounds) do
		if sound then
			sound:Stop()
		end
	end
	for i=1,#Events do
		if Events[i] then
			Events[i]:Disconnect()
		end
	end
	Events = {}
end


Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)