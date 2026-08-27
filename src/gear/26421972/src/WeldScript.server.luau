zombieParent = false

while zombieParent == false do

	wait(1)
	if script.Parent.Name == "SummonedZombie" then
		zombieParent = true
	end

end


local p=script.Parent:GetChildren()
for i=1,#p do 
if p[i].className=="Part" then 

	local weld = Instance.new("Weld") 
        weld.Name="Hold"
	weld.Part0 = p[i]
	weld.Part1 = script.Parent.Parent.Torso

	local HitPos = p[i].Position + (p[i].CFrame.lookVector * .5) 

	local CJ = CFrame.new(HitPos) 
	local C0 = p[i].CFrame:inverse() *CJ 
	local C1 = script.Parent.Parent.Torso.CFrame:inverse() * CJ 

	weld.C0 = C0 
	weld.C1 = C1 

	weld.Parent = p[i]
end
end 