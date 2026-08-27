local Tool = script.Parent 
local Pos = Tool:WaitForChild('Pos')

local Camera = Game.Workspace.CurrentCamera 

local Character 
local Torso 

local Arrow = Instance.new('Part')
Arrow.FormFactor = 3
Arrow.Size = Vector3.new(1, 1, 4)
Arrow.Anchored = true 
Arrow.CanCollide = false 
Arrow.Name = 'Arrow'

local ArrowMesh = Instance.new('SpecialMesh')
ArrowMesh.Parent = Arrow 
ArrowMesh.Scale = Vector3.new(8, 8, 8)
ArrowMesh.MeshId = 'http://www.roblox.com/asset/?id=110309063'
ArrowMesh.TextureId = 'http://www.roblox.com/asset/?id=110324377'
ArrowMesh.VertexColor = Vector3.new(1, 1, 0)

local ArrowScales = { Vector3.new(1, 1, 1), Vector3.new(1.5, 1.5, 1.5),  Vector3.new(-1, -1, -1),Vector3.new(-1.5, -1.5, -1.5)} 

local function OnEquipped()
	Character = Tool.Parent 
	Torso = Character:WaitForChild('Torso') 
	Arrow.Parent = Camera 
	Equipped = true 
end

local function OnUnequipped()
	Equipped = false 
	Arrow.Parent = nil 
end

local ArrowCo = coroutine.create(function() end)
coroutine.resume(ArrowCo) 

local eggLocation 

Pos.Changed:connect(function()
	eggLocation = Pos.Value 
	if Torso then 
		Arrow.Parent = Camera 
		if ArrowCo == nil or coroutine.status(ArrowCo) == 'dead' then 
			print(coroutine.status(ArrowCo)) 
			ArrowCo = coroutine.create(function()			
				local count = 1 
				local pCount = 1
				while true do 
					if Equipped then 
						Arrow.CFrame = CFrame.new(Torso.Position + Vector3.new(0, 4, 0), Vector3.new(eggLocation.X, Torso.Position.Y + 4, eggLocation.Z)) 					
						local distance = (Torso.Position - eggLocation).magnitude
						pCount = pCount + 1
						if pCount%40 == 0 then print('DISTANCE - ', math.floor(distance)) end 
						if distance < 35 then 
							ArrowMesh.Scale = ArrowMesh.Scale + ArrowScales[(count%#ArrowScales) + 1]
							count = count + 1
						else 
							ArrowMesh.Scale = Vector3.new(8, 8, 8) 
						end 						
					end 
					wait(0.015)
				end 
			end)
			coroutine.resume(ArrowCo) 
		end   
	end 
end)

Tool.Equipped:connect(OnEquipped) 
Tool.Unequipped:connect(OnUnequipped) 