local debris = game:service("Debris")
pellet = script.Parent
damage = 8

local Base = Instance.new("Part")
Base.Name = "XMASBase"
Base.BackSurface = "Smooth"
Base.BottomSurface = "Smooth"
Base.FrontSurface = "Smooth"
Base.LeftSurface = 0
Base.RightSurface = 0
Base.TopSurface = "Smooth"
Base.Shape = 1
Base.Size = Vector3.new(2,3.2,2) --4,3,4
Base.BrickColor = BrickColor.new(192)
Base.Locked = true
Base.Material = "Wood"


local Branch = Instance.new("Part")
Branch.Name = "XMAS"
Branch.Material = "Plastic"
Branch.BrickColor = BrickColor.new(37)
Branch.Material = "Grass"
Branch.BackSurface = "Smooth"
Branch.BottomSurface = "Smooth"
Branch.FrontSurface = "Smooth"
Branch.LeftSurface = "Smooth"
Branch.RightSurface = "Smooth"
Branch.TopSurface = "Smooth"
Branch.Shape = 1
Branch.Locked = true


function onTouched(hit)
	--[[humanoid = hit.Parent:findFirstChild("Humanoid")
	if humanoid~=nil then
		tagHumanoid(humanoid)
		humanoid:TakeDamage(damage)
	else
		damage = damage / 2
		if damage < 1 then
			connection:disconnect()
			pellet.Parent = nil
		end
	end
	--]]

	local tree = Instance.new("Model")


	local bottom = Base:clone()
	bottom.Position = pellet.Position  + Vector3.new(0,1,0)
	bottom.Parent = tree
	tree.Parent = game.Workspace


	local level = Branch:clone()
	level.Size = Vector3.new(9,1.4, 9)  --13
	level.Position = bottom.Position --+ Vector3.new(0,2,0)
	level.Parent = tree

	
	w2 = Instance.new("Weld")
	w2.Name = "treeWeld" 
	w2.Part0 = bottom
	w2.Part1 = level
	w2.C0 = CFrame.new(0,0,0)
	w2.C1 = CFrame.new(0,-1.4,0)
	w2.Parent = game.Workspace

	buildBlocks = {}
	buildBlocks[0] = level

	for i=1,7 do
		buildBlock = Branch:clone()
		buildBlock.Size = Vector3.new(9- (1*i),1.4,9-(1*i))
		buildBlock.Position = level.Position + Vector3.new(0,1.4,0)
		buildBlock.Parent = tree
		buildBlocks[i] = buildBlock
		

		treeWeld = Instance.new("Weld")
		treeWeld.Name = "treeWeld"
		treeWeld.Part0 = buildBlocks[i-1]
		treeWeld.Part1 = buildBlocks[i]
		treeWeld.C0 = CFrame.new(0,0,0)
		treeWeld.C1 = CFrame.new(0,-1.2,0)
		treeWeld.Parent = game.Workspace

	end

	debris:AddItem(tree, 300)

	pellet.Parent = nil
end



connection = pellet.Touched:connect(onTouched)

r = game:service("RunService")
t, s = r.Stepped:wait()
d = t + 2.0 - s
while t < d do
	t = r.Stepped:wait()
end

pellet.Parent = nil