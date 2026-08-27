print("You got caked!")

splats = script:FindFirstChild("Splats")
if splats == nil then
	splats = Instance.new("Sound")
	splats.Parent = script
	splats.Volume = 1
	splats.Name = "Splats"
	splats.SoundId = "http://www.roblox.com/asset/?id=34376514"
end

screen = script.Parent:FindFirstChild("CakeScreen")
if screen == nil then
	print("Could not find screen in PlayerGUI")
end

cake = screen:FindFirstChild("cake")
if cake == nil then
	print("The Cake Was a Lie! (cake picture could not be found under CakeScreen)")
end

newCake = cake:Clone()
newCake.Position = UDim2.new(math.random(), -10, math.random()*.8, -10)
--newCake.Position = UDim2.new(math.random()*.70+.25, 0, math.random()*.70+.25, 0)
newCake.Size = UDim2.new(.2, 10, .2, 10)
newCake.Visible = true
newCake.Parent = screen

for i = 1,100 do
	newCake.Size = UDim2.new(.2, 10, .2+i*.008, 10)
	wait(.1)
end

--print("Finished cake script!!")
--script.Disabled = true
--script.Parent = nil
