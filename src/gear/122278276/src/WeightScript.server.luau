local Model = script.Parent

game.Debris:AddItem(Model, 3)

local CreatorTag = script:WaitForChild('creator')
while not CreatorTag.Value do CreatorTag.Changed:wait() end 
local Creator = CreatorTag.Value
local Character = Creator.Character

local Handle = Model:WaitForChild('Handle')
local EndOne = Model:WaitForChild('EndOne')
local EndTwo = Model:WaitForChild('EndTwo')

local Mover = Handle:WaitForChild('Mover')
game.Debris:AddItem(Mover, 0.1)

Spawn(function()
	wait(0.1)
	EndOne.CanCollide = true
	EndTwo.CanCollide = true
	wait(0.1)
	Handle.CanCollide = true
end)

local SOUND_HitGround = Handle:WaitForChild('SOUND_HitGround')

function TouchedHandler(part)
	if Character and part:IsDescendantOf(Character) then return end
	local hum = (part.Parent or game):FindFirstChild('Humanoid')
	if not hum then
		hum = ((part.Parent or game).Parent or game):FindFirstChild('Humanoid')
	end
	if hum then
		hum.Sit = true
		local tag = CreatorTag:Clone()
		game.Debris:AddItem(tag, 0.5)
		hum:TakeDamage(16)
	else
		SOUND_HitGround:Play()
	end
end

Handle.Touched:connect(TouchedHandler)
EndOne.Touched:connect(TouchedHandler)
EndTwo.Touched:connect(TouchedHandler)