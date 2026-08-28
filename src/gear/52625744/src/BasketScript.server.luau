local Tool = script.Parent
local Basket = Tool.Handle

local vCharacter

Tool.Enabled = true

insert = game:GetService("InsertService")

local assets = {16726030, 29939404, 10472779, 22787248, 16214845, 15932306, 15177716}
local assetModels = {}

for i, v in ipairs(assets) do
	local item = insert:LoadAsset(v)
	table.insert(assetModels, item:GetChildren()[1])
end

function onActivated()
	if Tool.Enabled == false then
		return
	end

	Tool.Enabled = false
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myTorso == nil then 
		return
	end
	basketClone = Basket:Clone()
	basketClone.Parent = game.Workspace
	basketClone.CanCollide = true
	Basket.Transparency = 1
	
	wait(0.4)

	a = assetModels[math.random(1, 4)] a = a:Clone() a.Parent = game.Workspace a.Handle.Position = myTorso.Position + (myTorso.CFrame.lookVector * 2.5)
	b = assetModels[math.random(3, 7)] b = b:Clone() b.Parent = game.Workspace b.Handle.Position = myTorso.Position + (myTorso.CFrame.lookVector * 3.0)
	c = assetModels[math.random(2, 5)] c = c:Clone() c.Parent = game.Workspace c.Handle.Position = myTorso.Position + (myTorso.CFrame.lookVector * 4.5)
	basketClone:Destroy()
	Tool:Destroy()
	wait(2)
	Tool.Enabled = true 
end

function onEquipped()
end

function onUnequipped()
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)