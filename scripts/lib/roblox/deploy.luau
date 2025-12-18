-- This is still a Lune script for now because rbxasset is not yet ported to
-- Lute. Follow this PR for updates:
-- https://github.com/Roblox/rbxasset/pull/5

-- FIXME: This script might be totally busted on Lune 0.10.x. Good opportunity
-- to update rbxasset?

local process = require("@lune/process")
local rbxasset = require("@luaupkg/rbxasset")

local args = process.args
local projectPath = args[1]
local apiKey = args[2]

rbxasset.publishPackageAsync(projectPath, "default", apiKey)
