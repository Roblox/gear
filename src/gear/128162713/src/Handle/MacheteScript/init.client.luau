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

--[[Sword Part Class]]--
	
local SwordPart =
{
	Damage = 20,
	AttackTime = 1,
	CoolDown = 2,
	
	LastSwing = 0,
	LastHit = 0,

	Part= nil,
	Owner = nil,--player object that owns this sword
	
	OnHit = nil,
	OnHitHumanoid = nil,
	OnAttackReady = nil,
	OnAttack = nil,
	
	
	SwingSound = nil,
	HitSound = nil,
	SwingAnimation = nil, --animation track!
	
	ActiveConnections = {},
	
}
do
	UTIL.MakeClass(SwordPart)
	function SwordPart.New(npart,nowner)
		local init= UTIL.DeepCopy(SwordPart)
		init.Part= npart
		init.Owner = nowner
		table.insert(init.ActiveConnections,init.Part.Touched:connect(function(hit) init:SwordTouch(hit) end))
		
		init.OnHit = InternalEvent.New()
		init.OnHitHumanoid = InternalEvent.New()
		init.OnAttackReady = InternalEvent.New()
		init.OnAttack = InternalEvent.New()
		
		return init
	end
	
	function SwordPart:SwordTouch(hit)
		if tick()-self.LastSwing >self.AttackTime or tick()-self.LastHit<self.AttackTime then return end
		self.OnHit:Fire(hit)
		local character,humanoid = UTIL.FindCharacterAncestor(hit)
		if character and character ~= self.Owner.Character then
			humanoid:TakeDamage(self.Damage)
			self.OnHitHumanoid:Fire(humanoid,hit)
			self.LastHit = tick()
			if self.HitSound then
				self.HitSound:Play()
			end
		end
		
	end
	
	function SwordPart:DoSwing()
		if tick()-self.LastSwing<self.AttackTime+self.CoolDown then
			return
		end
		
		if self.SwingAnimation then
			self.SwingAnimation:Play()
		end
		if self.SwingSound then
			self.SwingSound:Play()
		end
		self.LastSwing = tick()
		self.OnAttack:Fire()
	end
	
	function SwordPart:Destroy()
		for _,i in pairs(self.ActiveConnections) do
			i:disconnect()
		end
	end
end
do
	local Handle = script.Parent
	local Tool = Handle.Parent
	
	local Player = game.Players.LocalPlayer
	local Character = UTIL.WaitForValidCharacter(Player)
	local SwingAni = UTIL.Instantiate"Animation"
	{AnimationId = "http://www.roblox.com/Asset?ID=89289879"}
	
	local HitSound = Handle:WaitForChild('Hit')
	local SwingSound = Handle:WaitForChild('Swing')
	
	local ShockScript = script:WaitForChild('ShockScript')
	
	local SwingAniTrack
	
	local Sword
	
	local function DoEffect(pstart,target,humanoid)
		local stime = tick()
		local length = 2
		local rootPart = UTIL.Instantiate'Part'
		{
			FormFactor = 'Custom',
			Size = Vector3.new(1,1,1),
			Transparency = .4,
			Anchored = false,
			Parent = Character,
			CFrame = CFrame.new(pstart),
			BrickColor = BrickColor.new('Deep blue'),
			UTIL.Instantiate'SpecialMesh'
			{
				MeshId='http://www.roblox.com/Asset/?id=9756362',
				Scale = Vector3.new(.75,1.5,.75)
			},
			UTIL.Instantiate'BodyGyro'{},
			UTIL.Instantiate'BodyAngularVelocity'
			{
				angularvelocity = Vector3.new(0,4,0),
			},
			UTIL.Instantiate'PointLight'
			{}
		}
		local Sound = UTIL.Instantiate'Sound'
		{
			SoundId = 'http://www.roblox.com/asset/?id=128911690',
			Parent = rootPart,
		}
		local bodyPos = UTIL.Instantiate'BodyPosition'
		{
			maxForce = Vector3.new(math.huge,math.huge,math.huge),
			position = pstart,
			
		}
		bodyPos.Parent = rootPart
		for i=1,4,1 do
			local satalight = UTIL.Instantiate'Part'
			{
				FormFactor = 'Custom',
				CanCollide = false,
				CFrame = CFrame.new(pstart),
				Transparency = .4,
				Anchored = false,
				BrickColor = BrickColor.new('Bright blue'),
				UTIL.Instantiate'SpecialMesh'
				{
					MeshId='http://www.roblox.com/Asset/?id=9756362',
					Scale = Vector3.new(.35,.75,.35)
				},
				
			}
			satalight.Size = Vector3.new(.2,.2,.2)
			local weld = UTIL.Instantiate'Weld'
			{
				Part0 =rootPart,
				Part1 = satalight,
			}
			weld.C0 = CFrame.Angles(0,(math.pi*2/(4))*(i-1),0)
			weld.C1=CFrame.new(1,0,0)--math.sin((math.pi*2)/i),0,math.cos((math.pi*2)/i)
			weld.Parent = rootPart
			satalight.Parent = rootPart
		end	
		while tick()-stime<length do
			local tloc = ((target.CFrame.p-pstart)*((tick()-stime)/length))+pstart
			bodyPos.position = Vector3.new(tloc.x,tloc.y+(math.sin(tick()*5)*2),tloc.z)
			wait()
		end
		if not game.Players:GetPlayerFromCharacter(target.Parent) then
			humanoid:TakeDamage(20)
		else
			if not target.Parent:FindFirstChild('ShockScript') then
				local tscript = ShockScript:clone()
				tscript.Parent = target.Parent
				tscript.Disabled = false
			end
		end
		Sound:Play()
		wait(2)
		rootPart.Parent = nil
	end
	
	Tool.Equipped:connect(function(mouse)
		Sword = SwordPart.New(Handle,Player)
		Sword.Damage = 10
		Sword.HitSound = HitSound
		Sword.SwingSound = SwingSound
		Character = UTIL.WaitForValidCharacter(Player)
		local Humanoid = Character:FindFirstChild('Humanoid')

		SwingAniTrack = Humanoid:LoadAnimation(SwingAni)
		Sword.SwingAnimation = SwingAniTrack
		
		Sword.OnAttack:Connect(function()
			if not mouse.Target then return end
			local otherChar = UTIL.FindCharacterAncestor(mouse.Target)
			if not otherChar then return end
			local otherHumanoid = otherChar:FindFirstChild('Humanoid')
			if not otherHumanoid then return end
			local torso = otherChar:FindFirstChild('Torso')
			if not torso or not Handle then return end
			DoEffect(Handle.CFrame.p,torso,otherHumanoid)
			
		end)
		
		mouse.Button1Down:connect(function()
			Sword:DoSwing()
		end)
	end)
	Tool.Unequipped:connect(function()
		Sword:Destroy()
	end)

end
