-- Calls Destroy on this script's Parent after TimeToLive
TimeToLive = script:WaitForChild("TimeToLive")
wait(TimeToLive.Value)
if script.Parent then
	script.Parent:Destroy()
end
