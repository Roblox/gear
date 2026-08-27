local player = script.Parent

local origWalkSpeed = player.Humanoid.WalkSpeed
player.Humanoid.WalkSpeed = origWalkSpeed/4

local bodyColors = player:FindFirstChild("Body Colors")
bodyColors.Parent = nil

local newBodyColors = Instance.new("BodyColors")
newBodyColors.HeadColor = BrickColor.new("Bright blue")
newBodyColors.LeftArmColor = BrickColor.new("Bright blue")
newBodyColors.RightArmColor = BrickColor.new("Bright blue")
newBodyColors.RightLegColor = BrickColor.new("Bright blue")
newBodyColors.LeftLegColor = BrickColor.new("Bright blue")
newBodyColors.TorsoColor = BrickColor.new("Bright blue")
newBodyColors.Parent = player

wait(15)

player.Humanoid.WalkSpeed = origWalkSpeed
newBodyColors:remove()
bodyColors.Parent = player
script:remove()
