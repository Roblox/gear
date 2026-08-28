-- // Created by StarWars
local players = game:GetService("Players")
local debris = game:GetService("Debris")

local tool = script.Parent

local remotes = tool.Remotes

local player
local character
local humanoid

local RELOAD_TIME = 5
local FIRE_TIMEOUT = 10
local FIRE_DAMAGE = 5

function InvokeClient(mode, value)
	if not player then return end
	if not mode then return end
	
	local result
	pcall(function()
		result = remotes.ClientControls:InvokeClient(player, mode, value)
	end)
	
	return result
end

function CreateFire(part)
	local newFire = Instance.new("Fire")
	newFire.Color = Color3.new(0, 1, 0)
	newFire.SecondaryColor = Color3.fromRGB(0, 158, 0)
	newFire.Parent = part
	debris:AddItem(newFire, FIRE_TIMEOUT)
end

function CreateFireball(start, direction)
	local newPart = Instance.new("Part")
	newPart.Size = Vector3.new(1, 1, 1)
	newPart.Anchored = false
	newPart.CanCollide = false
	newPart.Color = Color3.new(0, 1, 0)
	newPart.TopSurface = Enum.SurfaceType.Smooth
	newPart.BottomSurface = Enum.SurfaceType.Smooth
	newPart.Material = Enum.Material.Neon
	newPart.CFrame = CFrame.new(start)
	CreateFire(newPart)
	
	local bodyForce = Instance.new("BodyForce")
	bodyForce.Force = Vector3.new(0, workspace.Gravity * newPart:GetMass(), 0)
	bodyForce.Parent = newPart
	
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = direction * 40
	bodyVelocity.Parent = newPart
	
	newPart.Touched:Connect(function(hit)
		if FindCharacterFromPart(hit) and not hit:IsDescendantOf(character) then
			CreateFire(hit)
			spawn(function()
				local counter = 0
				while counter < FIRE_TIMEOUT do
					local delta = wait()
					counter = counter + delta
					local hitCharacter = FindCharacterFromPart(hit)
					if hitCharacter then
						local hitHumanoid = hitCharacter:FindFirstChildOfClass("Humanoid")
						if hitHumanoid and hitHumanoid.Health > 0 then
							hitHumanoid:TakeDamage(FIRE_DAMAGE * delta)
						else
							break
						end
					end
				end
			end)
			newPart:Destroy()
		end
	end)
	
	newPart.Parent = workspace
	debris:AddItem(newPart, FIRE_TIMEOUT)
end

function FindCharacterFromPart(part)
	if not part then return end
	
	local parentTo = part.Parent
	if parentTo then
		if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
			parentTo = parentTo.Parent
		end
		
		if parentTo:FindFirstChildOfClass("Humanoid") then
			return parentTo
		end
	end
end

function CanFire()
	if humanoid and humanoid.Health > 0 and humanoid.RootPart and tool.Enabled then
		return true
	end
	
	return false
end

tool.Equipped:Connect(function()
	character = tool.Parent
	player = players:GetPlayerFromCharacter(character)
	humanoid = character:FindFirstChildOfClass("Humanoid")
end)

tool.Unequipped:Connect(function()
	character = nil
	player = nil
	humanoid = nil
end)

tool.Activated:Connect(function()
	if not CanFire() then return end
	tool.Enabled = false
	
	local mouseData = InvokeClient("GetMouseData")
	if mouseData then
		local direction = (mouseData.Position - humanoid.RootPart.CFrame.p).Unit
		CreateFireball(humanoid.RootPart.CFrame.p, direction)
	end
	
	wait(RELOAD_TIME)
	tool.Enabled = true	
end)