--Stickmasterluke (7/18/18)


tool = script.Parent
handle = tool:WaitForChild("Handle")
local fairyScript = script:WaitForChild('FairyScript')
local bitParticleEmitter = script:WaitForChild('BitParticleEmitter')
local healingParticleEmitter = script:WaitForChild('BitHealingParticleEmitter')


local BASE_URL = "http://www.roblox.com/asset/?id="
local TEXTUREID = "2098377090"
local SCALE = 5--2.5
local MESH_SCALE = .75

local created = false


local partTemplate = Instance.new('Part')
partTemplate.CanCollide = false
partTemplate.TopSurface = 'Smooth'
partTemplate.BottomSurface = 'Smooth'


tool.Equipped:connect(function()
	local character = tool.Parent
	if not created and character and character.Parent == workspace then
		local humanoid = character:FindFirstChild('Humanoid')
		local hrp = character:FindFirstChild('HumanoidRootPart')
		if humanoid and humanoid.Health > 0 and hrp then
			created = true
			handle.Transparency = 1

			local fairy = partTemplate:clone()
			fairy.Name = character.Name.."'s".."Fairy"
			fairy.Size = Vector3.new(.6,1,.6) * SCALE
			fairy.CFrame = hrp.CFrame

			bitParticleEmitter:clone().Parent = fairy
			healingParticleEmitter:clone().Parent = fairy

			local fairyMesh = Instance.new('SpecialMesh')
			fairyMesh.MeshType = Enum.MeshType.FileMesh
			fairyMesh.MeshId = BASE_URL..'2098375558'
			fairyMesh.Scale = Vector3.new(1,1,1) * SCALE/MESH_SCALE
			fairyMesh.TextureId = BASE_URL..TEXTUREID
			fairyMesh.Parent = fairy


			-------------------------------------------------
			-------------------Left Wing---------------------
			local leftWing = partTemplate:clone()
			leftWing.Name = 'LeftWing'
			leftWing.Size = Vector3.new(.5,.5,.2) * SCALE

			local wingMesh = Instance.new('SpecialMesh')
			wingMesh.MeshType = Enum.MeshType.FileMesh
			wingMesh.MeshId = BASE_URL..'2098376327'
			wingMesh.Scale = Vector3.new(1,1,1) * SCALE/MESH_SCALE
			wingMesh.TextureId = BASE_URL..TEXTUREID
			wingMesh.Parent = leftWing

			local jointLW = Instance.new('Motor')
			jointLW.Name = 'LeftWingJoint'
			jointLW.Part0 = fairy
			jointLW.Part1 = leftWing
			jointLW.C0 = CFrame.new(Vector3.new(-.15,0,0)*SCALE) * CFrame.Angles(math.pi*.5,0,0)
			jointLW.C1 = CFrame.new(Vector3.new(.15,-.07,-.25)*SCALE) * CFrame.Angles(math.pi*.5,0,0)
			jointLW.MaxVelocity = .1
			jointLW.Parent = leftWing

			leftWing.Parent = fairy
			-------------------------------------------------

			-------------------------------------------------
			-------------------Right Wing--------------------
			local rightWing = partTemplate:clone()
			rightWing.Name = 'RightWing'
			rightWing.Size = Vector3.new(.5,.5,.2) * SCALE

			local wingMesh = Instance.new('SpecialMesh')
			wingMesh.MeshType = Enum.MeshType.FileMesh
			wingMesh.MeshId = BASE_URL..'2098376725'
			wingMesh.Scale = Vector3.new(1,1,1) * SCALE/MESH_SCALE
			wingMesh.TextureId = BASE_URL..TEXTUREID
			wingMesh.Parent = rightWing

			local jointRW = Instance.new('Motor')
			jointRW.Name = 'RightWingJoint'
			jointRW.Part0 = fairy
			jointRW.Part1 = rightWing
			jointRW.C0 = CFrame.new(Vector3.new(.15,0,0)*SCALE) * CFrame.Angles(math.pi*.5,0,0)
			jointRW.C1 = CFrame.new(Vector3.new(-.15,-.07,-.25)*SCALE) * CFrame.Angles(math.pi*.5,0,0)
			jointRW.MaxVelocity = .1
			jointRW.Parent = rightWing

			rightWing.Parent = fairy
			-------------------------------------------------


			-------------------------------------------------
			---------------------Navi 1----------------------
			local navi1 = partTemplate:clone()
			navi1.Name = 'Navi1'
			navi1.Size = Vector3.new(.5,.4,.4) * SCALE

			local navi1Mesh = Instance.new('SpecialMesh')
			navi1Mesh.MeshType = Enum.MeshType.FileMesh
			navi1Mesh.MeshId = BASE_URL..'2098375051'
			navi1Mesh.Scale = Vector3.new(1,1,1) * SCALE/MESH_SCALE
			navi1Mesh.TextureId = BASE_URL..TEXTUREID
			navi1Mesh.Parent = navi1

			local jointN1 = Instance.new('Motor')
			jointN1.Name = 'NaviJoint'
			jointN1.Part0 = fairy
			jointN1.Part1 = navi1
			jointN1.C0 = CFrame.new(Vector3.new(.5, .5, .5)*SCALE)
			jointN1.C1 = CFrame.new(0,0,0)
			jointN1.MaxVelocity = .01
			jointN1.Parent = navi1

			navi1.Parent = fairy
			-------------------------------------------------

			-------------------------------------------------
			---------------------Navi 2----------------------
			local navi2 = partTemplate:clone()
			navi2.Name = 'Navi2'
			navi2.Size = Vector3.new(.5,.4,.4) * SCALE

			local navi2Mesh = Instance.new('SpecialMesh')
			navi2Mesh.MeshType = Enum.MeshType.FileMesh
			navi2Mesh.MeshId = BASE_URL..'2098375051'
			navi2Mesh.Scale = Vector3.new(1,1,1) * SCALE/MESH_SCALE
			navi2Mesh.TextureId = BASE_URL..TEXTUREID
			navi2Mesh.Parent = navi2

			local jointN2 = Instance.new('Motor')
			jointN2.Name = 'NaviJoint'
			jointN2.Part0 = fairy
			jointN2.Part1 = navi2
			jointN2.C0 = CFrame.new(Vector3.new(-.25, .75, .25)*SCALE)
			jointN2.C1 = CFrame.new(0,0,0)
			jointN2.MaxVelocity = .01
			jointN2.Parent = navi2

			navi2.Parent = fairy
			-------------------------------------------------


			local bp = Instance.new('BodyPosition')
			bp.Name = 'BodyPosition'
			bp.MaxForce = Vector3.new(1,1,1)*20000
			bp.Position = hrp.Position + Vector3.new(0,3 + SCALE,0)
			bp.Parent = fairy

			local bg = Instance.new('BodyGyro')
			bg.Name = 'BodyGyro'
			bg.MaxTorque = Vector3.new(1,1,1) * 400000
			bg.CFrame = hrp.CFrame
			bg.Parent = fairy

			local objectTag = Instance.new('ObjectValue')
			objectTag.Name = 'TargetTag'
			objectTag.Value = character
			objectTag.Parent = fairy

			local newFairyScript = fairyScript:clone()
			newFairyScript.Parent = fairy
			newFairyScript.Disabled = false

			fairy.Parent = workspace

			tool:Destroy()
		end
	end
end)













