local cCEffectData = FindMetaTable("CEffectData")
local cEntity = FindMetaTable("Entity")

function cCEffectData:SetColorCloudbox(r, g, b, a)
	if IsColor(r) then
		self:SetColor(r)
	else
		self:SetColor(Color(r, g, b, a))
	end
end

function cEntity:SetColorCloudbox(r, g, b, a)
	if IsColor(r) then
		self:SetColor(r)
	else
		self:SetColor(Color(r, g, b, a))
	end
end

if CLIENT then
	local cCLuaParticle = FindMetaTable("CLuaParticle")
	local cProjectedTexture = FindMetaTable("ProjectedTexture")

	function cCLuaParticle:SetColorCloudbox(r, g, b, a)
		if IsColor(r) then
			self:SetColor(r)
		else
			self:SetColor(Color(r, g, b, a))
		end
	end

	function cProjectedTexture:SetColorCloudbox(r, g, b, a)
		if IsColor(r) then
			self:SetColor(r)
		else
			self:SetColor(Color(r, g, b, a))
		end
	end
end
