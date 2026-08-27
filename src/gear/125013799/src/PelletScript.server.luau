local debris = game:GetService("Debris")
local pellet = script.Parent
local startingDamage = 14
local damage = startingDamage
local LastHitCharacter

local CreatorTag = pellet:WaitForChild('creator')

function tagHumanoid(humanoid)
	while humanoid:FindFirstChild('creator') do
		humanoid.creator:Destroy()
	end
	local myTag = CreatorTag:Clone()
	debris:AddItem(myTag, 4)
	myTag.Parent = humanoid
end

function onTouched(hit)
	if not (hit and hit.Name ~= 'Handle' and hit.Parent) then return end
	humanoid = hit.Parent:findFirstChild("Humanoid")
	if humanoid~=nil and humanoid.Parent ~= LastHitCharacter then
		if startingDamage == damage and game.Players:playerFromCharacter(hit.Parent) == CreatorTag.Value then 
			return 
		end
		LastHitCharacter = humanoid.Parent
		tagHumanoid(humanoid)
		humanoid:TakeDamage(damage)
	else
		if hit.CanCollide == false then return end
		damage = damage / 1.42
		if damage < 1 then
			connection:disconnect()
			pellet.Parent = nil
		end
	end
end

connection = pellet.Touched:connect(onTouched)
