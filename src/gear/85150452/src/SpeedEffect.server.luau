print("run latte")


-- assume we are in the character, let's check

function sepuku()
	script.Parent = nil
end

local h = script.Parent:FindFirstChild("Humanoid")

if (h == nil) then sepuku() end

local oldSpeed = h.WalkSpeed
h.WalkSpeed = h.WalkSpeed * 1.5

local ratio = h.Health/h.MaxHealth 
h.MaxHealth = 125
h.Health = ratio * 125


local torso = script.Parent:FindFirstChild("Torso") or script.Parent:FindFirstChild("UpperTorso")

if (torso == nil) then sepuku() end


local head = script.Parent:FindFirstChild("Head")
if (head == nil) then head = torso end



local s = Instance.new("Sparkles")
s.Color = Color3.new(0.6, 0, 0)
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

h.WalkSpeed = oldSpeed
ratio = h.Health/h.MaxHealth 
h.Health = ratio * 100
h.MaxHealth = 100
s:Remove()


script.Parent = nil