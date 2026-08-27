--Made by Luckymaxer

Character = script.Parent

Debris = game:GetService("Debris")

Duration = script:FindFirstChild("Duration")

BaseUrl = "http://www.roblox.com/asset/?id="

Rate = (1 / 60)

NewFace = (BaseUrl .. "255037803")

if Duration then
	Head = Character:FindFirstChild("Head")
	if Head then
		Face = Head:FindFirstChild("face")
		if Face then
			OriginalFace = Face.Texture
			Face.Texture = NewFace
		end
	end
end

while Duration.Value > 0 do
	local Time = wait(Rate)
	Duration.Value = (Duration.Value - Time)
end

if Face then
	Face.Texture = OriginalFace
end

Debris:AddItem(script, 0.25)