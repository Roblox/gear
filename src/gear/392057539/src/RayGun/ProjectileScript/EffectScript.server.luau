--Made by Luckymaxer

EffectTimer = script.Parent

while true do
	wait(2.5)
	EffectTimer.Value = (EffectTimer.Value - 1)
	if EffectTimer.Value <= 0 then
		EffectTimer:Destroy()
	end
end