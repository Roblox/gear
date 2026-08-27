--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")

ThumbnailDisplayBoundaries = Tool:FindFirstChild("ThumbnailDisplayBoundaries")
if ThumbnailDisplayBoundaries then
	ThumbnailDisplayBoundaries:Destroy()
end

Remover = script:WaitForChild("Remover")

NPCModel = InsertService:LoadAsset(205935215)
NPC = NPCModel:GetChildren()[1]:Clone()
if NPCModel and NPCModel.Parent then
	NPCModel:Destroy()
end
FakeHead = NPC:WaitForChild("FakeHead")
Logo = FakeHead:WaitForChild("Logo")
LogoImage = Logo:WaitForChild("ImageLabel")
LogoImage.Image = "http://www.roblox.com/asset/?id=207251266"


ReloadTime = 5

ToolEquipped = false

Tool.Enabled = true

function MakeNPC()
	if PlayerNPC and PlayerNPC.Parent then
		PlayerNPC:Destroy()
	end
	PlayerNPC = NPC:Clone()
	NPCHumanoid = PlayerNPC:FindFirstChild("Humanoid")
	NPCTorso = PlayerNPC:FindFirstChild("Torso")
	if not NPCHumanoid or not NPCTorso then
		return
	end
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, 0, math.huge)
	BodyGyro.Parent = NPCTorso
	local CreatorValue = Instance.new("ObjectValue")
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = PlayerNPC
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = PlayerNPC
	local RemoverClone = Remover:Clone()
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerNPC
	PlayerNPC.Parent = game:GetService("Workspace")
	local TorsoCFrame = Torso.CFrame
	local TorsoPosition = (TorsoCFrame + TorsoCFrame.lookVector * (Torso.Size.Z * -3.25))
	TorsoPosition = (TorsoPosition + (TorsoPosition * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (Torso.Size.X * 1.5))
	TorsoPosition = TorsoPosition - Vector3.new(0, ((PlayerNPC:GetModelSize().Y / 2) - (Torso.Size.Y / 2)), 0)
	NPCTorso.CFrame = TorsoPosition
	local NPCAnimation = PlayerNPC:FindFirstChild("Animation")
	if NPCAnimation then
		NPCAnimation.Disabled = true
		Delay(0.25, function()
			if NPCAnimation and NPCAnimation.Parent then
				NPCAnimation.Disabled = false
			end
		end)
	end
end

function Activated()
	if PlayerNPC and PlayerNPC.Parent then
		local Healing = PlayerNPC:FindFirstChild("Healing")
		if Healing then
			Healing.Value = true
		end
	end
end

function Equipped()
	Handle.Transparency = 1
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	if Tool.Enabled then
		Spawn(function()
			MakeNPC()
		end)
	end
	ToolEquipped = true
end

function Unequipped()
	if PlayerNPC then
		for i, v in pairs({PlayerNPC}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		PlayerNPC = nil
		Spawn(function()
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			if not ToolEquipped then
				Handle.Transparency = 0
			end
		end)
	end
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Enabled" and Tool.Enabled and ToolEquipped then
		MakeNPC()
	elseif Property == "Parent" and Tool.Parent and not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent) then
		Handle.Transparency = 0
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)