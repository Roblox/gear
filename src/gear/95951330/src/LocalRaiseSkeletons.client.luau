-----------------
--| Constants |--
-----------------


-----------------
--| Variables |--
-----------------

local DebrisService = game:GetService('Debris')
local PlayersService = game:GetService('Players')
local ContextActionService = game:GetService("ContextActionService")

local Tool = script.Parent
local ToolHandle = Tool.Handle
local SpawnSkeletonRemote = Tool:WaitForChild("SpawnSkeleton")

local MyPlayer = PlayersService.LocalPlayer

local MyModel = nil
local Skeleton = nil
local SummonTrack = nil

-----------------
--| Functions |--
-----------------


local function SpawnSkeletonKeyBind(ActionName, InputState, InputObject)
	SpawnSkeletonRemote:FireServer()		
end 



local function OnEquipped(mouse)
	MyModel = Tool.Parent

	local humanoid = MyModel:FindFirstChildOfClass('Humanoid')

	ContextActionService:BindAction("BoundSkeletonArmy", SpawnSkeletonKeyBind, true, Enum.KeyCode.E,Enum.KeyCode.Q,Enum.KeyCode.ButtonY)
	ContextActionService:SetTitle("BoundSkeletonArmy","Skele Squad")
	ContextActionService:SetPosition("BoundSkeletonArmy",UDim2.new(.5,0,-.5,0))
end

local function OnUnequipped()
	ContextActionService:UnbindAction("BoundSkeletonArmy")
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
