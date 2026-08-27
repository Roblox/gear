function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do print("waiting for " .. child) wait() end
	return parent[child]
end

local handle = WaitForChild(script.Parent,'Handle')
local shhSound= WaitForChild(handle,'Shh')

local HoldAni = WaitForChild(script.Parent,'holdAni')
local Billboard = WaitForChild(script.Parent,'BillboardGui')
local GuiImage = WaitForChild(Billboard,'image')

local previewHat = WaitForChild(script.Parent,'PreviewHat')
previewHat:Destroy()

local Character
local Player

local SphereMesh = WaitForChild(script.Parent,'SphereMesh')

local Hat = Instance.new('Hat')
Hat.AttachmentPos = Vector3.new(0.05, 0.2, 0.3)
do
	local hpart = Instance.new('Part')
	hpart.FormFactor = 'Custom'
	hpart.Size = Vector3.new(1.45, 0.38, 2)
	hpart.Name = 'Handle'
	local hmesh = Instance.new('SpecialMesh')
	hmesh.MeshId = 'http://www.roblox.com/asset/?id=104596746'
	hmesh.TextureId = 'http://www.roblox.com/asset/?id=104595186'
	hmesh.Scale = Vector3.new(1.1,1.1,1.1)
	hmesh.Parent = hpart
	hpart.Parent = Hat
end

local HoldAniTrack

local Equipped = false

local WeaponRange = 40

function VisualEffect(part)
	local EffectLength = 1.5
	local StartSphereScale = Vector3.new(.1,.1,.1)
	local EndSphereScale = Vector3.new(20,20,20)
	
	local sphere = Instance.new('Part')
	sphere.CanCollide = false
	sphere.Anchored = true
	sphere.Transparency = 0.5
	sphere.FormFactor = Enum.FormFactor.Custom
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(0.2, 0.2, 0.2)
	sphere.CFrame = CFrame.new(part.CFrame.p)
	sphere.TopSurface = Enum.SurfaceType.Smooth
	sphere.BottomSurface  = Enum.SurfaceType.Smooth
	sphere.Name = 'water' --LOL-CANO
	sphere.BrickColor=BrickColor.new('Cyan')
	sphere.Transparency = 1
	-- Add 0.2 for the wait below
	game.Debris:AddItem(sphere, EffectLength + 1)
	sphere.Parent = Workspace
	
	local sphereMesh = WaitForChild(script.Parent,'SphereMesh'):Clone()
	sphereMesh.VertexColor=Vector3.new(1,1,1)
	sphereMesh.Scale = Vector3.new(.1,.1,.1)
	sphereMesh.Parent = sphere
	
	
	
	sphere.Transparency = 0
	local startTime=time()
	while time()-startTime<EffectLength do
		sphere.CFrame = CFrame.new(part.CFrame.p)
		sphereMesh.Scale=StartSphereScale:Lerp(EndSphereScale,(time()-startTime)/EffectLength)+Vector3.new(math.random(),math.random(),math.random())
		sphere.Transparency=(time()-startTime)/EffectLength
		wait()
	end
end


function onEquipped(nmouse)
	if not Equipped then
		
	
		mouse=nmouse
		Equipped = true
		Character=script.Parent.Parent
		Hat.Parent = Character
		Player = game.Players:GetPlayerFromCharacter(Character)
		local myTorso = WaitForChild(Character,'Torso')

	end
	
end


function onUnequipped()
	Equipped = false
	Hat.Parent = nil
	print("I unequipped!")
end

function onActivate()
	if script.Parent.Enabled and Character and Character:FindFirstChild('Head') then
		script.Parent.Enabled=false
		Billboard.Parent = game.Workspace
		Billboard.Adornee = Character:FindFirstChild('Head')
		GuiImage.Visible = true
		shhSound:Play()
		VisualEffect(handle)
		local playerconnections = {}
		for _,i in pairs(game.Players:GetPlayers()) do
				if i.Character and i.Character:FindFirstChild('Right Arm') then
					local dist = (Character.Head.CFrame.p-i.Character['Right Arm'].CFrame.p).magnitude
					if i~=Player and dist<WeaponRange then
						for ii, v in pairs(i.Character:GetChildren()) do --Fix implemented by Luckymaxer
							if v:IsA("Tool") then
								v.Parent = i.Backpack
							end
						end
						local equipconnection = i.Character.ChildAdded:connect(function(child)
							wait()
							if child and child:IsA("Tool") and child.Parent then
								child.Parent = i.Backpack
							end
						end)
						table.insert(playerconnections, equipconnection)
					end
				end
		end
		wait(8)
		for i, v in pairs(playerconnections) do
			v:disconnect()
		end
		playerconnections = {}
		
		wait(8)
		Billboard.Adornee = nil
		Billboard.Parent = nil
		wait(5)
		script.Parent.Enabled=true
	end
end

script.Parent.Unequipped:connect(onUnequipped)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Activated:connect(onActivate)

