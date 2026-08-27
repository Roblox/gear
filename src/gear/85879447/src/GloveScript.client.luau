local function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do 
		wait()
	end 
	return parent[child]
end

local Tool = script.Parent 
local Glove = Tool.Handle

local RBX_Debris = game:GetService('Debris')

local Character
local Player 
local Torso
local Humanoid 

local PlayerGui 

Tool.Enabled = true 

local Mouse = nil 

local Charge = 0 
local Enabled = true 

local Glove_Gui = nil 
local Glove_Frame = nil 
local Glove_FillFrame = nil

local Fry_Sound = waitForChild(Glove, 'FrySound')
local Fry2_Sound = waitForChild(Glove, 'FrySound_2')

local ForceCharge_Anim 
local ForceRelease_Anim 

local Gui = {} -- Class, that contains functions to create various gui objects

-- Generic object Create function, which I am using to create Gui's 
-- Thanks to Stravant! 
function Gui:Create(guiType)
	return function(data)
		local obj = Instance.new(guiType)
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

function Gui:Clone(obj)
	return function(data)
		local cloneObj = obj:Clone()
		for k, v in pairs(data) do 
			if type(k) == "number" then 
				v.Parent = cloneObj 
			else 
				cloneObj[k] = v
			end
		end 
		return cloneObj
	end
end

local Lightning_Part = Instance.new('Part') 
Lightning_Part.Name = 'Lightning'
Lightning_Part.FormFactor = 3 
Lightning_Part.Size = Vector3.new(1, 1, 1) 
Lightning_Part.Anchored = false
Lightning_Part.CanCollide = false 

local Lightning_Mesh = Instance.new('SpecialMesh') 
Lightning_Mesh.Scale = Vector3.new(0.15, 0.15, 0.15) 
Lightning_Mesh.MeshId = "http://www.roblox.com/asset/?id=65419828" 
Lightning_Mesh.TextureId = "http://www.roblox.com/asset/?id=65419395" 
Lightning_Mesh.Parent = Lightning_Part 

local Sphere = Instance.new('Part') 
Sphere.Size = Vector3.new(0.5, 0.5, 0.5) 
Sphere.Transparency = 0.8 
Sphere.Shape = 'Ball' 
Sphere.FormFactor = 3 
Sphere.Name = 'Energy'

local Sphere_Mesh = Instance.new('SpecialMesh') 
Sphere_Mesh.MeshType = 'FileMesh'
Sphere_Mesh.Name = 'Mesh' 
Sphere_Mesh.MeshId = "http://www.roblox.com/asset/?id=48423624" 
Sphere_Mesh.TextureId = "http://www.roblox.com/asset/?id=48598142" 
Sphere_Mesh.Scale = Vector3.new(0.01, 0.01, 0.01) 
Sphere_Mesh.Parent = Sphere 

local Lightning_List = {} 

local MaxLightning = 16 

local EnergySphere = Instance.new('Part')
local BlastSphere = Instance.new('Part')

local function Blow(hit, laser)
	if (#Lightning_List > 4 or laser) and hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild('Humanoid')
		if hit.Parent:IsA('Hat') and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild('Humanoid')
		end 
		if humanoid then 
			humanoid:TakeDamage(7.5 * #Lightning_List/4)
			humanoid.Sit = true 

			if laser then 
				humanoid:TakeDamage(22.5)
			end 

			local torso = waitForChild(humanoid.Parent, 'Torso')

			BlastSphere = Sphere:Clone() 
			local bMesh = waitForChild(BlastSphere, 'Mesh')
			bMesh.Scale = Vector3.new(0.25, 0.25, 0.25)

			BlastSphere.CFrame = hit.CFrame
			BlastSphere.Parent = game.Workspace

			RBX_Debris:AddItem(BlastSphere, 0.5)

			local bVelocity = Instance.new('BodyVelocity')
			bVelocity.P = 200000
			bVelocity.maxForce = Vector3.new(bVelocity.P, bVelocity.P, bVelocity.P) * 10
			bVelocity.velocity = (torso.Position - Torso.Position).unit * 45.0 
			bVelocity.Parent = torso 

			RBX_Debris:AddItem(bVelocity, 0.75)
		end 
	end 
end 

local function FireBeam(beamStart, beamEnd) 
	local distance = (beamStart - beamEnd).magnitude 
	if distance > 150 then distance = 150 end 
	local laser = Instance.new('Part') 
	laser.Name = 'Bullet'
	laser.Anchored = true 
	laser.CanCollide = false 
	laser.Shape = 'Block'
	laser.formFactor = 'Custom'
	laser.Size = Vector3.new(2.0, 2.0, distance + 0.2) 
	laser.Material = Enum.Material.Plastic 
	laser.Locked = true 
	laser.TopSurface = 0 
	laser.BottomSurface = 0 
	laser.BrickColor = BrickColor.new('Bright red') 
	laser.CFrame = CFrame.new(beamEnd, beamStart) * CFrame.new(0, 0, -distance/2) 
	laser.Parent = game.Workspace 
	laser.Touched:connect(function(hit) Blow(hit, laser) end) 
	RBX_Debris:AddItem(laser, 0.35) 
end 


local function GenerateForce()
	if Charge < 20 then 
		Charge = 0
		Glove_FillFrame.Size = UDim2.new(0, 0, 0, 0)
		for i = 1, #Lightning_List do 
			Lightning_List[i]:Destroy()
		end 
		Lightning_List = {}
		if EnergySphere then EnergySphere:Destroy() end 
		return 
	end 

	-- do effect here pl0x 

	Humanoid.WalkSpeed = 9.0 

	wait(0.75)

	ForceRelease_Anim = Humanoid:LoadAnimation(Tool.ForceReleaseAnim)
	if ForceRelease_Anim then ForceRelease_Anim:Play() end 

	FireBeam(Glove.Position, Glove.Position + Glove.CFrame.lookVector * 30.0)

	if Fry_Sound then Fry_Sound:Stop() end 
	if Fry2_Sound then Fry2_Sound:Stop() end 

	-- BEAM CANNON 

	local bVelocity = Instance.new('BodyVelocity')
	bVelocity.P = 200000
	bVelocity.maxForce = Vector3.new(bVelocity.P, bVelocity.P, bVelocity.P) * 10
	bVelocity.velocity = Torso.CFrame.lookVector * - 60 
	bVelocity.Parent = Torso 

	RBX_Debris:AddItem(bVelocity, #Lightning_List/(MaxLightning * 2))	
	Humanoid.WalkSpeed = 16.0

	Charge = 0
	Glove_FillFrame.Size = UDim2.new(0, 0, 0, 0)
	for i = 1, #Lightning_List do 
		Lightning_List[i]:Destroy()
	end 
	Lightning_List = {}
	if EnergySphere then EnergySphere:Destroy() end 

	wait(0.35)
	if ForceRelease_Anim then ForceRelease_Anim:Stop() end 
end 

local function CreateLightning()
	if #Lightning_List  < MaxLightning then 
		local lightning = Lightning_Part:Clone()
		lightning.Parent = Glove 


		local lWeld = Instance.new('Weld')
		lWeld.Part0 = Glove 
		lWeld.Part1 = lightning 
		lWeld.Parent = lightning 
		tick()
		lWeld.C1 = CFrame.new(math.random(-1000, 1000)/1000, math.random(-1000, 1000)/1000, math.random(-1000, 1000)/1000) * CFrame.Angles(math.random(), math.random(), math.random())

		table.insert(Lightning_List, lightning)
		Spawn(function()
			wait(0.25)
			lightning.Transparency = 1.0  
		end)

		if #Lightning_List == MaxLightning then
			Spawn(function()
				local sign = -1 
				while #Lightning_List == MaxLightning do 					
					for i = 1, #Lightning_List do 
						if Lightning_List[i] then 
							if sign == 1 then 
								Lightning_List[i].Transparency = 0.0 
							else 
								Lightning_List[i].Transparency = 1.0 
							end 
						end
						sign = sign * -1
						wait()
					end 
					wait()		
					sign = sign * -1			
				end 
			end) 
		end 
	end 
end

local function OnEquip(mouse)
	Mouse = mouse 

	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Torso = waitForChild(Character, 'Torso')
	Humanoid = waitForChild(Character, 'Humanoid')

	PlayerGui = waitForChild(Player, 'PlayerGui')

	if PlayerGui:FindFirstChild('GloveGui') == nil then 
		Glove_Gui = Gui:Create'ScreenGui'{
							Name = 'GloveGui',
							Parent = PlayerGui
						}

		Glove_Frame = Gui:Create'Frame'{
							Name = 'GloveFrame',
							Parent = Glove_Gui,
							Size = UDim2.new(0, 250, 0, 25),
							Position = UDim2.new(0.5, -125, 1, -110),
							BackgroundTransparency = 1.0,
							Style = Enum.FrameStyle.RobloxSquare							
						}

		Glove_FillFrame = Gui:Clone(Glove_Frame){
							Name = 'FillFrame',
							Parent = Glove_Frame,
							BackgroundTransparency = 0.0,
							Size = UDim2.new(0, 0, 0, 0),
							Position = UDim2.new(0, -8, 0, -8),
							BackgroundColor3 = Color3.new(1, 0, 0),
							Style = Enum.FrameStyle.Custom, 
							ZIndex = 5.0
						}
	else 
		Glove_Gui = PlayerGui.GloveGui
		Glove_Frame = waitForChild(Glove_Gui, 'GloveFrame')
		Glove_FillFrame = waitForChild(Glove_Frame, 'FillFrame')
	end 

	Mouse.Button1Down:connect(function()
		Enabled = true 
		if Fry_Sound then Fry_Sound:Play() end 
		wait()
		if Fry2_Sound then Fry2_Sound:Play() end 
		ForceCharge_Anim = Humanoid:LoadAnimation(Tool.ForceChargeAnim)
		if ForceCharge_Anim then ForceCharge_Anim:Play() end 
		while Enabled do 
			Charge = math.min(Charge + 1, 97)			
			Glove_FillFrame.Size = UDim2.new(Charge/97, 16, 0, 25)
			if Charge%6 == 0 then 
				CreateLightning() 
			end 

			if not EnergySphere.Parent then 
				EnergySphere = Sphere:Clone()
				EnergySphere.Parent = Glove 

				local eWeld = Instance.new('Weld')
				eWeld.Part0 = Glove 
				eWeld.Part1 = EnergySphere 
				eWeld.Parent = EnergySphere

				eWeld.C1 = CFrame.new()
			else 
				local mesh = waitForChild(EnergySphere, 'Mesh')
				local size = math.min(mesh.Scale.X + 0.002, 0.1)
				mesh.Scale = Vector3.new(1, 1, 1) * size 
			end 
			wait()
		end 
		if ForceCharge_Anim then ForceCharge_Anim:Stop() end 
	end)

	Mouse.Button1Up:connect(function()
		Enabled = false 
		GenerateForce() 
	end)
end 

local function OnUnequip()
	if Glove_Gui then Glove_Gui:Destroy() end
	if Fry_Sound then Fry_Sound:Stop() end 
	if Fry2_Sound then Fry2_Sound:Stop() end 

	if ForceCharge_Anim then ForceCharge_Anim:Stop() end 
	if ForceRelease_Anim then ForceRelease_Anim:Stop() end 

	for i = 1, #Lightning_List do 
		if Lightning_List[i] then 
			Lightning_List[i]:Destroy()
		end 
	end 
	Lightning_List = {} 
	Charge = 0 
	Glove_FillFrame.Size = UDim2.new(0, 0, 0, 0)
	if EnergySphere then EnergySphere:Destroy() end 
end 

Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)

Glove.Touched:connect(function(hit)
	Blow(hit, nil)
end)
