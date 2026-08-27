local Tool = script.Parent
local Star = Tool.Handle

local starActive = Tool:FindFirstChild("StarActive")

local starClone

local vCharacter
local myTorso

local duration = 20

local debris = game:GetService("Debris")

local bav = Instance.new("BodyAngularVelocity")
bav.P = 50000
bav.maxTorque = Vector3.new(0, 0, 0)
bav.Name = "RV"
bav.angularvelocity = Vector3.new(0, 0, 10)

bp = Instance.new("BodyPosition")
bp.Name = "Stick"
bp.P = 100000
bp.maxForce = Vector3.new(bp.P, bp.P, bp.P)

local sh = Instance.new("Part")
sh.Name = "Shield"
sh.Shape = "Ball"
sh.FormFactor = 3
sh.CanCollide = false
sh.Size = Vector3.new(8, 8, 8)
sh.Transparency = 0.8

local shieldMesh = Instance.new("SpecialMesh") 
shieldMesh.MeshType = "FileMesh" 
shieldMesh.Name = "Mesh" 
shieldMesh.MeshId = "http://www.roblox.com/asset/?id=48423624" 
shieldMesh.TextureId = "http://www.roblox.com/asset/?id=48598142" 
shieldMesh.Scale = Vector3.new(0.275, 0.275, 0.275) 
shieldMesh.Parent = sh

bf = Instance.new("BodyForce")
bf.Name = "Float"
bf.force = Vector3.new(0, (Star:GetMass() + sh:GetMass()) * workspace.Gravity, 0)

local newSH

local newBP

local connection 

function blow(hit, char)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	--vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(char)
	myHumanoid = char:FindFirstChild("Humanoid")
	if myHumanoid ~= nil and humanoid ~= nil and myHumanoid ~= humanoid then 
		tagHumanoid(humanoid, vPlayer)
		humanoid:TakeDamage(5)
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		creator = Instance.new("ObjectValue")
		creator.Value = player
		creator.Name = "creator"
		creator.Parent = humanoid
	end
	debris:addItem(creator, 1)
end

function dissipate(char)
	myHumanoid = char.Humanoid
	while duration > 0 do 		
		newBP.position = char.Head.Position + Vector3.new(0, 1.5, 0)
		duration = duration - 0.125
		wait(0.125)
	end
	if starClone then starClone:Remove() end
	if newSH then newSH:Remove() end
	if connection then connection:disconnect() end
	starActive.Value = 0	
	Star.Transparency = 0.0
	duration = 20
	ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 100
	myHumanoid.Health = ratio * 100
end

function onKeyDown(key)	
	char = vCharacter
	head = vCharacter:FindFirstChild("Head")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if head == nil or myTorso == nil or myHumanoid == nil then return end
	if key:lower() == "x" then		
		if starActive.Value == 0 then 
			print("Activating Shield")
			starActive.Value = 1
			starClone = Star:Clone()
			starClone.CFrame = Star.CFrame * CFrame.Angles(0, math.pi/2, 0)
			starClone.Parent = game.Workspace

			starClone.Velocity = Vector3.new(0, 0, 0)

			starClone.Position = head.Position + Vector3.new(0, 1.5, 0)
			Star.Transparency = 1.0					

			newBF = bf:Clone()
			newBF.Parent = starClone

			newBP = bp:Clone()
			newBP.Parent = starClone

			newBP.position = head.Position + Vector3.new(0, 1.5, 0)
				
			newSH = sh:Clone()			
			newSH.Position = myTorso.Position
			newSH.Parent = game.Workspace

			newSH.Velocity = Vector3.new(0, 0, 0)

			weld = Instance.new("Motor")
			weld.Part0 = starClone
			weld.Part1 = newSH
			weld.C1 = CFrame.new(Vector3.new(0, 3, 0))	
			weld.C0 = weld.C0 * CFrame.Angles(math.pi/2, 0, 0)
			weld.Parent = starClone
			weld.Name = "ShieldWeld"
			weld.DesiredAngle = CFrame.new(Vector3.new(0, 0, 0)) * CFrame.Angles(0, math.pi, 0)

			connection = newSH.Touched:connect(function(hit) blow(hit, vCharacter) end)		

			newBAV = bav:Clone()
			newBAV.Parent = starClone
			ratio = myHumanoid.Health/myHumanoid.MaxHealth
			myHumanoid.MaxHealth = 175
			myHumanoid.Health = ratio * 175
			co = coroutine.create(dissipate)
			coroutine.resume(co, char)
		end
	end
end



function onEquipped(mouse)
	vCharacter = Tool.Parent
	if mouse then mouse.KeyDown:connect(onKeyDown) end
end

function onUnequipped()
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
