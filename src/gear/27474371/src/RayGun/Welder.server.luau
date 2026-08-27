local noob= script.Parent

noob.Torso.Anchored = true
noob.LeftArm.Anchored = true
noob.RightArm.Anchored = true
noob.LeftLeg.Anchored = true
noob.RightLeg.Anchored = true
noob.Head.Anchored = true

local keepYoHead = Instance.new("Weld")
keepYoHead.Part0 = noob.Head
keepYoHead.Part1 = noob.Torso
keepYoHead.C0 = CFrame.new(0,-1.5,0)
keepYoHead.Parent = noob.Head

local keepYoRightArm = Instance.new("Weld")
keepYoRightArm.Part0 = noob.Torso
keepYoRightArm.Part1 = noob.RightArm
keepYoRightArm.C0 = CFrame.new(1.5,0,0)
keepYoRightArm.Parent = noob.Torso

local keepYoLeftArm = Instance.new("Weld")
keepYoLeftArm.Part0 = noob.Torso
keepYoLeftArm.Part1 = noob.LeftArm
keepYoLeftArm.C0 = CFrame.new(-1.5,0,0)
keepYoLeftArm.Parent = noob.Torso

local keepYoLeftLeg = Instance.new("Weld")
keepYoLeftLeg.Part0 = noob.Torso
keepYoLeftLeg.Part1 = noob.LeftLeg
keepYoLeftLeg.C0 = CFrame.new(-0.5,-2,0)
keepYoLeftLeg.Parent = noob.Torso

local keepYoRightLeg = Instance.new("Weld")
keepYoRightLeg.Part0 = noob.Torso
keepYoRightLeg.Part1 = noob.RightLeg
keepYoRightLeg.C0 = CFrame.new(0.5,-2,0)
keepYoRightLeg.Parent = noob.Torso

noob.Torso.Anchored = false
noob.LeftArm.Anchored = false
noob.RightArm.Anchored = false
noob.LeftLeg.Anchored = false
noob.RightLeg.Anchored = false
noob.Head.Anchored = false
