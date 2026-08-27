function WaitForChild(parent,child) 
	while not parent:FindFirstChild(child) do
		wait() print('waiting for ' .. child)
	end
	return parent[child]
end

local ProjectileScript = WaitForChild(script.Parent,'IncinerateServer')

local Gravity = (-9.81*20)

local NumAimLines = 10
local ArcHeight = 10
local ArcDistance = 20

local AimCycleLength = 3

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')
local firesound = WaitForChild(Handle,'Sound')
local Player = game.Players.LocalPlayer
local pmouse = Player:GetMouse()
local MouseDown = Instance.new('BoolValue')
MouseDown.Value = false

local UpdateAimLines = false

local AimLines = {}

function MakeProjectile()
	local tpart = Instance.new('Part')
	tpart.Name = 'Effect'
	tpart.Size = Vector3.new(1,1,1)
	tpart.CanCollide = false
	local tmesh = Instance.new('SpecialMesh')
	tmesh.Parent = tpart
	tmesh.Scale = Vector3.new(.25,.25,.25)
	tmesh.MeshId = 'http://www.roblox.com/asset/?id=94736101'
	tmesh.TextureId = 'http://www.roblox.com/asset/?id=102496105'
	tmesh.VertexColor = Vector3.new(2,1,1)
	local tfire = Instance.new('Fire')
	tfire.Parent = tpart
	--[[
	local tpart2 = Instance.new('Part')
	tpart2.Name = 'Effect'
	tpart2.Parent = tpart
	tpart2.Size = Vector3.new(.2,.2,.2)
	tpart2.CFrame = tpart.CFrame + Vector3.new(0,0,-.2)
	tpart2.CanCollide = false
	tpart2.Transparency = .5
	
	local tweld = Instance.new("Weld")
	tweld.Part0 = tpart
	tweld.Part1 = tpart2
	tweld.C0 = CFrame.new()
	tweld.C1 = tpart2.CFrame:inverse() * tpart.CFrame
	tweld.Parent = tpart
	--]]
	return tpart
end

function InitAimLines()
	if #AimLines>0 then return end
	for i=1,10,1 do
		local tpart = Instance.new('Part')
		tpart.Name = 'Effect'
		tpart.FormFactor = 'Custom'
		tpart.Size = Vector3.new(.4,.4,.4)
		tpart.Transparency = .5
		tpart.Anchored = true
		tpart.CanCollide = false
		tpart.Parent= Tool
		table.insert(AimLines,tpart)
	end
end

local CanFire = true

function ClickDown(mouse)
	if CanFire then
		MouseDown.Value = true
		

		UpdateAimLines = true
		Spawn(UpdateAim) 

		Spawn(function()
			local startTime = tick()
			while MouseDown.Value do
				local alpha = math.min(((tick()-startTime)/AimCycleLength),1)
				ArcDistance = 3+(alpha*30)
				ArcHeight = -(alpha*10)+15
				wait(1/30)
			end
		end)
	end
end

function ClickUp(mouse)
	if CanFire then
		firesound:play()
		CanFire = false
		MouseDown.Value = false
		UpdateAimLines = false
		--do fireing code
		local proj = MakeProjectile()
		proj.CanCollide = false
		proj.Anchored =true
		proj.Parent = Workspace
		local tscript = ProjectileScript:Clone()
		tscript.Parent= proj
		Delay(.2,function() tscript.Disabled = false end)
		proj.CFrame = Handle.CFrame
		--print(ArcHeight)
		local direction = Handle.CFrame.p-AimLines[1].CFrame.p
		direction = CFrame.new(Vector3.new(),Vector3.new(direction.x,0,direction.z).unit)
		local yvel = math.sqrt(math.abs(ArcHeight*Gravity*2))
		local xvel = (ArcDistance*2)/((yvel/Gravity)*2)
		proj.Velocity = Vector3.new(0,yvel,0)+(direction*CFrame.new(Vector3.new(0,0,-xvel))).p	
		proj.Anchored=false
		--game.Debris:AddItem(proj,5)
		wait(1)
		print('click up')
		CanFire = true
	end
end

function UpdateAim()
	
	while UpdateAimLines do
		--print('updating aim lines')
		local initpoint =Handle.CFrame.p
		local target = pmouse.Hit.p
		local direction = (initpoint-target)
		direction = CFrame.new(Vector3.new(),Vector3.new(direction.x,0,direction.z).unit)
		local arcConst = ArcHeight/(ArcDistance*ArcDistance)
		for i=1,#AimLines,1 do
			local xpos =(((ArcDistance*2)/#AimLines)*i)- ArcDistance
			AimLines[i].Transparency =0
			AimLines[i].CFrame = (direction*CFrame.new(Vector3.new(0,(-arcConst*math.pow(xpos,2))+ArcHeight,xpos+ArcDistance)))+initpoint
		end
		wait(1/30)
	end

	for _, i in pairs(AimLines) do
		i.Transparency =1
	end
end

local isequipped = false

function OnEquipped(nmouse)
	if not isequipped then
		isequipped = true
		local mouse = Player:GetMouse()
		mouse.Button1Down:connect(function() ClickDown(mouse) end)
		mouse.Button1Up:connect(function() ClickUp(mouse) end)
		--mouse.Icon = 
		InitAimLines()
		
		print('finished init')
	end
	
end

function OnUnequipped()
	if isequipped then
		isequipped = false
		CanFire = true
		print('unequipped called')
		MouseDown.Value = false
		Tool.Enabled = true
		UpdateAimLines = false
		for _,i in pairs(AimLines) do
			i:Destroy()
		end
		AimLines = {}
	end
end

script.Parent.Equipped:connect(OnEquipped)

script.Parent.Unequipped:connect(OnUnequipped)
