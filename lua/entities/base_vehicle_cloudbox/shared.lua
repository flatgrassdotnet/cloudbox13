
/*---------------------------------------------------------
   Clientside Vehicles Base
---------------------------------------------------------*/

// Note: Vehicles aren't done yet. This is all just a placeholder.


ENT.Base			= "base_anim"
ENT.Type 			= "vehicle"


function ENT:SetupModel()

	self.Entity:SetModel( "models/props_interiors/BathTub01a.mdl" )

end

function ENT:Use( ply )

	if ( SERVER ) then
		self:SetDriver( ply )
	end

end

function ENT:SetupPhysics()

	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	
	self.Entity:StartMotionController()
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys) then
		phys:SetMaterial( "Ice" )
	end
	
end

function ENT:SetupPhysicsShadow()

	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:PhysicsInitShadow( true, true )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys) then
		phys:SetMaterial( "Ice" )
	end
	
end

function ENT:SharedInitialize()

	// In singleplayer we do all the controls and stuff on the server
	// In multiplayer we do it all on the client and grab
	self.DoProcessing = false
	if (CLIENT && !SinglePlayer() || SERVER && SinglePlayer()) then
		self.DoProcessing = true
	end
	
	self:SetupModel()
	self:ReConfigurePhysics()

end

//
// Reconfigures the physics situation. 
// This needs to be called every time the driver changes
//
function ENT:ReConfigurePhysics()

	// If we have a motion controller, stop it.
	self.Entity:StopMotionController()

	if ( CLIENT ) then
	
		if ( self:GetDriver() == LocalPlayer() && !SinglePlayer() ) then
			// If the current driver is the local player then predict the physics object
			self:SetupPhysics()
		else
			// Else make a physics shadow (so other objects can bump into us)
			self:SetupPhysicsShadow()
		end
	
	else
	
		if ( SinglePlayer() ) then
			// If we're in singleplayer the vehicle is 100% serverside
			self:SetupPhysics()
		else
			// If not we're a shadow on the server
			self:SetupPhysicsShadow()
		end
	
	end

end


function ENT:GetDriver()
	return self.Entity:GetNetworkedEntity( "driver" )
end

function ENT:SetDriver( ply )

	local OldDriver = self:GetDriver()
	if ( OldDriver != NULL ) then
		OldDriver:SetScriptedVehicle( NULL )
		OldDriver:SetParent( NULL )
		OldDriver:Spectate( OBS_MODE_NONE )
		OldDriver:SpectateEntity( NULL )
	end

	self.Entity:SetNetworkedEntity( "driver", ply )
	
	if ( ply ) then
	
		ply:SetScriptedVehicle( self.Entity )
		
		ply:SetPos( self.Entity:GetPos() )
		ply:SetParent( self.Entity )
		
		ply:Spectate( OBS_MODE_CHASE )
		ply:SpectateEntity( self.Entity )
		
		if ( !SinglePlayer() ) then
			ply:SetClientsideVehicle( self.Entity )
		end
	
	end
	
	self:ReConfigurePhysics()

end

function ENT:Think()

	local phys = self.Entity:GetPhysicsObject()
	
	if ( CLIENT ) then
	
		// The client needs to pick up on new drivers
		if ( self.OldDriver != self:GetDriver()  ) then
		
			self:ReConfigurePhysics()
			self.OldDriver = self:GetDriver()
			
		end
		
		// Keep the clientside shadow up to date
		if ( phys && (SinglePlayer() || self:GetDriver() != LocalPlayer()) ) then
		
			phys:UpdateShadow( self.Entity:GetPos(), self.Entity:GetAngles(), 0.01 )
			
		end
	
	end
	
	// Keep the phys object awake if we have a driver!
	if ( phys && self:GetDriver() ) then
	
		phys:Wake()
		
	end
	
	if ( self:GetDriver() && self:GetDriver():IsValid() ) then
	
		self:DoInputs( self:GetDriver() )
	
	end

end

function ENT:DoInputs( driver )

	if ( CLIENT ) then return end

	if ( driver:KeyDown( IN_USE ) ) then
	
		Msg("Exit!!\n")
		self:SetDriver( nil )
	
	end
	

end

function ENT:GetForwardAcceleration( driver, phys, ForwardVel )

	if (!driver || !driver:IsValid()) then return 0 end
	
	if ( driver:KeyDown( IN_FORWARD ) ) then return 50 end
	if ( driver:KeyDown( IN_BACK ) ) then return -50 end

	return 0
	
end

function ENT:GetTurnYaw( driver, phys, ForwardVel )

	if ( !driver || !driver:IsValid() ) then return 0 end
	
	if ( driver:KeyDown( IN_MOVELEFT ) ) then return 10 end
	if ( driver:KeyDown( IN_MOVERIGHT ) ) then return -10 end
	
	return 0
	
end

function ENT:CalcView( ply, origin, angles, fov, znear, zfar )

	local phys = self.Entity:GetPhysicsObject()
	if ( !phys ) then return end
	
	self.LastViewYaw = self.LastViewYaw or phys:GetAngle().yaw
	
	local distance = math.AngleDifference( self.LastViewYaw, phys:GetAngle().yaw )
	self.LastViewYaw = math.ApproachAngle( self.LastViewYaw, phys:GetAngle().yaw, distance * FrameTime() * 2 )

	local view = {}
	view.origin 	= phys:GetPos() + Vector( 0, 0, 64 ) - phys:GetAngle():Forward() * 128
	view.angles		= Angle( 10, self.LastViewYaw - distance * 1.25, distance*0.1 ) 
	view.fov 		= 90
	return view

end

/*---------------------------------------------------------
   Name: Simulate
---------------------------------------------------------*/
function ENT:PhysicsSimulate( phys, deltatime )

	// If we're not on the floor then don't do nothin
// Todo: This doesn't work clientside.
//	if ( !self.Entity:IsOnGround() ) then
//		return SIM_NOTHING
//	end

	// Make sure we're the right way up!
	local up = phys:GetAngle():Up()
	if ( up.z < 0.33 ) then
		return SIM_NOTHING
	end

	local driver = self:GetDriver()
	
	local forward = 0
	local right = 0
	
	local Velocity = phys:GetVelocity()
	local ForwardVel = phys:GetAngle():Forward():Dot( Velocity )
	local RightVel = phys:GetAngle():Right():Dot( Velocity )
	
	if ( driver ) then
	
		forward = self:GetForwardAcceleration( driver, phys, ForwardVel )
		yaw		= self:GetTurnYaw( driver, phys, ForwardVel )
		
	end
	
	// Kill any sidewards movement (unless we're skidding)
	right = RightVel * 0.95
	
	// Apply some ground friction of our own
	forward = forward - ForwardVel * 0.01
	
	local Linear = ( Vector( forward, right, 0 ) ) * deltatime * 1000;
	
	// Do angle changing stuff.
	local AngleVel = phys:GetAngleVelocity()
	// This simulates the friction of the tires
	local AngleFriction = AngleVel * -0.1
	
	local Angular = (AngleFriction + Vector( 0, 0, yaw )) * deltatime * 1000;

	// Note: Local Acceleration means that the values are applied to the object locally
	// ie, forward is whatever firection the entity is facing. This is perfect for a car
	// but if you're making a ball that you're spectating and pushing in the direction
	// that you're facing you'll want to override this whole function and use global
	return Angular, Linear, SIM_LOCAL_ACCELERATION
	
end
