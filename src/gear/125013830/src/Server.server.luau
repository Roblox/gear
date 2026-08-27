--Rescripted by TakeoHonorable

local Tool = script.Parent

Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle",10)

local MouseLoc = Tool:WaitForChild("MouseLoc",10)

local MyCharacter,MyHumanoid,MyPlayer

local Services  = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local Sounds = {
	Balefire = Handle:WaitForChild("Balefire",10),
	Recharged = Handle:WaitForChild("Recharged",10)
}

local Objects = {
	FireParticle = Handle:WaitForChild("Fire",10),
	ParticleFolder = Tool:WaitForChild("Particles",10)
}

Objects.FireParticle.Enabled = true

local Properties = {
	CooldownTime = 3,
	ExplosionCount = 20
}

local AntiLagExplosion = Instance.new("Part")
AntiLagExplosion.Anchored = true;
AntiLagExplosion.CanCollide = false;
AntiLagExplosion.Size = Vector3.new(1,1,1)*0
AntiLagExplosion.Transparency = 1;
AntiLagExplosion.Shape = Enum.PartType.Ball

local Attachment = Instance.new("Attachment")
Attachment.Position = Vector3.new(0,0,0)
Attachment.Name = "ExplosionAttachment"
Attachment.Parent = AntiLagExplosion
for _,v in pairs(Objects.ParticleFolder:GetChildren()) do
	if v:IsA("ParticleEmitter") then
		local Particle = v:Clone()
		Particle.Parent = Attachment
		Particle.Size = NumberSequence.new(1,((Particle.Name == "Fire" and 15) or 20))
	end
end

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

function onPlayerBlownUp(part, distance, position, explosionpressure)
	if not part or not part.Parent or part.Parent:IsA("Accoutrement") or part:IsDescendantOf(MyCharacter) then return end
	local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local Character = humanoid.Parent
		if Character and Character ~= MyCharacter and not Character:FindFirstChildOfClass("ForceField") and not IsTeamMate(MyPlayer,Services.Players:GetPlayerFromCharacter(Character)) then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, MyPlayer)
			for _,joints in pairs(part:GetJoints()) do
				joints:Destroy()
			end
			part.Velocity = (part.CFrame.p-position).unit*(explosionpressure/1000)
		end
	else
		--part:BreakJoints()
		for _,joints in pairs(part:GetJoints()) do
			joints:Destroy()
		end
		if not part.Anchored then
			part.Velocity = (part.CFrame.p-position).unit*(explosionpressure/100)
		end
	end
end


function Balefire(pos)
	
	if not MyPlayer or not MyCharacter or not MyHumanoid or MyHumanoid.Health <= 0 then return end

	local dir = (pos - Handle.CFrame.p).Unit
	
	for i = 1, Properties.ExplosionCount do
		local AntiLagPart = AntiLagExplosion:Clone() 
		
		local ex = Instance.new("Explosion")
		ex.BlastRadius = 10
		ex.Visible = false
		ex.DestroyJointRadiusPercent = 0
		ex.BlastPressure = 0
		ex.Position = Handle.CFrame.p + (dir * 6 * i) + (dir * 2)
		AntiLagPart.CFrame = CFrame.new(ex.Position)
		ex.Parent = workspace
		AntiLagPart.Parent = workspace
		coroutine.wrap(function()
			for _,v in pairs(AntiLagPart:WaitForChild("ExplosionAttachment"):GetChildren()) do
				v:Emit(v.Rate)
			end
		end)()
		ex.Hit:Connect(function(part, distance)  onPlayerBlownUp(part, distance, ex.Position, 600000) end)
		Services.Debris:AddItem(AntiLagPart,1)
	end
	Sounds.Balefire:Play()

end

function Equipped()
	MyCharacter = Tool.Parent
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter)
end

function Unequipped()
	Sounds.Recharged:Stop()
end

function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	Objects.FireParticle.Enabled = false
	local sucess,TargetPoint = pcall(function() return MouseLoc:InvokeClient(MyPlayer)end)
	TargetPoint = (sucess and TargetPoint) or Vector3.new(0,0,0)
	
	Balefire(TargetPoint)
	wait(Properties.CooldownTime)
	if Tool:IsDescendantOf(workspace) then
		Sounds.Recharged:Play()
	end
	Objects.FireParticle.Enabled = true
	Tool.Enabled = true
end

Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)
Tool.Unequipped:Connect(Unequipped)