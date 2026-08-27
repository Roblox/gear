local Tool = script.Parent
local Character;
local Player;

local Humanoid = nil

local RELOAD_TIME = 2

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

	mouse.Button1Down:connect(function()
		--we track the reload time like this so that the player can't fire faster with
		--rapid dis / re-equipping, which will actually be common usage with this gear.
		if Now() > NextFireAt.Value then
			NextFireAt.Value = Now() + RELOAD_TIME
			--
			local gr = Instance.new('Part')
			gr.TopSurface = 'Smooth'
			gr.BottomSurface = 'Smooth'
			gr.FormFactor = 'Custom'
			gr.Size = Vector3.new(1,1,1)
			gr.CFrame = Handle.CFrame
			ExplodeSound:Clone().Parent = gr
			local mesh = Instance.new('SpecialMesh', gr)
			mesh.MeshId = 'http://www.roblox.com/asset/?id=88794862'
			mesh.TextureId = 'http://www.roblox.com/asset/?id=88794893'
			mesh.Scale = Vector3.new(4,3,4)
			local sc = GrenadeScript:Clone()
			sc.Parent = gr
			sc.Disabled = false
			sc:WaitForChild("creator").Value = Player

			--calc velocity
			local toTarget = mouse.Hit.p - gr.Position
			local dy = toTarget.y
			toTarget = Vector3.new(toTarget.x, 0, toTarget.z)
			local dx = toTarget.magnitude
			toTarget = toTarget.unit

			Velocity = math.min(120, 40 + dx)

			local theta = computeLaunchAngle(dx, dy, 196.2)

			local vY = math.sin(theta)*Velocity
			local vX = toTarget.x * math.cos(theta) * Velocity
			local vZ = toTarget.z * math.cos(theta) * Velocity

			gr.CanCollide = false
			delay(0.1, function()
				gr.CanCollide = true
			end)
			gr.Velocity = Vector3.new(vX, vY, vZ)
			gr.Parent = game.Workspace

			--play sound / anim
			ThrowSound:Play()
			ThrowAnimation:Play(0,1,1)

			--reload
			Handle.Transparency = 1
			mouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
			wait(RELOAD_TIME)
			Handle.Transparency = 0
			mouse.Icon = 'rbxasset://textures\\GunCursor.png'
		end
	end)
end)

Tool.Unequipped:connect(function()
	if ThrowSound then
		ThrowSound:Stop()
	end
	if ThrowAnim then
		ThrowAnim:Stop()
	end
	if HoldAnim then
		HoldAnim:Stop()
	end
end)