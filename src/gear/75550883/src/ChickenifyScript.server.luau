while script:FindFirstChild("Scale") == nil do wait() end  

local vCharacter = script.Parent 
local myTorso = vCharacter:FindFirstChild("Torso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local scale = script.Scale

local charChildren = vCharacter:GetChildren()

local chickenTool = game:GetService("InsertService"):LoadAsset(75496631):GetChildren()[1] 

local replacedToolMeshId 
local replacedToolTextureId 

local thisTool

for i = 1, #charChildren do 
	if charChildren[i] and charChildren[i]:IsA("Tool") then 
		thisTool = charChildren[i]
		myHumanoid:UnequipTools()
		thisTool.Parent = nil

		chickenTool.Parent = game.Workspace 
		chickenTool.TextureId = thisTool.TextureId
		myHumanoid:EquipTool(chickenTool) 
	end 
end 

wait(math.max(5, scale.Value/5))
if chickenTool then chickenTool:Destroy() end 
if thisTool then 
	thisTool.Parent = game.Workspace   
	myHumanoid:EquipTool(thisTool) 
end 
wait(2.0)
if script then script:Destroy() end 