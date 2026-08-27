--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Functions = require(script:WaitForChild("Functions"))

MultiModule = require(191816425)

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Animations = {
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85},
	R15Swing = {Animation = Tool:WaitForChild("R15Swing"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85},
}

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Hit = Handle:WaitForChild("Hit"),
}

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")

ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

Tool.Enabled = true

local function IsAnythingAnchored(Dir)
	if Dir then
		local Descendants = Dir:GetDescendants()
		for i=1,#Descendants do
			if Descendants[i] and Descendants[i]:IsA("BasePart") and Descendants[i].Anchored then
				return true
			end
		end
	end
	return false
end

function CreateNet(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not Create then
		return
	end
	FakeHandle = BasePart:Clone()
	FakeHandle.Name = "FakeHandle"
	FakeHandle.Transparency = 1
	FakeHandle.Size = Vector3.new(0.5, 4, 0.5)
	local Weld = Instance.new("Weld")
	Weld.Name = "NetWeld"
	Weld.Part0 = Handle
	Weld.Part1 = FakeHandle
	Weld.C0 = (CFrame.new(0, -0.5, -0.5) * CFrame.Angles((math.pi / 4), 0, 0))
	Weld.C1 = CFrame.new(0, 0, 0)
	Weld.Parent = FakeHandle
	Weld.Parent = FakeHandle
	Net = BasePart:Clone()
	Net.Name = "Net"
	Net.Transparency = 1
	Net.Size = Vector3.new(1, 1, 1)
	local Weld = Instance.new("Weld")
	Weld.Name = "NetWeld"
	Weld.Part0 = Handle
	Weld.Part1 = Net
	Weld.C0 = (CFrame.new(0, 1.09, 1.45) * CFrame.Angles((math.pi / 4), 0, 0))
	Weld.C1 = CFrame.new(0, 0, 0)
	Weld.Parent = Net
	FakeHandle.Parent = Tool
	Net.Parent = Tool
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not CurrentAnimation then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	local character = Hit.Parent
	local humanoid,ff = character:FindFirstChildOfClass("Humanoid"),character:FindFirstChildOfClass("ForceField")
	if not humanoid or humanoid.Health == 0 or ff or IsAnythingAnchored(character) then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or Functions.IsTeamMate(Player, player)) then
		return
	end
	CurrentAnimation = nil
	Sounds.Hit:Play()
	ModuleFunctions.CatchPlayer(character)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local SwingAnims = {Animations.Swing}
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		SwingAnims = {Animations.R15Swing}
	end
	local SlashSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
	SlashSounds[math.random(1, #SlashSounds)]:Play()
	CurrentAnimation = SwingAnims[math.random(1, #SwingAnims)]
	spawn(function()
		InvokeClient("PlayAnimation", CurrentAnimation)
	end)
	wait(CurrentAnimation.Duration)
	CurrentAnimation = nil
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	spawn(function()
		CreateNet(true)
	end)
	ModuleData = MultiModule.GetTable({Key = "BigBugNet", Player = Player, Tool = Tool})
	if not ModuleData then
		return
	end
	ModuleFunctions = ModuleData.GetData({Player = Player, Tool = Tool})
	if not ModuleFunctions then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:Disconnect()
		end
	end
	spawn(function()
		CreateNet(true)
	end)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value then
		return
	end
end

delay(0, (function()
	if ToolEquipped then
		return
	end
	CreateNet(true)
end))

Handle.Touched:Connect(Blow)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)