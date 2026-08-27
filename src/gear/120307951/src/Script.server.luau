--Fixed by TakeoHonorable
--Revamped Periastrons: The Periastron of Darkness

local Tool = script.Parent
Tool.Enabled = true 

local Handle = Tool.Handle


local Player,vCharacter,myHumanoid,Root,myTorso


local Animations = Tool:WaitForChild("Animations",10)


local Sounds = {
	LungeSound = Handle:WaitForChild("LungeSound",10),
	SlashSound = Handle:WaitForChild("SlashSound",10),
}

local AttackAnims

local PointLight = Handle:WaitForChild("PointLight",10)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local Components = {
	PeriSparkle = Handle:WaitForChild("Sparkles",10),
	PeriTrail = Handle:WaitForChild("Trail",10),
	MouseInput = Tool:WaitForChild("MouseInput",10)
}
Components.PeriSparkle.Enabled = true
Components.PeriTrail.Enabled = false
PointLight.Enabled = true

local Seed = Random.new(tick())

local LightsOutSound

local DARKNESS_LOCK_TIME = 30
local TRANSPARENT_TIME = 15
local DARKNESS_SPARKLES_TIME = 1


local CurrentTime,LastTime = tick(),tick()
function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	spawn(function()
		if Handle.Transparency > 0.5 then
			Components.PeriSparkle.Enabled = true
			wait(DARKNESS_SPARKLES_TIME)
			Components.PeriSparkle.Enabled = false
		end
	end)
	CurrentTime = tick()
	if (CurrentTime-LastTime) <= 0.2 then
		--print("Lunge")
		Sounds.LungeSound:Play()
		Components.PeriTrail.Enabled = true
		local MousePosition = Components.MouseInput:InvokeClient(Player)
		local Direction = CFrame.new(Root.Position, Vector3.new(MousePosition.X, Root.Position.Y, MousePosition.Z))
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		BodyVelocity.Velocity = Direction.lookVector * 100
		Services.Debris:AddItem(BodyVelocity, 0.5)
		BodyVelocity.Parent = Root
		delay(.5,function()
			Components.PeriTrail.Enabled = false
		end)
		Root.CFrame = CFrame.new(Root.CFrame.p,Root.CFrame.p+Direction.lookVector)
		wait(1.5)
	else
		local SwingAnims = {AttackAnims.Slash,AttackAnims.SlashAnim,AttackAnims.RightSlash}
		local AttackAnim = SwingAnims[Seed:NextInteger(1,#SwingAnims)]
		spawn(function()
			if AttackAnim ~= AttackAnims.SlashAnim then
				Sounds.SlashSound:Play()
				else
				Sounds.SlashSound:Play()
				wait(.5)
				Sounds.SlashSound:Play()
			end	
		end)

		AttackAnim:Play()
	--wait(.4)
	end
	LastTime = CurrentTime
	Tool.Enabled = true
end

function lightsOut(key)
	if key:lower() == "q" and not Tool:FindFirstChild('DarknessDisabled') and not game.Lighting:FindFirstChild("BlackPeriastronWasHere") and vCharacter then
		LightsOutSound = Tool:FindFirstChild('LightsOutSound')
		if LightsOutSound then LightsOutSound:Play() end
		-- Create tag in lighting so other players with this gear can't mess it up
		local LightingTag = Instance.new("BoolValue")
		LightingTag.Name = "BlackPeriastronWasHere"
		LightingTag.Value = true
		LightingTag.Parent = game.Lighting
		
		-- Remove sparkles, make handle invisible...
		Components.PeriSparkle.Enabled = false
		
		-- Lock special attack so you can't use it multiple times in succession.
		local lock = Instance.new('BoolValue')
		lock.Name = 'DarknessDisabled'
		lock.Value = true
		lock.Parent = Tool
		game:GetService('Debris'):AddItem(lock, DARKNESS_LOCK_TIME)
		
		-- Make sparkles reset when darkness can be used again		
		Tool.ChildRemoved:Connect(function(child)
			if child.Name == 'DarknessDisabled' then
				Components.PeriSparkle.Enabled = true
			end
		end)

		-- Create a new part to hold the light
		local lightHolder = Instance.new('Part')
		lightHolder.CanCollide = false
		lightHolder.Anchored = true
		lightHolder.Transparency = 1.0
		lightHolder.Position = Handle.Position
		lightHolder.Name = 'BlackPeriastronLightHolder'
		lightHolder.Parent = workspace
		
		-- Script to absorb light is in workspace so it can be reset even if 
		-- this character dies
		local lightsOutScript = Tool:WaitForChild('LightsOutScript'):Clone()
		lightsOutScript.LightHolder.Value = lightHolder
		lightsOutScript.Handle.Value = Handle
		lightsOutScript.Parent = workspace
		lightsOutScript.Disabled = false
		
		-- But script to make character invisble just goes under the character.
		local ninjafyScript = Tool:WaitForChild('Ninjafy'):Clone()
		ninjafyScript.Parent = vCharacter
		ninjafyScript.Disabled = false
	end 
end 


function onEquipped()	
	vCharacter = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(vCharacter)
	myHumanoid = vCharacter:FindFirstChildOfClass("Humanoid")
	Root = vCharacter:FindFirstChild("HumanoidRootPart")
	AttackAnims = {
		Slash = Animations:WaitForChild(myHumanoid.RigType.Name,10):WaitForChild("Slash",10),
		RightSlash = Animations:WaitForChild(myHumanoid.RigType.Name,10):WaitForChild("RightSlash",10),
		SlashAnim = Animations:WaitForChild(myHumanoid.RigType.Name,10):WaitForChild("SlashAnim",10),
	}
	for i,v in pairs(AttackAnims) do
		AttackAnims[i] = myHumanoid:LoadAnimation(v)
	end
end

Tool:WaitForChild'Input'.OnServerEvent:Connect(function(client, button, down, ...)
	if client.Character == Tool.Parent then
		if button == 'Key' then
			if down then
				lightsOut(...)
			end
		end
	end
end)

function onUnequipped()
	for i,v in pairs(AttackAnims) do
		v:Stop()
	end
	if LightsOutSound then LightsOutSound:Stop() end
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)
