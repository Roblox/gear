--Now with an added search function! (For those who carry a lot of gear)
	
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

local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle")

Tool.Enabled = true

local GearRequest = (Tool:FindFirstChild("GearRequest") or Create("RemoteEvent"){
	Name = "GearRequest",
	Parent = Tool,
})

local Player,Character,Humanoid,Root

local Sounds = {
	Clone = Handle:WaitForChild("Clone")
}

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = (game:FindService("Players") or game:GetService("Players")):GetPlayerFromCharacter(Character)
	Root = Character:WaitForChild("HumanoidRootPart")
end

function Unequipped()
	Player,Character,Humanoid,Root = nil,nil,nil,nil
end

local Cloned = false
GearRequest.OnServerEvent:Connect(function(client,RequestedGear)
	
	if client ~= Player then return end
	if not Humanoid or Humanoid.Health <= 0 then return end
	if not RequestedGear or not RequestedGear:IsA("Tool") then return end --If the server doesn't see it, it dosen't exist
	if Cloned then return end
	Cloned = true
	print("A Request has been received")
	local ClonedGear = RequestedGear:Clone()
	
	local Handle = ClonedGear:FindFirstChild("Handle")
	local SpawnPos = (Root.CFrame * CFrame.new(0,0,-5)).p
	
	if Handle then
		Handle.CFrame = CFrame.new(SpawnPos)
	end
	
	Tool.Parent = nil --We're done with this
	
	local OrigSize = (Handle and math.max(Handle.Size.X,Handle.Size.Y,Handle.Size.Z))or 5
	local SpawnOrb = Create("Part"){
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
		Color = Color3.new(0,1,1),
		CanCollide = false,
		Locked = true,
		Anchored = true,
		Transparency = 0,
		CFrame = CFrame.new(SpawnPos),
		Size = Vector3.new(1,1,1)*(OrigSize*1.5),
		Parent = workspace
	}
	Sounds.Clone.Parent = SpawnOrb
	Sounds.Clone:Play()
	
	ClonedGear.Parent = workspace
	
	local Tween = (game:FindService("TweenService") or game:GetService("TweenService")):Create(SpawnOrb,TweenInfo.new(1,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0),{Transparency = 1,Size = Vector3.new(0,0,0)})
	Tween:Play();Tween.Completed:Wait()
	
	Tool:Destroy()--Make sure it's unrecoverable
	
end)

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)


