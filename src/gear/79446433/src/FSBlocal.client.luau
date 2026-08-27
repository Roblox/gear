print("Script gets called hurrr")
local Tool = script.Parent
local Handle = Tool.Handle
local Char
local Torso, Weld, saluteAnim

function getPlayer(mouse) --grabs target player and makes them salute
	local notfound = true
	if mouse.Target ~= nil then
		local target = mouse.Target
		local oChar = target.Parent -- the clicked player
		local oCharHumanoid = oChar:FindFirstChild("Humanoid")
		local player = game.Players:GetPlayerFromCharacter(oChar) --used below to see if you clicked a player. 
		local hasSS = oChar:FindFirstChild("SaluteScript")
		if player and oCharHumanoid and hasSS == nil then
			print("1")
			if Tool:FindFirstChild("SaluteScript") ~= nil then 
				print("2")
				local ss = Tool.SaluteScript:clone()
				ss.Parent = oChar
				ss.Disabled = false 
			end
		end
	end
end

function onEquipped(mouse) -- allows user to select another player and makes them salute
	if mouse ~= nil then
		print("before mouse icon change")
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
		Char = Tool.Parent
		Torso = Char:FindFirstChild("Torso")
		RightArm = Char:FindFirstChild("Right Arm")
		local Humanoid = Char:FindFirstChild("Humanoid")
		while RightArm:FindFirstChild("RightGrip") == nil do
			wait()
		end
	
		mouse.Button1Down:connect(function() getPlayer(mouse) end) -- call to getPlayer
	end
end

function onUnequipped() -- make sure no one is saluting

end


print("at end 1")
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
print("at end 2")
