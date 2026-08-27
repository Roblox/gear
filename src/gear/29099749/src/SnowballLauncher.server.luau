--[[
	Fixed by ArceusInator.  No longer fires at origin.  No longer makes the HumanoidRootPart visible.  No longer removes player's faces.
--]]

Tool = script.Parent
VELOCITY = 50 -- constant
loaded=false

local Pellet = Instance.new("Part")
Pellet.Shape = 1
Pellet.formFactor = 0
Pellet.Size = Vector3.new(1,1,4)
Pellet.BrickColor = BrickColor.new("Lime green")
Pellet.Material = Enum.Material.Ice
Pellet.Locked = true
Pellet.TopSurface = 0
Pellet.BottomSurface = 0

local looper = Instance.new("Sound")
looper.Name = "RaySound"
looper.SoundId = "http://www.roblox.com/asset/?id=28912822"
looper.Looped = true
looper.Parent = Pellet



script.Parent.SnowballScript:Clone().Parent = Pellet
script.Parent.TransmorphScript:Clone().Parent = Pellet


function fire(v, shootDirect)

-- find player's head pos
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	local head = vCharacter:FindFirstChild("Head")
	if not head then return end

	Tool.Handle.Fire:Play()
	local launch = head.Position + 10 * v

	local missile = Pellet:Clone()
	missile.CFrame = CFrame.new(launch,shootDirect)
	missile.Position = launch
	missile.Velocity = v * 200

	local force = Instance.new("BodyForce")
	force.Force = Vector3.new(0,workspace.Gravity * missile:GetMass(),0)
	force.Parent = missile

	missile.SnowballScript.Disabled = false
	missile.RaySound:Play()

	missile.Parent = workspace
	missile:SetNetworkOwner(nil)

end

function gunUp()
	Tool.GripPos = Vector3.new(0,-0.3,-1)
end

function gunOut()
	Tool.GripPos = Vector3.new(0,-0.3,-0.8)
end

function onEquipped()

	Tool.Handle.Fire:Stop()

end

function onUnequipped()

	Tool.Handle.Fire:Stop()

end

Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)


enabled = true
function onActivated(p)
	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = p
	local lookAt = (targetPos - character.Head.Position).unit
	local shootDirect = targetPos

	local reload = 0.6

	gunUp()
	fire(lookAt, shootDirect)
	wait(reload)
	gunOut()
	wait(reload)

	Tool.Enabled = true

end

script.Parent.Mouse1.OnServerEvent:connect(function(client, down, hit)
	if client.Character == Tool.Parent and down then
		onActivated(hit)
	end
end)
