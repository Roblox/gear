--[[
	By ArceusInator
--]]
local GLib = require(206209239)
local Tool = script.Parent
local Handle = Tool:WaitForChild'Handle'

local Shield, GhostWeld, GhostHandle
local Equipped = false

Tool.Equipped:connect(function()
	if Equipped then return end
	Equipped = true
	
	local character = GLib.GetCharacter(Tool)
	local leftArm = character and character:FindFirstChild'Left Arm'
	
	if leftArm and leftArm:IsA'BasePart' then
		-- Weld the shield to the left arm
		Shield = GLib.Create'Part'{
			Name = 'Shield',
			BrickColor = BrickColor.new'Bright violet',
			Material = 'Metal',
			CanCollide = false,
			Locked = true,
			FormFactor = 'Custom',
			Size = Vector3.new(2.13, 3.65, 0.2),
			TopSurface = 'Smooth',
			BottomSurface = 'Smooth',
			
			GLib.Create'SpecialMesh'{
				Name = 'Mesh',
				MeshId = 'http://www.roblox.com/asset/?id=242903692',
				TextureId = 'http://www.roblox.com/asset/?id=242903736'
			}
		}
		local shieldWeld = GLib.Create'Weld'{
			Name = 'ShieldWeld',
			Parent = Shield,
			Part0 = leftArm,
			Part1 = Shield,
			C0 = CFrame.Angles(0, math.pi/2, -math.pi/2) * CFrame.new(0, -0.25, -0.5)
		}
		GhostHandle = GLib.Create'Part'{
			Name = 'GhostHandle',
			Transparency = 1,
			FormFactor = 'Custom',
			CanCollide = false,
			Locked = true,
			Size = Vector3.new(0.3, 0.2, 2.71),
			TopSurface = 'Smooth',
			BottomSurface = 'Smooth'
		}
		for i=1, 8 do
			GLib.Create'ParticleEmitter'{
				Name = 'Emitter',
				Color = ColorSequence.new(Color3.new(1,1,1)),
				LightEmission = 1,
				Size = NumberSequence.new(0.3),
				Texture = 'rbxasset://textures/spark.png',
				ZOffset = -1,
				Lifetime = NumberRange.new(0.05),
				Rate = 1000,
				RotSpeed = NumberRange.new(1000),
				Speed = NumberRange.new(0),
				Enabled = false,
				Parent = GhostHandle
			}
		end
		GhostWeld = GLib.Create'Weld'{
			Name = 'GhostWeld',
			Parent = Handle,
			Part0 = Handle,
			Part1 = GhostHandle,
			C0 = CFrame.new(0, 0, -0.7)
		}
		
		Tool.Shield.Value = Shield
		Shield.Parent = workspace -- It won't be traced back to the character if a projectile hits it
		GhostHandle.Parent = Tool
	end
end)

Tool.Unequipped:connect(function()
	if not Equipped then return end
	Equipped = false
	
	Tool.Shield.Value = nil
	if Shield then Shield:Destroy() Shield = nil end
	if GhostWeld then GhostWeld:Destroy() GhostWeld = nil end
	if GhostHandle then GhostHandle:Destroy() GhostHandle = nil end
end)