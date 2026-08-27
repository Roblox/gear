function WaitForChild(obj, name)
	while not obj:FindFirstChild(name) do
		wait()
		print("1waiting for " .. name)
	end
	return obj:FindFirstChild(name)
end

local Tool = script.Parent
local Sword = WaitForChild(Tool, "Handle")
local RunServe = game:service("RunService")
 -- time last key was pressed
local LastWDown = 0
local LastADown = 0
local LastDDown = 0
local LastSuperStrike = 0



function OnKeyDown(key)
	keytime = RunServe.Stepped:wait()
	if key:lower() == "w" then
		LastWDown = keytime
	elseif key:lower() == "a" then
		LastADown = keytime
	elseif key:lower() == "d" then
		LastDDown = keytime
		if LastDDown - LastADown <.4 and LastWDown>LastADown then 
			print("SUPER STRIKE") 
			LastSuperStrike = keytime
			script.Parent:FindFirstChild("lastSuperStrike").Value = LastSuperStrike
		end
	end
end

function OnEquippedLocal(mouse)
	mouse.KeyDown:connect(OnKeyDown)
end
Tool.Equipped:connect(OnEquippedLocal)



while not Tool:FindFirstChild("doStrike") do wait() end

print("got here in localscript")
Tool.doStrike.Changed:connect(function()
	local h = WaitForChild(Tool.Parent, "Humanoid")
	local t = WaitForChild(Tool.Parent, "Torso")
	local anim = WaitForChild(Tool, "AxeSwing")
	theanim = h:LoadAnimation(anim)
	if theanim and h.Health>0 then
		theanim:Play()
	end
end)
