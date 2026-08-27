--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ControlFunction = Tool:WaitForChild("ControlFunction")

Animations = {
	{Animation = Tool:WaitForChild("Swing1"), Duration = 1, Speed = 1.125, Damage = 20},
	{Animation = Tool:WaitForChild("Swing2"), Duration = 1, Speed = 2, Damage = 25},
	{Animation = Tool:WaitForChild("Swing3"), Duration = 1.25, Speed = 1.5, Damage = 15},
	{Animation = Tool:WaitForChild("Swing4"), Duration = 1, Speed = 2, Damage = 30}
}

Special = Tool:WaitForChild("Special")

LastAnimUsed = nil
AnimReused = 0

function ChooseAnimation()
	local AnimChosen = Animations[math.random(1, #Animations)]
	AnimReused = ((AnimChosen == LastAnimUsed and (AnimReused + 1)) or 0)
	if AnimChosen ~= LastAnimUsed or AnimReused <= 1 then
		LastAnimUsed = AnimChosen
		return AnimChosen
	else
		return ChooseAnimation()
	end
end

function Activated()
	if not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 or SpecialActive or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	if SwingAnim then
		SwingAnim:Stop()
	end
	local AnimChosen = ChooseAnimation()
	SwingAnim = Humanoid:LoadAnimation(AnimChosen.Animation)
	if SwingAnim then
		SwingAnim:Play(nil, nil, AnimChosen.Speed)
		AnimPlaying = AnimChosen
	end
	pcall(function()
		ControlFunction:InvokeServer("AnimationPlaying", {Name = AnimChosen.Animation.Name, Duration = AnimChosen.Duration, Damage = AnimChosen.Damage})
	end)
	wait(AnimChosen.Duration)
	if SwingAnim then
		SwingAnim:Stop()
	end
	AnimPlaying = nil
	wait(ReloadTime)
	Tool.Enabled = true
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == "q" then
			local SpecialSuccessful = false
			pcall(function()
				SpecialSuccessful = ControlFunction:InvokeServer("KeyDown", Key)
			end)
			if SpecialSuccessful then
				SwingAnim = Humanoid:LoadAnimation(Special)
				if SwingAnim then
					SwingAnim:Play(nil, nil, 0.5)
				end
				local UnequippedCheck = false
				local UnequippedConnection
				UnequippedConnection = Tool.Unequipped:connect(function()
					UnequippedCheck = true
					UnequippedConnection:disconnect()
				end)
				wait(2)
				if UnequippedConnection then
					UnequippedConnection:disconnect()
				end
				if not UnequippedCheck and SwingAnim then
					SwingAnim:Stop()
				end
			end
		end
	end)
end

function Unequipped()
	if SwingAnim then
		SwingAnim:Stop()
	end
	AnimPlaying = nil
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)