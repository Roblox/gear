--------------------- TEMPLATE ASSAULT RIFLE WEAPON ---------------------------
-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end
local GLib = require(206209239)

----- MAGIC NUMBERS ABOUT THE TOOL -----
-- How much damage a bullet does
local Damage = 4
-- how many bullets are fired at a time
local BulletCount = 20
-- How many times per second the gun can fire
local FireRate = .4
-- The maximum distance the can can shoot, this value should never go above 1000
local Range = 250
-- In radians bullet spread
local Spread = .175
-- Number of bullets in a clip
local ClipSize = 6
-- Time it takes to reload weapon
local ReloadTime = 3
----------------------------------------
local MOUSE_TARGET = Vector3.new()

-- Colors
local FriendlyReticleColor = Color3.new(0, 1, 0)
local EnemyReticleColor	= Color3.new(1, 0, 0)
local NeutralReticleColor	= Color3.new(1, 1, 1)


local AmmoInClip = ClipSize

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')
local WeaponGui = nil

local Reloading = false
local IsShooting = false

-- Player specific convenience variables
local MyPlayer = nil
local MyCharacter = nil
local MyHumanoid = nil
local MyTorso = nil

local DebrisService = game:GetService('Debris')

local FireSound

local OnFireConnection = nil
local OnReloadConnection = nil

-- this is a dummy object that holds the flash made when the gun is fired
local FlashHolder = nil

local EquipTrack = nil
local PumpTrack = nil


local WorldToCellFunction = Workspace.Terrain.WorldToCellPreferSolid
local GetCellFunction = Workspace.Terrain.GetCell

function RayIgnoreCheck(hit, pos)
	if hit then
		if hit.Transparency >= 1 or string.lower(hit.Name) == "water" or
				hit.Name == "Effect" or hit.Name == "Rocket" or hit.Name == "Bullet" or
				hit.Name == "Handle" or hit:IsDescendantOf(MyCharacter) then
			return true
		elseif hit:IsA('Terrain') and pos then
			local cellPos = WorldToCellFunction(Workspace.Terrain, pos)
			if cellPos then
				local cellMat = GetCellFunction(Workspace.Terrain, cellPos.x, cellPos.y, cellPos.z)
				if cellMat and cellMat == Enum.CellMaterial.Water then
					return true
				end
			end
		end
	end
	return false
end

-- @preconditions: vec should be a unit vector, and 0 < rayLength <= 1000
function RayCast(startPos, vec, rayLength)
	local hitObject, hitPos = game.Workspace:FindPartOnRay(Ray.new(startPos + (vec * .01), vec * rayLength), Handle)
	if hitObject and hitPos then
		local distance = rayLength - (hitPos - startPos).magnitude
		if RayIgnoreCheck(hitObject, hitPos) and distance > 0 then
			-- there is a chance here for potential infinite recursion
			return RayCast(hitPos, vec, distance)
		end
	end
	return hitObject, hitPos
end



function TagHumanoid(humanoid, player)
	-- Add more tags here to customize what tags are available.
	while humanoid:FindFirstChild('creator') do
		humanoid:FindFirstChild('creator'):Destroy()
	end 
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
	DebrisService:AddItem(creatorTag, 1)
end

local function CreateFlash()
	if not FlashHolder then
		FlashHolder = Instance.new("Part", Tool)
		FlashHolder.Name = "FlashHolder"
		FlashHolder.Transparency = 1
		FlashHolder.CanCollide= false
		FlashHolder.FormFactor = "Custom"
		FlashHolder.Size = Vector3.new(.4,.4,.4)
		FlashHolder.Position = Tool.Handle.Position
		local Weld = Instance.new("ManualWeld")
		Weld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.C1 = CFrame.new(0, .4, -2.4, 0, 0, 1, 1, 0, 0, 0, 1, 0)
		Weld.Part0 = FlashHolder
		Weld.Part1 = Tool.Handle
		Weld.Parent = FlashHolder
	end
	local flash = Instance.new('Fire', FlashHolder)
	flash.Color = Color3.new(1, 140 / 255, 0)
	flash.SecondaryColor = Color3.new(1, 0, 0)
	flash.Size = 0.3
	DebrisService:AddItem(flash, FireRate / 1.5)
end

local BulletBase = Instance.new('Part')
BulletBase.FormFactor = Enum.FormFactor.Custom
BulletBase.Size = Vector3.new(1,1,1)
BulletBase.BrickColor = BrickColor.new("Black")
BulletBase.CanCollide = false
BulletBase.Anchored = true
BulletBase.TopSurface = Enum.SurfaceType.Smooth
BulletBase.BottomSurface = Enum.SurfaceType.Smooth
BulletBase.Name = 'Bullet'

local BulletMesh = Instance.new("SpecialMesh")
BulletMesh.MeshType = 'Sphere'
BulletMesh.Scale = Vector3.new(.2,.2,.2)
BulletMesh.Parent = BulletBase


local function CreateBullet(bulletPos, hit)
	local bullet = BulletBase:Clone()

	bullet.CFrame = CFrame.new(bulletPos)
	bullet.Parent = game.Workspace
	DebrisService:AddItem(bullet, 2.5)
	
	if hit.Anchored == false then
		local weld = Instance.new'Weld'
		weld.C0 = hit.CFrame:toObjectSpace(CFrame.new(bulletPos))
		weld.Part0 = hit
		weld.Part1 = bullet
		weld.Parent = bullet
		bullet.Anchored = false
	end

	return bullet
end

local function Reload()
	if not Reloading then
		Reloading = true
		Tool.SetIcon:FireClient(game.Players:GetPlayerFromCharacter(Tool.Parent), "rbxasset://textures\\GunWaitCursor.png")
		-- Don't reload if you are already full or have no extra ammo
		if AmmoInClip ~= ClipSize then
			if PumpTrack then
				PumpTrack:Stop()
			end
			for i = 1,6 do
				if PumpTrack then
					PumpTrack:Play()
				end
				if Handle:FindFirstChild('PumpSound') then
					Handle.PumpSound:Play()
				end
				wait(ReloadTime/6)
			end
			-- Only use as much ammo as you have
			local ammoToUse = ClipSize - AmmoInClip
			AmmoInClip = AmmoInClip + ammoToUse
			UpdateAmmo(AmmoInClip)
		end
		Tool.SetIcon:FireClient(game.Players:GetPlayerFromCharacter(Tool.Parent), "rbxasset://textures\\GunCursor.png")
		Reloading = false
	end
end

local CasingBase = Instance.new('Part')
CasingBase.FormFactor = Enum.FormFactor.Custom
CasingBase.Elasticity = 0
CasingBase.Size = Vector3.new(.3,.3,.5)
local CasingMesh = Instance.new('SpecialMesh')
CasingMesh.MeshId = 'http://www.roblox.com/asset/?id=94248124'
CasingMesh.TextureId = 'http://www.roblox.com/asset/?id=94219470'
--CasingMesh.Scale = Vector3.new(.75,.75,.75)
CasingMesh.Parent = CasingBase

function OnFire()
	if IsShooting then return end
	if MyHumanoid and MyHumanoid.Health > 0 then
		if RecoilTrack and AmmoInClip > 0 then
			
		end
		IsShooting = true
		if AmmoInClip > 0 and not Reloading then
			--if RecoilTrack then RecoilTrack:Play() end
			if Handle:FindFirstChild('FireSound') then
				Handle.FireSound:Play()
			end
			CreateFlash()
			Tool.SetIcon:FireClient(game.Players:GetPlayerFromCharacter(Tool.Parent), "rbxasset://textures\\GunWaitCursor.png")
			local targetPoint = MOUSE_TARGET
			for i = 1, BulletCount do
				local shootDirection = (targetPoint - Handle.Position).unit
				-- Adjust the shoot direction randomly off by a little bit to account for recoil
				-- moves random*spread in a random angle from center shot point (center bias)
				shootDirection = ((CFrame.new(Vector3.new(0,0,0),shootDirection) * CFrame.Angles(0,0,math.random()*2*math.pi))*CFrame.Angles(math.random()*Spread,0,0)).lookVector
				local hitObject, bulletPos = RayCast(Handle.Position, shootDirection, Range)
				local bullet
				-- Create a bullet here
				if hitObject then
					bullet = CreateBullet(bulletPos, hitObject)
				end
				if hitObject and hitObject.Parent then
					local hitHumanoid = hitObject.Parent:FindFirstChild("Humanoid") or hitObject.Parent.Parent:FindFirstChild'Humanoid'
					if hitHumanoid then
						local hitPlayer = game.Players:GetPlayerFromCharacter(hitHumanoid.Parent)
						if not GLib.IsTeammate(MyPlayer, hitPlayer) then
							GLib.TagHumanoid(MyPlayer, hitHumanoid, 1)
							hitHumanoid:TakeDamage(Damage)
							if bullet then
								bullet:Destroy()
								bullet = nil
								--bullet.Transparency = 1
							end
						end
					end
				end
			end

			local casing = CasingBase:Clone()
			casing.Position = Tool.Handle.Position + Vector3.new(0,1,0)
			casing.Velocity = (Vector3.new((math.random()-.5),(.5+math.random()),(math.random()-.5)) - 1.5*(Tool.Handle.CFrame * CFrame.Angles(0,math.pi/4,0)).lookVector)*20
			DebrisService:AddItem(casing, 2.5)
			casing.Parent = game.Workspace

			AmmoInClip = AmmoInClip - 1
			UpdateAmmo(AmmoInClip)
			wait(FireRate-.2)

			if AmmoInClip > 0 then
				if PumpTrack then
					PumpTrack:Play()
				end
				if Handle:FindFirstChild('PumpSound') then
					Handle.PumpSound:Play()
				end
				wait(.2)
			end
			Tool.SetIcon:FireClient(game.Players:GetPlayerFromCharacter(Tool.Parent), "rbxasset://textures\\GunCursor.png")
		end		
		IsShooting = false
		if AmmoInClip == 0 then
			Reload()
		end
		if RecoilTrack then
			RecoilTrack:Stop()
		end
	end
end

function UpdateAmmo(value)
	if WeaponGui and WeaponGui:FindFirstChild('AmmoHud') and WeaponGui.AmmoHud:FindFirstChild('ClipAmmo') then
		WeaponGui.AmmoHud.ClipAmmo.Text = AmmoInClip
	end
	--if WeaponGui and WeaponGui:FindFirstChild('AmmoHud') and WeaponGui.AmmoHud:FindFirstChild('TotalAmmo') then
	--	WeaponGui.AmmoHud.TotalAmmo.Text = SpareAmmo
	--end
end


function OnMouseDown()
	LeftButtonDown = true
	OnFire()
end

function OnMouseUp()
	LeftButtonDown = false
end

function OnKeyDown(key)
	if string.lower(key) == 'r' then
		Reload()
	end
end

Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'Mouse1' then
			local down, pos = ...
			
			if down then
				OnMouseDown()
			else
				OnMouseUp()
			end
		elseif action == 'Key' then
			local down, key = ...
			
			if down then
				OnKeyDown(key)
			end
		elseif action == 'MouseMove' then
			local pos = ...
			
			MOUSE_TARGET = pos
		end
	end
end)


function OnEquipped()
	EquipAnim = WaitForChild(Tool, 'Equip')
	PumpAnim = WaitForChild(Tool, 'Reload')
	FireSound  = WaitForChild(Handle, 'FireSound')

	MyCharacter = Tool.Parent
	MyPlayer = game:GetService('Players'):GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = MyCharacter:FindFirstChild('Humanoid')
	MyTorso = MyCharacter:FindFirstChild('Torso')
	WeaponGui = WaitForChild(Tool, 'WeaponHud'):Clone()
	if WeaponGui and MyPlayer then
		WeaponGui.Parent = MyPlayer.PlayerGui
		UpdateAmmo(AmmoInClip)
	end
	if EquipAnim then
		Tool.Grip = CFrame.new(0.132808685, 0.00749024749, 0.526850462, 0.925221086, 0.000443253666, 0.379427731, 0.00859767944, 0.999718785, -0.0221330915, -0.379331142, 0.0237402022, 0.924956799)
		EquipTrack = MyHumanoid:LoadAnimation(EquipAnim)
		EquipTrack:Play()
	end
	if PumpAnim then
		PumpTrack = MyHumanoid:LoadAnimation(PumpAnim)
	end

	Tool.SetIcon:FireClient(game.Players:GetPlayerFromCharacter(Tool.Parent), "rbxasset://textures\\GunCursor.png")
end


-- Unequip logic here
function OnUnequipped()
	LeftButtonDown = false
	Reloading = false
	MyCharacter = nil
	MyHumanoid = nil
	MyTorso = nil
	MyPlayer = nil
	if OnFireConnection then
		OnFireConnection:disconnect()
	end
	if OnReloadConnection then
		OnReloadConnection:disconnect()
	end
	if FlashHolder then
		FlashHolder = nil
	end
	if WeaponGui then
		WeaponGui.Parent = nil
		WeaponGui = nil
	end
	if EquipTrack then
		EquipTrack:Stop()
	end
	if PumpTrack then
		PumpTrack:Stop()
	end
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
