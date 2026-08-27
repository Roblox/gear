--Made by Luckymaxer
--Precautionary method to work with a future existing property which has currently not been released.

Handle = script.Parent

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("ParticleEmitter") then
		pcall(function()
			v.InheritsMotion = true
		end)
		pcall(function()
			v.InheritsMotion = 1
		end)
	end
end