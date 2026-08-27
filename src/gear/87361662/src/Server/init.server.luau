--Rescripted by TakeoHonorable

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

local Remote = Tool:WaitForChild("Remote")

local Damage,SlashDamage,Swingdamage,BaseDamage = 2,9,14,2

local FreezeRange = 15

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Animations = {}

local Sounds = {
	Equip = Handle:WaitForChild("Unsheath"),
	Freeze = Handle:WaitForChild("FreezeSound"),
	Slash = Handle:WaitForChild("Slash")
}

local Player,Character,Humanoid,LeftHand

local Touch 

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

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end


local function Frozen(Character) -- Quick check to see if they're not frozen
	for _,v in pairs(Services.ServerScriptService:GetChildren()) do
		if v:IsA("Script") and v.Name == "Freeze" and v:FindFirstChild("Target") and v:FindFirstChild("Target").Value == Character then
			return true
		end
	end
	return false
end

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	LeftHand = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand")
	Animations = Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name)
	Animations = {
		LeftSlash = Humanoid:LoadAnimation(Animations:WaitForChild("LeftSlash")),
		OverHeadSwing = Humanoid:LoadAnimation(Animations:WaitForChild("OverHeadSwing")),
		RightSlash = Humanoid:LoadAnimation(Animations:WaitForChild("RightSlash")),
		Freeze = Humanoid:LoadAnimation(Animations:WaitForChild("TonightsForcast"))
	}
	Sounds.Equip:Play()
	Touch = Handle.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
		if not Hum or Hum == Humanoid or FF or IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		if Frozen(Hum.Parent) then
			Hum.Parent:BreakJoints()
		else
			Hum:TakeDamage(Damage)
		end
	end)
end

function Unequipped()
	if Touch then
		Touch:Disconnect();Touch = nil
	end
end

function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	local AttackAnims = {Animations.LeftSlash,Animations.RightSlash,Animations.OverHeadSwing}
	AttackAnims = AttackAnims[Random.new():NextInteger(1,#AttackAnims)]
	AttackAnims:Play(nil,nil,1)
	Damage = (AttackAnims.Animation.Name == "OverHeadSwing" and Swingdamage) or SlashDamage
	Sounds.Slash:Play()
	wait(1.1)
	Damage = BaseDamage
	Tool.Enabled = true
end


								
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)

Remote.OnServerEvent:Connect(function(Client,Key)
	if Client ~= Player or not Key or not Tool.Enabled then return end
	if Key == Enum.KeyCode.Q then
		Tool.Enabled = false
		Animations.Freeze:Play()
		Sounds.Freeze:Play()
		Humanoid.WalkSpeed = 4
		wait(1)
		local Freeze = true
		local Puff
		if LeftHand then
			Puff = script:WaitForChild("Puff"):Clone()
			Puff.Parent = LeftHand
			Puff.Enabled = true
		end
		coroutine.wrap(function() -- Freezing action
			repeat
				if LeftHand then
					--[[local HitBox = Create("Part"){
						CanCollide = false,
						Transparency = 0.5,
						Position = (LeftHand.CFrame.p + LeftHand.CFrame.upVector*-((LeftHand.Size.Y/2)+FreezeRange/2)),
						Size = Vector3.new(1,1,1)*FreezeRange,
						Anchored = true,
						Color = Color3.fromRGB(255,0,0),
						Shape = Enum.PartType.Ball,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
						Parent = workspace
					}
					Services.Debris:AddItem(HitBox,.5)]]
					local pos = LeftHand.CFrame.p - LeftHand.CFrame.upVector*((LeftHand.Size.Y/2)+(FreezeRange/2))
					local Neg,Pos = pos - Vector3.new(1,1,1)*(FreezeRange/2),pos + Vector3.new(1,1,1)*(FreezeRange/2)
					local Region = Region3.new(Neg,Pos)
					local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Character},math.huge)
					local CapHumanoids = {}
					for _,part in pairs(Parts) do
						if part and part.Parent and (part.CFrame.p - pos).Magnitude <= FreezeRange then
							local Hum,FF = part.Parent:FindFirstChildOfClass("Humanoid"),part.Parent:FindFirstChildOfClass("ForceField")
							if Hum and not FF and not IsInTable(CapHumanoids,Hum) then							
								if not Frozen(Hum.Parent) then
									CapHumanoids[#CapHumanoids+1] = Hum
									local FreezeScript = script:WaitForChild("Freeze"):Clone()
									FreezeScript:WaitForChild("Creator").Value = Player
									FreezeScript:WaitForChild("Target").Value = Hum.Parent
									FreezeScript.Parent = Services.ServerScriptService
									FreezeScript.Disabled = false
								end
							end 
						end
					end
					wait(1/5)
				end
			until not Freeze
			Puff:Destroy()
		end)()
		wait(4)
		Freeze = false
		Humanoid.WalkSpeed = 16
		Sounds.Freeze:Stop()
		Animations.Freeze:Stop()
		Tool.Enabled = true
	end
end)