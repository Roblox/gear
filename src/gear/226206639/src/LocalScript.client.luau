--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")

Animations = {}
LocalObjects = {}

Sounds = {
	SpringSound = Handle:WaitForChild("SpringSound"),
}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

Rate = (1 / 60)

ToolEquipped = false

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

function CanJump()
	local Direction = Vector3.new(0, -1, 0)
	local DistanceBelow = ((Torso.Size.Y * 1.5) + Handle.Size.Y + 0.1)
	local Ignore = {Character}
	local RayPositions = {
		(Torso.CFrame * CFrame.new(0, 0, 0)).p, --Center
		(Torso.CFrame * CFrame.new(-((Torso.Size.X / 2) + 0.2), 0, 0)).p, --Center Left
		(Torso.CFrame * CFrame.new(((Torso.Size.X / 2) + 0.2), 0, 0)).p, --Center Right
		(Torso.CFrame * CFrame.new(0, 0, ((Torso.Size.Z / 2) + 0.2))).p, --Front Center
		(Torso.CFrame * CFrame.new(0, 0, -((Torso.Size.Z / 2) + 0.2))).p, --Back Center
		(Torso.CFrame * CFrame.new(-((Torso.Size.X / 2) + 0.2), 0, -((Torso.Size.Z / 2) + 0.2))).p, --Back Left
		(Torso.CFrame * CFrame.new(((Torso.Size.X / 2) + 0.2), 0, -((Torso.Size.Z / 2) + 0.2))).p, --Back Right
		(Torso.CFrame * CFrame.new(-((Torso.Size.X / 2) + 0.2), 0, ((Torso.Size.Z / 2) + 0.2))).p, --Front Left
		(Torso.CFrame * CFrame.new(((Torso.Size.X / 2) + 0.2), 0, ((Torso.Size.Z / 2) + 0.2))).p, --Front Right
	}
	for i, v in pairs(RayPositions) do
		local RayHit, RayPos, RayNormal = RayCast(v, Direction, DistanceBelow, Ignore)
		if RayHit then
			return true
		end
	end
	return false
end

function SetAnimation(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		for i, v in pairs(Animations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(Value.Animation)
		table.insert(Animations, {Animation = Value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(Value.FadeTime, Value.Weight, Value.Speed)
	elseif Mode == "StopAnimation" and Value then
		for i, v in pairs(Animations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Player:GetMouse()
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true})
	end)
	Mouse.Button1Up:connect(function()
		InvokeServer("MouseClick", {Down = false})
	end)
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
	Spawn(function()
		Torso.Velocity = Vector3.new(Torso.Velocity.X, 0, Torso.Velocity.Z)
		Humanoid.AutoRotate = false
		Humanoid.WalkSpeed = 0
		for i, v in pairs({ToolUnequipped, HumanoidJumped}) do
			if v then
				v:disconnect()
			end
		end
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		HumanoidJumped = Humanoid.Changed:connect(function(Property)
			if Property == "Jump" then
				if Humanoid.Jump and CanJump() then
					Sounds.SpringSound.Pitch = (math.random(1100, 1300) * 0.001)
					Sounds.SpringSound:Play()
					Humanoid.AutoRotate = true
					Humanoid.WalkSpeed = 16
					Torso.Velocity = Vector3.new(0, 50, 0)
					wait(0.5)
					local JumpEnabled = false
					while CheckIfAlive() and Humanoid.Jump and not JumpEnabled and CurrentlyEquipped do
						JumpEnabled = CanJump()
						wait(Rate)
					end
					if CurrentlyEquipped then
						Humanoid.AutoRotate = false
						Humanoid.WalkSpeed = 0
						Humanoid.Jump = false
						Torso.Velocity = Vector3.new(Torso.Velocity.X, 0, Torso.Velocity.Z)
						Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
					end
				else
					Humanoid.Jump = false
				end
			end
		end)
		Humanoid.Jump = false
		Spawn(function()
			Humanoid:ChangeState(Enum.HumanoidStateType.None)
		end)
	end)
end

function Unequipped()
	ToolEquipped = false
	LocalObjects = {}
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({ObjectLocalTransparencyModifier, ToolUnequipped, HumanoidJumped}) do
		if v then
			v:disconnect()
		end
	end
	Animations = {}
	if CheckIfAlive() then
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		Humanoid.AutoRotate = true
		Humanoid.WalkSpeed = 16
	end
end

function InvokeServer(Mode, Value)
	local ServerReturn
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(Mode, Value)
	end)
	return ServerReturn
end

function OnClientInvoke(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", Value)
	elseif Mode == "StopAnimation" and Value then
		SetAnimation("StopAnimation", Value)
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
	elseif Mode == "MousePosition" then
		return PlayerMouse.Hit.p
	elseif Mode == "SetLocalTransparencyModifier" and Value and ToolEquipped then
		pcall(function()
			local ObjectFound = false
			for i, v in pairs(LocalObjects) do
				if v == Value then
					ObjectFound = true
				end
			end
			if not ObjectFound then
				table.insert(LocalObjects, Value)
				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end
				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
					for i, v in pairs(LocalObjects) do
						if v.Object and v.Object.Parent then
							if ((not v.AutoUpdate and (v.Object.LocalTransparencyModifier == 1 or  v.Object.LocalTransparencyModifier == 0)) or v.AutoUpdate) then
								v.Object.LocalTransparencyModifier = v.Transparency
							end
						else
							table.remove(LocalObjects, i)
						end
					end
				end)
			end
		end)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)