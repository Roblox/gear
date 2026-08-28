local vCharacter = script.Parent

local Tool = vCharacter:findFirstChild("Korblox Sword")

myHumanoid = vCharacter:findFirstChild("Humanoid")
if myHumanoid then 
	myHumanoid:TakeDamage(10)	
end

local berserkTime = 12

if myHumanoid ~= nil then 

	if Tool then 		
		Tool.SlashDamage.Value =  32
		Tool.LungeDamage.Value =  40

		
		part = Instance.new("Part")
		part.Name = "Eye"
		part.Parent = Tool.Handle 
		part.Shape = "Ball"
		part.Size = Vector3.new(0.2, 0.2, 0.2) 
		part.Transparency = 1.0
		
		weld = Instance.new("Weld")
		weld.Name = "EyeWeld"
		weld.Part0 = Tool.Handle
		weld.Part1 = part		
		weld.C1 = CFrame.new(Vector3.new(0.0, 0.05, 2.5))		
		weld.Parent = Tool.Handle 

		fire = Instance.new("Fire")
		fire.Color = Color3.new(0.0, 0.0, 1.0)
		fire.Parent = part
		fire.Heat = 1
		fire.Size = 2
	end
	while berserkTime > 0 do 
	
		myHumanoid.Health = myHumanoid.Health - 2.5
		berserkTime = berserkTime - 1
		
		wait(1.0)
	end
		
	if Tool then
		Tool.SlashDamage.Value = 16.0
		Tool.LungeDamage.Value = 20.0
	end

	if part then part:Remove() end

	wait(12.0)
	script:Remove()
end
