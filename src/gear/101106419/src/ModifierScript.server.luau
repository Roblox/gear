--this script modifies this weapon depending on if you have the according gamepass

local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do wait() end
	return parent[childName]
end

local Tool=script.Parent
local Player=Tool.Parent.Parent
local Handle=WaitForChild(Tool,'Handle')
local Mesh= WaitForChild(Handle,'Mesh')

local RedTexture= WaitForChild(Handle,'RedTextureId')

local MrBombModifierName = 'MrBomb'

local IsGold=WaitForChild(Tool,'IsGoldBomb')

local NormalTexture = 'http://www.roblox.com/asset/?id=94691681'
local MrBombTexture = 'http://www.roblox.com/asset/?id=98260356'

local MrBombRedTexture = 'http://www.roblox.com/asset/?id=98261349'
local NormalRedTexture = 'http://www.roblox.com/asset/?id=94691735'

local NormalMesh = 'http://www.roblox.com/asset/?id=94691640'
local MrBombMesh = 'http://www.roblox.com/asset/?id=98260446'

local NormalIcon = 'http://www.roblox.com/asset/?id=94690231'
local MrBombIcon = 'http://www.roblox.com/asset/?id=97923204'


function OnModifierAdded(nmodifier)
	print('modifier added')
	if nmodifier.Name == MrBombModifierName then
		IsGold.Value=true
		Mesh.TextureId=MrBombTexture
		Mesh.MeshId=MrBombMesh
		Tool.TextureId= MrBombIcon
		RedTexture.Value=MrBombRedTexture
		Tool.ToolTip= 'Professor Bomb'
	end
end

function OnModifierRemoved(nmodifier)
	if nmodifier.Name == MrBombModifierName then
		IsGold.Value=false
		Mesh.TextureId= NormalTexture
		Mesh.MeshId=NormalMesh
		Tool.TextureId= NormalIcon
		RedTexture.Value=NormalRedTexture
		Tool.ToolTip= 'Bomb'
	end
end

function OnPlayerChildAdded(nchild)
	if nchild.Name=='PlayerModifiers' then
		nchild.ChildAdded:connect(OnModifierAdded)
		for _,i in pairs(nchild:GetChildren()) do
			OnModifierAdded(i)
		end
		nchild.ChildRemoved:connect(OnModifierRemoved)
	end
end

Player.ChildAdded:connect(OnPlayerChildAdded)
if Player:FindFirstChild('PlayerModifiers') then
	OnPlayerChildAdded(Player['PlayerModifiers'])
end
