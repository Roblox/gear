while script:FindFirstChild("CamJam") == nil do wait() end 
while script:FindFirstChild("SlapAnim") == nil do wait() end


local character = script.Parent

local torso = character:FindFirstChild("Torso")

local initCF = torso.CFrame 

local camJam = script.CamJam 

local slapAnim = script.SlapAnim 

if camJam.Value then 
	print(camJam.Value)
	game.Workspace.CurrentCamera.CameraSubject = camJam.Value 
	game.Workspace.CurrentCamera.CameraType = "Custom" 

	if torso then 
		torso.Anchored = true 
		torso.CFrame = CFrame.new(0, 65000, 0) 
	end 	
end 

local ended = false

while script:FindFirstChild("End") == nil do wait() end 
local endVal = script.End 
endVal.Changed:connect(function()
	ended = true 
	if endVal and endVal.Value == true then 
		torso.CFrame = initCF
		torso.Anchored = false 
		game.Workspace.CurrentCamera.CameraSubject = character 
		game.Workspace.CurrentCamera.CameraType = "Custom" 		
	end 
end) 


