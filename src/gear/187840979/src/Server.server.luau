local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")
local PenguinAi = Tool:WaitForChild("PenguinAi")
local TargetPosition = Tool:WaitForChild("TargetPosition")

local PenguinDamage = 15
local PenguinTime = 15

local PenguinsNumber = 5
local PenguinsMax = 8
local PenguinsReloadTime = 2

function onEquipped()
	onUnequipped()
end

function onUnequipped()
	
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function createPenguin(position)
	local penguin = Handle:Clone()
	penguin.Name = "Penguin"
	penguin.CFrame = CFrame.new(position) * CFrame.Angles(0, math.pi * 2 * math.random(), 0) + Vector3.new(0, penguin.Size.Y/2, 0)
	penguin.CanCollide = true
	
	local toolPointer = Instance.new("ObjectValue")
	toolPointer.Name = "ToolPointer"
	toolPointer.Value = Tool
	toolPointer.Parent = penguin
	
	local damage = Instance.new("NumberValue")
	damage.Name = "Damage"
	damage.Value = PenguinDamage
	damage.Parent = penguin
	
	local player = Instance.new("ObjectValue")
	player.Name = "Player"
	player.Value = getPlayer()
	player.Parent = penguin
	
	local ai = PenguinAi:Clone()
	ai.Disabled = false
	ai.Parent = penguin
	
	penguin.Parent = workspace
	
	game:GetService("Debris"):AddItem(penguin, PenguinTime)
end

function onActivate(position)
	TargetPosition.Value = position
	
	if PenguinsNumber > 0 then
		createPenguin(Handle.Position)
		
		PenguinsNumber = PenguinsNumber - 1
		penguinsNumberUpdated()
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		onActivate(...)
	end
end

function penguinsNumberUpdated()
	if PenguinsNumber <= 0 then
		Handle.Transparency = 1
	else
		Handle.Transparency = 0
	end
end

function reloadPenguin()
	PenguinsNumber = math.min(PenguinsNumber + 1, PenguinsMax)
	penguinsNumberUpdated()
	delay(PenguinsReloadTime, reloadPenguin)
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnServerEvent:connect(onRemote)
reloadPenguin()
