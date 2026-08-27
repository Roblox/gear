--Wait for the bass

local Tool = script.Parent
local Wubstep = nil

local Character 
local Player 
local Torso 
local Humanoid

local AOE = 15 
local DubstepLength = 12
local AreaQueryInterval = 1

local dt = 0

function DestroyBoombox()
	if not Wubstep then 
		print("Cannot destroy boombox when boombox doesn't exist")
		return 
	end
	--Who ever wants to stop?
	Wubstep:Destroy()
	Wubstep = nil
	Tool.Handle.Transparency = 0
	dt = 0
end

function CreateBoombox()
	if Wubstep then 
		print("Cannot create boombox when boombox exists")
		return 
	end
	--Drop the bass
	Wubstep = Tool.Handle:Clone()
	Wubstep.Parent = game.Workspace
	Wubstep.CanCollide = true
	
	--Play the sweet sounds of the gods
	local WubSound = Tool.WubWub:Clone()
	WubSound.Parent = Wubstep
	WubSound:Play()

	--Loop through all the players and tell them to get their boogy on
	Spawn(function() 
		while Wubstep do 
			local Players = game.Players:GetPlayers() 
			for i = 1, #Players do 
				if Players[i] and Players[i] ~= Player 
						and Players[i].Character and Players[i].Character:FindFirstChild('Torso') then 
					local distance = (Wubstep.Position - Players[i].Character.Torso.Position).magnitude 
					if distance < AOE and (not Players[i].Character:FindFirstChild('DanceScript')) then 
						local dScript = script.DanceScript:Clone()
						dScript.Parent = Players[i].Character
						dScript.Disabled = false 
					end 			
				end 
			end 
			if(dt >= DubstepLength) then DestroyBoombox() end
			dt = dt + wait(AreaQueryInterval) 
			
		end 
	end) 

	Tool.Handle.Transparency = 1
end


function onActivate()
	if(not Tool.Enabled) then 
		print("Tool not enabled")
		return
	end
	--If the boombox is out, Drop it.  If it's not, pull it back in
	Tool.Enabled = false
	if(Wubstep) then
		print("Destroying Boombox")
		DestroyBoombox()
	else
		print("Creating Boombox")
		CreateBoombox()
	end
	Tool.Enabled = true
end


function onEquip()
	Tool.Enabled = true
	Character = Tool.Parent 
	Player = game.Players:GetPlayerFromCharacter(Character)
	
	Torso = Character:FindFirstChild('Torso')
	Humanoid = Character:FindFirstChild('Humanoid')
end

function onUnequip()
	Tool.Enabled = false

end

Tool.Activated:connect(onActivate)
Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)



