local Tool = script.Parent
local Sword = Tool.Handle

local iceCo
local natureCo

local vCharacter
local myTorso
local myHumanoid

function wait12()	
	wait(12)
end

function wait20()
	wait(20)
end

function letsDoThis(key)
	if key:lower() == "x" then
		print("pRessed x")
		formIce = Tool:FindFirstChild("FormIce")
		if iceCo == nil or coroutine.status(iceCo) == 'dead' then
			iceCo = coroutine.create(wait12)
			coroutine.resume(iceCo)
			if formIce then formIce.Value = 1 end
			ice = Instance.new("Fire")
			ice.Name = "Ice"
			ice.Parent = Sword
			ice.Color = Color3.new(0, 0, 0.9)
			ice.SecondaryColor = Color3.new(0, 0, 0.5)
		end
	elseif key:lower() == "e" then
		print("pRessed e")
		if natureCo == nil or coroutine.status(natureCo) == 'dead' then 
			natureCo = coroutine.create(wait20)
			coroutine.resume(natureCo)
			players = game.Players:GetChildren()
			for i = 1, #players do 
				tempChar = players[i].Character
				tempTorso = tempChar:FindFirstChild("Torso")
				tempHumanoid = tempChar:FindFirstChild("Humanoid")
				if tempTorso and tempChar ~= vCharacter then 
					distance = (tempTorso.Position - myTorso.Position).magnitude
					if distance < 35 then 
						if tempHumanoid then tempHumanoid:TakeDamage(10) end
						if (myHumanoid.Health + 10) <= myHumanoid.MaxHealth then 
							myHumanoid.Health = myHumanoid.Health + 10
						else
							myHumanoid.Health = myHumanoid.MaxHealth
						end
					end
				end					
			end
		end
	end
	
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	mouse.KeyDown:connect(letsDoThis)
end

Tool.Equipped:connect(onEquipped)
