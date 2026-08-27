--Rescripted by TakeoHonorable

local Tool = script.Parent

Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle",10)

local RayAttachment = Handle:WaitForChild("RayAttachment",10)

local RayBeam = Handle:WaitForChild("RayBeam",10)

local MouseClick = Tool:WaitForChild("MouseClick",10)

local StopHittingScript = script:WaitForChild("StopHittingYourself",10)

local MyPlayer,MyCharacter,MyHumanoid

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}


local Properties = {
	CooldownTime = 1
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end




local TaggedHumanoid
local CurrentAttachment = Instance.new("Attachment");CurrentAttachment.Position = Vector3.new(0,0,0)


function TagCharacter(Player,HitPart) -- Step2. Check legitimacy on the server
	if not Tool.Enabled or not MyPlayer or MyPlayer ~= Player or not HitPart or not HitPart.Parent or not MyHumanoid or MyHumanoid.Health <= 0 then return end
	
	local Humanoid = HitPart.Parent:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 or IsTeamMate(MyPlayer,Services.Players:GetPlayerFromCharacter(Humanoid.Parent)) then return end
	
	local Head = Humanoid.Parent:FindFirstChild("Head")
	if not Head then return end
	
	Tool.Enabled = false
	
	if TaggedHumanoid and TaggedHumanoid ~= Humanoid then
		RayBeam.Attachment1 = nil
		CurrentAttachment.Parent = nil
	end
	
	CurrentAttachment.Parent = Head
	RayBeam.Attachment1 = CurrentAttachment
	
	TaggedHumanoid = Humanoid
	
	local StopHittingScriptClone = StopHittingScript:Clone()
	StopHittingScriptClone:WaitForChild("creator",10).Value = MyPlayer
	StopHittingScriptClone:WaitForChild("Attachment").Value = CurrentAttachment
	StopHittingScriptClone:WaitForChild("Tool").Value = Tool
	StopHittingScriptClone.Parent = Humanoid.Parent
	StopHittingScriptClone.Disabled = false

	repeat
		Services.RunService.Heartbeat:Wait()
	until not StopHittingScriptClone or not StopHittingScriptClone:IsDescendantOf(workspace) or not Head or not Head:IsDescendantOf(workspace) or not MyHumanoid or not MyHumanoid:IsDescendantOf(workspace) or MyHumanoid.Health <= 0 or not Humanoid or not Humanoid:IsDescendantOf(workspace) or Humanoid.Health <= 0 or Tool.Parent ~= MyCharacter

	Services.Debris:AddItem(StopHittingScriptClone,.5)
	RayBeam.Attachment1 = nil
	--CurrentAttachment.Parent = nil

	TaggedHumanoid = nil

	wait(Properties.CooldownTime)
	
	Tool.Enabled = true
end


function Equipped()
	MyCharacter = Tool.Parent
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter)
	if not MyPlayer then return end
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
end

Tool.Equipped:Connect(Equipped)
MouseClick.OnServerEvent:Connect(TagCharacter)