local function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do 
		wait()
	end 
	return parent[child]
end 


local Tool = script.Parent 
local Book = Tool.Handle

local vCharacter
local vTorso
local vHumanoid

local vPlayer
local PlayerGui 

Tool.Enabled = true

local AORGui 
local AORGui_Id = 147852116
local AORFrame 
local RBX_InsertService = game:GetService("InsertService") 
local RBX_AssetLoader = RBX_InsertService.LoadAsset 
local RBX_ContentProvider = game:GetService("ContentProvider") 

local NextPage_ImageButton

local PageCount = 1 

local function onActivated()
	if Tool.Enabled == false then
		return 
	end 

	wait(0.2) 

	if AORFrame then  
		AORFrame.Visible = true 
	end 

	Tool.Enabled = true  
end 

local function onEquipped()
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	PlayerGui = waitForChild(vPlayer, "PlayerGui")
	if AORGui then 
		AORGui.Parent = PlayerGui
	else 
		AORGui = RBX_AssetLoader(RBX_InsertService, AORGui_Id):GetChildren()[1] 
		AORGui.Parent = PlayerGui 
	end 
	AORFrame = waitForChild(AORGui, "AORFrame") 	
	AORFrame.Visible = false 
	local fChildren = AORFrame:GetChildren()
	for i = 1, #fChildren do 
		if i == 1 then 
			fChildren[i].ZIndex = 9
		else 
			fChildren[i].ZIndex = 1
		end 
		fChildren[i].Visible = true 
	end 
	NextPage_ImageButton = waitForChild(AORFrame, "Next")
	NextPage_ImageButton.ZIndex = 10 
	NextPage_ImageButton.MouseButton1Click:connect(function()
		PageCount = PageCount + 1 
		if PageCount > 17 then 
			PageCount = 1 
		end 
		local fChildren = AORFrame:GetChildren()
		for i = 1, #fChildren do 
			if fChildren[i].Name == tostring(PageCount) and fChildren[i]:IsA("ImageLabel") then 
				fChildren[i].ZIndex = 9
			elseif fChildren[i]:IsA("ImageButton") then 
				fChildren[i].ZIndex = 10
			else 
				fChildren[i].ZIndex = 1
			end  
		end  
	end) 
end 

local function onUnequipped()
	if AORGui then 
		AORGui.Parent = nil 
	end  
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
