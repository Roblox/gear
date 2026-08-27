--Made by Luckymaxer

Humanoid = script.Parent
Character = Humanoid.Parent
Head = Character:FindFirstChild("Head")
if Head then
	Face = Head:FindFirstChild("face")
	if Face then
		OriginalFace = Face.Texture
		Face.Texture = "http://www.roblox.com/asset/?id=108213708"
		wait(20)
		Face.Texture = OriginalFace
		script:Destroy()
	end
end