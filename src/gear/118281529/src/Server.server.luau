--Rescripted by TakeoHonorable
--Fixed the harpoon bypassing ForceFields

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local HarpoonBeam = Handle:WaitForChild("HarpoonBeam")

local StartPoint = Handle:WaitForChild("Start")

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end


local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
}


function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end


local MouseRemote = (Tool:FindFirstChild("MouseRemote") or Create("RemoteFunction"){
	Name = "MouseRemote",
	Parent = Tool,
})

local Player,Character,Humanoid
function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	
end

function Unequipped()
	if HarpoonBeam then
		HarpoonBeam.Attachment0 = StartPoint
		HarpoonBeam.Attachment1 = nil
	end
end

function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	local Sucess,MousePos = pcall(function() return MouseRemote:InvokeClient(Player) end)
	MousePos = (Sucess and MousePos) or Vector3.new(0,0,0)
	local AdjustedMousePos = StartPoint.WorldPosition + ((MousePos) - StartPoint.WorldPosition).Unit * math.clamp(((MousePos) - StartPoint.WorldPosition).Magnitude,0,150)
	local HarpoonRay = Ray.new(StartPoint.WorldPosition,(AdjustedMousePos-StartPoint.WorldPosition).Unit*150)
	
	local hit,pos = workspace:FindPartOnRayWithIgnoreList(HarpoonRay,{Character})
	local DummyPart = Create("Part"){
		Locked = true,
		Anchored = true,
		Transparency = false,
		Size = Vector3.new(0,0,0),
		Name = "HarpoonSpot",
		CFrame = CFrame.new(pos),
		Parent = workspace
	}
	local DummyPoint = Create("Attachment"){
		Position = Vector3.new(0,0,0),
		Name = "DummyPoint",
		Parent = DummyPart
	}
	HarpoonBeam.Attachment0 = StartPoint
	HarpoonBeam.Attachment1 = DummyPoint
	Services.Debris:AddItem(DummyPart,.3)
	wait(.3)
	
	if Tool:IsDescendantOf(Character) and hit and hit.Parent and not hit.Anchored and not hit.CanCollide and not hit.Parent:IsA("Accoutrement") and not hit.Parent:IsA("Tool") and not IsTeamMate(Services.Players:GetPlayerFromCharacter(hit.Parent),Player) and not hit.Parent:FindFirstChildOfClass("ForceField") then
		--"Snatch" the part
		--local PartClone = hit:Clone()
		--hit:Destroy()
		local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:TakeDamage(23)
		end
		hit.Parent = workspace
		hit:BreakJoints()	
		hit:SetNetworkOwner(nil)
		hit.Anchored = false
		hit.CanCollide = true
		local hitPoint = Create("Attachment"){
			Position = Vector3.new(0,0,0),
			Name = "DummyPoint",
			Parent = hit
		}
		HarpoonBeam.Attachment0 = StartPoint
		HarpoonBeam.Attachment1 = hitPoint
		hit.Velocity = (StartPoint.WorldPosition-hit.Position).Unit * (StartPoint.WorldPosition-hit.Position).Magnitude * 1.5
		Services.Debris:AddItem(hit,5)
		wait(2)
	else
		wait(1.5)
	end
	Tool.Enabled = true
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)