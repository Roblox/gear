local Meteor = script.Parent

local Creator = script:WaitForChild("Creator",10).Value

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

Services.Debris:AddItem(Meteor,30) -- Safety net

for _,sounds in pairs(script:GetChildren()) do
	if sounds:IsA("Sound") then
		sounds.Parent = Meteor
	end
end

local Sounds = {
	Fall = Meteor:WaitForChild("Fall",10),
	WahWah = Meteor:WaitForChild("WahWah",10),
	Explosion = Meteor:WaitForChild("Explosion",10)
}

local SmashSmoke = script:WaitForChild("SmashSmoke",10)

local ParticleAttachment = Instance.new("Attachment")
ParticleAttachment.Position = Vector3.new(0,0,0)


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

Sounds.Fall:Play()

local TouchedEvent

TouchedEvent = Meteor.Touched:Connect(function(hit)
	if not hit or not hit.Parent or not hit.CanCollide then return end
	
	local Rays = Ray.new(Meteor.CFrame.p,(Vector3.new(Meteor.CFrame.p.x,hit.CFrame.p.y,Meteor.CFrame.p.z)-Meteor.CFrame.p).unit*999.999)
	local part,pos = workspace:FindPartOnRay(Rays,Meteor)

	Sounds.Fall:Stop()
	Sounds.Explosion:Play()
	if part then
		local EffectPart = Instance.new("Part")
		SmashSmoke.Parent = ParticleAttachment
		ParticleAttachment.Parent = EffectPart
		Services.Debris:AddItem(EffectPart,5)
		EffectPart.Name = "Effect"
		EffectPart.CanCollide = false
		EffectPart.Anchored = true
		EffectPart.Transparency = 1
		EffectPart.Size = Vector3.new(1,1,1)*0
		EffectPart.CFrame = CFrame.new(pos)
		EffectPart.Parent = workspace
		SmashSmoke:Emit(300)
	end
	local Directory = hit.Parent
	if hit.Parent:IsA("Accoutrement") then
		Directory = hit.Parent.Parent
	end
	
	local Humanoid = Directory:FindFirstChildOfClass("Humanoid")
	if Humanoid and not Directory:FindFirstChildOfClass("ForceField") and Humanoid ~= Creator.Character:FindFirstChildOfClass("Humanoid") and not IsTeamMate(Services.Players:GetPlayerFromCharacter(Humanoid.Parent),Creator) then
		UntagHumanoid(Humanoid)
		TagHumanoid(Humanoid,Creator)
		Humanoid:TakeDamage(math.huge)
		if Humanoid.Health <= 0 then
			Sounds.WahWah:Play()
		end
	end
	
	TouchedEvent:Disconnect()
end)
