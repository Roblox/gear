--Fixed by Luckymaxer

function sepuku()
	script.Parent = nil
end

local h = script.Parent:FindFirstChild("Humanoid")

if (h == nil) then sepuku() end

h.WalkSpeed = 16 * 1.6




local torso = script.Parent:FindFirstChild("Torso") or script.Parent:FindFirstChild("UpperTorso")

if (torso == nil) then sepuku() end


local head = script.Parent:FindFirstChild("Head")
if (head == nil) then head = torso end



local s = Instance.new("Sparkles")
s.Color = Color3.new(.8, 0, .8)
s.Parent = torso


local count = h:FindFirstChild("CoffeeCount")
if (count == nil) then
	count = Instance.new("IntValue")
	count.Name = "CoffeeCount"
	count.Value = 1
	count.Parent = h
else
	
	if (count.Value > 3) then
		if (math.random() > .5) then

			local sound = Instance.new("Sound")
			sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
			sound.Parent = head
			sound.Volume = 1
			sound:play()

			local e = Instance.new("Explosion")
			e.BlastRadius = 4
			e.Position = head.Position
			
			s:Clone().Parent = head
			e.Parent = head
			

		end
	end
	count.Value = count.Value + 1
end

wait(30)

h.WalkSpeed = 16
s:Destroy()


script.Parent = nil