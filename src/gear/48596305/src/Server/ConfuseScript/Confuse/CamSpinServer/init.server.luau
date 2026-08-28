--monitors the client to make sure nothing glitches

local Self = script

local Duration,Target = Self:WaitForChild("Duration").Value,Self:WaitForChild("Target").Value

local CamSpinClient = Self:FindFirstChild("CamSpinClient")

if CamSpinClient then
	local Dur = Instance.new("NumberValue")
	Dur.Name = "Duration"
	Dur.Value = Duration
	Dur.Parent = CamSpinClient
	CamSpinClient.Parent = Target:WaitForChild("PlayerGui")
	CamSpinClient.Disabled = false
	 
end

delay(Duration + 1, function()
	if CamSpinClient then
		CamSpinClient:Destroy()
	end
	Self:Destroy()
end)
