-- Swings fast, does great damage
-- Can cast mark of the damned, to summon a skeleton upon a frag
-- Lasts 150 seconds

local Tool = script.Parent
local Hammer = Tool.Handle

local debris = game:GetService("Debris")

Tool.Enabled = true

local vCharacter
local myTorso
local hammerSound

local skeletonValue = Tool:FindFirstChild("Skeleton")
local mark = Tool:FindFirstChild("Mark")

local damage = 22

local spawnConnection

local bbGui = Instance.new("BillboardGui")
bbGui.Name = "Child of the Hammer"
bbGui.Size = UDim2.new(1, 0, 1, 0)
bbGui.StudsOffset = Vector3.new(0, 2, 0)

local image = Instance.new("ImageLabel")
image.Name  = "Child"
image.Image = "http://www.roblox.com/asset/?id=53594614"
image.Size = UDim2.new(1, 0, 1, 0)
image.BackgroundTransparency = 1.0
image.Parent = bbGui

local bbClone
local bbLocalClone

local co
local rmCo

local puppet = Tool:FindFirstChild("Puppet")

local hammerSound 
local unAnchoredParts = {}

function resetConnection()	
	print("Resetting")
	local duration = 5
	while duration > 0 do
		if bbClone then bbClone.Child.Visible = not bbClone.Child.Visible end
		if bbLocalClone then bbLocalClone.Child.Visible = not bbLocalClone.Child.Visible end
		duration = duration - 0.5
		wait(0.5)
	end
	print("Removing BB")
	if bbClone then bbClone:Remove() end
	if bbLocalClone then bbLocalClone:Remove() end
	if spawnConnection then spawnConnection:disconnect() end
end

local skeleton

function bite(hit)
	if hit.Parent then
		humanoid = hit.Parent:FindFirstChild("Humanoid")
	end
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid and humanoid ~= myHumanoid and myHumanoid ~= nil then 
		humanoid:TakeDamage(12)
	end
end

function removeCo(skeleton)
	duration = 150
	while duration > 0 do 		
		duration = duration - 1
		wait(1.0)
	end
	if skeleton then skeleton:Remove() end
	if puppet then puppet.Value = nil end
end

function offsetModelBy(model, offset) 
	local childs = model:GetChildren() 
	for i = 1, #childs do 
		if childs[i].className == "Part" or childs[i].className == "TrussPart" or childs[i].className == "WedgePart" then 
			childs[i].CFrame = childs[i].CFrame + offset                           
		if not childs[i].Anchored then table.insert(unAnchoredParts, childs[i]) end 
			childs[i].Anchored = true -- anchor everything 
		elseif childs[i].className == "Tool" or childs[i].className == "Hat" or childs[i].className == "Model" then 
			offsetModelBy(childs[i], offset) 
		end 
	end 
end 

function spawnSkeleton(humanoid)
	skeleton = game:GetService("InsertService"):LoadAsset(53604463)
	if skeleton then
		print("Inserting Model")
		skeleton = skeleton:GetChildren()[1] 		
		skeletonTorso = skeleton:FindFirstChild("Torso")
		while skeletonTorso == nil do
			wait(1.0)
			skeletonTorso = skeleton:FindFirstChild("Torso")
		end
		torso = humanoid.Parent:FindFirstChild("Torso")
		unAnchoredParts = {}
		if torso then offsetVector = (torso.Position - skeleton.Torso.Position) else offsetVector = (myTorso.Position - skeleton.Torso.Position) end
		offsetModelBy(skeleton, offsetVector)	
		skeleton.Parent = game.Workspace
		neck = skeleton.Torso.Neck
		neck.Part0 = skeleton.Head
		neck.Part1 = skeleton.Torso
		-- Hack -- 
		for j = 1, 10 do 
			skeleton.Humanoid.MaxHealth = 500
			skeleton.Humanoid.Health = 500
			skeleton:MakeJoints()
			wait(0.1)
		end
		-- unanchor everything 
		for u = 1, #unAnchoredParts do unAnchoredParts[u].Anchored = false end 
	
		skeletonValue.Value = 1
		skeleton.Humanoid.Health = 500
		skeleton.Humanoid.Died:connect(function() if puppet then puppet.Value = nil end if skeletonValue then skeletonValue.Value = 0 end end)
		skeleton.Torso.Touched:connect(bite)
		rmCo = coroutine.create(removeCo)
		coroutine.resume(rmCo, skeleton)		
		if puppet then puppet.Value = skeleton end		
	end
end

function blow(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then 
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Hammer or rightGrip.Part1 == Hammer) then 
				tagHumanoid(humanoid, vPlayer)
				if mark.Value == 1 then 
					print("Marking")
					mark.Value = 0
					voidScript = Tool.VoidScript:Clone()
					voidScript.Parent = humanoid.Parent
					voidScript.Disabled = false
					if puppet.Value == nil then 
						spawnConnection = humanoid.Died:connect(function() spawnSkeleton(humanoid) end)
					end
					bbClone = bbGui:Clone()
					bbLocalClone = bbGui:Clone()
					bbLocalClone.Parent = vPlayer.PlayerGui
					hitHead = hit.Parent:FindFirstChild("Head")
					if hitHead then  bbLocalClone.Adornee = hitHead end
					player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
					if player then print("Parenting Gui") bbClone.Parent = player.PlayerGui
						bbClone.Adornee = hit.Parent.Head						
					end
					co = coroutine.create(resetConnection)
					coroutine.resume(co)
				end
				humanoid:TakeDamage(damage)
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creator = Instance.new("ObjectValue")
		creator.Value = player
		creator.Name = "creator"
		creator.Parent = humanoid
		debris:addItem(creator, 1)
	end	
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		return
	end

	hammerSound = Tool:FindFirstChild("HammerSound")
	if hammerSound then hammerSound:Play() end

	wait(2.0)
	Tool.Enabled = true 
end

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
end

function onUnequipped()
	if hammerSound then hammerSound:Stop() end
	if spawnConnection then spawnConnection:disconnect() end
	if skeleton then skeleton:Remove() end

	if bbClone then bbClone:Remove() end
	if bbLocalClone then bbLocalClone:Remove() end
	if puppet then puppet.Value = nil end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Hammer.Touched:connect(blow)
