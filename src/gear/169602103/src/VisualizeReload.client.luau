-----------------
--| Constants |--
-----------------

local ROCKET_MESH_ID = 'http://www.roblox.com/asset/?id=94690081'
local ROCKET_MESH_SCALE = Vector3.new(1, 1, 1)

local ROCKET_SHOW_TIME = 1.5 -- Seconds after animation begins to show the rocket
local ROCKET_HIDE_TIME = 2.2 -- Seconds after animation begins to hide the rocket

-----------------
--| Variables |--
-----------------

local Tool = script.Parent
local ToolHandle = Tool.Handle

local MyModel = nil
local ReloadRocket = nil

local StillEquipped = false

-----------------
--| Functions |--
-----------------

local function MakeReloadRocket()
	local reloadRocket = Instance.new('Part')
	reloadRocket.Name = "Ammo"
	reloadRocket.FormFactor = Enum.FormFactor.Custom --NOTE: This must be done before changing Size
	reloadRocket.Size = Vector3.new() -- As small as possible

	local mesh = Instance.new('SpecialMesh', reloadRocket)
	mesh.MeshId = ROCKET_MESH_ID
	mesh.Scale = ROCKET_MESH_SCALE
	mesh.TextureId = ToolHandle.Mesh.TextureId

	return reloadRocket
end

local function OnEquipped()
	MyModel = Tool.Parent
	ReloadRocket = MakeReloadRocket()
end

local function OnChanged(property)
	if property == 'Enabled' and Tool.Enabled == false then
		-- Show the next rocket going into the launcher
		StillEquipped = true
		wait(ROCKET_SHOW_TIME)
		if StillEquipped then
			local torso = MyModel:FindFirstChild('Torso')
			if torso and torso:FindFirstChild('Left Shoulder') then
				local leftArm = MyModel:FindFirstChild('Left Arm')
				if leftArm then
					local weld = ReloadRocket:FindFirstChild('Weld')
					if not weld then
						weld = Instance.new('Weld')
						weld.Part0 = leftArm
						weld.Part1 = ReloadRocket
						weld.C1 = CFrame.new(Vector3.new(0, 1, 0))
						weld.Parent = ReloadRocket
					end
					ReloadRocket.Parent = MyModel
				end
				wait(ROCKET_HIDE_TIME - ROCKET_SHOW_TIME)
				if StillEquipped and ReloadRocket.Parent == MyModel then
					ReloadRocket.Parent = nil
				end
			end
		end
	end
end

local function OnUnequipped()
	StillEquipped = false
	ReloadRocket:Destroy()
	ReloadRocket = nil
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Changed:connect(OnChanged)
Tool.Unequipped:connect(OnUnequipped)
