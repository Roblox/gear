local Tool = script.Parent
local Character;
local Player;

local RELOAD_TIME = 4

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

local Handle = WaitFor(Tool).Handle()
local NextFireAt = WaitFor(Tool).NextFireAt()
local ThrowSound = WaitFor(Handle).ThrowSound()

local MineScript = WaitFor(Tool).MineScript()

local function Now()
	return game.Workspace.DistributedGameTime
end

---------------------------------------------

local Velocity = 120
function computeLaunchAngle(dx, dy, grav)	
	-- This function is nasty or what? :P 
	-- There are ways to solve launch angle of a projectile given a point in 3D space 
	-- This one solves for tan(theta) 
		
	-- Simplify the distance formula of a projectile 
	local g = math.abs(grav)
	local inRoot = (Velocity * Velocity * Velocity * Velocity) - (g * ((g * dx * dx) + (2 * dy * Velocity * Velocity)))
	if inRoot <= 0 then
		return 0.25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((Velocity * Velocity) + root) / (g*dx)

	local inATan2 = ((Velocity * Velocity) - root) / (g*dx)
	local a1 = math.atan(inATan1)
	local a2 = math.atan(inATan2)
	if a1 < a2 then return a1 end
	return a2
end

---------------------------------------------

Tool.Equipped:connect(function(mouse)
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)

	--setup first anim / cursor cycle
	if Now() > NextFireAt.Value then
		Handle.Transparency = 0
		mouse.Icon = 'rbxasset://textures\\GunCursor.png'
	else
		Handle.Transparency = 1
		Delay(NextFireAt.Value - Now(), function()
			mouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
			Handle.Transparency = 0
		end)
	end

	mouse.Button1Down:connect(function()
		--we track the reload time like this so that the player can't fire faster with
		--rapid dis / re-equipping, which will actually be common usage with this gear.
		if Now() > NextFireAt.Value then

			--find where to place the mine
			local function getPartsRec(tb, o)
				for _, ch in pairs(o:GetChildren()) do
					if ch:IsA('Part') then tb[#tb+1] = ch end
					getPartsRec(tb, ch)
				end
				return tb
			end
			local ignore = getPartsRec({}, Character)
			local ray = Ray.new(Handle.Position, Vector3.new(0,-999,0))
			local hit, at = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
			while hit and (not hit.CanCollide or (hit.Parent or game):FindFirstChild('Humanoid')) do
				ignore[#ignore+1] = hit
				hit, at = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
			end

			--if we hit somewhere, place the mine there
			if hit then
				NextFireAt.Value = Now() + RELOAD_TIME
				
				--
				local mine = Handle:Clone()
				mine.CFrame = CFrame.new(at + Vector3.new(0,0.4,0))
				mine.Anchored = true
				mine.CanCollide = false
				local sc = MineScript:Clone()
				sc.Parent = mine
				sc.Disabled = false
				sc.creator.Value = Player
				mine.Parent = game.Workspace

				--play sound 
				ThrowSound:Play()
				local animReq = Instance.new('StringValue')
				animReq.Name = 'toolanim'
				animReq.Value = 'Slash'
				animReq.Parent = Tool

				--reload
				Handle.Transparency = 1
				mouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
				wait(RELOAD_TIME)
				Handle.Transparency = 0
				mouse.Icon = 'rbxasset://textures\\GunCursor.png'
			end
		end
	end)
end)

Tool.Unequipped:connect(function()
	if ThrowSound then
		ThrowSound:Stop()
	end
end)