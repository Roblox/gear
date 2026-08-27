math.randomseed(tick()); math.random()

local Tool = script.Parent
local Handle = Tool.Handle

local ProjectileScript

local myCharacter
local myHumanoid

local ServeAnim

function onActivated()
	if not Tool.Enabled then return end
	ProjectileScript = Tool:FindFirstChild("VolleyballProjScript")
	if ProjectileScript then
		Tool.Enabled = false
		myCharacter = Tool.Parent
		myHumanoid = myCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			ServeAnim = Tool:FindFirstChild("VolleyballServe")
			if ServeAnim then
				ServeAnim = myHumanoid:LoadAnimation(ServeAnim)
				ServeAnim:Play()
			end
		end
		local CloneScript = ProjectileScript:Clone()
		CloneScript.Parent = Tool
		CloneScript.Disabled = false
		wait(1.2)
		if Handle:FindFirstChild("HitSound") then Handle.HitSound:Play() end
		Handle.Transparency = 1.0
		wait(3.9)
		Handle.Transparency = 0.0
		Tool.Enabled = true
	end
end

function onEquipped()
	if not Tool.Enabled then
		wait(3)
		Tool.Enabled = true
	end
end

function onUnequipped()
	if ServeAnim then ServeAnim:Stop() end
	Handle.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
