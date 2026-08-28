local Tool = script.Parent
local Tripmine = Tool.Handle

Tool.Enabled = true

local vCharacter

local tripmineClone

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myTorso == nil then 
		return
	end

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then 
		return
	end
	
	tripmineClone = Tripmine:Clone()
	tripmineClone.CanCollide = true 

	Tripmine.Transparency = 1.0

	tripmineClone.Parent = game.Workspace
	
	newScript = Tool.BombScript:Clone()
	newScript.Parent = tripmineClone
	newScript.Disabled = false

	creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = vPlayer
	creatorTag.Name = "creator"
	creatorTag.Parent = tripmineClone
	
	wait(5.0)
	Tripmine.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	Tripmine.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
