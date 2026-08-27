Tool = script.Parent 

local stillEquipped = false 

function onEquippedLocal(mouse) 
     stillEquipped = true 
     if mouse == nil then 
          print("Mouse not found") 
          return 
     end 
     while stillEquipped do 
          print("Setting Mouse to go") 
          mouse.Icon = "rbxasset://textures\\GunCursor.png" 
          while Tool.Enabled and stillEquipped do 
               wait(0.01) 
          end 
          print("Setting Mouse to wait") 
          mouse.Icon = "rbxasset://textures\\GunWaitCursor.png" 
          while not Tool.Enabled and stillEquipped do 
               wait(0.01) 
          end      
     end 
end 


function onUnequippedLocal() 
     stillEquipped = false 
end 

Tool.Equipped:connect(onEquippedLocal) 
Tool.Unequipped:connect(onUnequippedLocal)
