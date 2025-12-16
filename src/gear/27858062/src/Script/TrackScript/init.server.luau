local start = tick()
local unequipped = false

script.LinkedTool.Value.Unequipped:connect(function() unequipped = true end)

while true do
	if unequipped then break end
	if tick()-start > script.Time.Value then break end
	
	wait()
end

if _G[script.Track.Value] then _G[script.Track.Value]:Stop() end
if script.Song.Value then script.Song.Value:Stop() end
if script.DiscoBall.Value then script.DiscoBall.Value:Destroy() end

script:Destroy()