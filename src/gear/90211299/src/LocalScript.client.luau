--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Animation = Tool:WaitForChild("Animation")

local Animations = {
	ClawsUp = Tool:WaitForChild("Animation"),
	R15ClawsUp = Tool:WaitForChild("R15Animation")
}

AnimState = Tool:WaitForChild("AnimState")

function StartAnim()
	if Humanoid and Humanoid.Parent then
		StopAnim()
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			AnimTrack = Humanoid:LoadAnimation(Animations.R15ClawsUp)
		else 
			AnimTrack = Humanoid:LoadAnimation(Animations.ClawsUp)
		end
		AnimTrack:Play()
	end
end

function StopAnim()
	if AnimTrack then
		AnimTrack:Stop()
		AnimTrack:Destroy()
	end

	AnimTrack = nil
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
	StopAnim()
	Character = nil
	Player = nil
	Humanoid = nil
end 

AnimState.Changed:connect(function()
	if AnimState.Value then
		StartAnim()
	else
		StopAnim()
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:Connect(Unequipped)