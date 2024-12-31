
/*---------------------------------------------------------
   Clientside Vehicles Base
---------------------------------------------------------*/

include( "shared.lua" )


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	
	self:SharedInitialize()
	
	self.Entity:SetShouldDrawInViewMode( true )
	
end
