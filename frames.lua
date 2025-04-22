---------------------
-- Creating Frames --
---------------------

function NotGrid:CreateFrames()
	self.Container = self:CreateContainerFrame()
	for i=1,40 do
		self.UnitFrames["raid"..i] = self:CreateUnitFrame("raid"..i,i)
	end
	for i=1,4 do
		self.UnitFrames["party"..i] = self:CreateUnitFrame("party"..i)
	end
	for i=1,4 do
		self.UnitFrames["partypet"..i] = self:CreateUnitFrame("partypet"..i)
	end
	self.UnitFrames["player"] = self:CreateUnitFrame("player")
	self.UnitFrames["pet"] = self:CreateUnitFrame("pet")
end

function NotGrid:CreateContainerFrame()
	local f = CreateFrame("Frame","NotGridContainer",UIParent)
	f:SetWidth(1)
	f:SetHeight(1)
	--f:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", tile = true, tileSize = 16, edgeSize = 10})
	f:SetMovable(true)
	f:SetPoint("CENTER",40,-40)
	return f
end

function NotGrid:CreateUnitFrame(unitid,raidindex)
	local f = CreateFrame("Button","$parent"..unitid,self.Container)
	f.unit = unitid
	f.lastseen = GetTime() -- we set this at creation, so we don't have to config frame as out of range alpha by default
	if raidindex then
		f.raidindex = raidindex -- :^)
	end
	if string.find(unitid,"pet") then
		f.pet = true -- so I have a boolean to check against
	end

	-- Add background role icon
	f.roleIcon = CreateFrame("Frame", nil, f)
	f.roleIcon:SetWidth(20)
	f.roleIcon:SetHeight(20)
	f.roleIcon:SetPoint("TOPRIGHT", f, "TOPRIGHT", 5, 5)
	f.roleIcon:SetFrameLevel(f:GetFrameLevel() + 3)
	
	-- -- Add black circular border texture
	-- f.roleIcon.border = f.roleIcon:CreateTexture(nil, "BACKGROUND")
	-- f.roleIcon.border:SetTexture("Interface\\AddOns\\NotGrid\\media\\tank2")
	-- f.roleIcon.border:SetVertexColor(0, 0, 0, 1)
	-- f.roleIcon.border:SetWidth(22)  -- 4 pixels larger than the icon
	-- f.roleIcon.border:SetHeight(22) -- 4 pixels larger than the icon
	-- f.roleIcon.border:SetPoint("CENTER", f.roleIcon, "CENTER", 0, 0)
	-- f.roleIcon.border:SetAlpha(0.65)
	
	f.roleIcon.texture = f.roleIcon:CreateTexture(nil, "OVERLAY")
	f.roleIcon.texture:SetAllPoints()
	f.roleIcon.texture:SetAlpha(0.85)
	f.roleIcon:Hide()

	f.border = CreateFrame("Frame","$parentborder",f) -- make a seperate frame for the edgefile/border for better customization possibilities
	f.border.middleart = f.border:CreateTexture("NGArtworkMiddle", "ARTWORK")

	f.healthbar = CreateFrame("StatusBar","$parenthealthbar",f)
	f.healthbar.bgtex = f.healthbar:CreateTexture("$parentbgtex","BACKGROUND")

	f.powerbar = CreateFrame("StatusBar","$parenthealthbar",f)
	f.powerbar.bgtex = f.powerbar:CreateTexture("$parentbgtex","BACKGROUND")

	f.incres = CreateFrame("Frame","$parentresicon",f.healthbar)
	f.incres.bgtex = f.incres:CreateTexture("$parentbgtex","BACKGROUND")

	f.incheal = CreateFrame("Frame","$parenthealcommbar",f.healthbar) -- Was using a statusbar behind the health frame but when the frame's alpha is low this would be seen through it
	
	-- I was having problems with incheal covering up these fontstrings. My soluction is to parent them to the incheal, but set the relative point to the healthbar. And instead of hide/show the incheal I just lower/higher its color opacity
	f.namehealthtext = f.incheal:CreateFontString("$parentnamehealthtext", "ARTWORK")
	f.healcommtext = f.incheal:CreateFontString("$parenthealcommtext", "OVERLAY")

	for i=1,8 do
		f.healthbar["trackingicon"..i] = CreateFrame("Frame","$parenttrackingicon"..i,f.healthbar) -- easier to work with digits than topleft/topright/etc..
		f.healthbar["trackingicon"..i]:SetFrameLevel(f.namehealthtext:GetParent():GetFrameLevel() + 1)
		f.healthbar["trackingicon"..i]:SetFrameStrata("MEDIUM")
		-- Добавляем текстуру для иконки спелла
		f.healthbar["trackingicon"..i].spellicon = f.healthbar["trackingicon"..i]:CreateTexture("$parentspellicon", "BACKGROUND")
		f.healthbar["trackingicon"..i].spellicon:SetAllPoints()
		f.healthbar["trackingicon"..i].spellicon:SetAlpha(0.3) -- Полупрозрачность для фона
	end

	f.raidicon = CreateFrame("Frame", nil, f.healthbar)
	f.raidicon.texture = f.raidicon:CreateTexture(nil,"OVERLAY")

	--scripts and stuff
	f:RegisterForClicks("LeftButtonDown", "RightButtonDown", "MiddleButtonDown", "Button4Down", "Button5Down") -- somehow I recall this not matterign?
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnClick", function()
		if Clique then
			if not Clique:OnClick(arg1, this.unit) then
				self:ClickHandle(arg1) -- if it failed to find anything in clique then we send it to the regular handler
			end
		else
			self:ClickHandle(arg1)
		end
	end)
	f:SetScript("OnEnter", function()
		if UnitAffectingCombat("player") and self.o.disablemouseoverincombat then
			return
		end

		UnitFrame_OnEnter() -- a blizzard function that handles the tooltip for the unit
	end)
	f:SetScript("OnLeave", function() 
		UnitFrame_OnLeave() -- blizz function that handles tooltip for units
	end)

	f:SetScript("OnDragStart", function()  -- on drag of any unit frame will drag the NotGridContainer frame
		if self.o.draggable then
			self.Container:StartMoving()
		end
	end)
	f:SetScript("OnDragStop", function()
		if self.o.draggable then
			self.Container:StopMovingOrSizing()
		end
	end)

	--we can split these up into their own relative frames & functions later
	--might as well
	f:RegisterEvent("UNIT_NAME_UPDATE")
	f:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	--healthbar
	f:RegisterEvent("UNIT_HEALTH")
	f:RegisterEvent("UNIT_MAXHEALTH")
	--manabar
	f:RegisterEvent("UNIT_MANA")
	f:RegisterEvent("UNIT_RAGE")
	f:RegisterEvent("UNIT_FOCUS")
	f:RegisterEvent("UNIT_ENERGY")
	f:RegisterEvent("UNIT_HAPPINESS")
	f:RegisterEvent("UNIT_MAXMANA")
	f:RegisterEvent("UNIT_MAXRAGE")
	f:RegisterEvent("UNIT_MAXFOCUS")
	f:RegisterEvent("UNIT_MAXENERGY")
	f:RegisterEvent("UNIT_MAXHAPPINESS")
	f:RegisterEvent("UNIT_DISPLAYPOWER")
	--aura
	f:RegisterEvent("UNIT_AURA")
	--used for highlight target feature
	f:RegisterEvent("PLAYER_TARGET_CHANGED")
	--banzai/healcomm are registered in core on enable

	--used for update raid icon
	f:RegisterEvent("RAID_TARGET_UPDATE")

	f:SetScript("OnEvent", function()
		if arg1 and arg1 == this.unit then -- if an event has coniditions specific to a unit, then only specified unit will update
			if event == "UNIT_AURA" then
				self:UNIT_AURA(this.unit)
			else
				self:UNIT_MAIN(this.unit)
				self:UNIT_BORDER(this.unit)
			end
		elseif event == "RAID_TARGET_UPDATE" then
				self:UNIT_RAID_TARGET(this.unit)
		elseif event == "PLAYER_TARGET_CHANGED" then -- all units will update their border
			self:UNIT_BORDER(this.unit)
		end
	end)

	return f
end

-------------------
-- Config Frames --
-------------------

function NotGrid:ConfigUnitFrames() -- this can get called on every setting change, instead of doing some wierd roundabout way. Hurray!
	local o = self.o
	for _,f in self.UnitFrames do
		--f:SetAlpha(self.o.ooralpha) -- we set lastseen at frame creation instead. doing it like this makes config mode weird, and would obstruct disabling prox checking
		local width, height
		if o.showpowerbar and o.powerposition <= 2 then -- factor in a modifier for the powerbar width/height
			width = o.unitwidth
			height = o.unitheight+o.powersize+1
		elseif o.showpowerbar and o.powerposition >= 3 then
			width = o.unitwidth+o.powersize+1
			height = o.unitheight
		else
			width = o.unitwidth
			height = o.unitheight
		end
		f:SetWidth(width)
		f:SetHeight(height)
		f:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", tile = true, tileSize = 16})
		f:SetBackdropColor(unpack(o.unitbgcolor))

		if o.borderartwork then
			f.border:SetWidth(width+o.unitborder) -- the way edgefile works is it basically sits on the center of the edge of the frame and expands both inward and outward. So to compensate asthetically for that I ahve to increase the size of my frame double the desired width of the edgefile/border
			f.border:SetHeight(height+o.unitborder)
			f.border:SetBackdrop({edgeFile = "Interface\\AddOns\\NotGrid\\media\\borderartwork", edgeSize = 16})
		else
			f.border:SetWidth(width+o.unitborder*2) -- the way edgefile works is it basically sits on the center of the edge of the frame and expands both inward and outward. So to compensate asthetically for that I ahve to increase the size of my frame double the desired width of the edgefile/border
			f.border:SetHeight(height+o.unitborder*2)
			f.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = o.unitborder})
		end
		f.border:SetBackdropBorderColor(unpack(o.unitbordercolor))
		f.border:SetPoint("CENTER",0,0)
		f.border:SetFrameLevel(f:GetFrameLevel() + 2)
		f.border.middleart:SetTexture("Interface/TargetingFrame/UI-TargetingFrame")
		if o.powerposition <= 2 then
			f.border.middleart:SetTexCoord((58/256)+(1/256/2), (82/256)+(1/256/2), (39/128)+(1/128/2), (44/128)+(1/128/2))
			f.border.middleart:SetVertexColor(unpack(o.unitbordercolor))
		else
			f.border.middleart:SetTexCoord((26/256)+(1/256/2), (32/256)+(1/256/2), (27/128)+(1/128/2), (34/128)+(1/128/2))
			f.border.middleart:SetVertexColor(unpack(o.unitbordercolor))
		end


		f.healthbar:SetWidth(o.unitwidth)
		f.healthbar:SetHeight(o.unitheight)
		if o.unithealthorientation == 1 then
			f.healthbar:SetOrientation("VERTICAL")
		else
			f.healthbar:SetOrientation("HORIZONTAL")
		end
		f.healthbar:SetStatusBarTexture(o.unithealthbartexture)
		f.healthbar:SetStatusBarColor(unpack(o.unithealthbarcolor))
		f.healthbar.bgtex:SetTexture(o.unithealthbarbgtexture)
		f.healthbar.bgtex:SetVertexColor(unpack(o.unithealthbarbgcolor))
		f.healthbar.bgtex:SetAllPoints()


		-- raid target icon
		f.raidicon:SetWidth(o.raidiconsize)
		f.raidicon:SetHeight(o.raidiconsize)
		f.raidicon:SetPoint("CENTER", f.healthbar, "CENTER", o.raidiconoffx, o.raidiconoffy)
		f.raidicon.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		f.raidicon.texture:SetAllPoints(f.raidicon)
		f.raidicon:Hide()


		--position health and powerbar
		f.healthbar:ClearAllPoints()
		f.powerbar:ClearAllPoints()
		f.border.middleart:ClearAllPoints()
		if o.showpowerbar then
			if o.powerposition <= 2 then -- power on top
				if o.powerposition == 1 then
					f.healthbar:SetPoint("BOTTOM",0,0)
					f.powerbar:SetPoint("TOP",0,0)
					f.border.middleart:SetPoint("BOTTOM", f.powerbar, 0, -4)
				else
					f.healthbar:SetPoint("TOP",0,0)
					f.powerbar:SetPoint("BOTTOM",0,0)
					f.border.middleart:SetPoint("TOP", f.powerbar, 0, 4)
				end
				f.powerbar:SetWidth(o.unitwidth)
				f.powerbar:SetHeight(o.powersize)
				f.powerbar:SetOrientation("HORIZONTAL")
				f.border.middleart:SetWidth(width)
				f.border.middleart:SetHeight(6)
			elseif o.powerposition >= 3 then
				if o.powerposition == 3 then
					f.healthbar:SetPoint("LEFT",0,0)
					f.powerbar:SetPoint("RIGHT",0,0)
					f.border.middleart:SetPoint("LEFT", f.powerbar, -4, 0)
				else
					f.healthbar:SetPoint("RIGHT",0,0)
					f.powerbar:SetPoint("LEFT",0,0)
					f.border.middleart:SetPoint("RIGHT", f.powerbar, 4, 0)
				end
				f.powerbar:SetWidth(o.powersize)
				f.powerbar:SetHeight(o.unitheight)
				f.powerbar:SetOrientation("VERTICAL")
				f.border.middleart:SetWidth(6)
				f.border.middleart:SetHeight(height)
			end
			f.powerbar:Show()
			if o.borderartwork then
				f.border.middleart:Show()
			else
				f.border.middleart:Hide()
			end
		else
			f.healthbar:SetPoint("CENTER",0,0)
			f.powerbar:Hide()
			f.border.middleart:Hide()
		end
		f.powerbar:SetStatusBarTexture(o.unithealthbartexture)
		f.powerbar.bgtex:SetTexture(o.unithealthbartexture)
		f.powerbar.bgtex:SetVertexColor(unpack(o.unitpowerbarbgcolor))
		f.powerbar.bgtex:SetAllPoints()
		--f.powerbar:SetStatusBarColor(unpack(o.unithealthbarcolor))

		f.incres:SetWidth(o.unitheight) -- yep, so it stays square under most common sizes. Think of a mathematical way in the future
		f.incres:SetHeight(o.unitheight)
		f.incres:ClearAllPoints()
		f.incres:SetPoint("CENTER",0,0)
		f.incres.bgtex:SetTexture("Interface\\AddOns\\NotGrid\\media\\res")
		f.incres.bgtex:SetAllPoints()
		f.incres:Hide()

		f.incheal:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", tile = true, tileSize = 16, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
		f.incheal:SetBackdropColor(0,0,0,0)
		f.incheal:SetBackdropBorderColor(0,0,0,0) -- mostly just so its 0 opacity
		f.incheal:SetWidth(o.unitwidth)
		f.incheal:SetHeight(o.unitheight)

		for _,fsname in {"namehealthtext", "healcommtext"} do
			local fs = f[fsname]
			fs:SetShadowColor(0, 0, 0, 1.0)
			fs:SetShadowOffset(0.80, -0.80)
			fs:ClearAllPoints()
			if fsname == "namehealthtext" then
				if not o.colorunitnamehealthbyclass then
					fs:SetTextColor(unpack(o.unitnamehealthtextcolor))
				end
				fs:SetFont(o.unitfont, o.unitnamehealthtextsize)
				fs:SetPoint("CENTER",f.healthbar,"CENTER",o.unitnamehealthoffx,o.unitnamehealthoffy)
			elseif fsname == "healcommtext" then
				fs:SetTextColor(unpack(o.unithealcommtextcolor))
				fs:SetFont(o.unitfont, o.unithealcommtextsize)
				fs:SetPoint("CENTER",f.healthbar,"CENTER",o.unithealcommtextoffx,o.unithealcommtextoffy)
				if not o.showhealcommtext then
					fs:Hide()
				end
			end
		end
		for i,point in {"TOPLEFT", "TOP", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "BOTTOM", "BOTTOMLEFT", "LEFT"} do
			local fi = f.healthbar["trackingicon"..i]
			fi:SetWidth(o.unittrackingiconsize)
			fi:SetHeight(o.unittrackingiconsize)
			fi:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", tile = true, tileSize = o.unittrackingiconsize, edgeSize = o.unittrackingiconborder})
			fi:SetBackdropBorderColor(o.unittrackingiconbordercolor)
			fi:SetBackdropColor(unpack(o["trackingicon"..i.."color"]))
			fi:ClearAllPoints()
			fi:SetPoint(point,0,0)
			fi:Hide()
		end
	end
end

---------------------
-- Position Frames --
---------------------

function NotGrid:PositionFrames()
	local partycount = GetNumPartyMembers()
	local raidcount = GetNumRaidMembers()

	local SubGroupCounts = self.Compost:Acquire(0,0,0,0,0,0,0,0,0,0) -- reset it every time
	local TotalGroups = 0
	local TotalUnits = 0
	local o = self.o

	local powermodx = 0 -- so I can interject the width of the powerbar into the positioning calcs without doing a million more conditionals
	local powermody = 0
	if o.showpowerbar then
		if o.powerposition <= 2 then
			powermody = o.powersize+1
		else
			powermodx = o.powersize+1
		end
	end	

	--handle all the unitframes and subgroups
	for i=1,10 do -- 1-8 is raid, 9 is party, 10 is partypet
		for key,f in self.UnitFrames do
			if UnitExists(f.unit) or o.configmode then
				-- first get the subgroup
				local subgroup = nil
				if f.raidindex then -- if a frame with raid unitid
					if o.configmode then
						subgroup = (math.ceil(math.abs(f.raidindex/5))) -- doing it like this does mean it loops and calcs this 10 times for all the unitframes, though
					else
						_,_,subgroup = GetRaidRosterInfo(f.raidindex)
					end
				elseif (string.find(f.unit,"party%d") or (f.unit == "player")) and ((raidcount > 0 and o.showpartyinraid) or (raidcount == 0 and partycount > 0 and o.showinparty and not o.configmode) or (raidcount == 0 and partycount == 0 and o.showwhilesolo and not o.configmode) or (o.configmode and o.showpartyinraid)) then
					subgroup = 9
				elseif (string.find(f.unit,"partypet%d") or (f.unit == "pet")) and ((raidcount > 0 and o.showpartyinraid and o.showpets) or (raidcount == 0 and partycount > 0 and o.showinparty and o.showpets and not o.configmode) or (raidcount == 0 and partycount == 0 and o.showwhilesolo and o.showpets and not o.configmode) or (o.configmode and o.showpartyinraid and o.showpets)) then
					subgroup = 10
				else
					f:Hide() -- I won't set a subgroup so it will fail the next check, wont position, and won't get counted into subgroup/totalgroups
				end

				--then do all the positioning
				if subgroup == i then
					f:ClearAllPoints()
					if o.growthdirection == 1 then -- groups grow left to right, units grow top to bottom
						f:SetPoint("CENTER",(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*TotalGroups,-(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*SubGroupCounts[i])
					elseif o.growthdirection == 2 then -- groups grow left to right, units grow bottom to top
						f:SetPoint("CENTER",(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*TotalGroups,(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*SubGroupCounts[i])
					elseif o.growthdirection == 3 then -- groups grow right to left, units grow bottom to top
						f:SetPoint("CENTER",-(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*TotalGroups,(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*SubGroupCounts[i])
					elseif o.growthdirection == 4 then -- groups grow right to left, units grow top to bottom
						f:SetPoint("CENTER",-(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*TotalGroups,-(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*SubGroupCounts[i]) -- i do subgroup -1 so group 1 will be 0 and be at 0 offset
					elseif o.growthdirection == 5 then -- groups grow top to bottom, units grow left to right
						f:SetPoint("CENTER",(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*SubGroupCounts[i],-(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*TotalGroups)
					elseif o.growthdirection == 6 then -- groups grow bottom to top, units grow left to right
						f:SetPoint("CENTER",(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*SubGroupCounts[i],(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*TotalGroups)
					elseif o.growthdirection == 7 then -- groups grow bottom to top, units grow right to left
						f:SetPoint("CENTER",-(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*SubGroupCounts[i],(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*TotalGroups)
					elseif o.growthdirection == 8 then -- groups grow top to bottom, units grow right to left
						f:SetPoint("CENTER",-(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*SubGroupCounts[i],-(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*TotalGroups)
					elseif o.growthdirection == 9 then -- single top to bottom
						f:SetPoint("CENTER",0,-(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*TotalUnits)
					elseif o.growthdirection == 10 then -- single bottom to top
						f:SetPoint("CENTER",0,(o.unitheight+powermody+o.unitborder*2+o.unitpadding)*TotalUnits)
					elseif o.growthdirection == 11 then -- single left to right
						f:SetPoint("CENTER",(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*TotalUnits,0)
					elseif o.growthdirection == 12 then -- single right to left
						f:SetPoint("CENTER",-(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)*TotalUnits,0)
					end
					f:Show()
					TotalUnits = TotalUnits+1
					SubGroupCounts[i] = SubGroupCounts[i]+1
				end
			else
				f:Hide()
			end
		end
		if SubGroupCounts[i] > 0 then
			TotalGroups = TotalGroups+1
		end
	end

	--handle the container frame
	if not o.draggable then
		self.Container:ClearAllPoints()
		if o.smartcenter == true and (o.growthdirection == 1 or o.growthdirection == 2) then
				self.Container:SetPoint(o.containerpoint,o.containeroffx-(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)/2*(TotalGroups-1),o.containeroffy)
		elseif o.smartcenter == true and (o.growthdirection == 3 or o.growthdirection == 4) then
				self.Container:SetPoint(o.containerpoint,o.containeroffx+(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)/2*(TotalGroups-1),o.containeroffy)
		elseif o.smartcenter == true and (o.growthdirection == 5 or o.growthdirection == 6) then
				table.sort(SubGroupCounts)
				self.Container:SetPoint(o.containerpoint,o.containeroffx-(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)/2*(SubGroupCounts[10]-1),o.containeroffy)
		elseif o.smartcenter == true and (o.growthdirection == 7 or o.growthdirection == 8) then
				table.sort(SubGroupCounts)
				self.Container:SetPoint(o.containerpoint,o.containeroffx+(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)/2*(SubGroupCounts[10]-1),o.containeroffy)
		elseif o.smartcenter == true and o.growthdirection == 11 then
			self.Container:SetPoint(o.containerpoint,o.containeroffx-(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)/2*(TotalUnits-1),o.containeroffy)
		elseif o.smartcenter == true and o.growthdirection == 12 then
			self.Container:SetPoint(o.containerpoint,o.containeroffx+(o.unitwidth+powermodx+o.unitborder*2+o.unitpadding)/2*(TotalUnits-1),o.containeroffy)
		else
			self.Container:SetPoint(o.containerpoint,o.containeroffx,o.containeroffy)
		end
	end

	self.Compost:Reclaim(SubGroupCounts)
end

function NotGrid:UNIT_MAIN(unitid)
	local o = self.o
	local f = self.UnitFrames[unitid]
	if o.configmode then
		unitid = "player"
	end

	if f and UnitExists(unitid) then
		local name = UnitName(unitid)
		local shortname = name
		
		-- Check if name starts with "Pepe" and truncate it
		if string.sub(name, 1, 4) == "Pepe" then
			shortname = "Pepe"
		else
			-- Function to check if character is a consonant
			local function isConsonant(char)
				local vowels = {"a","e","i","o","u","A","E","I","O","U"}
				for _, vowel in ipairs(vowels) do
					if char == vowel then
						return false
					end
				end
				return true
			end
			
			-- Function to remove vowels one by one until name is short enough
			local function removeVowelsUntilShort(name, maxLength)
				local firstChar = string.sub(name, 1, 1) -- Save first character
				local result = string.sub(name, 2) -- Remove first character
				local vowels = {"a","e","i","o","u","A","E","I","O","U"}
				
				-- Keep removing vowels until name is short enough
				while string.len(result) > maxLength - 1 do -- -1 because we'll add firstChar back
					local foundVowel = false
					-- Find first vowel in the name
					for i = 1, string.len(result) do
						local char = string.sub(result, i, i)
						for _, vowel in ipairs(vowels) do
							if char == vowel then
								-- Remove this vowel
								result = string.sub(result, 1, i-1) .. string.sub(result, i+1)
								foundVowel = true
								break
							end
						end
						if foundVowel then break end
					end
					-- If no more vowels found, break the loop
					if not foundVowel then break end
				end
				
				return firstChar .. result -- Add first character back
			end
			
			-- First try removing vowels
			shortname = removeVowelsUntilShort(name, o.namelength)
			
			-- If still too long, take first letter, one consonant after it, and two last consonants
			if string.len(shortname) > o.namelength then
				local firstChar = string.sub(shortname, 1, 1) -- Save first character
				local restOfName = string.sub(shortname, 2) -- Remove first character
				local firstConsonant = ""
				local lastConsonants = ""
				local consonantCount = 0
				
				-- Get first consonant from the rest of the name
				for i = 1, string.len(restOfName) do
					local char = string.sub(restOfName, i, i)
					if isConsonant(char) then
						firstConsonant = char
						break
					end
				end
				
				-- Get last two consonants from the rest of the name
				consonantCount = 0
				for i = string.len(restOfName), 1, -1 do
					if consonantCount >= 2 then break end
					local char = string.sub(restOfName, i, i)
					if isConsonant(char) then
						lastConsonants = char .. lastConsonants
						consonantCount = consonantCount + 1
					end
				end
				
				shortname = firstChar .. firstConsonant .. lastConsonants
			end
		end
		
		local _,class = UnitClass(unitid)
		local powertype = UnitPowerType(unitid)
		local pcolor = ManaBarColor[powertype]
		local color = {}

		if o.configmode then
			local c = {"WARRIOR","PALADIN","HUNTER","ROGUE","PRIEST","SHAMAN","MAGE","WARLOCK","DRUID"}
			local id = string.sub(f.unit, -1)
			id = tonumber(id)
			if id == 0 then id = 1 end
			if id == 1 then
				pcolor = ManaBarColor[1]
			elseif id == 4 then
				pcolor = ManaBarColor[3]
			else
				pcolor = ManaBarColor[0]
			end
			class = c[id]
		end

		if f.pet and o.usepetcolor then
			color.r,color.g,color.b = unpack(o.petcolor)
		elseif class and class == "SHAMAN" and o.useshamancolor then
			color = {r=0.14,g=0.35,b=1}
		elseif class then
			color = RAID_CLASS_COLORS[class]
		else
			color = {r=1,g=0,b=1}
		end

		--update some stuff
		f.name = name
		--handle coloring text
		if o.colorunithealthbarbyclass then
			f.healthbar:SetStatusBarColor(color.r, color.g, color.b, o.unithealthbarcolor[4])
		end
		if o.colorunitnamehealthbyclass then
			f.namehealthtext:SetTextColor(color.r, color.g, color.b, o.unitnamehealthtextcolor[4])
		end
		if o.colorunithealthbarbgbyclass then
			f.healthbar.bgtex:SetVertexColor(color.r, color.g, color.b)
		end

		f.powerbar:SetStatusBarColor(pcolor.r, pcolor.g, pcolor.b)
		if o.colorpowerbarbgbytype then
			f.powerbar.bgtex:SetVertexColor(pcolor.r, pcolor.g, pcolor.b)
		end

		-- Set role icon
		local role = self:GetPlayerRole(unitid)
		if role == "TANK" then
			f.roleIcon.texture:SetTexture("Interface\\AddOns\\NotGrid\\media\\tank2")
			if self.Banzai:GetUnitAggroByUnitId(unitid) then
				-- f.roleIcon.border.texture:SetVertexColor(0.8, 0.2, 0.2, 1) -- Красная подсветка для танков под аггро
			else
				-- f.roleIcon.texture:SetVertexColor(0.2, 0.2, 0.2, 1) -- Черная подсветка для танков без аггро
			end
			f.roleIcon:Show()
		elseif role == "HEALER" then
			f.roleIcon.texture:SetTexture("Interface\\AddOns\\NotGrid\\media\\healer2")
			if self.Banzai:GetUnitAggroByUnitId(unitid) then
				f.roleIcon.texture:SetVertexColor(0.8, 0.2, 0.2, 1) -- Красная подсветка для танков под аггро
			else
				f.roleIcon.texture:SetVertexColor(0.2, 0.8, 0.2, 1) -- Зеленая подсветка для хилов
			end
			f.roleIcon:Show()
		elseif role == "DPS" then
			-- f.roleIcon.texture:SetTexture("Interface\\AddOns\\NotGrid\\media\\damage2")
			-- f.roleIcon:Show()
			f.roleIcon:Hide()
		else
			f.roleIcon:Hide()
		end

		if UnitIsConnected(unitid) then
			local healamount, currhealth, maxhealth, deficit, healtext, currpower, maxpower
			if o.configmode then
				currhealth = UnitHealth(unitid)/2
				maxhealth = UnitHealthMax(unitid)
				deficit = maxhealth - currhealth
				currpower = UnitManaMax(unitid)/2
				maxpower = UnitManaMax(unitid)
				healamount = maxhealth/4
			else
				currhealth = UnitHealth(unitid)
				maxhealth = UnitHealthMax(unitid)
				deficit = maxhealth - currhealth
				currpower = UnitMana(unitid)
				maxpower = UnitManaMax(unitid)
				healamount = self.HealComm:getHeal(name)
			end

			if healamount > 999 then
				healtext = string.format("+%.1fk", healamount/1000.0)
			else
				healtext = string.format("+%d", healamount)
			end

			f.healthbar:SetMinMaxValues(0, maxhealth)
			f.healthbar:SetValue(currhealth)

			f.powerbar:SetMinMaxValues(0, maxpower)
			f.powerbar:SetValue(currpower)

			if UnitIsDead(unitid) then
				self:UnitHealthZero(f, "Вмер", shortname)
			elseif UnitIsGhost(unitid) or (deficit >= maxhealth) then
				self:UnitHealthZero(f, "Дух", shortname)
			elseif currhealth/maxhealth*100 <= self.o.healththreshhold then
				local deficittext
				if deficit > 999 then
					deficittext = string.format("-%.1fk", deficit/1000.0)
				else
					deficittext = string.format("-%d", deficit)
				end
				f.namehealthtext:SetFont(o.unitnumberfont, o.unitnamehealthtextsize)
				f.namehealthtext:SetText(deficittext)
			else
				f.namehealthtext:SetFont(o.unitfont, o.unitnamehealthtextsize)
				f.namehealthtext:SetText(shortname)
			end

			if healamount > 0 then
				if o.showhealcommbar then
					self:SetIncHealFrame(f, healamount, currhealth, maxhealth)
				end
				if o.showhealcommtext then
					f.healcommtext:SetFont(o.unitnumberfont, o.unithealcommtextsize)
					f.healcommtext:SetText(healtext)
					f.healcommtext:Show()
				end
			else
				f.incheal:SetBackdropColor(0,0,0,0)
				f.healcommtext:Hide()
			end

			if self.HealComm:UnitisResurrecting(name) then
				f.incres:Show()
			else
				f.incres:Hide()
			end
		else
			self:UnitHealthZero(f, "Офл", shortname)
		end
	end
end

function NotGrid:UnitHealthZero(f, state, shortname)
	f.namehealthtext:SetFont(self.o.unitfont, self.o.unitnamehealthtextsize)
	f.namehealthtext:SetText(shortname.."\n"..state)
end

function NotGrid:ClickHandle(button)
	if button == "RightButton" and SpellIsTargeting() then
		SpellStopTargeting()
		return
	end
	if button == "LeftButton" then
		if SpellIsTargeting() then
			SpellTargetUnit(this.unit)
		elseif CursorHasItem() then
			DropItemOnUnit(this.unit)
		else
			TargetUnit(this.unit)

			if has_unitxp and playerClass == "DRUID" then
				if UnitXP("inSight", "player", this.unit) and UnitXP("distanceBetween", "player", this.unit) <= 40 then

					local deficit = UnitHealthMax(this.unit) - UnitHealth(this.unit)
					local deficitPercent = (deficit / UnitHealthMax(this.unit)) * 100
					local hasRejuv, hasRegrowth, hasAbolish, hasCurse, hasPoison = hasUnitBuff(this.unit)

					if hasCurse then
						castSpell("Remove Curse", this.unit)
					elseif hasPoison and not hasAbolish then
						castSpell("Abolish Poison", this.unit)
					elseif deficitPercent > 10 and (hasRegrowth or hasRejuv) then
						local slotSwiftmend, bookTypeSwiftmend = GetSpellSlotTypeIdForName("Swiftmend")
						local start, duration = GetSpellCooldown(slotSwiftmend, "spell")
						if duration == 0 or (start > 0 and duration <= 1.5) then
							castSpell("Swiftmend", this.unit)
						end
					end
				end
			end
		end
	elseif button == "RightButton" then
		if IsControlKeyDown() then
			ToggleFriendsFrame(4) -- Открываем окно рейда (4 - это индекс для рейда)
		else
			local name = UnitName(this.unit)
			local id = string.sub(this.unit,5)
			local unit = this.unit
			local menuFrame = FriendsDropDown
			menuFrame.displayMode = "MENU"
			menuFrame.initialize = function() UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "PARTY", unit, name, id) end
			ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
		end
	end
end
