-----------------
--| Constants |--
-----------------

local PET_ID = 105428829
local AI_SCRIPT_NAME = 'TelamonAi'

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local InsertService = Game:GetService('InsertService')
local PlayersService = Game:GetService('Players')

local MyPlayer = nil

local Tool = script.Parent
local ToolHandle = Tool.Handle

local AiScript = WaitForChild(script, AI_SCRIPT_NAME)
local CreatorTag = WaitForChild(AiScript, 'creator')

local Pet = nil
local MyHumanoid = nil

-----------------
--| Functions |--
-----------------

local function OnEquipped()
	MyPlayer = PlayersService:GetPlayerFromCharacter(Tool.Parent)	
	
	if MyPlayer then
		CreatorTag.Value = MyPlayer
		if MyPlayer.Character then
			MyHumanoid = MyPlayer.Character:FindFirstChild('Humanoid')
		end
	end
end

local function OnActivated()
	if not Pet then -- LoadAsset failed, try again
		Pet = InsertService:LoadAsset(PET_ID):GetChildren()[1]
	end
	if Pet and Tool.Enabled and MyHumanoid and MyHumanoid.Health > 0 then
		Tool.Enabled = false

		-- Place the Pet
		Pet.Parent = Workspace
		Pet:MoveTo(ToolHandle.Position)

		-- Give Pet the AiScript
		AiScript.Parent = Pet
		AiScript.Disabled = false

		Tool:Destroy()
	end
end

--------------------
--| Script Logic |--
--------------------

Pet = InsertService:LoadAsset(PET_ID):GetChildren()[1]

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
