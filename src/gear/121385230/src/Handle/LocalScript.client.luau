------------------------
--[[UTIL Functions]]--
------------------------
--Global functions used by all classes are wrapped in UTIL
--deal with it.
local UTIL = {}
 
function UTIL.Class(tableIn,template)
        tableIn = tableIn or {}
        local mt = {
        __metatable = UTIL.DeepCopy(template);
        __index     = UTIL.DeepCopy(template);
        }
        return setmetatable(tableIn, mt)
end
function UTIL.MakeClass(...)
        local arg = {...}
        assert(#arg>0, 'ERROR: class needs 1 argument or more')
        local members = arg[1]
        for i=2,#arg,1 do
                if type(arg[i])=='table' then
                        for key,val in pairs(arg[i]) do
                                if not members[key] then
                                        members[key] = val
                                end
                        end
                end
        end
        local function New(init)
                return UTIL.Class(init or {},members)
        end
        local function Copy(obj, ...)
                local newobj = obj:New(unpack(arg))
                for n,v in pairs(obj) do newobj[n] = v end
                return newobj
        end
        members.New  = New
        members.Copy = Copy
        return mt
end
 
function UTIL.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[UTIL.DeepCopy(orig_key)] = UTIL.DeepCopy(orig_value)
        end
        setmetatable(copy, UTIL.DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function UTIL.Instantiate(guiType)
	return function(data)
		local obj = Instance.new(guiType)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end 

function UTIL.RetroRegister(func,...)
	func()
	for _,i in ipairs({...}) do
		i:connect(func)
	end
end

-- Waits for a new character to be added if the current one is invalid
-- (Ensures that you don't have the old dead character after a respawn)
function UTIL.WaitForValidCharacter(player)
	local character = player.Character
	if not character or not character.Parent or not character:FindFirstChild('Humanoid') or character.Humanoid.Health <= 0 then
		player.CharacterAdded:wait()
		wait(0) --NOTE: Necessary for server scripts executing on the same event
		character = player.Character
	end
	return character
end


-- Returns a character ancestor and its Humanoid, or nil
function UTIL.FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return UTIL.FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

UTIL.AssetURL = 'http://www.roblox.com/asset/?id='


UTIL.TouchEnabled = game:GetService("UserInputService").TouchEnabled 
do
	local suceeded,_ =pcall(function() game.Workspace.CurrentCamera:GetPanSpeed() end)
	UTIL.CanCheckPanSpeed = suceeded
end


local DebrisService = Game:GetService('Debris')
local DebugPrintOffset = 0
function UTIL.Dprint(...)
	local line = ''
	for _, segment in pairs({...}) do
		line = line .. (line and ' ' or '') .. tostring(segment)
	end
	local gui = Instance.new('ScreenGui')
	local label = Instance.new('TextLabel')
	label.Text = line
	label.Size = UDim2.new(0.25, 0, 0.05, 0)
	label.BackgroundTransparency = 0.5
	label.Position = UDim2.new(0, 0, 0, DebugPrintOffset)
	label.TextWrapped = true
	label.Parent = gui
	DebrisService:AddItem(gui, 30)
	gui.Parent = script.Parent
	DebugPrintOffset = (DebugPrintOffset <= 600) and DebugPrintOffset + 30 or 0
end
--
--All Welding Related Utility functions should be put here
--
WeldUtil = {}


do


	function WeldUtil.WeldBetween(a, b)
		local weld = Instance.new("Weld")
		weld.Part0 = a
		weld.Part1 = b
		weld.C0 = CFrame.new()
		weld.C1 = b.CFrame:inverse() * a.CFrame

		weld.Parent = a
		return weld
	end
	
	function WeldUtil:PermaWeld(weld)
		local OriginalParent = weld.Parent
		weld.Changed:connect(function()
			Delay(0,function() weld.Parent = OriginalParent end)
		end)
	end

end

local InternalEvent =
{
	Listeners = nil,
}
do
	UTIL.MakeClass(InternalEvent)
	function InternalEvent:Connect(func)
		if not self.Listeners then self.Listeners = {} end
		table.insert(self.Listeners,func)
	end
	function InternalEvent:Fire(...)
		if not self.Listeners then return end
		local args = {...}
		for _,i in ipairs(self.Listeners) do
			Spawn(function() i(unpack(args)) end)
		end
	end
end
local PartProjectile =
{
	Damage = 5, -- Base output damage per shot.
	Range = 250, -- Max distance that the weapon can fire.
	Speed = 1,--how many studs per second to move
	DirectionRay=nil,
	Part = nil,
	StartPos = nil,
	LinearPosition = 0,
	IsAlive = true,
	IgnoreList = {},
	Arching = Vector3.new(0,1,0),--WARNING, if arching is 0, divide by 0 errors, used to arc bullets
	QuadraticA = 0,	--used for arching in equation y = A(x^2)+Bx
	QuadraticB = 0,
	EffectFunction = nil,
}
do
	UTIL.MakeClass(PartProjectile)
	function PartProjectile.New(base,ray)
		local init = nil
		--if base is a copy of this class, then copy over fields
		if type(base) == 'table' and base.Update then
			init = UTIL.DeepCopy(base)
			init.Part= base.Part:Clone()
		else
			init = UTIL.DeepCopy(PartProjectile)
			init.Part = base:Clone()
		end
		init.StartPos = CFrame.new(ray.Origin,ray.Origin+(ray.Direction.unit*math.min(ray.Direction.magnitude,init.Range)))
		init.Part.CFrame = init.StartPos
		init.Part.Parent = game.Workspace
		init.DirectionRay = Ray.new(ray.Origin,(ray.Direction.unit*math.min(ray.Direction.magnitude,init.Range)))
		init.QuadraticA = -((4*init.Arching)/math.pow(init.DirectionRay.Direction.magnitude,2))
		init.QuadraticB = ((4*init.Arching)/init.DirectionRay.Direction.magnitude)
		init.LinearPosition = 0
		table.insert(init.IgnoreList,init.Part)
		return init
	end
	
	function PartProjectile:Hit(part)
		local char,hum = UTIL.FindCharacterAncestor(part)
		
		if hum then
			hum:TakeDamage(self.Damage)
			if self.EffectFunction then
				self.EffectFunction(hum,part)
			end
		end
		self.IsAlive = false
	end
	
	function PartProjectile:Update(dt)
		if not self.IsAlive then return end
		
		self.LinearPosition = self.LinearPosition + ((self.Speed*dt)/(self.Arching.magnitude/(self.DirectionRay.Direction.magnitude*.5)))
		
		local oldPos = self.Part.CFrame
		
		self.Part.CFrame = (self.StartPos+(self.DirectionRay.Direction.unit*self.LinearPosition))+(self.QuadraticA*math.pow(self.LinearPosition,2))+(self.QuadraticB*self.LinearPosition)
		
		if (self.Part.CFrame.p-self.DirectionRay.Origin).magnitude>self.Range then
			self.IsAlive = false
		end
		local obj = game.Workspace:FindPartOnRayWithIgnoreList( Ray.new(oldPos.p,self.Part.CFrame.p-oldPos.p), self.IgnoreList,false )
		if obj then
			self:Hit(obj)
		end
		
	end
	
	function PartProjectile:Destroy()
		self.Part.Parent = nil
	end
	
end

--[[shooting Tool Class]]--
	
local ShootingTool =
{
	FireRate = .5, -- How often the weapon can fire.
	Automatic = false, -- hold down to continue firing
	Spread = 0, -- The bigger the spread, the more inaccurate the shots will be.
	ClipSize = 50, -- Shots in a clip
	ReloadTime = 3, -- Time it takes to reload the tool.
	StartingClips = -1,
	BarrelPos = CFrame.new(0, 0, - 1.2), -- L, F, U
	
	SourcePart = nil,
	TemplateProjectile = nil,
	Projectiles = {},
	IsFireing = false,
	
	OnFire = nil,
	OnReload = nil,
	
	BulletsLeft = 50,
	
	LastReload = 0,
	
	FireSound = nil,
	
}
do
	UTIL.MakeClass(ShootingTool)
	function ShootingTool.New(nSource,nProjectile)
		local init= UTIL.DeepCopy(ShootingTool)
		init.SourcePart= nSource
		init.TemplateProjectile = nProjectile
		init.OnFire = InternalEvent.New()
		init.OnReload = InternalEvent.New()
		return init
	end
	
	function ShootingTool:UpdateBullets(dt)
		for index,i in ipairs(self.Projectiles) do
			if i.IsAlive then 
				i:Update(dt) 
			else
				i:Destroy()
				table.remove(self.Projectiles, index)
			end
		end
	end
	
	function ShootingTool:StartFireing(mouse)
		if tick()-self.LastReload<self.ReloadTime then return end
		while self.IsFireing do wait() end
		self.IsFireing = true
		repeat
			if tick()-self.LastReload>self.ReloadTime then
				local startPos = self.SourcePart.CFrame:toWorldSpace(self.BarrelPos)
				local dir = CFrame.Angles((math.random()-.5)*2*self.Spread,(math.random()-.5)*2*self.Spread,(math.random()-.5)*2*self.Spread)*(mouse.Hit.p-startPos.p)
				local nprojectile = PartProjectile.New(self.TemplateProjectile, Ray.new(startPos.p,dir))
				
				table.insert(self.Projectiles,nprojectile)
				self.OnFire:Fire()
				if self.FireSound then
					self.FireSound:Play()
				end
				self.BulletsLeft = self.BulletsLeft -1
			end
			if self.BulletsLeft==0 then
				self.OnReload:Fire()
				self.BulletsLeft = self.ClipSize
				self.LastReload = tick()
			end
			wait(self.FireRate)
		until not self.IsFireing or not self.Automatic
	end
	
	function ShootingTool:EndFireing()
		self.IsFireing=false
	end
	
end
do
	local Handle = script.Parent
	local Tool = Handle.Parent
	
	
	local Player = game.Players.LocalPlayer
	local Character = UTIL.WaitForValidCharacter(Player)
	local HoldAni = UTIL.Instantiate"Animation"
	{AnimationId = "http://www.roblox.com/Asset?ID=94242777"}
	local ReloadAni = UTIL.Instantiate"Animation"
	{AnimationId = "http://www.roblox.com/Asset?ID=94245658"}
	
	local HoldAniTrack
	local ReloadAniTrack
	local ShellMesh = UTIL.Instantiate"SpecialMesh"
	{
		MeshId = UTIL.AssetURL..121554296,
		TextureId = UTIL.AssetURL..121554262,
		Scale = Vector3.new(.3,.3,.3),
	}
	local Projectile
	do
		local tpart = UTIL.Instantiate"Part"
		{
			Anchored = true,
			CanCollide = false,
			Size = Vector3.new(.2,.2,.6),
			ShellMesh:Clone(),
		}
		Projectile = PartProjectile.New(tpart,Ray.new())
	end 
	table.insert(Projectile.IgnoreList,Handle)
	
	Projectile.Speed = 20
	Projectile.Arching = Vector3.new(0,5,0)
	
	Projectile.EffectFunction = function(hum,part)
		Spawn(function()
			if (not (hum.Parent and hum.Parent:FindFirstChild('Torso'))) or hum.Parent.Torso:FindFirstChild('SMELL_GUI') then
				return
			end
			local bgui = UTIL.Instantiate"BillboardGui"
			{
				Name = 'SMELL_GUI',
				Size = UDim2.new(10,0,10,0),
				StudsOffset = Vector3.new(0,0,1),
				SizeOffset = Vector2.new(0,.7),
				Adornee = hum.Parent.Torso,
				Parent = hum.Parent.Torso,
			}
			
			local tempSmell = UTIL.Instantiate"ImageLabel"
			{
				Image = "http://www.roblox.com/Asset?ID=121574448",
				Size = UDim2.new(.1,0,.3,0),
				BackgroundTransparency = 1,
			}
			
			for i=0,10,1 do
				hum:TakeDamage(5)
				local t = tempSmell:Clone()
				local ypos = (math.random()*.2)+.7
				local xpos = (math.random()*.5)+.2
				t.Position = UDim2.new(xpos,0,ypos,0)
				t.Parent = bgui
				Spawn(function()
					local startTime = tick()
					while tick()-startTime<3 do
						ypos=ypos-.01
						t.Position = UDim2.new(xpos,0,ypos,0)
						wait()
					end
					t:Destroy()
				end)
				wait(1+math.random())
			end
			wait(3)
			bgui:Destroy()
		end)
		
	end
	
	local Gun = ShootingTool.New(Handle,Projectile)
	Gun.Automatic = false
	Gun.BarrelPos = CFrame.new(0, 0, - 3.1)
	Gun.FireRate = 1
	Gun.Spread = .05
	Gun.ClipSize = 2
	Gun.BulletsLeft = 2
	Gun.ReloadTime = 1.5
	Gun.FireSound  = Handle:WaitForChild('FireSound')
	
	Gun.OnFire:Connect(function()

	end)
	
	Gun.OnReload:Connect(function()
		if ReloadAniTrack then
			ReloadAniTrack:Play(.1,1,.2)
		end
		wait(3)

	end)
	
	Tool.Equipped:connect(function(mouse)
		
		Character = UTIL.WaitForValidCharacter(Player)
		local Humanoid = Character:FindFirstChild('Humanoid')
		table.insert(Projectile.IgnoreList,Character)
		HoldAniTrack = Humanoid:LoadAnimation(HoldAni)
		ReloadAniTrack = Humanoid:LoadAnimation(ReloadAni)
		HoldAniTrack:Play()
		mouse.Button1Down:connect(function()
			Gun:StartFireing(mouse)
		end)
		mouse.Button1Up:connect(function()
			Gun:EndFireing()
		end)
	end)
	Tool.Unequipped:connect(function()
		HoldAniTrack:Stop()
	end)
	while true do
		Gun:UpdateBullets(1/30)
		wait()
	end

end
