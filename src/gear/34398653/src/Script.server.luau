local Tool = script.Parent
--[[
     ---- possible gears ----
	(1)slingshot decoy
	(2)deploy
	(3)magic ninja
	(4)flashbang
	(5)bucket
	(6)BANG!
	(7)magic dragon
	(8)a very special monster
	(9)helen the hiphipapotamus
	(10)ronin katana
]]

local gears = {33382537,30392263,30847779,16979083,25162389,26419811,24659699,21439991,15179006,12187348}


function onActivated()
	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(gears[math.random(1,#gears)])

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	root = root:GetChildren()
	if #root == 1 then
		root = root[1]
	-- needed for irregularity in hippo gear
	elseif #root == 2 then
		for i = 1, #root do
			if root[i].Name == "Hippo" then
				root = root[i]
				break
			end
		end
	end
	print(root)
	root.Parent = Tool.Parent
	Tool:Destroy()

end

Tool.Activated:connect(onActivated)
