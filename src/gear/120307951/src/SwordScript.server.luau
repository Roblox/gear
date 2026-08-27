-- Copied from Grimgold Periastron Beta

local Tool = script.Parent
local Sword = Tool.Handle
local GLib = require(206209239)

local vCharacter
local myTorso
local myHumanoid 

local equipped = false

local debris = game:GetService("Debris")

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end

function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function cut(hit)
	local humanoid
	local vPlayer
	if hit and hit.Parent and myHumanoid then 
		if hit.Parent:IsA("Accoutrement") then
			humanoid = hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
		else
			humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		end
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid and humanoid ~= myHumanoid and not GLib.IsTeammate(GLib.GetPlayerFromPart(Tool), GLib.GetPlayerFromPart(humanoid)) then 
			UntagHumanoid(humanoid)
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(27)
		end
	end
end

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("HumanoidRootPart")
	myHumanoid = vCharacter:FindFirstChildOfClass("Humanoid")	
end

Tool.Equipped:Connect(onEquipped)

Sword.Touched:Connect(cut)