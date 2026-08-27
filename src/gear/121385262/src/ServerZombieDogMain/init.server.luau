local ZombieDog = script.Parent
--
local Player = script:WaitForChild('Creator')
while not Player.Value do Player.Changed:wait() end
Player = Player.Value

if not Player.Character or 
	not Player.Character:FindFirstChild('Humanoid') 
	or Player.Character.Humanoid.Health <= 0 
	or not ZombieDog:FindFirstChild('Humanoid')
then
	ZombieDog:Destroy()
	return
end

local MyHumanoid = ZombieDog.Humanoid
local PlayerHumanoid = Player.Character.Humanoid

MyHumanoid.Died:connect(function()
	wait(0.5)
	ZombieDog:Destroy()
end)
PlayerHumanoid.Died:connect(function()
	MyHumanoid.Health = 0
end)
Player.Changed:connect(function(pr)
	if pr == 'Parent' then
		MyHumanoid.Health = 0
	end
end)

local PoisonScript = ZombieDog:WaitForChild('PoisonScript')

ZombieDog:WaitForChild('Torso').Touched:connect(function(part)
	if part.Parent and part.Parent:FindFirstChild('Humanoid') and 
		part.Parent:FindFirstChild('Torso') and 
		not part.Parent:FindFirstChild('PoisonScript') and
		part.Parent:FindFirstChild('Humanoid') ~= Player.Character:FindFirstChild('Humanoid')
	then
		local poison = PoisonScript:Clone()
		poison.Disabled = false
		poison.Parent = part.Parent
	end
end)