--Made by Luckymaxer
--[[
	Fixed by ArceusInator
	2/23 - The UFO now replicates properly
--]]

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

UFOModel = InsertService:LoadAsset(162741606)

UFO = UFOModel:GetChildren()[1]:Clone()

UFOModel:Destroy()

CurrentUFO = Tool:WaitForChild("CurrentUFO")

SpawnUFO = Tool:WaitForChild("SpawnUFO")

RemoverScript = script:WaitForChild("Remover")

Grips = {
	NormalGrip = CFrame.new(0, -0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	SummoningGrip = CFrame.new(0.25, -0.75, 0, 1.12500096e-007, 1, -0, -0.99999994, 1.12500111e-007, 0, 0, 0, 1),
}

Equipped = false

ReloadTime = 15

function TransformModel(Parent, NewCFrame)
	local Origins = {}
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			Origins[v] = Parent:GetModelCFrame():toObjectSpace(v.CFrame)
		end
	end
	for i, v in pairs(Origins) do
		i.CFrame = NewCFrame:toWorldSpace(v)
	end
end

function onMouse1Down()
	if Tool.Enabled and Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
		Tool.Enabled = false
		SpawnUFOAnim = Humanoid:LoadAnimation(SpawnUFO)
		if SpawnUFOAnim then
			SpawnUFOAnim:Play()
			wait(0.1)
			Tool.Grip = Grips.SummoningGrip
			wait(0.25)
			if Equipped then
				local TorsoCFrame = Torso.CFrame
				Handle.Transparency = 1
				UFODeploy = Handle:Clone()
				UFODeploy.Name = "MiniUFO"
				UFODeploy.Transparency = 0
				UFODeploy.CanCollide = true
				UFODeploy.CFrame = CFrame.new(Handle.Position)
				local UFOCloneY = UFODeploy:Clone()
				UFOCloneY.CFrame = UFOCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.maxForce = Vector3.new((UFODeploy:GetMass() * 196.20), (UFODeploy:GetMass() * 196.20) * 2, (UFODeploy:GetMass() * 196.20))
				BodyVelocity.velocity = UFOCloneY.CFrame.lookVector * 1.25
				BodyVelocity.Parent = UFODeploy
				local BodyGyro = Instance.new("BodyGyro")
				BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
				BodyGyro.cframe = UFODeploy.CFrame
				BodyGyro.Parent = UFODeploy
				Debris:AddItem(UFODeploy, 20)
				UFODeploy.Parent = game:GetService("Workspace")
				UFODeploy.CFrame = CFrame.new(Handle.Position) + Vector3.new(0, 0.1, 0)
				Delay(3, function()
					if UFODeploy and UFODeploy.Parent and BodyVelocity and BodyVelocity.Parent then
						BodyVelocity.velocity = TorsoCFrame.lookVector * 2.5
						wait(5)
						UFODeploy.Anchored = true
						UFODeploy.CanCollide = false
						Spawn(function()
							while UFODeploy and UFODeploy.Parent and UFODeploy.Mesh.Scale.Y < 3 do
								local NewScale = (UFODeploy.Mesh.Scale.Y + 0.05)
								UFODeploy.Mesh.Scale = Vector3.new(NewScale, NewScale, NewScale)
								wait()
							end
							if UFODeploy and UFODeploy.Parent then
								local UFOVehicle = UFO:Clone()
								local Creator = Instance.new("ObjectValue")
								Creator.Name = "Creator"
								Creator.Value = Player
								Creator.Parent = UFOVehicle
								local RemoverScriptClone = RemoverScript:Clone()
								RemoverScriptClone.Disabled = false
								RemoverScriptClone.Parent = UFOVehicle
								CurrentUFO.Value = UFOVehicle
								UFOVehicle.Parent = game:GetService("Workspace")
								UFOVehicle.Changed:connect(function(Property)
									if Property == "Parent" and not UFOVehicle.Parent then
										wait(ReloadTime)
										Handle.Transparency = 0
										Tool.Enabled = true
									end
								end)
								TransformModel(UFOVehicle, CFrame.new(UFODeploy.CFrame.p))
								if UFOVehicle.Engine.Position.Y < UFOVehicle.BeamPart.Position.Y then
									TransformModel(UFOVehicle, UFOVehicle:GetModelCFrame() * CFrame.Angles(0, math.pi, 0))
								end
								UFODeploy:Destroy()
							end
						end)
					end
				end)
				wait(2)
				Tool.Grip = Grips.NormalGrip
			end
		end
	end		
end

function onKeyDown(key)
	if key == "x" then
		if CurrentUFO.Value then
			CurrentUFO.Value:Destroy()
		end
	end
end

Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'Mouse1Down' then
			onMouse1Down()
		elseif action == 'KeyDown' then
			onKeyDown(...)
		end
	end
end)

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid and Humanoid.Health == 0 or not Torso then
		return
	end
	if not Tool.Enabled and not CurrentUFO.Value then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	Equipped = true
	Tool.Grip = Grips.NormalGrip
end

function Unequipped()
	Equipped = false
	if SpawnUFOAnim then
		SpawnUFOAnim:Stop()
	end
	if UFODeploy and UFODeploy.Parent then
		UFODeploy:Destroy()
	end
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)