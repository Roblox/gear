--Made by Luckymaxer

Humanoid = script.Parent

Spicy = script:WaitForChild("SpicyAnim")

SpicyAnim = Humanoid:LoadAnimation(Spicy)
if SpicyAnim then
	SpicyAnim:Play()
end

wait(2)

script:Destroy()