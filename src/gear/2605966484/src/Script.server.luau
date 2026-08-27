-- Recreated by StarWars
local Debris = game:GetService("Debris")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local Animations = {
	Eat = {Animation = tool.Animations.R6.Eat},
	R15Eat = {Animation = tool.Animations.R15.Eat},
}

function InvokeClient(mode, value)
	if not mode then return end
	
	local result
	pcall(function()
		result = gear.ClientControls:InvokeClient(gear.Player, mode, value)
	end)
	
	return result
end

function Fire(direction)
	local head = gear.Character and gear.Character:FindFirstChild("Head")
	
	if head then
		for i = 1, 3 do
			local part = Instance.new("Part")
			part.Name = "Effect"
			part.Color = Color3.fromRGB(218, 133, 65)
			part.Shape = Enum.PartType.Ball
			part.Size = Vector3.new(2, 2, 2)
			part.CFrame = CFrame.new(head.CFrame.Position + direction * 4)
			part.Velocity = direction * math.random(50, 80) + Vector3.new(0, 15, 0)
			
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshId = "rbxassetid://" .. 165709404
			mesh.TextureId = "rbxassetid://" .. 2159442418
			mesh.Parent = part
			
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://" .. 167488249
			sound.Name = "Pop"
			sound.Parent = part
			
			-- Fire
			local fire = Instance.new("Fire")
			fire.Color = Color3.fromRGB(0, 170, 255)
			fire.SecondaryColor = Color3.fromRGB(55, 138, 139)
			fire.Parent = part
			
			part.Parent = workspace
			
			Debris:AddItem(part, 5)
			
			local debounce = false
			part.Touched:Connect(function(hit)
				if hit and hit.Parent and not debounce then
					 local parentTo = hit.Parent
					if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
						parentTo = parentTo.Parent
					end
					
					local humanoid = parentTo:FindFirstChildOfClass("Humanoid")
					local rootPart = humanoid and humanoid.RootPart
					
					if humanoid and rootPart and humanoid.Health > 0 and rootPart ~= gear.RootPart then
						debounce = true
						local fire2 = Instance.new("Fire")
						fire2.Parent = rootPart
						fire2.Color = fire.Color
						fire2.SecondaryColor = fire.SecondaryColor
						
						Debris:AddItem(fire2, 10)
						fire2.Size = 15
						local cache = humanoid.WalkSpeed 
						for i = 1, 3 do
							humanoid:TakeDamage(19)
							humanoid.WalkSpeed = 0
							wait(1.5)
						end
						
						humanoid.WalkSpeed = cache
						
						fire2:Destroy()
					else
						if debounce then
							debounce = false
							sound:Play()
							part.Velocity = part.Velocity + Vector3.new(0, 30, 0)
							wait(0.5)
							debounce = true
						end
					end
				end
			end)
			wait(0.5)
		end
	end
end

tool.Activated:Connect(function()
	if tool.Enabled and gear:IsPlayerAlive() then
		tool.Enabled = false
		
		local mouseData = InvokeClient("GetMouseData")
		local anim = Animations.Eat
		if gear.Humanoid and gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
			anim = Animations.R15Eat
		end
		InvokeClient("PlayAnimation", anim)
		wait(2)
		if mouseData then
			Fire((mouseData.Position - gear.RootPart.CFrame.Position).Unit)
		end
		tool.Enabled = true
	end
end)

