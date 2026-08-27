-- Turn them into a newt (and then make them get bettah)
-- which basically means turn them invisible and put LizardWrap into their char...  maybe attach to torso?

local vCharacter = script.Parent
local newtHead = script.NewtOnHead
newtHead.Anchored = false
-- find the parts
charChilds = vCharacter:GetChildren()
local partsToHide = {}
local numPartsToHide = 0

for i = 1, #charChilds do
	currChild = charChilds[i]
	if currChild.className == "Part" and currChild.Transparency < 1 then
		numPartsToHide = numPartsToHide + 1
		partsToHide[numPartsToHide] = currChild
	end
	if currChild.className == "Hat" then
		numPartsToHide = numPartsToHide + 1
		partsToHide[numPartsToHide] = currChild.Handle
	end
end

-- fade them out
-- faceoff
myFace = vCharacter.Head:FindFirstChild("face")
if myFace ~= nil then
	myFace.Parent = nil
end

--[[for i = 1, 10 do
	for j = 1, numPartsToHide do
		partsToHide[j].Transparency = i/10
	end
	newtHead.Transparency = (10-i)/10
	wait(.2) --.08... .5 ...  .2
end]]--

	for j = 1, numPartsToHide do
		if partsToHide[j] ~= nil then partsToHide[j].Transparency = 1 end
	end
	
	newtHeadWeld = Instance.new("Weld")
	newtHeadWeld.Part0 = newtHead
	newtHeadWeld.Part1 = vCharacter.Torso
	newtHead.CFrame = vCharacter.Torso.CFrame*CFrame.Angles(-math.pi/2,0,0)
	newtHeadWeld.C0 = newtHead.CFrame:inverse()*vCharacter.Torso.CFrame
	newtHeadWeld.Parent = vCharacter

	if newtHead ~= nil then newtHead.Transparency = 0 end

	--local rightArm = vCharacter:FindFirstChild("Right Arm")

	--local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	--if rightArm ~= nil then 
		--rightArm.Parent = vCharacter.Parent 
	--end  --silly newt, newts can't use items

	wait(30) --15

	--if rightArm ~= nil then 
		--rightArm.Parent = vCharacter 
	--end  -- oh, my mistake; have ur itemz back

	-- bring them back
--[[for i = 1, 10 do
	for j = 1, numPartsToHide do
		partsToHide[j].Transparency = (10-i)/10
	end
	newtHead.Transparency = i/10
	wait(.2)
end]]--

for j = 1, numPartsToHide do
	if partsToHide[j] ~= nil then partsToHide[j].Transparency = 0 end
end
if newtHead ~= nil then newtHead.Transparency = 1 end

if myFace ~= nil then
	myFace.Parent = vCharacter.Head
end

script:remove()
