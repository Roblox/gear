-- Calls Destroy on this script's Parent after TimeToLive
while not script:FindFirstChild("TimeToLive") do wait() end -- Irony
wait(script.TimeToLive.Value)
if script.Parent then script.Parent:Destroy() end
