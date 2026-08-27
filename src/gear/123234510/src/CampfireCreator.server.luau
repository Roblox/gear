

local Tool = script.Parent
local event = Tool:WaitForChild('CampfireEvent')
local CurrentCampfire = Tool:WaitForChild('CurrentCampfire')

local InsertService = game:GetService('InsertService')

local CAMPFIRE_ASSET_ID = 123041248
local SMALL_OFFSET = Vector3.new(0, 5, 0)
local LARGE_OFFSET = Vector3.new(0, 1000, 0)

local function createCampfire(player, targetPos)
	local character = Tool.Parent
	if character and character == player.Character then
		local humanoid = character:FindFirstChild('Humanoid')
		if humanoid and not humanoid.Sit then	-- Don't let them create a new campfire if they're already sitting at one
			local hitLocation = targetPos
			local previousCampfire = CurrentCampfire.Value
			if previousCampfire then
				previousCampfire:Remove()
			end
			local campfire = InsertService:LoadAsset(CAMPFIRE_ASSET_ID):GetChildren()[1]
			CurrentCampfire.Value = campfire
			campfire.Parent = workspace
			-- Make sure it gets deleted if player dies...
			humanoid.Died:connect(function()
				campfire:Destroy()
			end)
			campfire:MoveTo(hitLocation.p + SMALL_OFFSET)
		end
	end	
end


event.OnServerEvent:connect(createCampfire)
