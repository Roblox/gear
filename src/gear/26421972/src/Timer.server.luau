zombieParent = false

while zombieParent == false do

	wait(1)
	if script.Parent.Name == "SummonedZombie" then
		zombieParent = true
	end

end

wait(30)
script.Parent:remove()