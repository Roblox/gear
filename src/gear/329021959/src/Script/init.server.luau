--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")

NPCModule = require(191816425)

BaseUrl = "http://www.roblox.com/asset/?id="

RemoverScript = script:WaitForChild("RemoverScript")

NPCModel = InsertService:LoadAsset(327243569)
NPC = NPCModel:GetChildren()[1]:Clone()
if NPCModel and NPCModel.Parent then
	NPCModel:Destroy()
end

ReloadTime = 5

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function MakeNPC()
	if PlayerNPC and PlayerNPC.Parent then
		PlayerNPC:Destroy()
	end
	PlayerNPC = NPC:Clone()
	local Data = NPCModule.GetTable({Key = "MakeNPC", Player = Player})
	if not Data then
		return
	end
	local NPCData = Data.GetData({Player = Player, Tool = Tool})
	NPCData.MakeNPC({
		NPC = PlayerNPC, AIControl = {
			Creator = Player,
			Mode = "Follow",
			MaxDistance = math.hgue,
			Follow = Player,
			Offset = Vector3.new(-4.5, 2.05, -0.5),
			Chase = false,
			ChaseDistance = 0,
			ChaseRange = 0,
			Target = nil,
			TargetPos = Vector3.new(0, 0, 0),
			Damage = 0,
			NormalSpeed = 16,
			ChaseSpeed = 16, SelfSufficient = true
		}
	})
	NPCHumanoid = PlayerNPC:FindFirstChild("Humanoid")
	NPCHead = PlayerNPC:FindFirstChild("Head")
	NPCTorso = PlayerNPC:FindFirstChild("Torso")
	if not NPCHumanoid or not NPCHead or not NPCTorso then
		return
	end
	local RemoverScriptCopy = RemoverScript:Clone()
	RemoverScriptCopy.Disabled = false
--	RemoverScriptCopy.Parent = PlayerNPC
	PlayerNPC.Parent = game:GetService("Workspace")
	NPCTorso.CFrame = (Torso.CFrame * CFrame.new(PlayerNPC.Offset.Value))
	NPCHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Handle.Transparency = 1
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
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
	if Property == "Enabled" and Tool.Enabled and ToolEquipped and Tool.Parent then
		MakeNPC()
	elseif Property == "Parent" and Tool.Parent and not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent) then
		Handle.Transparency = 0
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)