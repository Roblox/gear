local Tool = script.Parent
local Wand = Tool.Handle

Tool.Enabled = true 

local vCharacter
local myTorso 
local myHumanoid 
local vPlayer 

local castAnim
local chantAnim 

local wavePart 

local mouseDown = false
local casting = false 

local sg 
local frame 
local fillFrame 
local glowImage 

local chargeLevel = 200 

local chickySound

while Tool:FindFirstChild("SpellWeld") == nil do wait() end 
local storeWeld = Tool.SpellWeld
while Wand:FindFirstChild("SpellPart") == nil do wait() end  
local spellPart = Wand.SpellPart

local chicky 

function chickenify(part, hit, scale)
	if hit and part and hit.Parent and part.Parent and hit.Parent ~=  vCharacter and hit.Parent ~= Tool then 
		part:Destroy() 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")			
		end 
		if humanoid and humanoid.Parent:FindFirstChild("ChickenifyScript") == nil then 
			local chickenScript = Tool.ChickenifyScript:Clone() 
			chickenScript.Parent = humanoid.Parent
			
			if scale then 
				local chickenPowa = Instance.new("IntValue")
				chickenPowa.Name = "Scale"
				chickenPowa.Value = scale
				chickenPowa.Parent = chickenScript 
			end 

			chickenScript.Disabled = false 

			chickySound = Tool:FindFirstChild("ChickySound")
			if chickySound then chickySound:Play() end 
		end 
	end 
end 

function voodoo(scale)
	if spellPart and glowImage then 
		chicky = spellPart:Clone()
		
		local floatForce = Instance.new("BodyForce")
		floatForce.Parent = chicky
		floatForce.force = Vector3.new(0, chicky:GetMass() * 196.1, 0)

		chicky.CFrame = spellPart.CFrame
		chicky.Velocity = Vector3.new(0, 0, 0)
		wait()

		--chicky.Anchored = true
		
		chicky.Velocity = (myHumanoid.TargetPoint - chicky.Position).unit * 99.0 
		
		chicky.Parent = game.Workspace 

		chicky.Touched:connect(function(hit)
			chickenify(chicky, hit, scale) 
		end) 
		if glowImage and glowImage.Visible == true then 
			-- do a AOE splash of chickens 
		end 
	end 
end 

function chargeSpell()
	if not casting then 
		mouseDown = true 
		chantAnim = myHumanoid:LoadAnimation(Tool.ChantAnim)
		if chantAnim then chantAnim:Play() end 
		Tool.Grip = CFrame.new(0, 0.2, -1.1, -1, 0, -0, 0, 0.847950041, 0.530076146, 0, 0.530076146, -0.847950041)		
		while mouseDown == true and myHumanoid do 
			if fillFrame then
				if fillFrame.Size.X.Offset < chargeLevel then 
					fillFrame.Size = UDim2.new(0, fillFrame.Size.X.Offset + 2, 0, 25)		
					if spellPart and spellPart:FindFirstChild("Mesh") then 
						spellPart.Mesh.Scale = spellPart.Mesh.Scale + Vector3.new(0.001, 0.001, 0.001) 
						if spellPart.Mesh.Scale.X > 0.060 then 
							if spellPart:FindFirstChild("Fire") then 
								spellPart.Fire.Enabled = true 
								spellPart.Fire.Size = 4
							end							
						end 
						spellPart.Transparency = 0.0 
					end 
				else
					if glowImage then glowImage.Visible = true end 			
				end 
			end 			
			wait()
		end 	
		if chantAnim then chantAnim:Stop() end 
		Tool.Grip = CFrame.new(0, 0.2, -1.1, -1, 0, -0, -0, 0, 1, 0, 1, -0)
		--castAnim = myHumanoid:LoadAnimation(Tool.CastAnim)
		if castAnim then castAnim:Play() end 
		voodoo(fillFrame.Size.X.Offset)
		if fillFrame then fillFrame.Size = UDim2.new(0, 0, 0, 0) end
		if glowImage then glowImage.Visible = false end 		
		if spellPart then 
			spellPart.Transparency = 1.0
			if spellPart:FindFirstChild("Mesh") then spellPart.Mesh.Scale = Vector3.new(0.012, 0.012, 0.012) end 
			if spellPart:FindFirstChild("Fire") then spellPart.Fire.Enabled = false end 
		end 
		Tool.Enabled = false
		wait(3.5)
		Tool.Enabled = true 
		casting = false 
	end 
end 

function castSpell()
	mouseDown = false 
	casting = true 
end 

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if mouse then 
		--mouse.KeyDown:connect(beTheChange)
		mouse.Button1Down:connect(chargeSpell)
		mouse.Button1Up:connect(castSpell)
	end 

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer then 
		local playerGui = vPlayer:FindFirstChild("PlayerGui")
		if playerGui and playerGui:FindFirstChild("LanternGui") == nil then 
			sg = Instance.new("ScreenGui")
			sg.Name = "LanternGui"
			sg.Parent = playerGui 

			frame = Instance.new("Frame")
			frame.Parent = sg 
			frame.Size = UDim2.new(0, 200, 0, 30)
			frame.Position = UDim2.new(0.5, -100, 1, -130) 
			frame.Style = Enum.FrameStyle.RobloxSquare

			fillFrame = Instance.new("Frame")
			fillFrame.Parent = frame 
			fillFrame.Size = UDim2.new(0, 0, 0, 0)
			fillFrame.BackgroundTransparency = 0.0
			fillFrame.BackgroundColor3 = Color3.new(1, 1, 0)
			fillFrame.Position = UDim2.new(0, -7, 0, -6)

			glowImage = Instance.new("ImageLabel")
			glowImage.Parent = frame 
			glowImage.Size = UDim2.new(0, 210, 0, 35)
			glowImage.BackgroundTransparency = 1.0 
			glowImage.Position = UDim2.new(0.5, -105, 0.5, -18)
			glowImage.Visible = false 
			glowImage.Image = "http://www.roblox.com/asset/?id=75462586"
			glowImage.ZIndex = 10.0
		end 
	end 
	if storeWeld then 
		storeWeld.Parent = Tool
	end 
end 

function onUnequipped()	
	if chantAnim then chantAnim:Stop() end 
	if castAnim then castAnim:Stop() end 
	if sg then sg:Destroy() end 
	if chickySound then chickySound:Stop() end 
	casting = false 
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped) 
