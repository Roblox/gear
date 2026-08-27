local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")
local ProjectileScript = Tool:WaitForChild("Projectile")

local BowMeshData = "http://www.roblox.com/asset/?id=192454332"
local ArrowMeshData = "http://www.roblox.com/asset/?id=192454343"
local TextureData = "http://www.roblox.com/asset/?id=192454363"

local CurrentArrow = nil
local Arrows = {}

local Heartbeat = game:GetService("RunService").Heartbeat

local AttackDamage = 25
local Charge = 0
local MaxCharge = 350
local ChargeRate = MaxCharge / 2
local JumpAble = true
local JumpRestTime = 15

local LastLandedArrow = nil

function createArrow()
	local arrow = Instance.new("Part")
	arrow.TopSurface = "Smooth"
	arrow.BottomSurface = "Smooth"
	arrow.FormFactor = "Custom"
	arrow.Size = Vector3.new(0.2, 0.2, 2.4)
	arrow.CanCollide = false
	
	local sound = Instance.new("Sound")
	sound.Name = "Hit"
	sound.SoundId = "http://www.roblox.com/asset/?id=89343281"
	sound.Parent = arrow
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "FileMesh"
	mesh.MeshId = ArrowMeshData
	mesh.TextureId = TextureData
	mesh.Parent = arrow
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 236 / 1.2 * arrow:GetMass(), 0)
	lift.Parent = arrow
	
	local fire = Instance.new("Fire")
	fire.Size = 1
	fire.Heat = 0
	fire.Color = Color3.new(51/255, 150/255, 232/255)
	fire.SecondaryColor = Color3.new(1, 1, 1)
	fire.Parent = arrow
	
	return arrow
end

function onEquip()
	--ensure unequip
	onUnequip()
	
	--ensure lone bow aesthetic
	if Handle.Mesh.MeshId ~= BowMeshData then
		Handle.Mesh.MeshId = BowMeshData
	end
	
	--play holding animation
	Remote:FireClient(getPlayer(), "PlayAnimation", "Idle")
end

function onUnequip()
	--stop holding animation
	Remote:FireClient(getPlayer(), "StopAnimation", "Idle")
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function jumpAttack()
	if not JumpAble then return end
	
	if LastLandedArrow and LastLandedArrow.Parent then
		local root = Tool.Parent:FindFirstChild("HumanoidRootPart")
		if root then
			local a = root.Position
			local b = LastLandedArrow.Position + Vector3.new(0, 2.5, 0)
			
			Handle.Warp:Play()
			
			JumpAble = false
			delay(JumpRestTime, function()
				JumpAble = true
			end)
			
			local t = 0
			local duration = 0.5
			while t < duration do
				t = t + Heartbeat:wait()
				root.CFrame = CFrame.new(a + (b - a) * (t / duration), b)
				root.Velocity = Vector3.new()
			end
			root.CFrame = CFrame.new(b)
		end
	end
end

function onActivate()	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Hold", 0.75)
	
	local larm = Tool.Parent:FindFirstChild("Left Arm")
	if larm then
		local arrow = createArrow()
		arrow.Parent = Tool
		
		game:GetService("Debris"):AddItem(arrow, 30)
		
		local weld = Instance.new("Weld")
		weld.Part0 = larm
		weld.Part1 = arrow
		weld.Parent = weld.Part0
		
		CurrentArrow = arrow
		
		while CurrentArrow do
			local hand = larm.CFrame * CFrame.new(0, -1, 0)
			local cframe = CFrame.new(hand.p, Handle.Position) * CFrame.new(0, 0, -1.2)
			weld.C0 = larm.CFrame:toObjectSpace(cframe)
			
			local dt = Heartbeat:wait()
			
			Charge = Charge + ChargeRate * dt
			if Charge > MaxCharge then Charge = MaxCharge end
		end
	end
end

function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function onDeactivate(targetPosition)
	if not CurrentArrow then return end
	
	Remote:FireClient(getPlayer(), "StopAnimation", "Hold")
	
	if Charge < MaxCharge / 3 then
		Charge = 0
		CurrentArrow:Destroy()
		CurrentArrow = nil
		jumpAttack()
		return
	end
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Shoot", 0)
	if CurrentArrow then
		Handle.Shoot.Pitch = 0.6 + (0.8 * Charge/MaxCharge)
		Handle.Shoot:Play()
		
		local arrow = CurrentArrow
		CurrentArrow = nil
		
		arrow.Parent = workspace
		arrow:BreakJoints()
		arrow.CFrame = arrow.CFrame * CFrame.new(0, 0, -arrow.Size.Z)
		arrow.Velocity = (targetPosition - arrow.Position).unit * Charge
		
		local arrowCharge = Charge
		Charge = 0
		
		table.insert(Arrows, arrow)
		
		local ps = ProjectileScript:Clone()
		ps.Disabled = false
		ps.Parent = arrow
		
		local touched
		touched = arrow.Touched:connect(function(part)
			if part:IsDescendantOf(Tool.Parent) then return end
			if contains(Arrows, part) then return end
			
			if arrowCharge < MaxCharge then
				ps:Destroy()
				arrow.Velocity = Vector3.new()
				
				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.Part1 = arrow
				weld.C0 = part.CFrame:toObjectSpace(arrow.CFrame)
				weld.Parent = weld.Part0
				touched:disconnect()
				
				LastLandedArrow = arrow
			end
			
			if part.Parent and part.Parent:FindFirstChild("Humanoid") and not arrow:FindFirstChild("Cooldown") then
				local human = part.Parent.Humanoid
				tagHuman(human)
				human:TakeDamage(AttackDamage)
				
				local cooldown = Instance.new("BoolValue")
				cooldown.Name = "Cooldown"
				cooldown.Parent = arrow
				game:GetService("Debris"):AddItem(cooldown, 0)
				
				arrow.Hit.Pitch = math.random(80, 120)/100
				arrow.Hit:Play()
			end
		end)
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		onActivate(...)
	elseif func == "Deactivate" then
		onDeactivate(...)
	end
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Remote.OnServerEvent:connect(onRemote)