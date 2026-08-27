local TAXI_ASSET = 125896025

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')
local MyCharacter = nil
local MyTorso = nil
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
--local Car = Game.Workspace:WaitForChild('TaxiCar'):Clone()
local Car = Game:GetService('InsertService'):LoadAsset(TAXI_ASSET):GetChildren()[1]

local COOLDOWN_TIME = 15

local DeployedCar = nil

function OnTouched(hitPart)
	
end

function CreateOwnerTag()
	local ownerTag = Instance.new('ObjectValue')
	ownerTag.Value = PlayersService:GetPlayerFromCharacter(MyCharacter)
	ownerTag.Name = "Owner"
	return ownerTag
end

function SpawnCar()
	if MyTorso then
		local ownerTag = CreateOwnerTag()
		if DeployedCar then
			DeployedCar:Destroy()
		end
		local carClone = Car:Clone()
		ownerTag.Parent = carClone
		carClone.Parent = Game.Workspace
		--print(Car:GetModelCFrame().p)
		carClone:TranslateBy((MyTorso.CFrame.p - Car:GetModelCFrame().p) + Vector3.new(0,5,0) + MyTorso.CFrame.lookVector * 15)
		--carClone:TranslateBy(Vector3.new(0, 30, 0))
		carClone:MakeJoints()
		DeployedCar = carClone
		
		DebrisService:AddItem(carClone, 60 * 30) -- 30 mins debris so they doesnt stay forever
	end
end

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	-- Maybe check if enough room?
	SpawnCar()
	wait(COOLDOWN_TIME)
	Tool.Enabled = true
end

function OnEquipped(mouse)
	Handle.Touched:connect(OnTouched)
	MyCharacter = Tool.Parent
	MyTorso = MyCharacter:WaitForChild('Torso')
end

function OnUnequipped()
	if DeployedCar then
		DeployedCar:Destroy()
	end
end


Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

