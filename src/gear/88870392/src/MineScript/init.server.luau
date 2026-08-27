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

--clean us up after 4 mins or so if we haven't been tripped
game.Debris:AddItem(script.Parent, 60*4)

----------------------------------------

local Mine = script.Parent
local MineScript = WaitFor(Mine).MineScript()
local Creator = WaitFor(MineScript).creator().Value
local ExplodeSound = WaitFor(Mine).ExplodeSound()
local Character = Creator.Character

---------------------------------------

local Handling = false
Mine.Touched:connect(function(part)
	--ignore collisions with firer's stuff
	if Character and part:IsDescendantOf(Character) then return end

	local hum = (part.Parent or game):FindFirstChild('Humanoid')
	if not hum then return end

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
	local tag = MineScript.creator:Clone()
	game.Debris:AddItem(tag, 2)
	tag.Parent = hum
	--
	hum:TakeDamage(60)
	ExplodeSound:Play()
	--and kill their gear if they're holding any
	local ToolToDestroy = nil
	for _, ch in pairs(hum.Parent:GetChildren()) do
		if ch:IsA('Tool') or ch:IsA('HopperBin') then
			ToolToDestroy = ch
		end
	end
	hum:UnequipTools()
	Delay(0, function()
		if ToolToDestroy then ToolToDestroy:Destroy() end
	end)

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

