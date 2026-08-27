Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

DrinkAnim = Tool:WaitForChild("DrinkAnim")
FastScript = script:WaitForChild("FastScript")

PlaySound = Tool:WaitForChild("PlaySound")

DrinkSound = Handle:WaitForChild("DrinkSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ReloadTime = 45

KeyframeReachedConnection = nil
DrinkAnimTrack = nil

function Activated()
	if Tool.Enabled and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and not Humanoid:FindFirstChild(FastScript.Name) then
		Tool.Enabled = false
		DrinkAnimTrack = Humanoid:LoadAnimation(DrinkAnim)
		if DrinkAnimTrack then
			DrinkAnimTrack:Play()
			delay(DrinkAnimTrack.Length, function()
				PlaySound.Value = DrinkSound.Name
				local FastScriptClone = FastScript:Clone()
				Debris:AddItem(FastScriptClone, (ReloadTime * 1.5))
				FastScriptClone.Parent = Humanoid	
				FastScriptClone.Disabled = false
			end)	
--			KeyframeReachedConnection = DrinkAnimTrack.KeyframeReached:Connect(function()
--				PlaySound.Value = DrinkSound.Name
--				local FastScriptClone = FastScript:Clone()
--				FastScriptClone.Disabled = false
--				Debris:AddItem(FastScriptClone, (ReloadTime * 1.5))
--				FastScriptClone.Parent = Humanoid
--				KeyframeReachedConnection:Disconnect()
--			end)
		end
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Equipped()
	local Character = Tool.Parent
	local Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		DrinkAnim.AnimationId = "rbxassetid://668704468"
	else
		DrinkAnim.AnimationId = "rbxassetid://94700140"
	end
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	if KeyframeReachedConnection then
		KeyframeReachedConnection:disconnect()
	end
	if DrinkAnimTrack then
		DrinkAnimTrack:Stop()
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)