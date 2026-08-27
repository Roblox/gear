--Stickamsterluke
--this script this made so that the sound is not played locally


sp=script.Parent


wait(1)

sp.PlaySound.Changed:connect(function()
	sp.Handle.Sound:Play()
end)


