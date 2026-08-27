local Tool = script.Parent
local Gun = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 
local vPlayer 

local gunCrossHair

local mapFrame 

local guiSet = false

function showMap(key) 
	key = key:lower() 	
	if key == "v" or key == "e" then 
		if mapFrame then 
			mapFrame.Visible = true 
		end 
	elseif key == "q" then 
		if gameVictoryScreen and not gameVictoryScreen.Visible then 
			guiSet = true
			gameVictoryScreen.Visible = true 
		end 
	elseif key == "c" then 
		if gameClassesFrame then 
			gameClassesFrame.Visible = not gameClassesFrame.Visible
		end 
	end 
end 

function closeMap(key)
	key = key:lower() 
	if key == "v" or key == "e" then 
		if mapFrame then 
			mapFrame.Visible = false 
		end 
	elseif key == "q" then 
		if gameVictoryScreen and guiSet then 
			guiSet = false 
			gameVictoryScreen.Visible = false
		end 
	end 
end 

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if mouse then 
		mouse.KeyDown:connect(showMap)
		mouse.KeyUp:connect(closeMap)
	end 
	
	if vPlayer then 
		local playerGui = vPlayer:FindFirstChild("PlayerGui")
		if playerGui then 
			gameGui = playerGui:FindFirstChild("GameGui")
			if gameGui then 
				mapFrame = gameGui:FindFirstChild("MapFrame")
				gameVictoryScreen = gameGui:FindFirstChild("GameVictoryScreen") 
				gameClassesFrame = gameGui:FindFirstChild("ClassesFrame")
			end 
			local gunGui = playerGui:FindFirstChild("GunHud")
			if gunGui then
				gunCrossHair = gunGui:FindFirstChild("Crosshair")
				if gunCrossHair then 
					gunCrossHair.Visible = true
				end 
			end 
		end 
	end 
end 

function onUnequipped()
	if gunCrossHair then 
		gunCrossHair.Visible = false
	end 
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
