local Tool = script.Parent;
local con = nil 

function onButton1Down(mouse)

	script.Parent.Opponent.Value = nil

	if mouse ~= nil and mouse.Target ~= nil and mouse.Target.Parent ~= nil then
		local humanoid = mouse.Target.Parent:FindFirstChild("Humanoid")
		if humanoid ~= nil then
			local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
			if player ~= nil then
				script.Parent.Opponent.Value = player
			end
		end
	end

end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end
		
	con = mouse.Button1Down:connect(function() onButton1Down(mouse) end)

end

function onUnequippedLocal()

	con:disconnect()

end


Tool.Unequipped:connect(onUnequippedLocal)
Tool.Equipped:connect(onEquippedLocal)
