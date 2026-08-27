-- // Updated for R15 avatars by StarWars

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
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

local Tool = script.Parent
Tool.Enabled = true
local Character;
local Player;

local Humanoid = nil

local RELOAD_TIME = 13

local Handle = Tool:WaitForChild("Handle")
local ThrowSound = Handle:WaitForChild("ThrowSound")

local MouseInput = (Tool:FindFirstChild("MousePos") or Create("RemoteFunction"){
	Name = "MousePos",
	Parent = Tool
})

local GrenadeScript = Tool:WaitForChild("GrenadeScript")

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

local Events = {}

Tool.Equipped:Connect(function()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if Humanoid and Humanoid.Health > 0 then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			ThrowAnimation = Humanoid:LoadAnimation(Animations["R15Throw"])
		elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
			ThrowAnimation = Humanoid:LoadAnimation(Animations["Throw"])
		end
	end


	Events[#Events+1] = Tool.Activated:Connect(function()
		if Tool.Enabled then
			Tool.Enabled = false
			local gr = Handle:Clone()
			gr.CanCollide = false
			local sc = GrenadeScript:Clone()
			sc.Parent = gr
			sc.Disabled = false
			Create("ObjectValue"){
				Name = "creator",
				Value = Player,
				Parent = sc
			}

			--calc velocity
			
			local sucess,MousePosition = pcall(function() return MouseInput:InvokeClient(game.Players:GetPlayerFromCharacter(Character)) end)
			MousePosition = (sucess and MousePosition) or Vector3.new(0,0,0)
			
			local toTarget = MousePosition - gr.Position
			local dy = toTarget.y
			toTarget = Vector3.new(toTarget.x, 0, toTarget.z)
			local dx = toTarget.Magnitude
			toTarget = toTarget.Unit

			Velocity = math.min(120, 40 + dx)

			local theta = computeLaunchAngle(dx, dy, workspace.Gravity)

			local vY = math.sin(theta)*Velocity
			local vX = toTarget.x * math.cos(theta) * Velocity
			local vZ = toTarget.z * math.cos(theta) * Velocity

			gr.CanCollide = false
			delay(0.1, function()
				gr.CanCollide = true
			end)
			gr.Velocity = Vector3.new(vX, vY, vZ)
			gr.Parent = workspace
			gr:SetNetworkOwner(nil)

			--play sound / anim
			ThrowSound:Play()
			ThrowAnimation:Play(0, 1, 1)

			--reload
			Handle.Transparency = 1
			wait(RELOAD_TIME)
			Handle.Transparency = 0
			Tool.Enabled = true
		end
	end)
end)

Tool.Unequipped:Connect(function()
	for i=1,#Events do
		if Events[i] then
			Events[i]:Disconnect();
		end
	end
	Events = {}
	if ThrowSound then
		ThrowSound:Stop()
	end
	
	if ThrowAnimation then
		ThrowAnimation:Stop()
		ThrowAnimation = nil
	end

end)