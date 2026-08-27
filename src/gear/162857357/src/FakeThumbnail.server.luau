--[[alexnewtron 2014]]--
local p = script.Parent;
if p:findFirstChild("Fake1") then p["Fake1"]:Destroy(); end
if p:findFirstChild("Fake2") then p["Fake2"]:Destroy(); end
script:Destroy();