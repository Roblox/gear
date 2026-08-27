local Tool = script.Parent
local Handle = Tool.Handle
local Fire

local myCharacter
local myHumanoid
local Torso
local RightShoulder
local TargetPoint
local TargetDir
local TargetHorAngle
local TargetVertAngle

local ProjectileScript

local newlyRunning = true	-- Purpose of this boolean is to make the wait for the tool to be re-equipped
									--   a little less painful.

local StandardC1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0)

function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	myCharacter = Tool.Parent
	if myCharacter then
		myHumanoid = myCharacter:FindFirstChild("Humanoid")
		Torso = myCharacter:FindFirstChild("Torso")
		if Torso then
			RightShoulder = Torso:FindFirstChild("Right Shoulder")
		end
		if myHumanoid and RightShoulder then		
			-- Bring arm up, to prepare to throw dagger.
			-- Standard shoulder C1 is StandardC1 * CFrame.Angles(0, 0, 0), so we use that as the
			--   starting point.
			-- Upright is StandardC1 * CFrame.Angles(0, 0, -math.pi/2), so we use that as the endpoint
			--   and interpolate between.
			for i = 1, 15 do
				RightShoulder.C1 = StandardC1 * CFrame.Angles(0, 0, -i * math.pi/30)
				wait()
			end
			wait(0.1)

			-- Calculate target direction and corresponding horizontal angle.
			-- But make sure we're not throwing behind us (even though that would
			--   be cool). The limit is throwing directly to the side.
			TargetPoint = myHumanoid.TargetPoint
			TargetDir = Torso.CFrame:pointToObjectSpace(TargetPoint) - Vector3.new(1, 0.5, 0)
			TargetVertAngle = math.atan(TargetDir.Y / TargetDir.Z)
			if TargetDir.Z > 0 then
				if TargetDir.X > 0 then 
					TargetHorAngle = math.pi/2
				else
					TargetHorAngle = -math.pi/2
				end
			else
				TargetHorAngle = math.atan(TargetDir.X / TargetDir.magnitude)
			end

			-- Meanwhile, down angle is at StandardC1 * CFrame.Angles(TargetHorAngle, 0, TargetVertAngle), so we again
			--   interpolate to bring the arm down.
			for i = 1, 5 do
				wait()
				RightShoulder.C1 = StandardC1 * CFrame.Angles(i * TargetHorAngle / 5, 0, (i-5) * math.pi/10 + i * TargetVertAngle / 5)
			end
			
			-- Now, fire off a projectile.
			
			ProjectileScript = Tool:FindFirstChild("BDProjScript")
			if ProjectileScript then
				TargetPos = Tool:FindFirstChild("TargetPos")
				if TargetPos and myHumanoid then
					TargetPos.Value = myHumanoid.TargetPoint	-- Necessary to send this since server only updates TargetPoint on mouse click.
				end
				ProjectileScript = ProjectileScript:Clone()
				ProjectileScript.Parent = Tool
				ProjectileScript.Disabled = false
			end

			--	And bring your arm back to normal.
			wait(0.2)
			for i = 10, 0, -1 do
				wait()
				RightShoulder.C1 = StandardC1 * CFrame.Angles(i * TargetHorAngle/10, 0, 0)
			end	
		else
			Tool.Enabled = true
		end
	else
		Tool.Enabled = true
	end
end

function onEquipped()
	if newlyRunning and not Tool.Enabled then
		wait(5)
		Tool.Enabled = true
	end
	newlyRunning = false
end

function onUnequipped()
	Handle.Transparency = 0.0
	Fire = Handle:FindFirstChild("Fire")
	if Fire then Fire.Enabled = true end
	if RightShoulder then RightShoulder.C1 = StandardC1 end
	if not Tool.Enabled then
		wait(5)
		Tool.Enabled = true
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
