--Made by Luckymaxer

Part = script.Parent
Decal = Part:WaitForChild("Decal")

Debris = game:GetService("Debris")

Rate = (1 / 60)

FadeRate = 100

for i = 1, FadeRate do
	Decal.Transparency = (1 - (i / FadeRate))
	wait(Rate)
end