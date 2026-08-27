local CreatorSnowman = script.Parent.CreatorSnowman.Value
local CreatorPlayer = CreatorSnowman.SnowmanOwner.Value

function TagHumanoid(humanoid)
	local tag = Instance.new('ObjectValue')
	tag.Name = "creator" 
	tag.Value = CreatorPlayer
	tag.Parent = humanoid
end
function UntagHumanoid(humanoid)
	if humanoid:FindFirstChild("creator") then
		humanoid.creator.Parent = nil
	end
end

local DamageToDo = 20

script.Parent.Touched:connect(function(part)
	--ignore touching the creator itself
	if not part:IsDescendantOf(CreatorSnowman) then
		local hum = (part.Parent or game):FindFirstChild('Humanoid')
		--catch hats and handles too
		hum = hum or ((part.Parent or game).Parent or game):FindFirstChild('Humanoid')

		if hum then
			--inflict damage
			TagHumanoid(hum)
			hum:TakeDamage(DamageToDo)
			Delay(0.1, function()
				UntagHumanoid(hum)
			end)
		end
		script.Parent.Parent = nil
	end
end)

local FlightTime = 2
for t = 0, FlightTime, 0.1 do
	wait(0.1)
	local fracLeft = (1-t/FlightTime)
	script.Parent.Size = Vector3.new(0.8, 0.8, 0.8)*fracLeft
	script.Parent.Mesh.Scale = Vector3.new(fracLeft, fracLeft, fracLeft)
	DamageToDo = 20*fracLeft
end

script.Parent.Parent = nil