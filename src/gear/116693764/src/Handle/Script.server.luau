------------------------
--[[UTIL Functions]]--
------------------------
--Global functions used by all classes are wrapped in UTIL
--deal with it.
local UTIL = {}
local GLib = require(206209239)
 
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


	function WeldUtil:WeldBetween(a, b)
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
	IsAlive = true,
	IgnoreList = {},
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
		init.Part.CFrame = CFrame.new(ray.Origin,ray.Origin+ray.Direction)
		init.Part.Parent = game.Workspace
		init.DirectionRay = ray
		table.insert(init.IgnoreList,init.Part)
		return init
	end
	
	function PartProjectile:Hit(part)
		local char,hum = UTIL.FindCharacterAncestor(part)
		
		if hum and not GLib.IsTeammate(GLib.GetPlayerFromPart(script), GLib.GetPlayerFromPart(hum)) then
			GLib.TagHumanoid(GLib.GetPlayerFromPart(script), hum, 1)
			hum:TakeDamage(self.Damage)
		end
		self.IsAlive = false
	end
	
	function PartProjectile:Update(dt)
		if not self.IsAlive then return end
		local oldPos = self.Part.CFrame
		self.Part.CFrame = oldPos+(self.DirectionRay.Direction*self.Speed*dt)
		if (self.Part.CFrame.p-self.DirectionRay.Origin).magnitude>self.Range then
			self.IsAlive = false
		end
		local obj = game.Workspace:FindPartOnRayWithIgnoreList( Ray.new(oldPos.p,self.DirectionRay.Direction*self.Speed*dt), self.IgnoreList,false )
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
	
	function ShootingTool:StartFireing()
		if tick()-self.LastReload<self.ReloadTime then return end
		while self.IsFireing do wait() end
		self.IsFireing = true
		repeat
			if tick()-self.LastReload>self.ReloadTime and Gun.MousePos then
				local startPos = self.SourcePart.CFrame:toWorldSpace(self.BarrelPos)
				local dir = (CFrame.Angles((math.random()-.5)*2*self.Spread,(math.random()-.5)*2*self.Spread,(math.random()-.5)*2*self.Spread)*CFrame.new((Gun.MousePos-startPos.p).unit)).p
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
	
	local BarrelClip = UTIL.Instantiate"Part"
	{
		Size = Vector3.new(0.2, 0.2, 0.32),
		UTIL.Instantiate'SpecialMesh'
		{
			TextureId = "http://www.roblox.com/asset/?id=116679995",
			MeshId = "http://www.roblox.com/asset/?id=116740155",
			Scale = Vector3.new(0.9, 0.9, 0.9),
		},
		CanCollide = false,
		Parent = Tool
	}
	
	local BarrelWeld = UTIL.Instantiate"Weld"
	{
		C1 = CFrame.new(0.0183372498, 0.378660202, 0.237049103, 0.00777955074, 0.0069010579, 0.999946177, -0.0223222617, 0.999727845, -0.00672559161, -0.999720693, -0.0222686939, 0.00793197285),
		C0 = CFrame.new(0, 0, 0, 0.00777955074, 0.0069010579, 0.999946177, -0.0223222617, 0.999727845, -0.00672559161, -0.999720693, -0.0222686939, 0.00793197285),
		Part0 = Handle,
		Part1 = BarrelClip,
		Parent = Handle,
	}
	WeldUtil:PermaWeld(BarrelWeld)
	
	local OrangeLight = Handle:WaitForChild('OrangeLight')
	local RedLight = Handle:WaitForChild('RedLight')
	local SpotLight = Handle:WaitForChild('SpotLight')
	
	
	local ShellMesh = UTIL.Instantiate"SpecialMesh"
	{
		MeshId = UTIL.AssetURL..94295100,--116680945,
		TextureId = UTIL.AssetURL..94287792,--116681256,
		Scale = Vector3.new(2.8,2.8,5),
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
	
	Projectile.Speed = 200
	Gun = ShootingTool.New(Handle,Projectile)
	Gun.Automatic = true
	Gun.BarrelPos = CFrame.new(0, 0, - 3.1)
	Gun.FireRate = .05
	Gun.Spread = .1
	Gun.FireSound  = Handle:WaitForChild('FireSound')
	
	local HoldAniTrack
	local ReloadAniTrack
	Gun.OnFire:Connect(function()
		SpotLight.Enabled = true
		if(math.random()>.5) then
			OrangeLight.Enabled =true
		else
			RedLight.Enabled =true
		end
		wait(.05)
		SpotLight.Enabled = false
		OrangeLight.Enabled =false
		RedLight.Enabled =false
	end)
	
	Gun.OnReload:Connect(function()
		local leftArm = script.Parent.Parent.Parent:FindFirstChild('Left Arm')
		if not leftArm then return end
		local reloadBarrel = BarrelClip:Clone()
		reloadBarrel.Parent = Tool
		local tweld=WeldUtil:WeldBetween(reloadBarrel,leftArm)
		BarrelClip.Transparency = 1
		if ReloadAniTrack then
			ReloadAniTrack:Play()
		end
		wait(3)
		reloadBarrel:Destroy()
		tweld:Destroy()
		BarrelClip.Transparency = 0
	end)
	
	Tool.Equipped:connect(function()
		
		local Character = script.Parent.Parent.Parent
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		local HoldId = 116690317
		local ReloadId = 116695140
		if Humanoid then
			if Humanoid.RigType == Enum.HumanoidRigType.R15 then
				HoldId = 857035982
				ReloadId = 857036793
			end
		end
		local HoldAni = UTIL.Instantiate"Animation"
		{AnimationId = "http://www.roblox.com/Asset?ID="..HoldId}
		local ReloadAni = UTIL.Instantiate"Animation"
		{AnimationId = "http://www.roblox.com/Asset?ID="..ReloadId}
		
		table.insert(Projectile.IgnoreList,Character)
		HoldAniTrack = Humanoid:LoadAnimation(HoldAni)
		ReloadAniTrack = Humanoid:LoadAnimation(ReloadAni)
		HoldAniTrack:Play()
	end)
	Tool.Unequipped:connect(function()
		if HoldAniTrack then
			HoldAniTrack:Stop()
		end
	end)
	spawn(function()
		while true do
			Gun:UpdateBullets(1/30)
			wait()
		end
	end)

end

local Tool = script.Parent.Parent
Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'Mouse1' then
			local down, pos = ...
			
			if down and Gun then
				Gun:StartFireing()
			elseif not down and Gun then
				Gun:EndFireing()
			end
		elseif action == 'MouseMove' then
			local pos = ...
			if Gun then
				Gun.MousePos = pos
			end
		end
	end
end)