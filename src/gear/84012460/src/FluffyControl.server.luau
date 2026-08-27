--Fluffy Tool Control Script

local Tool = script.Parent
local FluffyHandle = Tool.Handle

local FluffyInstance = nil

local DiedEvent = nil

local Character = nil

--Destroy Fluffy.  
function DestroyFluffy()
		if not FluffyInstance then return end
		FluffyInstance:Destroy()
		FluffyInstance = nil
		FluffyHandle.Transparency = 0

end


--Create a new Fluffy
function CreateFluffy()
		if FluffyInstance then return end

		--Create a new Part for Fluffy
		FluffyInstance = FluffyHandle:Clone()
		FluffyInstance.Parent = Character.Head
		FluffyInstance.Anchored = true
		FluffyInstance.Name = "Fluffy"

		--Display Fluffy's sparkles
		local FluffySparkles = Instance.new("Sparkles")
		FluffySparkles.Parent = FluffyInstance
		FluffySparkles.SparkleColor = Color3.new(1,0,1)
		FluffySparkles.Name = "FluffyTrail"

		--Tell Fluffy to orbit
		local FluffyAI = FluffyHandle.Parent.FluffyAIControl:Clone()
		FluffyAI.Parent = FluffyInstance
		FluffyAI.Disabled = false
		
		FluffyHandle.Transparency = 1.0
	


end

function onActivated()

		if(Character == nil) then 
			print("Character Nil!")
			return 
		end
		if Tool.Enabled == false then 
			print("Tool Not Ready!")
			return 
		end
			
		
		if FluffyInstance then 
			DestroyFluffy() -- DUN DUN DAAA DAAAA
			return 
		end
		
		Tool.Enabled = false
		
		CreateFluffy()

		Tool.Enabled = true
end

function onEquipped()
	Character = Tool.Parent
	Tool.Enabled = true
	DiedEvent = Character.Humanoid.Died:connect(onControllerDied)
end

function onUnequipped()
	Tool.Enabled = false
	if DiedEvent then
		DiedEvent:Disconnect()
	end
	Character = nil
	
end


function onControllerDied()
	DestroyFluffy() --NOOOOOOOOOOOOOOOOOOOOOOO!!!!!


end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
