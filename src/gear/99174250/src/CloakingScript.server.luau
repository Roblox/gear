local player = script.Parent
local color = player.CloakPart.Value.BrickColor

local hats = {}

local transparentParts = {}

local shirt = player:FindFirstChild("Shirt")
local pants = player:FindFirstChild("Pants")
local bodyColors = player:FindFirstChild("Body Colors"):clone()
local bodyColorsChange = player:FindFirstChild("Body Colors")
local shirtGraphic = player:FindFirstChild("Shirt Graphic")

local head = player:FindFirstChild("Head")
local face = nil
if head ~= nil then
	face = head:FindFirstChild("face")
	face.Parent = nil
end

if shirt ~= nil then
	shirt.Parent = nil
end

if pants ~= nil then
	pants.Parent = nil
end

local torso = player:FindFirstChild("Torso")
local roblox = torso:FindFirstChild("roblox")
if roblox ~= nil then
	roblox.Parent = nil
end
if shirtGraphic ~= nil then
	shirtGraphic.Parent = nil
end

bodyColorsChange.HeadColor = color
bodyColorsChange.LeftArmColor = color
bodyColorsChange.LeftLegColor = color
bodyColorsChange.RightArmColor = color
bodyColorsChange.RightLegColor = color
bodyColorsChange.TorsoColor = color

local parts = player:GetChildren()

for i = 1, #parts do

	if parts[i].className == "Hat" then
		table.insert(hats, parts[i])
		parts[i].Parent = nil
	elseif parts[i].className == "Part" then
		parts[i].Transparency = 0.9
		table.insert(transparentParts,parts[i])
	end

end


wait(20)

bodyColorsChange:remove()
bodyColorsChange = bodyColors
bodyColorsChange.Parent = player

for i = 1, #hats do
	hats[i].Parent = player
end

if shirt ~= nil then
	shirt.Parent = player
end

if pants ~= nil then
	pants.Parent = player
end

if face ~= nil then
	face.Parent = head
end

if roblox ~= nil then
	roblox.Parent = torso
end
if shirtGraphic ~= nil then
	shirtGraphic.Parent = player
end

for i = 1, #transparentParts do
	transparentParts[i].Transparency = 0
end

player.Humanoid.Jump = true

player.CloakPart:remove()
script:remove()
