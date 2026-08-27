-- Dragon Plushie!!

Tool  = script.Parent
Dragon = script.Parent.Handle

Tool.Enabled = true

local FlapSound = script.FlapSound
local FireSound = script.FireSound

local NumClicks = 0


--This call will cause a "wait" until the data comes back
local error = true
local FireFace = nil
while FireFace == nil do
	error = false
	FireFace = game:GetService("InsertService"):LoadAsset(45942969)

	local instances = FireFace:GetChildren()
	if #instances == 0 then
		FireFace:Remove()
		print("could not create fireface")
		error = true
		FireFace = nil
	else 
		FireFace = FireFace:FindFirstChild("FireFace")
	end
	--local missile = root:Clone()
	wait()
end

FireFace.Parent = Tool

local FireWeld = Instance.new("Weld")
FireWeld.Name = "FireWeld"
FireWeld.Part0 = FireFace
FireWeld.Part1 = Tool.Handle
FireWeld.C1 = CFrame.new() + Vector3.new(-0.204999924, 0.900000095, 0.414999962)
FireWeld.Parent = Tool	
FireFace.CanCollide = false

function onActivated()

	NumClicks = NumClicks + 1		

	if not Tool.Enabled then 
		return
	end
	
	Tool.Enabled = false
		
	if NumClicks > 5 then 		
		FireFace.Fire.Enabled = true
		FireSound:Play()
		wait(2)
		-- Do the fire stuff here
		Tool.Enabled = true
		NumClicks = 0	
		FireFace.Fire.Enabled = false

	else
		NumClicks = 0
		FlapSound:Play()
		for i =1,5,1 do
			Dragon.Mesh.MeshId = "http://www.roblox.com/asset?id=45918598" -- D
			wait(0.1)
			Dragon.Mesh.MeshId = "http://www.roblox.com/asset?id=45919463" -- W1
			wait(0.1)
			Dragon.Mesh.MeshId = "http://www.roblox.com/asset?id=45919487" -- W2
			wait(0.1)
			Dragon.Mesh.MeshId = "http://www.roblox.com/asset?id=45919463" -- W1
			wait(0.1)		
		end		
		wait(0.2)
		Tool.Enabled = true	
	end
end

function onEquipped()
	FlapSound.Volume = 1
	FireSound.Volume = 1
	FlapSound:Stop()
	FireSound:Stop()

	FireFace.Anchored = false
	FireWeld = Tool:FindFirstChild("FireWeld")
	if FireWeld == nil then
		print("Remaking weld")
		FireWeld = Instance.new("Weld")
		FireWeld.Name = "FireWeld"
		FireWeld.Part0 = FireFace
		FireWeld.Part1 = Tool.Handle
		FireWeld.C1 = CFrame.new() + Vector3.new(-0.204999924, 0.900000095, 0.414999962)
		FireWeld.Parent = Tool	
	end
end

function onUnequipped()
	FlapSound.Volume = 0
	FireSound.Volume = 0	
	FireSound:Stop()
	FlapSound:Stop()
	FireFace.Fire.Enabled = false
	FireFace.Anchored = true
	if FireWeld ~= nil then FireWeld:remove() end
	FireWeld = Tool:FindFirstChild("FireWeld")
end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)