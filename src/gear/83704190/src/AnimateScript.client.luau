local function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do print(instance) wait() end 
	return parent:FindFirstChild(instance)
end 

local Tool = script.Parent 
local Sword = Tool.Handle

local vCharacter
local vPlayer 
local vTorso 
local vHumanoid 

local RBX_Debris = game:GetService("Debris")

local Slash_Animation
local Stab_Animation
local Darken_Animation 

local Charge_Animation 

local Slash_Sound 

local MouseDown_Bool = false 

local Camera = game.Workspace.CurrentCamera

local Darken_BoolValue 
local Animating_Bool = false 

local WindCounter = 0

local PlayerGui 
local Wind_Gui 
local Wind_Frame 
local Bar_Frame 

local Wave_Part = Instance.new("Part")
Wave_Part.FormFactor = 3 
Wave_Part.Size = Vector3.new(10, 0.2, 4) 

local Top_Decal = Instance.new("Decal")
Top_Decal.Texture = "http://www.roblox.com/asset/?id=83658504"
Top_Decal.Parent = Wave_Part 
Top_Decal.Face = "Top"

local Bottom_Decal = Top_Decal:Clone()
Bottom_Decal.Face = "Bottom"
Bottom_Decal.Parent = Wave_Part

local function createBarGui()
	if PlayerGui then 
		Wind_Gui = Instance.new("ScreenGui")
		Wind_Gui.Name = "WindGui"
		Wind_Gui.Parent = PlayerGui 

		Wind_Frame = Instance.new("Frame")
		Wind_Frame.BackgroundTransparency = 1.0 
		Wind_Frame.Name = "WindFrame"
		Wind_Frame.Style = Enum.FrameStyle.RobloxSquare
		Wind_Frame.Parent = Wind_Gui
		Wind_Frame.Size = UDim2.new(0, 220, 0, 30)
		Wind_Frame.Position = UDim2.new(0.5, -110, 1, -130) 

		Bar_Frame = Instance.new("Frame") 
		Bar_Frame.BackgroundTransparency = 0.0 
		Bar_Frame.BackgroundColor3 = Color3.new(0, 0.3, 0.9) 
		Bar_Frame.Parent = Wind_Frame 
		Bar_Frame.Size = UDim2.new(0, 0, 0, 30) 
		Bar_Frame.Position = UDim2.new(0, -8, 0, -8)
		Bar_Frame.Name = "Bar"
	end  
end 

local function blow(hit)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and humanoid ~= vHumanoid then 
			humanoid:TakeDamage(13)
			local char = humanoid.Parent 
			local cChildren = char:GetChildren()
			for i = 1, #cChildren do 
				if cChildren[i]:IsA("Tool") or cChildren[i]:IsA("Hat") then
					cChildren[i].Parent = game.Workspace 
					if cChildren[i]:FindFirstChild("Handle") then
 
						local h = cChildren[i].Handle:Clone()
						h.CFrame = cChildren[i].Handle.CFrame 					
						h.Velocity = (vTorso.Position - h.Position).unit * 40.0   					
						h.Parent = game.Workspace 
						h.CanCollide = true	
					
						cChildren[i]:Destroy() 

						RBX_Debris:AddItem(h, 5.5)
					end 
				end 
			end  
		end  
	end  
end  

local function releaseTheShockWave(counter)	
	local wp = Wave_Part:Clone() 
	wp.Size = wp.Size * (counter/30) 
	wp.CFrame = CFrame.new(vTorso.Position, vTorso.Position + vTorso.CFrame.lookVector)
	wp.Transparency = 1.0 
	wp.CanCollide = false
	--wp.Anchored = true 

	local float_BodyForce = Instance.new("BodyForce")
	float_BodyForce.Name = "Float"
	float_BodyForce.force = Vector3.new(0, 196.1 * wp:GetMass(), 0)
	float_BodyForce.Parent = wp 

	wp.Parent = game.Workspace 

	wp.Velocity = wp.CFrame.lookVector * 40.0 
	wp.Touched:connect(blow) 

	WindCounter = 0 

	RBX_Debris:AddItem(wp, 2.5)	
end 

local function onEquipped(mouse)
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vTorso = vCharacter:FindFirstChild("Torso")
	vHumanoid = vCharacter:FindFirstChild("Humanoid") 

	PlayerGui = waitForChild(vPlayer, "PlayerGui")
	
	if not Wind_Gui or not Wind_Gui.Parent then
		createBarGui() 
	end
	mouse.Button1Down:connect(function()
		if Animating_Bool == false then 
			MouseDown_Bool = true 
			Charge_Animation = vHumanoid:LoadAnimation(Tool.ChargeAnim)
			Charge_Animation:Play() 
			local currentSpeed = vHumanoid.WalkSpeed
			while MouseDown_Bool do 				
				vHumanoid.WalkSpeed = math.min(vHumanoid.WalkSpeed + 0.1, 50) 				
				WindCounter = math.min(90, WindCounter + 1)
				Bar_Frame.Size = UDim2.new(0, WindCounter/90 * 220, 0, 30) 
				wait(0.1) 
			end 
			if WindCounter > 30 then 
				Spawn(function() releaseTheShockWave(WindCounter) end)				
			end  
			if Charge_Animation then Charge_Animation:Stop() end 
			local vDirection = (vTorso.Position - Camera.CoordinateFrame.p).unit 
			local mDirection = (vHumanoid.TargetPoint - Camera.CoordinateFrame.p).unit 

			local angleBetweenVectors = math.abs(math.acos(vDirection:Dot(mDirection)))			
			if angleBetweenVectors < 0.5 then 
				Slash_Animation = vHumanoid:LoadAnimation(Tool.SlashAnim)
				Slash_Animation:Play() 								
			else 
				Stab_Animation = vHumanoid:LoadAnimation(Tool.StabAnim)
				Stab_Animation:Play() 
				Tool.Grip = CFrame.new(0, -2.5, 0, 1, -0, 0, 0, 0, -1, 0, 1, 0)
				wait(1.3)
				Tool.Grip = CFrame.new(0, -2.5, 0, 0, 0, -1, -0, 1, 0, 1, 0, 0)
			end 					
			vHumanoid.WalkSpeed = currentSpeed 
		else 					
		end 
	end) 

	mouse.Button1Up:connect(function()
		MouseDown_Bool = false 
		if Animating_Bool == false then 
			Tool.Enabled = false
			Animating_Bool = true 
			wait(1.5)			
			Tool.Enabled = true 
			Animating_Bool = false 		
		end 			
		Bar_Frame.Size = UDim2.new(0, 0, 0, 30)
	end)

	mouse.KeyDown:connect(function(key)
		key = key:lower() 
		if key == "q" then 
			Darken_BoolValue = Tool:FindFirstChild("Darken")
			if Darken_BoolValue and Darken_BoolValue.Value == false then 
				Animating_Bool = true 
				Darken_Animation = vHumanoid:LoadAnimation(Tool.DarkenAnim)
				Darken_Animation:Play() 	
				wait(0.4)
				vHumanoid.WalkSpeed = 0.0 
				Darken_BoolValue.Value = true				
				wait(2.0)
				Animating_Bool = false 
			end  
		end 
	end) 
end 

local function onUnequipped()
	-- Do stuff
	if Charge_Animation  then Charge_Animation:Stop() end 
	if Slash_Animation then Slash_Animation:Stop() end 
	if Stab_Animation then Stab_Animation:Stop() end 
	if Darken_Animation then Darken_Animation:Stop() end 
	if Wind_Gui and Wind_Gui.Parent then --Fix implemented by Luckymaxer
		Wind_Gui:Destroy()
	end
	Animating_Bool = false 	
	Tool.Grip = CFrame.new(0, -2.5, 0, 0, 0, -1, -0, 1, 0, 1, 0, 0)
	MouseDown_Bool = false 
	if vHumanoid then 
		vHumanoid.WalkSpeed = 16.0
	end 
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)