-- need to add particle effects in after the fact so we can get a good thumbnail/profile pic

local part = Instance.new("Part")
part.Name = "Frost"
part.CanCollide = false
part.Locked = true
part.formFactor = 0
part.Size = Vector3.new(1,1,1)
part.Transparency = 1

local froster = Instance.new("Fire")
froster.Name = "IceFrost"
froster.Color = Color3.new(102/255,174/255,1)
froster.Heat = -25
froster.SecondaryColor = Color3.new(0,0,1)
froster.Size = 2
froster.Enabled = false
froster.Parent = part

part.Parent = script.Parent

script:remove()