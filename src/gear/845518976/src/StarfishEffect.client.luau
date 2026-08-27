--Made by StarWars
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 24
local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Brightness = -0.5

BlurEffect.Parent = game.Lighting
ColorCorrection.Parent = game.Lighting

Debris:AddItem(BlurEffect, 5)
Debris:AddItem(ColorCorrection, 5)
script:Destroy()