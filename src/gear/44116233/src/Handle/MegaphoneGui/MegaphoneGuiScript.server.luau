local reloadTime = 1.5

local mGui = script.Parent
local sirenButton = mGui.SirenButton
local blahButton = mGui.BlahButton
local whatButton = mGui.WhatButton
local yayButton = mGui.YayButton

local mHandle = mGui.Parent

local whatSound = mHandle.What
local blahSound = mHandle.Blah
local yaySound = mHandle.Yay
local sirenSound = mHandle.Siren

local soundDebounce = false

function onSiren()
	if soundDebounce then return end
	soundDebounce = true
	sirenSound:Play()
	print("siren")
	wait(reloadTime)
	soundDebounce = false
end

function onBlah()
	if soundDebounce then return end
	soundDebounce = true
	blahSound:Play()
	print("blah")
	wait(reloadTime)
	soundDebounce = false
end

function onYay()
	if soundDebounce then return end
	soundDebounce = true
	yaySound:Play()
	print("yay")
	wait(reloadTime)
	soundDebounce = false
end

function onWhat()
	if soundDebounce then return end
	soundDebounce = true
	whatSound:Play()
	print("what")
	wait(reloadTime)
	soundDebounce = false
end

sirenButton.MouseButton1Click:connect(onSiren)
blahButton.MouseButton1Click:connect(onBlah)
whatButton.MouseButton1Click:connect(onWhat)
yayButton.MouseButton1Click:connect(onYay)
