local Grenade = script.Parent

while Grenade:FindFirstChild("Sparkles") == nil do wait() end

while script:FindFirstChild("BOOM") == nil do 
	wait()
end

local debris = game:GetService("Debris")

local boom = script.BOOM
boom:Play() 

local duration = 2.5

local christmasAssets = {19398784, 1235487, 42781797, 67187806, 67187797, 67187780, 67187806, 67187806, 67187806, 67187797, 67187780, 67187797, 67187780}

local bg = Instance.new("BodyGyro")
bg.Name = "BodyGyro"
bg.P = 200000
bg.maxTorque = Vector3.new(bg.P, bg.P, bg.P)

local sparkles = Grenade.Sparkles 
sparkles.Enabled = true

while duration > 0 do 
	tick()
	duration = duration - wait()
	wait()
	sparkles.SparkleColor = Color3.new(math.random(), math.random(), math.random())
end

local sound = Instance.new("Sound")
sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
sound.Parent = script.Parent
sound.Volume = 1
sound:play()

wait(0.25)

function handleAsset(bGyro, asset, part)	
	print(bGyro, asset, part)
	wait(0.25)	
	print(bGyro, asset, part)
	if asset then 
		if (asset:IsA("Accessory") or asset:IsA("Tool")) then 		
		else 
			print(part.Parent)
			if bGyro and asset and part then
				bGyro.Parent = part
				part.CFrame = bGyro.cframe
				print("Unanchoring part", part.Parent)
				part.Anchored = false 
			end 
		end 
	else
		print("Asset not found")
	end 
end

for i = 1, #christmasAssets do 
	local asset = game:GetService("InsertService"):LoadAsset(christmasAssets[i]) 
	if asset then 
		asset = asset:GetChildren()
		if asset then 
			asset = asset[1] 
			asset.Parent = game.Workspace 
			if asset:IsA("Accessory") or asset:IsA("Tool") then 
				while asset:FindFirstChild("Handle") == nil do 
					wait()
				end 
				local bgClone = bg:Clone()
				bgClone.cframe = asset.Handle.CFrame 
				coroutine.resume(coroutine.create(function() 
					handleAsset(bgClone, asset, asset:FindFirstChild("Handle"))
				end)) 
				asset.Handle.Position = Grenade.Position
				asset.Handle.Velocity = Vector3.new(math.random(), math.random(), math.random()) * 75.0
				if sparkles then 
					local s = sparkles:Clone()					
					s.SparkleColor = Color3.new(math.random(), math.random(), math.random())
					debris:AddItem(s, 4)
				end 				
				
			elseif asset:IsA("Model") then 	
				if asset.PrimaryPart then 
					asset.PrimaryPart.Anchored = true
					asset.PrimaryPart.Velocity = Vector3.new(math.random(), math.random(), math.random()) * 115.0
					local bgClone = bg:Clone()
					bgClone.cframe = asset:GetModelCFrame() 
					coroutine.resume(coroutine.create(function() 
						handleAsset(bgClone, asset, asset.PrimaryPart)						
					end)) 	
					asset:MoveTo(Grenade.Position + Vector3.new(math.random(-35, 35), 0, math.random(-35, 35)))
					if sparkles then 
						local s = sparkles:Clone()						
						s.SparkleColor = Color3.new(math.random(), math.random(), math.random())
						debris:AddItem(s, 4)
					end 
				else 
					local children = asset:GetChildren()
					for i = 1, #children do 
						if children[i]:IsA("BasePart") then
							local bgClone = bg:Clone()
							bgClone.cframe = asset:GetModelCFrame() 
							asset:MoveTo(Grenade.Position + Vector3.new(math.random(-35, 35), 0, math.random(-35, 35)))
							children[i].Anchored = true 
							children[i].Velocity = Vector3.new(math.random(), math.random(), math.random()) * 115.0	
							local localChild = children[i]
							print("Found it")
							coroutine.resume(coroutine.create(function()
								print("Coroutining")
								handleAsset(bgClone, asset, localChild)
							end))								
							if sparkles then 
								local s = sparkles:Clone()									
								s.SparkleColor = Color3.new(math.random(), math.random(), math.random())
								debris:AddItem(s, 4)
							end						 
							break 
						end 
					end 				
				end 
			end 
			debris:AddItem(asset, 15)
		end 
	end 
end 

for i = 1, math.random(60, 120) do 
	local p = Instance.new("Part")
	p.Transparency = 1.0
	p.FormFactor = 3.0
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.Parent = game.Workspace
	p.Position = Grenade.Position
	p.Velocity = Vector3.new(math.random(), math.random(), math.random()) * 35.0
	if sparkles then 
		local s = sparkles:Clone()
		s.Parent = p
		s.SparkleColor = Color3.new(math.random(), math.random(), math.random())
		debris:AddItem(s, 4)
		debris:AddItem(p, 3)
	end 	
	if i%10 == 0 then wait() end
end 

if sparkles then sparkles:Destroy() end 
wait(0.15)
if boom then boom:Stop() end
if Grenade then Grenade:Destroy() end


