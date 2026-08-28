local Tool = script.Parent
local Mace = Tool.Handle

Tool.Enabled = true 

local vCharacter

local staticDamage = 12

local damage = 18

local debris = game:GetService("Debris")

local MaceSound,EquipSound

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

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

function blow(hit)
	local humanoid,FF
	if hit.Parent then
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		FF = hit.Parent:FindFirstChild("ForceField")
	end
	vCharacter = Tool.Parent
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")
	local vPlayer = Services.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid and myHumanoid and humanoid ~= myHumanoid and not FF and not IsTeamMate(Services.Players:GetPlayerFromCharacter(humanoid.Parent),vPlayer) then 
		local destroy = math.random(1, 100)
		local rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
		if rightArm then 
			local rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Mace or rightGrip.Part1 == Mace) then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, vPlayer)							
				humanoid:TakeDamage(damage)				
				damage = staticDamage
				if destroy < 12 then 
					if hit.Name == "Torso" or hit.Name == "UpperTorso" or hit.Name == "LowerTorso" or hit.Name == "Head"  then 
						--print(hit.Name)
						humanoid:TakeDamage(500)
					end
					hit:BreakJoints()					
				end		
			end
		end
	end
end
function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false 
	vCharacter = Tool.Parent
	local myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if not myTorso then return end
	
	MaceSound = Mace:FindFirstChild("MaceSound")
	if MaceSound then MaceSound:Play() end
	wait(1.25)
	Tool.Enabled = true
end

function onUnequipped()
	if MaceSound then MaceSound:Stop() end
	if EquipSound then EquipSound:Stop() end
end

function onEquipped()
	EquipSound = Mace:FindFirstChild("EquipSound")
	if EquipSound then EquipSound:Play() end
end

Tool.Equipped:Connect(onEquipped)
Tool.Activated:Connect(onActivated)
Tool.Unequipped:Connect(onUnequipped)

Mace.Touched:Connect(blow)