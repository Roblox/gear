--Skull Cracker
--Rescripted by TakeoHonorable
--50% chance to stun your opponent 

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

local Player,Character,Humanoid

local Handle = Tool:WaitForChild("Handle")

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Sounds = {
	Slap = Handle:WaitForChild("SlapSound")
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


local function Stunned(Character) -- Quick check to see if they're not stunned
	for _,v in pairs(Services.ServerScriptService:GetChildren()) do
		if v:IsA("Script") and v.Name == "Stun" and v:FindFirstChild("Target") and v:FindFirstChild("Target").Value == Character then
			return true
		end
	end
	return false
end

local Seed = Random.new()
function Attack(hit)
	if not hit or not hit.Parent then return end
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or Hum.Health <= 0 or Hum == Humanoid or FF or IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	UntagHumanoid(Hum)
	TagHumanoid(Hum,Player)
	Hum:TakeDamage(5)
	
	if Seed:NextNumber() < 0.5 and not Stunned(Hum.Parent) then
		--print("Stunned")
		Sounds.Slap:Play()
		local StunScript = script:WaitForChild("Stun"):Clone()
		Create("ObjectValue"){
			Name = "Target",
			Value = Hum.Parent,
			Parent = StunScript
		}
		Create("ObjectValue"){
			Name = "Creator",
			Value = Player,
			Parent = StunScript
		}
		StunScript.Parent = Services.ServerScriptService
		StunScript.Disabled = false
	end
	
end


local Events = {}
local Animations = {}
function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 then return end
	
	Animations = Tool:WaitForChild("Animations")
	Animations = Animations:WaitForChild(Humanoid.RigType.Name)
	Animations = {
		Slam = Humanoid:LoadAnimation(Animations:WaitForChild("Slam"))
	}
	
	Events[#Events+1] = Handle.Touched:Connect(Attack)
end

function Unequipped()
	for i=1,#Events do
		if Events[i] then
			Events[i]:Disconnect();Events[i] = nil
		end
	end
	for _,anim in pairs(Animations) do
		if anim then
			anim:Stop();
		end
	end
	Animations = {}
end

function Activated()
	if not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 then return end
	Tool.Enabled = false
	Animations.Slam:Play()
	wait(1)
	Tool.Enabled = true
end


Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)
