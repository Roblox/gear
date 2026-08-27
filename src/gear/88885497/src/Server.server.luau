local Tool = script.Parent
Tool.Enabled = true

local Players = (game:FindService("Players") or game:GetService("Players"))

local Instant,Pairs,Type,Tick,wrap,Delay,Wait,Pcall = Instance.new,pairs,type,tick,coroutine.wrap,delay,wait,pcall

local Cframe,Angles,Vec3,huge,abs,atan,sqrt,min,sin,cos,pi = CFrame.new,CFrame.Angles,Vector3.new,math.huge,math.abs,math.atan,math.sqrt,math.min,math.sin,math.cos,math.pi

function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in Pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local MouseInput = (Tool:FindFirstChild("MousePos") or Create("RemoteFunction"){
	Name = "MousePos",
	Parent = Tool
})


local Character;
local Player;

local Humanoid = nil

local RELOAD_TIME = 8

local Handle = Tool:WaitForChild("Handle")
local NextFireAt = Tool:WaitForChild("NextFireAt")
local ThrowSound = Handle:WaitForChild("ThrowSound")

local GrenadeScript = Tool:WaitForChild("GrenadeScript")
local ExplodeSound = Handle:WaitForChild("ExplodeSound")

local Animations = {
	Throw = Tool:WaitForChild("ThrowAnim");	
	R15Throw = Tool:WaitForChild("R15ThrowAnim")
}

local ThrowAnimation = nil

local function Now()
	return workspace.DistributedGameTime
end

---------------------------------------------

local Velocity = 120
function computeLaunchAngle(dx, dy, grav)	
	-- This function is nasty or what? :P 
	-- There are ways to solve launch angle of a projectile given a point in 3D space 
	-- This one solves for tan(theta) 
		
	-- Simplify the distance formula of a projectile 
	local g = abs(grav)
	local inRoot = (Velocity * Velocity * Velocity * Velocity) - (g * ((g * dx * dx) + (2 * dy * Velocity * Velocity)))
	if inRoot <= 0 then
		return 0.25 * pi
	end
	local root = sqrt(inRoot)
	local inATan1 = ((Velocity * Velocity) + root) / (g*dx)

	local inATan2 = ((Velocity * Velocity) - root) / (g*dx)
	local a1 = atan(inATan1)
	local a2 = atan(inATan2)
	if a1 < a2 then return a1 end
	return a2
end

---------------------------------------------

Tool.Equipped:Connect(function(mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:WaitForChild("Humanoid")

	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			ThrowAnimation = Humanoid:LoadAnimation(Animations["R15Throw"])
		elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
			ThrowAnimation = Humanoid:LoadAnimation(Animations["Throw"])
		end
	end

	--setup first anim / cursor cycle
	if Now() > NextFireAt.Value then
		Handle.Transparency = 0
		mouse.Icon = 'rbxasset://textures\\GunCursor.png'
	else
		Handle.Transparency = 1
		delay(NextFireAt.Value - Now(), function()
			mouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
			Handle.Transparency = 0
		end)
	end

	Tool.Activated:Connect(function()
		--we track the reload time like this so that the player can't fire faster with
		--rapid dis / re-equipping, which will actually be common usage with this gear.
		if Now() > NextFireAt.Value then
			NextFireAt.Value = Now() + RELOAD_TIME
			--
			local gr = Create("Part"){
				TopSurface = 'Smooth',
				BottomSurface = 'Smooth',
				FormFactor = 'Custom',
				Size = Vector3.new(1,1,1),
				CFrame = Handle.CFrame,
				Anchored = false,
				Locked = true
			}
			
			ExplodeSound:Clone().Parent = gr
			
			local mesh = Create("SpecialMesh"){
				TextureId = 'http://www.roblox.com/asset/?id=88795021',
				MeshId = 'http://www.roblox.com/asset/?id=88795005',
				Parent = gr
			}
			
			local sc = GrenadeScript:Clone()
			sc.Parent = gr
			sc.Disabled = false
			sc:WaitForChild("creator").Value = Player

			--calc velocity
			local sucess,MousePosition = Pcall(function() return MouseInput:InvokeClient(Player) end)
			MousePosition = (sucess and MousePosition) or Vec3.new(0,0,0)
			
			local toTarget = MousePosition - gr.Position
			local dy = toTarget.y
			toTarget = Vec3(toTarget.x, 0, toTarget.z)
			local dx = toTarget.magnitude
			toTarget = toTarget.unit

			Velocity = min(120, 40 + dx)

			local theta = computeLaunchAngle(dx, dy, 196.2)

			local vY = sin(theta)*Velocity
			local vX = toTarget.x * cos(theta) * Velocity
			local vZ = toTarget.z * cos(theta) * Velocity

			gr.CanCollide = false
			Delay(0.1, function()
				gr.CanCollide = true
			end)
			gr.Velocity = Vec3(vX, vY, vZ)
			gr.Parent = workspace
			
			if gr:CanSetNetworkOwnership() then
				gr:SetNetworkOwner(nil)
			end

			--play sound / anim
			ThrowSound:Play()
			ThrowAnimation:Play(0,1,1)

			--reload
			Handle.Transparency = 1
			Tool.Enabled = false
			--mouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
			Wait(RELOAD_TIME)
			Tool.Enabled = true
			Handle.Transparency = 0
			--mouse.Icon = 'rbxasset://textures\\GunCursor.png'
		end
	end)
end)

Tool.Unequipped:Connect(function()
	if ThrowSound then
		ThrowSound:Stop()
	end
	
	if ThrowAnimation then
		ThrowAnimation:Stop()
		ThrowAnimation = nil
	end
end)