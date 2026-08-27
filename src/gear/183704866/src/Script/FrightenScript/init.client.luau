--Made by Luckymaxer

Character = script.Parent

JumpScare = script:WaitForChild("JumpScare")
FrightenedCoverFace = script:WaitForChild("FrightenedCoverFace")

Debris = game:GetService("Debris")

function DestroyScript()
	Debris:AddItem(script, 2)
end

Humanoid = Character:FindFirstChild("Humanoid")
if not JumpScare or not FrightenedCoverFace or not Humanoid then
	DestroyScript()
end

local JumpScareAnim = Humanoid:LoadAnimation(JumpScare)
if JumpScareAnim then
	DisableJump = Humanoid.Changed:connect(function(Property)
		if Property == "Jump" then
			Humanoid.Jump = false
		end
	end)
	Humanoid.WalkSpeed = 0
	JumpScareAnim:Play(nil, nil, 2)
	wait(1)
	local FrightenedCoverFaceAnim = Humanoid:LoadAnimation(FrightenedCoverFace)
	if FrightenedCoverFaceAnim then
		FrightenedCoverFaceAnim:Play()
		wait(5)
		if FrightenedCoverFaceAnim then
			FrightenedCoverFaceAnim:Stop()
			if DisableJump then
				DisableJump:disconnect()
			end
			Humanoid.WalkSpeed = 16
			DestroyScript()
		end
	end
end

