local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local LocalZombieDogMain = Tool:WaitForChild('LocalZombieDogMain')
local ServerZombieDogMain = Tool:WaitForChild('ServerZombieDogMain')
local PoisonScript = Tool:WaitForChild('PoisonScript')
local Torso;
local Character;

Tool.Equipped:connect(function(mouse)
	Character = Tool.Parent
	Torso = Character:WaitForChild('Torso')
	local Player = game.Players:GetPlayerFromCharacter(Character)
	
	mouse.Button1Down:connect(function()
		if Character:FindFirstChild('LocalZombieDogMain') then return end
		local hit = mouse.Hit.p
		if (hit-Torso.Position).magnitude < 120 then
			local dog = game:GetService('InsertService'):LoadAsset(121605203):GetChildren()[1]
			--
			local dogServerScript = ServerZombieDogMain:Clone()
			dogServerScript:WaitForChild('Creator').Value = Player
			dogServerScript.Parent = dog
			dogServerScript.Disabled = false
			--
			local dogPoison = PoisonScript:Clone()
			dogPoison.Parent = dog
			--
			dog.Parent = game.Workspace
			dog:MoveTo(hit)
			--
			local dogLocalScript = LocalZombieDogMain:Clone()
			dogLocalScript:WaitForChild('ZombieDog').Value = dog
			dogLocalScript.Disabled = false
			dogLocalScript.Parent = Character
		end
	end)
end)
