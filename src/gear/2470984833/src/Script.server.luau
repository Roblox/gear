-- // Created by StarWars
local GearService = require(1075123174)

local Debris = game:GetService("Debris")

local tool = script.Parent
local gear = GearService:BindGear(tool)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local BASE_URL = "rbxassetid://"
local CANDY_MESHES =
{
	--179536104; --BloxyDrops
	--179536148; -- Bloxroll
	179536189; --BlueDark
	179536223; --BlueLight
	179536243; --Green
	179536282; --Orange
	179536309; --Pink
	179536326; -- Purple
	179536343; --Red
	179536364; --Yellow
	--179536390; --Chocoblox
	--179536422; --MrBloxBar
}
local CANDY_TX = 179535876
local RELOAD_TIME = .5

local ANIMATIONS = {
	Throw = {Animation = tool.Animations.R6.Throw},
	R15Throw = {Animation = tool.Animations.R15.Throw}
}

local candyRandom = Random.new()

function InvokeClient(mode, value)
	if mode then
		local result
		
		pcall(function()
			result = gear.ClientControls:InvokeClient(gear.Player, mode, value)
		end)
		
		return result
	end
end

function CreateCandy()
	local candyIndex = candyRandom:NextInteger(1, #CANDY_MESHES)
	
	local newPart = Instance.new("Part")
	newPart.TopSurface = Enum.SurfaceType.Smooth
	newPart.BottomSurface = Enum.SurfaceType.Smooth
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = BASE_URL .. CANDY_MESHES[candyIndex]
	mesh.TextureId = BASE_URL .. CANDY_TX
	mesh.Scale = Vector3.new(3.5, 3.5, 3.5)
	mesh.Parent = newPart
	
	newPart.Size = Vector3.new(1,1,1)
	
	local bodyForce = Instance.new("BodyForce")
	bodyForce.Force = Vector3.new(0, newPart:GetMass() * workspace.Gravity * 0.85, 0)
	bodyForce.Parent = newPart
	
	Debris:AddItem(newPart, 30)
	
	return newPart
end

tool.Activated:Connect(function()
	if gear:IsPlayerAlive() and tool.Enabled then
		tool.Enabled = false
		
		local mouseData = InvokeClient("GetMouseData")
		if mouseData and mouseData.Position then
			local anim = ANIMATIONS.Throw
			if gear.Humanoid and gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
				anim = ANIMATIONS.R15Throw
			end
			
			InvokeClient("PlayAnimation", anim)
			wait(0.5)			
			
			local newCFrame = CFrame.new(gear.RootPart.CFrame.p, mouseData.Position)
			local newCandyPart = CreateCandy()
			newCandyPart.CFrame = newCFrame
			newCandyPart.Velocity = newCFrame.LookVector * 50
			newCandyPart.RotVelocity = Vector3.new(candyRandom:NextInteger(1, 4), candyRandom:NextInteger(1, 4), candyRandom:NextInteger(1, 4))
			newCandyPart.Parent = workspace
		end
		
		wait(RELOAD_TIME)
		tool.Enabled = true
	end
end)