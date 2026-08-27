--Rescripted by TakeoHonorable

local Character = script.Parent

local CreatorTag = script:WaitForChild("creator",10).Value

local AttachmentTag = script:WaitForChild("Attachment",10).Value

local ToolTag = script:WaitForChild("Tool",10).Value

local CreatorHumanoid = CreatorTag.Character:FindFirstChildOfClass("Humanoid")

local CreatorHead = CreatorTag.Character:FindFirstChild("Head")

local SoundFolder = script:WaitForChild("Sounds",10)

local Sounds = {
SoundFolder:WaitForChild("Slap1",10),
SoundFolder:WaitForChild("Slap2",10)
}

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local AnimationFolder = script:WaitForChild("Animations",10)

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local Head = Character:FindFirstChild("Head")



function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end


function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end


if not Humanoid or not CreatorHumanoid or not CreatorHead or not Head then
	script:Destroy()
end
	
local SlapAnimation = Humanoid:LoadAnimation(AnimationFolder:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("SlapSelf",10))

	SlapAnimation:Play()
	
	TaggedHumanoid = Humanoid
	
	local Seed = Random.new(tick())
	local HumHealth = TaggedHumanoid.Health
	local MinDamage,MaxDamage = 4,10
	spawn(function()
		while TaggedHumanoid and (HumHealth-(MaxDamage+5))<=TaggedHumanoid.Health do
			HumHealth = TaggedHumanoid.Health
			UntagHumanoid(Humanoid)
			TagHumanoid(Humanoid,CreatorTag)
			local Distance = (Head.CFrame.p-CreatorHead.CFrame.p).magnitude
			TaggedHumanoid:TakeDamage(math.clamp(math.ceil(MaxDamage-((Distance/50)*2)),MinDamage,MaxDamage))
				spawn(function()
					local SlapSound = Sounds[Seed:NextInteger(1,#Sounds)]:Clone()
					SlapSound.Parent = Head
					SlapSound:Play();Services.Debris:AddItem(SlapSound,SlapSound.TimeLength+.5)
				end)
			wait((Seed:NextNumber(0,1)*.3)+Seed:NextNumber(.1,.4))
		end
		HumHealth = nil
	end)
	
	repeat
		Services.RunService.Heartbeat:Wait()
	until not HumHealth or not CreatorHead or not ToolTag:IsDescendantOf(CreatorTag.Character) or CreatorHumanoid.Health <= 0 or not Head or not Head:IsDescendantOf(workspace) or not Humanoid or not Humanoid:IsDescendantOf(workspace) or Humanoid.Health <= 0

	if SlapAnimation then
		SlapAnimation:Stop()
	end
	
	AttachmentTag.Parent = nil
	TaggedHumanoid = nil
	SlapAnimation = nil
	Services.Debris:AddItem(script,.5)
