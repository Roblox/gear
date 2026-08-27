-- // Rescripted for R15 and FE by StarWars
local InsertService = game:GetService("InsertService")

local MODEL_ASSET_ID = 159856065
local TOOTHLESS_MODEL = InsertService:LoadAsset(MODEL_ASSET_ID):GetChildren()[1]

local Tool = script.Parent
local Handle = Tool.Handle

local GearService = require(1075123174)

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

function FindToothless()
	for _, Object in next, workspace:GetDescendants() do
		if Object:IsA("Model") and Object.Name == "Toothless" then
			local Creator = Object:FindFirstChild("creator")
			if Creator and Creator.Value == Gear.Player then
				return Object
			end
		end
	end
end

Gear:BindActivateFunction("toothless_activate", function()
	local MouseHit = nil
	local MyToothless = FindToothless()
	if MyToothless then
		pcall(function()
			MouseHit = Gear.ClientControls:InvokeClient(Gear.Player, "GetMouseData")
		end)
		-- Just in case the model gets destroyed while it was yielding for GetMouseData
		if MouseHit and MyToothless then
			local ShootAt = MyToothless:FindFirstChild("ShootAt")
			if ShootAt then
				ShootAt.Value = MouseHit.Position
			end
		end
	else
		if Gear.RootPart then
			local NewToothless = TOOTHLESS_MODEL:Clone()
			local Creator = NewToothless:FindFirstChild("creator")
			if Creator then
				Creator.Value = Gear.Player
				NewToothless.Parent = workspace
				NewToothless:MoveTo(Gear.RootPart.CFrame.p + Vector3.new(0, 15, 0))
				Handle.Transparency = 1
			else
				NewToothless:Destroy()
			end
		end
	end
	
	wait(1)
end)

Gear:BindEquippedFunction("toothless_equipped", function()
	Handle.Transparency = FindToothless() and 1 or 0
end)