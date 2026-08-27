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

local function CountAnansi()
	local nAnansi = 0
	for _, child in pairs(vCharacter:GetChildren()) do 
		if child:IsA('Model') and child.Name == 'Anansi' then 
			nAnansi = nAnansi + 1
		end 
	end 
	return nAnansi
end 

local function onEquipped(mouse)
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vTorso = vCharacter:FindFirstChild("Torso")
	vHumanoid = vCharacter:FindFirstChild("Humanoid") 

	mouse.Button1Down:connect(function()
		if Animating_Bool == false then 
			MouseDown_Bool = true 
			Charge_Animation = vHumanoid:LoadAnimation(Tool.ChargeAnim)
			Charge_Animation:Play() 
			local currentSpeed = vHumanoid.WalkSpeed
			while MouseDown_Bool do 				
				vHumanoid.WalkSpeed = math.min(vHumanoid.WalkSpeed + 0.1, 23) 				
				wait() 
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
				Tool.Grip = CFrame.new(0, -1.75, 0, 0.99999994, 0, -0, 0, -0.691990137, -0.72190702, -0, 0.72190702, -0.691990137)
				wait(1.3)
				Tool.Grip = CFrame.new(0, -2.20000005, 0, 0, 0, -1, -0, 1, 0, 1, 0, 0)
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
	end)

	mouse.KeyDown:connect(function(key)
		key = key:lower() 
		if key == "q" then 
			Darken_BoolValue = Tool:FindFirstChild("Fanged")
			if Darken_BoolValue and Darken_BoolValue.Value == false and CountAnansi() < 4 then 
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
	Animating_Bool = false 	
	Tool.Grip = CFrame.new(0, -2.20000005, 0, 0, 0, -1, -0, 1, 0, 1, 0, 0)
	MouseDown_Bool = false 
	vHumanoid.WalkSpeed = 16.0
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)