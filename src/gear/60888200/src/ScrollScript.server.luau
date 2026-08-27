local Tool = script.Parent
local Scroll = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local vPlayer

local scrollSound

local scrollSummon

Tool.Enabled = true

local checkWeld 

local debris = game:GetService("Debris")

local pierceDamage = 30

local storeWeld  = Tool:FindFirstChild("FireWeld")
while storeWeld == nil do wait() storeWeld = Scroll:FindFirstChild("FireWeld") end

local waves = {}

local wave = Instance.new("Part")
wave.FormFactor = 3
wave.Shape = "Block"
wave.Size = Vector3.new(1, 3, 6)
wave.CanCollide = false
wave.Name = "Wave"
wave.Transparency = 0.0

local waveMesh = Instance.new("SpecialMesh")
waveMesh.MeshId = "http://www.roblox.com/asset/?id=60886166"
waveMesh.TextureId = "http://www.roblox.com/asset/?id=60886211"
waveMesh.Scale = Vector3.new(0.35, 0.35, 0.35)
waveMesh.Parent = wave

function tagHumanoid(humanoid, player) 
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue") 
		creatorTag.Name = "creator" 
		creatorTag.Parent = humanoid 
		creatorTag.Value = player 
		debris:AddItem(creatorTag, 1.5) 
	end 
end 

function pierce(wave, hit) 	
	if wave then 
		if hit.Parent and hit then 
			if hit.className == "Hat" then 
				humanoid = hit.Parent.Parent:FindFirstChild("Humanoid") 
			else 
				humanoid = hit.Parent:FindFirstChild("Humanoid") 
			end 
			if humanoid ~= nil and myHumanoid ~= humanoid and myHumanoid ~= nil then 
				tagHumanoid(humanoid, vPlayer) 				
				humanoid:TakeDamage(pierceDamage)     
			end 
		end 
	end 
end 

function summon()	
	scrollSummon = Tool:FindFirstChild("ScrollSummon")
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if scrollSummon and myTorso and myHumanoid then 		
		if scrollSummon.Value == 1 then 
			wait(2.0)
			coroutine.resume(coroutine.create(function() 
				wait(3.0) 
				scrollSummon = Tool:FindFirstChild("ScrollSummon")
				if scrollSummon then 
					scrollSummon.Value = 0
				end
			end))
			myHumanoid.WalkSpeed = 0.0
			myTorso.Anchored = true
			for i = 1, 10 do 
				local direction = CFrame.Angles(0, i * math.pi/5, 0)	* myTorso.CFrame.lookVector 
				local spawnPos = myTorso.Position + direction * 4.0
				waves[i] = wave:Clone()
				waves[i].CFrame = CFrame.new(spawnPos, spawnPos + direction)
				waves[i].Velocity = direction * 55.0
				
				local floatForce = Instance.new("BodyForce")
				floatForce.force = Vector3.new(0, waves[i]:GetMass() * 196.1, 0)
				floatForce.Parent = waves[i]
	
				waves[i].Parent = game.Workspace				

				waves[i].Touched:connect(function(hit) pierce(waves[i], hit) end)
				debris:AddItem(waves[i], 2)			
			end
			wait(1.0)
			myHumanoid.WalkSpeed = 22.0
			coroutine.resume(coroutine.create(function() wait(3.0) if myHumanoid then myHumanoid.WalkSpeed = 16.0 end end))
			myTorso.Anchored = false			
		end
	end
end

function onEquipped()
	checkWeld = Scroll:FindFirstChild("FireWeld")
	if checkWeld == nil then
		checkWeld = storeWeld:Clone() 
		checkWeld.Parent = Scroll
	end
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end

function onUnequipped()
	if scrollSound then scrollSound:Stop() end	
	if myHumanoid then myHumanoid.WalkSpeed = 16.0 end
end

Tool.Unequipped:connect(onUnequipped)
Tool.Equipped:connect(onEquipped)

while Tool:FindFirstChild("ScrollSummon") == nil do wait() end
scrollSummon = Tool:FindFirstChild("ScrollSummon")
if scrollSummon then 
	scrollSummon.Changed:connect(summon)
end
