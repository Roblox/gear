-- // Made by StarWars
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool.Handle 

local Player = nil
local Character = nil
local Humanoid = nil 
local RootPart = nil 

local RELOAD_TIME = 5
local FUSE_TIME = 2
local THROW_POWER = 50  
local BLAST_RADIUS = 10
local BLAST_DAMAGE = 10

local BasePart = Handle:Clone()

local ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

local ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

function CreateFirecracker() 
	local NewFirecracker = BasePart:Clone() 
	local BodyForce = Instance.new("BodyForce")

	NewFirecracker.CFrame = Handle.CFrame * CFrame.new(0, 0, 1)

	BodyForce.Force = Vector3.new(0, NewFirecracker:GetMass() * workspace.Gravity * 0.5, 0)
	BodyForce.Parent = NewFirecracker

	return NewFirecracker
end 

function OnEquip()
	Character = Tool.Parent 
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
end 

function OnUnequip()
	Player = nil
	Character = nil
	Humanoid = nil 
	RootPart = nil 
end 

function OnActivate()
	if not Tool.Enabled then return end 
	if not Character then return end 
	if not RootPart then return end 
	if not Humanoid or Humanoid.Health <= 0 then return end 

	Tool.Enabled = false 

	local NewFirecracker = CreateFirecracker() 
	local MouseData = InvokeClient("MouseData")
	local Direction = (MouseData.Position - RootPart.Position).Unit 
	local Velocity = (Direction * THROW_POWER) + Vector3.new(0, THROW_POWER * 0.5, 0)
	NewFirecracker.Velocity = Velocity 
	Debris:AddItem(NewFirecracker, 30)
	NewFirecracker.Parent = workspace 

	local SparkEmitter = NewFirecracker:FindFirstChild("Spark")
	local SpotLight = NewFirecracker:FindFirstChild("SpotLight")
	if SparkEmitter then 
		SparkEmitter.Enabled = true
	end 
	if SpotLight then
		SpotLight.Enabled = true
	end 

	delay(FUSE_TIME, function()
		if NewFirecracker and NewFirecracker.Parent then 
			if SparkEmitter then 
				SparkEmitter.Enabled = false 
			end 
			if SpotLight then
				SpotLight.Enabled = false 
			end 				
			wait()
			
			-- Adding this code back in will cause the firecracker to do damage.
			--[[
			local NewExplosion = Instance.new("Explosion")
			NewExplosion.BlastPressure = 0
			NewExplosion.BlastRadius = BLAST_RADIUS
			NewExplosion.Visible = false 
			NewExplosion.Hit:Connect(function(hitPart, distance)
				if hitPart and hitPart.Parent then
					local HitHumanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
					if HitHumanoid then 
						local ExplosionDamage = math.min((distance / BLAST_RADIUS) * BLAST_DAMAGE, BLAST_DAMAGE)
						HitHumanoid:TakeDamage(ExplosionDamage)
					end 
				end 
			end)

			NewExplosion.Position = NewFirecracker.Position
			NewExplosion.Parent = workspace
			--]]			
			
			NewFirecracker.Transparency = 1
			local ParticleEmitter = NewFirecracker:FindFirstChild("ParticleEmitter")
			if ParticleEmitter then 
				ParticleEmitter.Enabled = true
			end 
			local Sound = NewFirecracker:FindFirstChild("Sound")
			if Sound then
				Sound:Play()
			end 
			wait(1/20)
			if NewFirecracker and ParticleEmitter then 
				ParticleEmitter.Enabled = false   
			end 
		end 
	end)

	wait(RELOAD_TIME)
	Tool.Enabled = true 
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value or not CheckIfAlive() or not ToolEquipped then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:Connect(OnEquip)
Tool.Unequipped:Connect(OnUnequip)
Tool.Activated:Connect(OnActivate)