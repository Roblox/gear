Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

BaseUrl = "rbxassetid://"

Animations = {
	LeftSwing = {Animation = Tool.Animations.R6:WaitForChild("LeftSwing"), FadeTime = nil, Weight = nil, Speed = nil},
	RightSwing = {Animation = Tool.Animations.R6:WaitForChild("RightSwing"), FadeTime = nil, Weight = nil, Speed = nil},
	Stab = {Animation = Tool.Animations.R6:WaitForChild("Stab"), FadeTime = nil, Weight = nil, Speed = nil},
	R15LeftSwing = {Animation = Tool.Animations.R15:WaitForChild("LeftSwing"), FadeTime = nil, Weight = nil, Speed = nil},
	R15RightSwing = {Animation = Tool.Animations.R15:WaitForChild("RightSwing"), FadeTime = nil, Weight = nil, Speed = nil},	
	R15Stab = {Animation = Tool.Animations.R15:WaitForChild("Stab"), FadeTime = nil, Weight = nil, Speed = nil}
}

Grips = {
	Stab = CFrame.new(0, -2.5, 0.5, 1, 0, 0, 0, 0, -1, -0, 1, 0),
	Equip = CFrame.new(0, -2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

Damage = {Min = 5, Max = 20}

CurrentDamage = 0

ReloadTime = 1
ToolEquipped = false

Rate = (1 / 60)

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

Swinging = false 

OnTouchedConn = nil

local AttackAnim = -1 
local LastAnim = nil

local Tags = {}

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function OnTouched(hitPart)
	if hitPart and hitPart.Parent then
		local HitHumanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
		if HitHumanoid and HitHumanoid ~= Humanoid and not Tags[hitPart.Parent] then 
			HitHumanoid:TakeDamage(CurrentDamage)
			Tags[hitPart.Parent] = true 
			wait(ReloadTime)
			Tags[hitPart.Parent] = nil
		end 
	end 
end 

function SelectAttackAnimation()
	AttackAnim = (AttackAnim + 1) % 3
	local Animation = nil 
	if AttackAnim == 0 then
		Animation = Animations.LeftSwing
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15LeftSwing
		end			
	elseif AttackAnim == 1 then
		Animation = Animations.RightSwing
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15RightSwing
		end			
	elseif AttackAnim == 2 then
		Animation = Animations.Stab
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Stab
		end		
	end
	
	if LastAnim then
		InvokeClient("StopAnimation", LastAnim)
	end
	
	return Animation
end

function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false 
	local Animation = SelectAttackAnimation()
	LastAnim = Animation
	if AttackAnim == 2 then
		ReloadTime = 1
	else
		ReloadTime = 0.5
	end

	CurrentDamage = math.random(Damage.Min, Damage.Max)
	spawn(function()
		InvokeClient("PlayAnimation", Animation)
		if AttackAnim == 2 then
			wait(0.4)
			Tool.Grip = Grips.Stab
			wait(0.6)
			Tool.Grip = Grips.Equip
		end
	end)		
			
	wait(ReloadTime)
	CurrentDamage = Damage.Min
	Tool.Enabled = true 
end

function Equipped()
	if OnTouchedConn then
		OnTouchedConn:Disconnect()
	end 

	OnTouchedConn = Tool.Handle.Touched:Connect(OnTouched)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not CheckIfAlive() then
		return
	end
	spawn(function()		
		local Limbs = {"Left Arm", "Right Arm", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm"}
		for i, v in pairs(Limbs) do
			local Limb = Character:FindFirstChild(v)
			if Limb then
				spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Limb, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	if OnTouchedConn then
		OnTouchedConn:Disconnect()
	end 
	
	OnTouchedConn = nil
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
Tool.Activated:connect(Activated)