local Pillar = script.Parent

local Creator = script:WaitForChild("Creator",5).Value


local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService"))
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
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

local LaserSound = script:WaitForChild("Laser",5)
LaserSound.Parent = Pillar


wait(.5)

local PillarTween = Services.TweenService:Create(Pillar,TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Transparency = 1,Size = Vector3.new(Pillar.Size.X,30,30),Color = Color3.fromRGB(255, 0, 255)})
local SoundTween = Services.TweenService:Create(LaserSound,TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Volume = 0})
for _,light in pairs(Pillar:GetChildren()) do
	if light:IsA("Light") then
		local LightTween = Services.TweenService:Create(light,TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Color = Color3.fromRGB(255, 0, 255)})
		LightTween:Play()
	end
end

LaserSound:Play()
PillarTween:Play()
SoundTween:Play()


local TaggedHumanoids = {}
Pillar.Touched:Connect(function(hit)
	if not hit or not hit.Parent then return end
	local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end
	if Creator == Services.Players:GetPlayerFromCharacter(Humanoid.Parent) or IsTeamMate(Creator,Services.Players:GetPlayerFromCharacter(Humanoid.Parent)) or IsInTable(TaggedHumanoids,Humanoid) then return end
	TaggedHumanoids[#TaggedHumanoids+1]=Humanoid
	UntagHumanoid(Humanoid)
	TagHumanoid(Humanoid,Creator)
	Humanoid:TakeDamage(40)
end)

SoundTween.Completed:Wait()
Pillar:Destroy()