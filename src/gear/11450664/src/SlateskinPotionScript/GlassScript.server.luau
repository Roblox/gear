--Rescripted by Luckymaxer

Part = script.Parent

Debris = game:GetService("Debris")

Sounds = {
	GlassBreak = Part:WaitForChild("GlassBreak")
}

function Touched(Part)
	local PartTouched
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		Sounds.GlassBreak:Play()
		if PartTouched then
			PartTouched:disconnect()
		end
	end)
end

Touched(Part)

Debris:AddItem(Part, 30)