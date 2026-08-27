--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1.7},
	TwoHandSlash = {Animation = Tool:WaitForChild("TwoHandSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.75, Damage = 15},
	TwoHandUpperSlash = {Animation = Tool:WaitForChild("TwoHandUpperSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.75, Damage = 15},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.75, Damage = 10},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.75, Damage = 10},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge")
}

Damage = 5

Equipped = false
Active = false
CurrentAnimation = nil

Special = {
	Enabled = true,
	Active = false,
	ReloadTime = 10
}

Grips = {
	Equipped = CFrame.new(0, 0, 1.60000002, 1, 0, 8.90154915e-005, -8.90154915e-005, 0, 1, 0, -1, 0)
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and Equipped and Active and CheckIfAlive() then
		if Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if Key == "q" and Down then
				if Special.Enabled and not Special.Active and Tool.Enabled then
					Special.Enabled = false
					Special.Active = true
					local CurrentlyEquipped = true
					if ActivatedToolUnequipped then
						ActivatedToolUnequipped:disconnect()
					end
					ActivatedToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
						if ActivatedToolUnequipped then
							ActivatedToolUnequipped:disconnect()
						end
					end)
					Tool.Grip = Grips.Equipped
					CurrentAnimation = {Damage = 20}
					for i = 1, 240 do 
						if CurrentlyEquipped then
							local Theta = ((i % 12) * (math.pi / 6))
							Tool.GripUp = Vector3.new(0, -math.sin(Theta), math.cos(Theta))
							wait()
						end
					end
					CurrentAnimation = nil
					Tool.Grip = Grips.Equipped
					Special.Active = false
					wait(Special.ReloadTime)
					Special.Enabled = true
				end
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Blow(Part)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not Equipped or not CheckIfAlive() then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if character ~= Character and humanoid and humanoid.Health > 0 then
			local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or Damage)
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(DamageValue)
		end
	end)
end

function Activated()
	if not Tool.Enabled or not Equipped or not Active or not CheckIfAlive() or Special.Active then
		return
	end
	Tool.Enabled = false
	Sounds.Slash:Play()
	local CurrentlyEquipped = true
	if ActivatedToolUnequipped then
		ActivatedToolUnequipped:disconnect()
	end
	ActivatedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ActivatedToolUnequipped then
			ActivatedToolUnequipped:disconnect()
		end
	end)
	local SlashAnims = {Animations.TwoHandSlash, Animations.TwoHandUpperSlash, Animations.LeftSlash, Animations.RightSlash}
	local SlashAnim = SlashAnims[math.random(1, #SlashAnims)]
	CurrentAnimation = SlashAnim
	InvokeClient("PlayAnimation", SlashAnim)
	InvokeClient("PlaySound", Sounds.Slash)
	wait(SlashAnim.Duration)
	if CurrentlyEquipped then
		InvokeClient("StopAnimation", SlashAnim)
		CurrentAnimation = nil
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	Sounds.Unsheath:Play()
	local EquipAnim = Animations.Equip
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	InvokeClient("PlayAnimation", EquipAnim)
	wait(EquipAnim.Duration)
	if CurrentlyEquipped then
		InvokeClient("StopAnimation", EquipAnim)
		Active = true
	end
end

function Unequipped()
	Equipped = false
	Active = false
	CurrentAnimation = nil
	for i, v in pairs({ToolUnequipped, ActivatedToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		if v and v.Parent then
			InvokeClient("StopAnimation", v)
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
			InvokeClient("StopSound", v)
		end
	end
end

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)