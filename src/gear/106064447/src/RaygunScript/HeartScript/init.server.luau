local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end


local contentProvider = game:GetService("ContentProvider")
local DebrisService = Game:GetService('Debris')

local BASE_URL = contentProvider.BaseUrl
local AmmoTXId = BASE_URL .. 'asset/?id=105977933'
local AmmoMeshId = BASE_URL .. 'asset/?id=105992239'

local AmmoPrefab = Instance.new('Part')
AmmoPrefab.FormFactor = 'Custom'
AmmoPrefab.Size = Vector3.new(1, 1, 0.2)
AmmoPrefab.Locked = true
AmmoPrefab.TopSurface = 'Smooth'
AmmoPrefab.BottomSurface = 'Smooth'
AmmoPrefab.CanCollide = false
AmmoPrefab.Transparency = 0
AmmoPrefab.Name = 'HeartMesh'


local AmmoMesh = Instance.new('SpecialMesh')
AmmoMesh.TextureId = AmmoTXId
AmmoMesh.MeshId = AmmoMeshId
AmmoMesh.Scale = Vector3.new(2,2,1)
-- Lets run randomize this from the range of (1,1,1) to (1,0,0) to add a little variation
AmmoMesh.VertexColor = Vector3.new(1,0.3,0.3)
AmmoMesh.Parent = AmmoPrefab

local Torso = script.Parent

-- Wait because of set parent while setting parent bug
wait()

local HeartBeatScript = WaitForChild(script, 'SoundScript')
DebrisService:AddItem(HeartBeatScript, 5)
HeartBeatScript.Parent = Torso
HeartBeatScript.Disabled = false

local newAmmo = AmmoPrefab:Clone()
DebrisService:AddItem(newAmmo, 5)
newAmmo.Parent = Workspace

--wait()

local Weld = Instance.new('ManualWeld')
Weld.Part0 = Torso
Weld.Part1 = newAmmo
Weld.C0 = CFrame.Angles(0, math.pi, 0) * CFrame.new(0.3,0.42, 0.4)
Weld.Name = "weld"
Weld.Parent = newAmmo

while newAmmo and newAmmo:FindFirstChild('Mesh') do
	newAmmo:FindFirstChild('Mesh').Scale = Vector3.new(2,2,3.3 * (math.sin(tick() * 20) + 1.5))
	
	wait()
end

script:Destroy()

