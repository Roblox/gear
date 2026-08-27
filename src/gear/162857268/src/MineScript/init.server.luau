------------------------------------------
local function WaitFor(parent)
	return setmetatable({}, {
		__index = function(tb, child)
			return function()
				while not parent:FindFirstChild(child) do 
					parent.ChildAdded:wait()
				end
				return parent:FindFirstChild(child)			
			end
		end;
	})
end
----------------------------------------

--clean us up after 30 secs if we haven't exploded
game.Debris:AddItem(script.Parent, 30)

----------------------------------------

local Mine = script.Parent
local MineScript = WaitFor(Mine).MineScript()
local CreatorValue = WaitFor(MineScript).creator()
while not CreatorValue.Value do wait() end
local Creator = CreatorValue.Value
local ExplodeSound = WaitFor(Mine).ExplodeSound()
local Character = Creator.Character

---------------------------------------

local Handling = false
Mine.Touched:connect(function(part)
	--ignore collisions with firer's stuff
	if Character and part:IsDescendantOf(Character) then return end

	if Handling then return end
	Handling = true

	--end Mine
	Mine.Anchored = true
	Mine.CanCollide = false
	Mine.Transparency = 1

	--do explode
	local BlastPart = Instance.new('Part', game.Workspace)
	BlastPart.FormFactor = 'Custom'
	BlastPart.Size = Vector3.new(1,1,1)
	BlastPart.Transparency = 0.3
	BlastPart.Anchored = true
	BlastPart.CanCollide = false
	BlastPart.CFrame = CFrame.new(Mine.Position)*CFrame.Angles(-math.pi/2,0,0)
	local BlastCFrame = CFrame.new(Mine.Position)*CFrame.Angles(-math.pi/2,0,0)
	local BlastMesh = Instance.new('SpecialMesh', BlastPart)
	BlastMesh.MeshId = 'http://www.roblox.com/asset/?id=1080954'
	BlastMesh.TextureId = 'http://www.roblox.com/asset/?id=37856148'
	game.Debris:AddItem(BlastPart, 10)

	--damage the humanoid
	local reg = Region3.new(Mine.Position - Vector3.new(7,7,7), Mine.Position + Vector3.new(7,7,7))
	local parts = game.Workspace:FindPartsInRegion3(reg, Character)
	local damagedMap = {}
	for _, part in pairs(parts) do
		if (Mine.Position-part.Position).magnitude < 7 then
			local hum = (part.Parent or game):FindFirstChild('Humanoid')
			if hum and not damagedMap[hum] then
				damagedMap[hum] = true
				local tag = MineScript.creator:Clone()
				game.Debris:AddItem(tag, 2)
				tag.Parent = hum
				--
				hum:TakeDamage(100)
			end
		end
	end
	
	ExplodeSound:Play()

	--display a blast
	for i = 0, 1, 0.2 do
		wait()
		BlastPart.CFrame = CFrame.new(0, math.sqrt(i)*5,0)*BlastCFrame
		BlastMesh.Scale = Vector3.new(2 + 2*i, 2 + 2*i, 2 + math.sqrt(i)*12)
	end
	for i = 0, 1, 0.1 do
		wait()
		BlastPart.CFrame = CFrame.new(0,5 - i*i*2,0)*BlastCFrame
		BlastMesh.Scale = Vector3.new(4 + i*1, 4 + i*1, 14 - i*i*4)
		BlastPart.Transparency = 0.3 + 0.7*i*i
	end
	BlastPart:Destroy()

	wait(1) --let sound wind down for a bit

	--and finally get rid of us
	Mine:Destroy()
end)

