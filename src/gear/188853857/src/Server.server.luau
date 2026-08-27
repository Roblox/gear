--Updated for R15 avatars by StarWars
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Mesh = Handle:WaitForChild("Mesh")
local Remote = Tool:WaitForChild("Remote")

local UcMeshData = "http://www.roblox.com/asset/?id=188539404"
local UcGripPos = Vector3.new(1.5, 1.25, -3.5)
local UcGripUp = Vector3.new(0, 1, 0)
local UcGripRt = Vector3.new(1, 0, 0)
local UcGripFw = Vector3.new(0, 0, -1)

local CuMeshData = "http://www.roblox.com/asset/?id=188635159"
local CuGripPos = Tool.GripPos
local CuGripUp = Tool.GripUp
local CuGripRt = Tool.GripRight
local CuGripFw = Tool.GripForward

local AttackAble = true
local AttackDamaging = false
local AttackVictims = {}
local AttackDamage = 22.5
local AttackWindow = 0.35
local AttackRest = 1

function setCurlState(curled)
	local meshData, gripPos, gripUp, gripRt, gripFw
	if curled then
		meshData = CuMeshData
		gripPos = CuGripPos
		gripUp = CuGripUp
		gripRt = CuGripRt
		gripFw = CuGripFw
	else
		meshData = UcMeshData
		gripPos = UcGripPos
		gripUp = UcGripUp
		gripRt = UcGripRt
		gripFw = UcGripFw
	end
	Mesh.MeshId = meshData
	Tool.GripPos = gripPos
	Tool.GripUp = gripUp
	Tool.GripRight = gripRt
	Tool.GripForward = gripFw
end

function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function onHandleTouched(part)
	if not AttackDamaging then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		if not contains(AttackVictims, human) then
			table.insert(AttackVictims, human)
			tagHuman(human)
			human:TakeDamage(AttackDamage)
		end
	end
end

function attack()
	if not AttackAble then return end
	local Humanoid = Tool.Parent:FindFirstChild("Humanoid")
	
	AttackAble = false
	delay(AttackRest, function()
		AttackAble = true
	end)
	
	AttackDamaging = true
	setCurlState(false)
	delay(AttackWindow, function()
		AttackDamaging = false
		setCurlState(true)
	end)
	
	AttackVictims = {}
	
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Remote:FireClient(getPlayer(), "PlayAnimation", "R15Spin")
	else
		Remote:FireClient(getPlayer(), "PlayAnimation", "Spin")
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		attack()
	end
end

Remote.OnServerEvent:connect(onRemote)
Handle.Touched:connect(onHandleTouched)