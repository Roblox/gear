local TIME_UNTIL_ENABLED = 32
wait(TIME_UNTIL_ENABLED)
if script.Parent then
	script.Parent.Enabled = true
end
script:Remove()
