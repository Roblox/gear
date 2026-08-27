local Tool = script.Parent
local Character = nil

local Equipped = false

local POWER = 150

local function FireShirt(hitPosition, shirtId)
	local Part = Instance.new("Part")
	Part.BrickColor = BrickColor.new("White")
	Part.CanCollide = false
	Part.TopSurface = Enum.SurfaceType.Smooth
	Part.BottomSurface = Enum.SurfaceType.Smooth
	
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshId = "rbxassetid://80179115"
	Mesh.TextureId = "rbxassetid://80172875"
	Mesh.Parent = Part
	
	Part.Size = Vector3.new(2, 2, 3)
	local Vector = (hitPosition - Tool.Handle.Position).Unit
	Part.CFrame = CFrame.new(Tool.Handle.Position, Tool.Handle.Position + Vector) * CFrame.new(0, 0, 2)
	Part.Velocity = (Vector * POWER) + Vector3.new(0, 20, 0)
	Part.Touched:connect(function(hit)
		if hit and hit.Parent then
			if hit.Parent ~= Tool.Parent and hit.Name ~= "Handle" and hit.Name ~= "Effect" then
				local Humanoid = hit.Parent:FindFirstChild("Humanoid")
				if Humanoid then
					for i, v in ipairs(hit.Parent:GetChildren()) do
						if v:IsA("Shirt") then
							v:Destroy()
						end
					end
					
					local NewShirt = Instance.new("Shirt")
					NewShirt.ShirtTemplate = "rbxassetid://" .. tostring(shirtId - 1)
					NewShirt.Parent = hit.Parent
				end
				
				Part:Destroy()
			end
		end
	end)
	
	Tool.Handle.Sound:Play()
	game:GetService("Debris"):AddItem(Part, 10)
	Part.Parent = workspace
end

local LaunchShirtEvent = Instance.new("RemoteEvent")
LaunchShirtEvent.Name = "LaunchShirt"
LaunchShirtEvent.OnServerEvent:connect(function(player, mouseHitPosition, shirtId)
	if not Equipped or Character ~= player.Character then return end
	FireShirt(mouseHitPosition, shirtId)
end)
LaunchShirtEvent.Parent = Tool

Tool.Equipped:connect(function()
	Equipped = true
	Character = Tool.Parent
end)

Tool.Unequipped:connect(function()
	Equipped = false
	Character = nil
end)