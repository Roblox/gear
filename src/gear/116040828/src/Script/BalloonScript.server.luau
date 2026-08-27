--Made by Luckymaxer

Model = script.Parent
Balloon = Model:FindFirstChild("Balloon")
MainPart = Model:FindFirstChild("MainPart")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Seated = Instance.new("BoolValue")
Seated.Value = false

Seats = {}

function DestroyModel()
	Debris:AddItem(Model, 0.5)
end

Creator = Model:FindFirstChild("Creator")
IdleDuration = Model:FindFirstChild("IdleDuration")

if not Balloon or not MainPart or not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Creator.Value.Parent or not IdleDuration then
	DestroyModel()
	return
end

BalloonWeld = MainPart:FindFirstChild("BalloonWeld")
if not BalloonWeld then
	DestroyModel()
	return
end

Player = Creator.Value
Character = Player.Character

IdleDuration = IdleDuration.Value

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function IdleRemove()
	local CanRemove = true
	local RemoveCheck = Seated.Changed:connect(function()
		if Seated.Value then
			CanRemove = false
		end
	end)
	wait(IdleDuration)
	if RemoveCheck then
		RemoveCheck:disconnect()
	end
	if CanRemove then
		DestroyModel()
	end
end

Player.Changed:connect(function(Property)
	if Property == "Parent" and not Player.Parent then
		DestroyModel()
	elseif Property == "Character" and not Player.Character or not Player.Character.Parent then
		DestroyModel()
	end
end)

for i, v in pairs(Model:GetChildren()) do
	if v:IsA("Seat") then
		table.insert(Seats, v)
		v.ChildAdded:connect(function(Child)
			if Child:IsA("JointInstance") and Child.Name == "SeatWeld" then
				if ((Child.Part0 and Child.Part0.Parent == Character) or (Child.Part1 and Child.Part1.Parent == Character)) then
					Seated.Value = true
				end
			end
		end)
		v.ChildRemoved:connect(function(Child)
			if Child:IsA("JointInstance") and Child.Name == "SeatWeld" then
				if ((Child.Part0 and Child.Part0.Parent == Character) or (Child.Part1 and Child.Part1.Parent == Character)) then
					Seated.Value = false
				end
			end
		end)
	end
end

spawn(function()
	Seated.Changed:connect(function()
		if not Seated.Value then
			IdleRemove()
		end
	end)
	
	IdleRemove()
end)

spawn(function() --Broken monitor; Will determine whether or not the balloon is intact or in pieces.
	while true do
		if not MainPart.Parent or not Balloon.Parent or (not BalloonWeld.Parent or not BalloonWeld.Part0 or not BalloonWeld.Part0.Parent or not BalloonWeld.Part1 or not BalloonWeld.Part1.Parent) then --The base or balloon of the model is missing, so the balloon is removed.
			DestroyModel()
			break
		end
		local ConnectedParts = GetAllConnectedParts(MainPart)
		for i, v in pairs(Seats) do
			local SeatWelded = false
			for ii, vv in pairs(ConnectedParts) do
				if v == vv then
					SeatWelded = true
				end
			end
			if not SeatWelded then --If neither seat is attached to the balloon, it is unusable, therefore it is removed.
				table.remove(Seats, i)
			end
			if #Seats == 0 then
				DestroyModel()
				break
			end
		end
		wait(1)
	end
end)