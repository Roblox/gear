Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
TweenService = game:GetService("TweenService")

LaserTweenInfo = TweenInfo.new(
	1, 
	Enum.EasingStyle.Elastic,
	Enum.EasingDirection.Out
)

BaseUrl = "rbxassetid://"

Animations = {
	LeftSwing = {Animation = Tool.Animations.R6:WaitForChild("LeftSwing"), FadeTime = nil, Weight = nil, Speed = nil},
	RightSwing = {Animation = Tool.Animations.R6:WaitForChild("RightSwing"), FadeTime = nil, Weight = nil, Speed = nil},
	R15LeftSwing = {Animation = Tool.Animations.R15:WaitForChild("LeftSwing"), FadeTime = nil, Weight = nil, Speed = nil},
	R15RightSwing = {Animation = Tool.Animations.R15:WaitForChild("RightSwing"), FadeTime = nil, Weight = nil, Speed = nil},	
}

Sounds = {

}

Damage = {Min = 5, Max = 20}

CurrentDamage = 0

ReloadTime = 5
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

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function CreateLaser(start, endPoint)
	local Distance = (start - endPoint).Magnitude
	local NewPart = Instance.new("Part")
	NewPart.Name = "Laser"
	NewPart.CanCollide = false
	NewPart.Anchored = true
	NewPart.Locked = true 
	NewPart.Material = Enum.Material.Neon
	NewPart.BrickColor = BrickColor.new("Bright blue")
	NewPart.Size = Vector3.new(0.2, 0.2, Distance)
	NewPart.CFrame = CFrame.new(start, endPoint) * CFrame.new(0, 0, -Distance * 0.5)
	NewPart.Parent = Tool 

	local LaserGoals = {
		Size = Vector3.new(0, 0, Distance);
		Transparency = 1;
	}

	local LaserTween = TweenService:Create(NewPart, LaserTweenInfo, LaserGoals)

	LaserTween:Play() 
	Debris:AddItem(NewPart, 1)
end 

function OnTouched(hitPart)
	if hitPart and hitPart.Parent then
		local HitHumanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
		if HitHumanoid and HitHumanoid ~= Humanoid then 
			HitHumanoid:TakeDamage(CurrentDamage)
		end 
	end 
end 


function Activated()
	if Tool.Enabled then 
		Tool.Enabled = false 

		local TargetPosition = InvokeClient("MousePosition").Position
		
		local NewRay = Ray.new(RootPart.Position, (TargetPosition - RootPart.Position).Unit*999)
		local Hit, EndPoint = workspace:FindPartOnRayWithIgnoreList(NewRay, {Character, Tool})
		if Hit then
			if Hit.Parent then
				local HitHumanoid = Hit.Parent:FindFirstChildOfClass("Humanoid")
				if HitHumanoid then
					HitHumanoid:TakeDamage(Damage.Max)
				end
			end
		end

		CreateLaser(Handle.Muzzle.WorldPosition, EndPoint)
		
		wait(ReloadTime)
		Tool.Enabled = true 
	elseif not Swinging then  
		Swinging = true 
		CurrentDamage = Damage.Min 
		local LeftSwing = Animations.LeftSwing 
		local RightSwing = Animations.RightSwing
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			LeftSwing = Animations.R15LeftSwing 
			RightSwing = Animations.R15RightSwing
		end 

		InvokeClient("PlayAnimation", LeftSwing)
		wait(1)
		InvokeClient("StopAnimation", LeftSwing)
		InvokeClient("PlayAnimation", RightSwing)
		wait(1) 
		InvokeClient("StopAnimation", RightSwing)
		Swinging = false 
	end 
end

function Equipped()
	if OnTouchedConn then
		OnTouchedConn:Disconnect()
	end 

	OnTouchedConn = Tool.Handle.Touched:Connect(OnTouched)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()		
		local Limbs = {"Left Arm", "Right Arm", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm"}
		for i, v in pairs(Limbs) do
			local Limb = Character:FindFirstChild(v)
			if Limb then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Limb, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end

	if OnTouchedConn then
		OnTouchedConn:Disconnect()
	end 

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
	if Mode == "MouseClick" then

	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
Tool.Activated:connect(Activated)