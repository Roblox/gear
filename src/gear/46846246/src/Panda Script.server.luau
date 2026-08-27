-- Panda Plushie!!

Tool  = script.Parent
Panda = script.Parent.Handle


local squeakSound = Panda.SqueakSound
local angrySound = Panda.AngrySound

local pandaUnequipped = false

-- set up blade of extreme panda ire

--This call will cause a "wait" until the data comes back
local error = true
local pandaPoker = nil
while pandaPoker == nil do
	error = false
	pandaPoker = game:GetService("InsertService"):LoadAsset(45944173)

	local instances = pandaPoker:GetChildren()
	if #instances == 0 then
		pandaPoker:Remove()
		print("could not create fireface")
		error = true
		pandaPoker = nil
	else 
		pandaPoker = pandaPoker:FindFirstChild("PandaPoker")
	end
	--local missile = root:Clone()
	wait()
end

pandaPoker.Parent = game.Lighting
pandaPoker.Anchored = false


Tool.Enabled = true
-- Sounds...

local pandaWeld = nil

local numClicks = 0
function onActivated()
	if Tool.Enabled then
		Tool.Enabled = false

		print(numClicks)

		if numClicks > 19 then  -- how many clicks in the 4.4 seconds of animation they need
			Tool.Enabled = false

			angrySound:Play()
			wait(2)

			pandaWeld = Instance.new("Weld")
			pandaWeld.Part0 = Panda
			pandaWeld.Part1 = pandaPoker
			pandaPoker.Parent = game.Workspace
			pandaWeld.C1 = CFrame.Angles(0, math.pi/2, math.pi) + Vector3.new(-0.4, 0.05, -0.55)  -- (y, z, x)
			pandaWeld.Parent = Panda

			pandaPoker.Transparency = 0
		
			wait(3)
			pandaPoker.Parent = game.Lighting
			Tool.Enabled = true
			numClicks = 0
		else
			numClicks = 0
			-- Baking the animation through code!
			-- Have, 6 different meshes and cycle through them in a short delay
			-- Twice!
			squeakSound:Play()
			for i =1,3,1 do
				if not pandaUnequipped then 
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45867891" -- D
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45873597" -- H1 
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45873628" -- H2
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45873597" -- H1
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45867891" -- D
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45874981" -- L1
					wait(0.1)					
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45867891" -- D 
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45875020" -- L2 
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45867891" -- D
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45874981" -- L1	
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45867891" -- D
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45875020" -- L2
					wait(0.1)
					Panda.Mesh.MeshId = "http://www.roblox.com/asset?id=45867891" -- D	
					wait(0.1)
				end
			end
			wait(.5)
			Tool.Enabled = true
		end
	else
		-- look for multiple clix
		numClicks = numClicks + 1
	end
end

function onEquipped()	
	pandaUnequipped = false
end

function onUnequipped()	
	if squeakSound then squeakSound:Stop() end
	if angrySound then angrySound:Stop() end

	pandaUnequipped = true

	pandaPoker.Parent = game.Lighting
end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
