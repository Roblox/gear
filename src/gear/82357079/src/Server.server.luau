local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")

local ClubMeshData = "http://www.roblox.com/asset/?id=82264918"
local ClubTextureData = "http://www.roblox.com/asset/?id=82265067"

local ShieldMeshData = Handle:WaitForChild("Mesh").MeshId
local ShieldTextureData = Handle:WaitForChild("Mesh").TextureId

local AttackAble = true
local AttackReload = 1.25
local AttackWindow = 0.5
local AttackDamaging = false
local AttackDamage = 15
local AttackSlowing = false
local AttackSlow = 0.5
local AttackSlowDuration = 1

local SlowScript = Tool:WaitForChild("SlowScript")

local Shield
local ShieldEquipping = false

function toggleShield(on)
	if on then
		ShieldEquipping = true
		
		Shield = Instance.new("Part")
		Shield.CanCollide = false
		Shield.FormFactor = "Symmetric"
		Shield.Size = Vector3.new(3, 5, 2)
		
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = "FileMesh"
		mesh.MeshId = ShieldMeshData
		mesh.TextureId = ShieldTextureData
		mesh.Parent = Shield
		
		Shield.Parent = Tool.Parent
		
		local larm = Tool.Parent:FindFirstChild("Left Arm")
		if larm then
			local weld = Instance.new("Weld")
			weld.Part0 = larm
			weld.Part1 = Shield
			weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(-0.4, 0.2, -0.6)
			weld.Parent = weld.Part0
		end
		
		Shield.Touched:connect(onShieldTouched)
		
		ShieldEquipping = false
	else
		if Shield then
			Shield:Destroy()
		end
	end
end

function onEquipped()
	if ShieldEquipping then return end
	
	onUnequipped()
	
	--make a shield
	toggleShield(true)
	
	--change the mesh
	local mesh = Handle:WaitForChild("Mesh")
	mesh.MeshId = ClubMeshData
	mesh.TextureId = ClubTextureData
end

function onUnequipped()
	--change the mesh back
	local mesh = Handle:WaitForChild("Mesh")
	mesh.MeshId = ShieldMeshData
	mesh.TextureId = ShieldTextureData
	
	--remove the shield
	toggleShield(false)
end

function getPlayer()
	local char = Tool.Parent
	local player = game:GetService("Players"):GetPlayerFromCharacter(char)
	return player
end

function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function onShieldTouched(part)
	if not AttackSlowing then return end
	if part:IsDescendantOf(Tool.Parent) then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		
		local slow = SlowScript:Clone()
		slow.Percentage.Value = AttackSlow
		slow.Duration.Value = AttackSlowDuration
		slow.Parent = human
		slow.Disabled = false
		
		AttackSlowing = false
	end
end

function onTouched(part)
	if not AttackDamaging then return end
	if part:IsDescendantOf(Tool.Parent) then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		tagHuman(human)
		human:TakeDamage(AttackDamage)
		AttackDamaging = false
	end
end

function onAttack()
	if not AttackAble then return end
	
	--rest
	AttackAble = false
	delay(AttackReload, function()
		AttackAble = true
	end)
	
	--open damage window
	AttackDamaging = true
	AttackSlowing = true
	delay(AttackWindow, function()
		AttackDamaging = false
		AttackSlowing = false
	end)
	
	--animate
	Remote:FireClient(getPlayer(), "PlayAnimation", "ShieldBash")
end

function onRemote(player, func, ...)
	if not player == getPlayer() then return end
	
	if func == "Attack" then
		onAttack()
	end
end

Remote.OnServerEvent:connect(onRemote)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Handle.Touched:connect(onTouched)