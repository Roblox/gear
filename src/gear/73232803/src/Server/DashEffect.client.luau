--For Dragon Slayer's Sword & Shield
--Makes an after-image effect when dashing

local Self = script

local Game = game

local Wait,Instant,Pairs,Type = wait,Instance.new,pairs,type

--local Mat = Enum.Material.Plastic

local Camera = workspace.CurrentCamera

local SpawnRate = 1/30

local Character = Self:WaitForChild("Character").Value

local GetAllCharacterParts = Character.GetDescendants

local FindService,GetService = Game.FindService,Game.GetService
local function ObtainService(ServiceName)
	return FindService(Game,ServiceName) or GetService(Game,ServiceName)
end

local Services = {
	Players = ObtainService("Players"),
	Debris = ObtainService("Debris"),
	RunService = ObtainService("RunService")
}

function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in Pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end


local DashModelBase = Create("Model"){
	Name = "AfterImage",
}
while Character do
	
	local DashModel = DashModelBase:Clone()
	Services.Debris:AddItem(DashModel,.5)
	
	local Contents = GetAllCharacterParts(Character)
		
	for i=1,#Contents,1 do
		
		if Contents[i] and (Contents[i]:IsA("BasePart") --[[or Contents[i]:IsA("Humanoid") or Contents[i]:IsA("CharacterMesh") or Contents[i]:IsA("Clothing")]]) then
			
			local Clone = Contents[i]:Clone()
			
			if Clone:IsA("BasePart") then

				Clone.Transparency = (Clone.Transparency >= 1 and 1 or .7)
				Clone.Anchored = true
				Clone.CanCollide = false
				Clone.Locked = true
				--Clone.Material = Mat
				
			end
			
			for _,v in Pairs(Clone:GetDescendants()) do
				if v and (v:IsA("BasePart") or v:IsA("BaseScript") or v:IsA("JointInstance") or v:IsA("Sound") or v:IsA("Light")) then
					v:Destroy()
				end
			end
			
			Clone.Parent = DashModel
			
		end
		
	end
	DashModel.Parent = Camera
	DashModel:BreakJoints()
	Wait(SpawnRate)
end