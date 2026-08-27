--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Sounds = {}
for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("Sound") then
		table.insert(Sounds, v)
	end
end

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Sounds[math.random(1, #Sounds)]:Play()
	wait(1)
	Tool.Enabled = true
end

Tool.Activated:connect(Activated)

