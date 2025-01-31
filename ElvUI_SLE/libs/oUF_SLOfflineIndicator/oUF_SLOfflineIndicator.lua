local oUF = ElvUF or oUF
local UnitIsConnected = UnitIsConnected

local function Update(self)
	local element = self.SL_OfflineIndicator
	local unit = self.unit
	local isOffline = not UnitIsConnected(unit)

	if element.PreUpdate then
		element:PreUpdate()
	end

	if isOffline or self.isForced then
		isOffline = true
	else
		isOffline = false
	end

	element:SetShown(isOffline)

	if element.PostUpdate then
		return element:PostUpdate(isOffline)
	end
end

local function Path(self, ...)
	return (self.SL_OfflineIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.SL_OfflineIndicator

	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.ForceUpdate(element)

		self:RegisterEvent('UNIT_CONNECTION', Path)

		if element:IsObjectType('Texture') and not element:GetTexture() then
			element:SetTexture([[Interface\LootFrame\LootPanel-Icon]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.SL_OfflineIndicator

	if element then
		element:Hide()
		self:UnregisterEvent('UNIT_CONNECTION', Path)
	end
end

oUF:AddElement('SL_OfflineIndicator', Path, Enable, Disable)
