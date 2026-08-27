local MyCharacter = script.Parent
local MyTorso = MyCharacter:FindFirstChild('Torso')

if MyTorso then
	MyTorso.Anchored = true
end

wait(1.6)

if MyTorso then
	MyTorso.Anchored = false
end

script:Destroy()
