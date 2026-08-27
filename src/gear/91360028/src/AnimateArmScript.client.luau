-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

print('Starting doll')


local MyHumanoid = WaitForChild(script.Parent, 'Humanoid')

local RecoilAnim = WaitForChild(script, 'Recoil')
local RecoilTrack

print('Ending doll')

if RecoilAnim then
	RecoilTrack = MyHumanoid:LoadAnimation(RecoilAnim)
end

for i = 1, 3 do
	RecoilTrack:Play()
	wait(1)
end

RecoilTrack:Stop()

script:Destroy()
