local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle

local Character = nil
local Player = nil
local Humanoid = nil
local Torso = nil
local Debounce = false
local HitConnection = nil
local ToolEquipped = false
Tool.Enabled = true

local Whacking = false
local LastClick = 0
local DamageValue = 0

local RELOAD_TIME = 1.5
local DAMAGE = {Min = 10, Max = 20, Base = 5}

local BasePart = Instance.new("Part")
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = false
BasePart.Locked = true
BasePart.Anchored = true
BasePart.Transparency = 1

local Animations = {
	Whack = {Animation = Tool.Animations.R6:WaitForChild("Whack"), FadeTime = nil, Weight = nil, Speed = 1},
	HomeRun = {Animation = Tool.Animations.R6:WaitForChild("HomeRun"), FadeTime = nil, Weight = nil, Speed = 1},
	TwoHandAnim = {Animation = Tool.Animations.R6:WaitForChild("TwoHandAnim"), FadeTime = nil, Weight = nil, Speed = 1},
	
	R15Whack = {Animation = Tool.Animations.R15:WaitForChild("Whack"), FadeTime = nil, Weight = nil, Speed = 1},
	R15HomeRun = {Animation = Tool.Animations.R15:WaitForChild("HomeRun"), FadeTime = nil, Weight = nil, Speed = 1},
	R15TwoHandAnim = {Animation = Tool.Animations.R15:WaitForChild("TwoHandAnim"), FadeTime = nil, Weight = nil, Speed = 1}	
}

local Sounds = {
	HitGround = Handle:WaitForChild("HitGround")
}

local Remotes = Tool:WaitForChild("Remotes")
local ServerControl = Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction")
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

local ClientControl = Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction")
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

function RayCast(position, direction, max, ignore)
	local NewRay = Ray.new(position, direction.Unit * (max or 999), ignore)
	
	local Hit, EndPoint = workspace:FindPartOnRayWithIgnoreList(NewRay, ignore)
	
	return Hit, EndPoint
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function HomeRun()
	DamageValue = DAMAGE.Max
	local Debounce = false
	local HitConnection = Handle.Touched:Connect(function(hit)
		if Debounce then return end 
		if not hit or hit.Parent == nil then return end 		
		Debounce = true 
		local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if HitHumanoid and HitHumanoid ~= Humanoid then
			local Torso = HitHumanoid.Parent:FindFirstChild("Torso") or HitHumanoid.Parent:FindFirstChild("UpperTorso")
			if Torso then
				HitHumanoid.Sit = true
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				local Direction = CFrame.new(Handle.Position, Torso.Position).lookVector
				BodyVelocity.Velocity = Direction * 200 + Vector3.new(0, 100, 0)
				BodyVelocity.Parent = Torso 
				Debris:AddItem(BodyVelocity, 0.5)
--				Torso.Velocity = CFrame.new(Handle.Position, Torso.Position).lookVector * 200 + Vector3.new(0, 100, 0)
				Torso.RotVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
			end
		end
		wait(0.2)
		Debounce = false
	end)

	wait(0.6)	
	DamageValue = DAMAGE.Base
	if HitConnection then
		HitConnection:Disconnect()
	end	
end

function Whack()
	DamageValue = DAMAGE.Min
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character ~= Character then
			local Torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
			local PlayerHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if Torso and PlayerHumanoid then
				local Distance = (Torso.Position - (Handle.CFrame * CFrame.new(0, 3, 0)).p).Magnitude
				if Distance < 15 then
					PlayerHumanoid.Sit = true
					Torso.RotVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
 				end
			end
		end
	end
	
	delay(0.25, function()
		local CFrameValue =  Handle.CFrame - Vector3.new(0, Torso.Size.Y * 0.5, 0) + Torso.CFrame.lookVector * (Handle.Size.Y * 0.5)
		CFrameValue = CFrame.new(CFrameValue.p) * CFrame.Angles(0, 0, 0)
		CFrameValue = CFrameValue * CFrame.fromEulerAnglesXYZ(-math.pi * 0.5, 0, -math.pi * 0.5)
		local Hit, EndPoint = RayCast(CFrameValue.p, CFrameValue.lookVector, 4, {Character})
		if Hit then
			delay(0.35, function()
				InvokeClient("PlaySound", Sounds.HitGround)
			end)
			local NewPart = BasePart:Clone()
			NewPart.CFrame = CFrame.new(Handle.CFrame.x, EndPoint.y + 0.75, Handle.CFrame.z) + Torso.CFrame.lookVector * 1.75
			NewPart.Parent = workspace
			Debris:AddItem(NewPart, 1.3)
		end
	end)	
	
	wait(0.6)	
	DamageValue = DAMAGE.Base
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	if tick() - LastClick < 0.2 and not Whacking then
		Tool.Enabled = false
		local Animation = Animations.HomeRun
		local StopAnimation = Animations.Whack
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15HomeRun
			StopAnimation = Animations.R15Whack
		end
		InvokeClient("StopAnimation", StopAnimation)
		spawn(function() InvokeClient("PlayAnimation", Animation) end)
		HomeRun()
	elseif not Whacking then  
		Whacking = true
		local Animation = Animations.Whack
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Whack
		end
		spawn(function() InvokeClient("PlayAnimation", Animation) end)
		Whack()
		Whacking = false
	end
	
	LastClick = tick()
	wait(RELOAD_TIME)
	Tool.Enabled = true
end 

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	local Animation = Animations.TwoHandAnim
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15TwoHandAnim
	end
	spawn(function() InvokeClient("PlayAnimation", Animation) end)
	
	DamageValue = DAMAGE.Base
	HitConnection = Handle.Touched:Connect(function(hit)
		if Debounce then return end 
		if not hit or hit.Parent == nil then return end 		
		local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if HitHumanoid and HitHumanoid ~= Humanoid then
			Debounce = true
			HitHumanoid:TakeDamage(DamageValue)
			wait(0.2)
			Debounce = false
		end
	end)	
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
	if Torso and Torso.Parent then
		Handle.CFrame = (Torso.CFrame + Torso.CFrame.lookVector * (Torso.Size.Z * 2))
	end
	
	if HitConnection then 
		HitConnection:Disconnect()
	end
	HitConnection = nil
	DamageValue = 0
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)