local Tool = script.Parent 
local Book = Tool.Handle

local vCharacter
local vTorso
local vHumanoid

local vPlayer
local PlayerGui

Tool.Enabled = true

local GZGui 
local GZGui_Id = 110078313
local GZFrame 
local RBX_InsertService = Game:GetService("InsertService") 
local RBX_AssetLoader = RBX_InsertService.LoadAsset 
local RBX_ContentProvider = Game:GetService("ContentProvider") 

local NextPage_ImageButton

local PageCount = 1 
local NumberOfPages = 17

local function onActivated()
	if Tool.Enabled == false then
		return 
	end 

	wait(0.2) 

	if GZFrame then  
		GZFrame.Visible = true 
	end 

	Tool.Enabled = true  
end 

local function onEquipped()
	vCharacter = Tool.Parent 
	vPlayer = Game.Players:GetPlayerFromCharacter(vCharacter) 
	PlayerGui = vPlayer:WaitForChild('PlayerGui')
	if GZGui then 
		GZGui.Parent = PlayerGui
	else 
		GZGui = RBX_AssetLoader(RBX_InsertService, GZGui_Id):GetChildren()[1] 
		GZGui.Parent = PlayerGui 
	end 
	GZFrame = GZGui:WaitForChild('GZFrame')
	GZFrame.Visible = true 
	local fChildren = GZFrame:GetChildren()
	for i = 1, #fChildren do 
		if i == 1 then 
			fChildren[i].ZIndex = 9
		else 
			fChildren[i].ZIndex = 1
		end 
		fChildren[i].Visible = true 
	end 
	NextPage_ImageButton = GZFrame:WaitForChild('Next')
	NextPage_ImageButton.ZIndex = 10 
	NextPage_ImageButton.MouseButton1Click:connect(function()
		PageCount = PageCount + 1 
		if PageCount > NumberOfPages then 
			PageCount = 1 
		end 
		local fChildren = GZFrame:GetChildren()
		for i = 1, #fChildren do 
			if fChildren[i].Name == tostring(PageCount) and fChildren[i]:IsA("ImageLabel") then 
				fChildren[i].ZIndex = 9
			elseif fChildren[i]:IsA("TextButton") then 
				fChildren[i].ZIndex = 10
			else 
				fChildren[i].ZIndex = 1
			end  
		end  
	end) 
end 

local function onUnequipped()
	if GZGui then 
		GZGui.Parent = nil 
	end  
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
