--Made by Stickmasterluke


local sp=script.Parent


for i=1,100 do
	wait(1/30)
	if sp.className=="Humanoid" and sp.Health>0 then
		sp.Health=sp.Health+1
	end
end

script:remove()

