FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=31046267"
FuseSound.Parent = script.Parent
FuseSound:Play()

local debris = game:GetService("Debris")

local fragment = Instance.new("Part")
fragment.BrickColor = BrickColor.new("Deep blue")
fragment.Material = Enum.Material.Wood
fragment.formFactor = 2
fragment.Size = Vector3.new(1,0.4,1)
fragment.BottomSurface = 0
fragment.TopSurface = 0

local total_time = 5 -- seconds
local cur_time = 0

function update(frac)
	script.Parent.Fuse.Color = Color3.new(1,1 - frac,0)
end

local barrel = script.Parent

function blowUp()
	script.Parent.Explosion:Play()

	for j = 1, 6 do
	
		local barrelPiece = fragment:clone()
		barrelPiece.Position = barrel.Position
		barrelPiece.Parent = game.Workspace
		debris:AddItem(barrelPiece, 10)

	end

	for i = 1, 20 do

		local monkey = barrel.Monkey:clone()
		monkey.Transparency = 0
		monkey.Parent = game.Workspace
		monkey.Position = Vector3.new(barrel.Position.x + math.random(-3,3),barrel.Position.y + math.random(0,3),barrel.Position.z + math.random(-3,3))
		monkey.Velocity = Vector3.new(math.random(-50,50),math.random(0,100),math.random(-50,50))
		
		local monkeyScript = barrel.MonkeyScript:clone()
		monkeyScript.Parent = monkey
		monkeyScript.Disabled = false

	end

	script.Parent.Transparency = 1
end

function onPlayerBlownUp(part, distance, creator)
	if part.Name == "Head" then
		local humanoid = part.Parent.Humanoid
		tagHumanoid(humanoid, creator)
	end
end

function tagHumanoid(humanoid, creator)
	-- tag does not need to expire iff all explosions lethal
	
	if creator ~= nil then
		local new_tag = creator:clone()
		new_tag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

while cur_time < total_time do
	update(cur_time / total_time)
	local e,g = wait(.5)
	cur_time = cur_time + e
end


blowUp()
wait(3)
script.Parent:Destroy()
