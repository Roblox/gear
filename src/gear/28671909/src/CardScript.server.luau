local card = script.Parent

local debris = game:GetService("Debris")

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=28509434"
HitSound.Parent = card
HitSound.Volume = 1

wait(0.1)

function onTouched(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		tagHumanoid(humanoid)
		
		-- first yellow card, just do warning
		if card.Name == "YellowCard" and humanoid.Parent:FindFirstChild("YellowHit") == nil then

			HitSound.Pitch = math.random(0.8,1)
			HitSound:Play()
			local yellowHit = Instance.new("StringValue")
			yellowHit.Name = "YellowHit"
			yellowHit.Value = "YellowHit"
			yellowHit.Parent = humanoid.Parent

			local message = Instance.new("Message")
			message.Text = "You have been given a yellow card!"
			local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
			message.Parent = player

			debris:AddItem(message, 4)
			connection:disconnect()

		-- red card time!
		else
			if humanoid.Parent:FindFirstChild("TimeOutScript") == nil then
				
				HitSound.Pitch = math.random(0.8,1)
				HitSound:Play()
				local message = Instance.new("Message")
				message.Text = "Red Card! 10 second suspension!"
				local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
				message.Parent = player
				debris:AddItem(message, 4)

				local script = card:FindFirstChild("TimeOutScript"):clone()
				script.Parent = humanoid.Parent
				script.Disabled = false

				local yellowCard = humanoid.Parent:FindFirstChild("YellowHit")
				if yellowCard ~= nil then
					yellowCard.Parent = nil
					yellowCard:remove()
				end

			end
			connection:disconnect()

		end

		untagHumanoid(humanoid)
	end
	wait(2)
	card:remove()
end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = card:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
		new_tag.Parent = humanoid
	end
end


function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

connection = card.Touched:connect(onTouched)