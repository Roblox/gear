-- // Created by StarWars
local Debris = game:GetService("Debris")

local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle
local particlesFolder = tool.Particles

local rand = Random.new()

local gear = GearService:BindGear(tool)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local TIMEOUT = 10
local RELOAD_TIME = 2
local SPELL_SPEED = 24
local DAMAGE = 15
local FREEZE_TIME = 10

function InvokeClient(mode, value)
	if gear.Player and mode then
		local result
		pcall(function()
			result = gear.ClientControls:InvokeClient(gear.Player, mode, value)
		end)
		
		return result
	end
end

function CreateSpell()
	local newPart = Instance.new("Part")
	local particle = particlesFolder:GetChildren()[rand:NextInteger(1, #particlesFolder:GetChildren())]:Clone()
	
	newPart.Size = Vector3.new(1, 1, 1)
	newPart.Transparency = 1
	newPart.CanCollide = false
	newPart.Touched:Connect(function(hit)
		if hit:IsDescendantOf(gear.Character) then return end
		local parentTo = hit.Parent
		if parentTo then
			if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
				parentTo = parentTo.Parent
			end
			
			local humanoid = parentTo:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:TakeDamage(DAMAGE)
				for _, v in pairs(parentTo:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Anchored = true
					end
				end
				delay(FREEZE_TIME, function()
					if parentTo then
						for _, v in pairs(parentTo:GetDescendants()) do
							if v:IsA("BasePart") then
								v.Anchored = false
							end
						end
					end
				end)
			end
		end
		
		newPart:Destroy()
	end)	
	
	local bodyVelocity = Instance.new("BodyVelocity", newPart)
	bodyVelocity.MaxForce = Vector3.new(5000, 5000, 5000)
	
	local bodyForce = Instance.new("BodyForce", newPart)
	bodyForce.Force = Vector3.new(0, newPart:GetMass() * workspace.Gravity, 0)
	
	particle.Parent = newPart
	
	return {Part = newPart, BodyVelocity = bodyVelocity, Particle = particle}
end

tool.Activated:Connect(function()
	if not tool.Enabled or not gear:IsPlayerAlive() then return end
	tool.Enabled = false
	
	local mouseData = InvokeClient("GetMouseData")
	if mouseData then
		local direction = (mouseData.Position - gear.RootPart.CFrame.p).Unit
		local newSpell = CreateSpell()
		newSpell.Part.CFrame = CFrame.new(gear.RootPart.CFrame.p)
		newSpell.BodyVelocity.Velocity = direction * SPELL_SPEED
		newSpell.Part.Parent = workspace
		newSpell.Particle.Enabled = true
		
		Debris:AddItem(newSpell.Part, TIMEOUT)
	end
	
	wait(RELOAD_TIME)
	tool.Enabled = true
end)