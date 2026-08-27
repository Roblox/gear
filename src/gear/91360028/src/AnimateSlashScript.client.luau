-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

print('Starting doll')


local MyHumanoid = WaitForChild(script.Parent, 'Humanoid')

local RecoilAnim = WaitForChild(script, 'SlashAnim')
local RecoilTrack

print('Ending doll')

if RecoilAnim then
	RecoilTrack = MyHumanoid:LoadAnimation(RecoilAnim)
end
if RecoilTrack then
	RecoilTrack:Play()
	wait(6)
	RecoilTrack:Stop()
end


script:Destroy()
