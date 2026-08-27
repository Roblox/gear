local Tool = script.Parent

local swingWithOut = nil
local swingJump = nil
local swordThrust = nil

local humanoid = nil

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false

	wait()

	if Tool.Lunge.Value == true then
		humanoid.Jump = true
		swingJump:Play()
		wait(0.8)
		Tool.Lunge.Value = false
	else
		local anim = math.random(2,3)
		if anim == 2 then
			swingWithOut:Play()
		else
			swordThrust:Play()
		end
	end

	enabled = true

end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	
	humanoid = Tool.Parent:FindFirstChild("Humanoid")

	swingWithOut = humanoid:LoadAnimation(Tool.twohandswordwithswingout)
	swingJump = humanoid:LoadAnimation(Tool.swordswingjump)
	swordThrust = humanoid:LoadAnimation(Tool.swordthrust)

end

function onUnequippedLocal()

	swingWithOut:remove()
	swingJump:remove()
	swordThrust:remove()

end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
