--[[
	New Stamper
	UpdateLog:
		4/16/2013-initial release
		
	How to add user sets:
		add user IDs as intValue's in the Users model to add all sets related to that user
	How to add induvidual sets:
		add set IDs as intValue's in the Sets model
	How to make custom sets:
		add models under the Sets model, containing intValue's with asset IDs
	How to limit stamping area:
		inside the RestrictedArea model, add 2 Vector3Value's named "High" and "Low", these will form the Region3 this tool can stamp in
	How to Stamp inside a model:
		Set the value of MyStampModel to the object you want to place stamped models inside
	
	Contact fusroblox for any and all issues relating to Stamper	
--]]