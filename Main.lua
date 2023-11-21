local schools = {
    [0] = "Physical",
    [1] = "Holy",
    [2] = "Fire",
    [3] = "Nature",
    [4] = "Frost",
    [5] = "Shadow",
    [6] = "Arcane"
}

local schoolColors = {
    [0] = { r = 0.70196, g = 0.48627, b = 0.30196 },          -- Physical
    [1] = { r = 1, g = 1, b = 0 },                            -- Holy
    [2] = { r = 1, g = 0.5, b = 0 },                          -- Fire
    [3] = { r = 0, g = 1, b = 0 },                            -- Nature
    [4] = { r = 0, g = 1, b = 1 },                            -- Frost
    [5] = { r = 0.7, g = 0, b = 0.7 },                        -- Shadow
    [6] = { r = 1.0, g = 0.44, b = 0.76 }                     -- Arcane
}

local dispels = {
    [1] = "Magic",
    [2] = "Curse",
    [3] = "Disease",
    [4] = "Poison"
}

local spellIcons = {}
local Shown = false --One time show control for TipBuddy addon

--Check for TipBuddy addon
local function IsTipBuddyLoaded()
	return IsAddOnLoaded("TipBuddy")
end

local function wrap(text, width)
	-- Splits a string into a table
	local function split(str, pattern)
		local words = {}
		
		for word in string.gmatch(str, pattern) do
			words[table.getn(words)+1] = word
		end
		
		return words
	end
	
	local lines = split(text, "[^\r\n]+")
	local widthLeft
	local result = ""
	local line = {}
	
	-- Insert each source line into the result, one-by-one
	for k=1, table.getn(lines) do
		sourceLine = lines[k]
		widthLeft = width -- all the width is left
		
		local words = split(sourceLine, "%S+")
		
		for l = 1, table.getn(words) do
			word = words[l]
			
			-- If the word is longer than an entire line:
			if string.len(word) > width then
				-- In case the word is longer than multible lines:
				while (string.len(word) > width) do
					-- Fit as much as possible
					table.insert(line, word:sub(0, widthLeft))
					
					result = result..table.concat(line, " ").."\n"
					
					-- Take the rest of the word for next round
					word = word:sub(widthLeft + 1)
					widthLeft = width
					line = {}
				end
				
				-- The rest of the word that could share a line
				line = {word}
				widthLeft = width - (string.len(word) + 1)
				
			-- If we have no space left in the current line
			elseif (string.len(word) + 1) > widthLeft then
				result = result..table.concat(line, " ").."\n"
				
				-- start next line
				line = {word}
				widthLeft = width - (string.len(word) + 1)
				
			-- if we could fit the word on the line
			else
				table.insert(line, word)
				widthLeft = widthLeft - (string.len(word) + 1)
			end
		end
		
		-- Insert the rest of the source line
		result = result..table.concat(line, " ")
		line = {}
	end

	return result
end

local function GetNumLines(spellNumber)
	if IsTipBuddyLoaded() then
		return TipBuddyTooltip:NumLines()+spellNumber
	else
		return GameTooltip:NumLines()
	end
end

local function GetTextLeft(spellNumber)
	local s = "TooltipTextLeft"..GetNumLines(spellNumber)
	
	if IsTipBuddyLoaded() then
		return "TipBuddy"..s
	else
		return "Game"..s
	end
end

function Codex_OnTooltipShown()
	if Shown then return end
	
    -- Make sure the unit is not another player
    if UnitIsPlayer("mouseover") then return end

    -- Make sure we retrieve a name from the unit (to search the database)
    local unitName = UnitName("mouseover")
    if not unitName then return end
	
    local spellList = Codex_CreatureSpells[unitName]
	
	local function SetLastLineSize(size, spellNumber)
		getglobal(GetTextLeft(spellNumber)):SetFont("Fonts\\FRIZQT__.TTF", size)
	end
	
    if spellList then
        for i = 0, 4 do
            if spellList[i] then
                -- Create a separator to make some space between each spell
                GameTooltip:AddLine(" ")
				
                -- Use a double line for the spell name and icon
                GameTooltip:AddLine("        "..Codex_GetSpellName(spellList[i]), 1, 1, 1)
		SetLastLineSize(14, i)
				
                -- Create a spell icon UI if it doesn't exist
                if not spellIcons[i] then
                    spellIcons[i] = Codex_CreateSpellIcon()
                end
				
                local schoolColor = schoolColors[spellList[i].school]
				
                -- Set the proper spell icon, school and description
                Codex_SetSpellIcon(spellIcons[i], spellList[i], schoolColor, i)
                GameTooltip:AddLine("          "..Codex_GetSpellSchool(spellList[i]), schoolColor.r, schoolColor.g, schoolColor.b, true)
		SetLastLineSize(11, i)
                GameTooltip:AddLine("|cffFFD100"..wrap(Codex_GetSpellDescription(spellList[i]), 40).."|r")
		SetLastLineSize(12, i)
				
                -- Make sure the spell icon is visible
                Codex_ShowSpellIcon(spellIcons[i])
            elseif spellIcons[i] then
                -- Hide the spell icon if 
                Codex_HideSpellIcon(spellIcons[i])
            end
        end
		
        -- Force refresh GameTooltip size
		if not IsTipBuddyLoaded() then
			GameTooltip:Show()
		end
    end
	
	Shown = true
end

function Codex_GetSpellName(spell)
    if spell.name then
        return spell.name
    else
        return "Unknown spell"
    end
end

function Codex_GetSpellSchool(spell)
    if spell.dispel then
        return schools[spell.school] .. " (".. dispels[spell.dispel] .. ")"
    else
        return schools[spell.school]
    end
end

function Codex_GetSpellDescription(spell)
    if spell.description then
        local gender = UnitSex("mouseover") -- 1 = Neutrum/Unknown, 2 = Male, 3 = Female
		
        if gender == 1 then
            gender = math.random(2 ,3)
        end
		
        return string.gsub(spell.description, "$g([^:]+):([^]+)", "%" .. (gender - 1))
    else
        return "Unknown spell effect."
    end
end

local function GetParentTooltip()
	if IsTipBuddyLoaded() then
		return TipBuddyTooltip
	else
		return GameTooltip
	end
end

function Codex_CreateSpellIcon()
    local texture = GetParentTooltip():CreateTexture(nil, "OVERLAY")
	
    texture:SetWidth(29)
    texture:SetHeight(29)
	
    texture.border = CreateFrame("Frame", nil, GetParentTooltip())
    texture.border:SetPoint("TOPLEFT", texture, "TOPLEFT", -2, 2)
    texture.border:SetPoint("BOTTOMRIGHT", texture, "BOTTOMRIGHT", 2, -2)
    texture.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12})
	
    return texture
end

function Codex_SetSpellIcon(spellIcon, spell, borderColor, spellNumber)
    spellIcon:SetPoint("TOPLEFT", GetTextLeft(spellNumber), "TOPLEFT", 0, 1)
	
    if spell.icon then
        spellIcon:SetTexture(spell.icon)
        spellIcon.border:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b)
    else
        spellIcon:SetTexture("Interface\\Icons\\Inv_misc_questionmark")
        spellIcon.border:SetBackdropBorderColor(1, 0, 0)
    end
end

function Codex_ShowSpellIcon(spellIcon)
    spellIcon:Show()
    spellIcon.border:Show()
end

function Codex_HideSpellIcon(spellIcon)
    spellIcon:Hide()
    spellIcon.border:Hide()
end

function Codex_OnTooltipHidden()
    for i = 0, 4 do
        if spellIcons[i] then
            Codex_HideSpellIcon(spellIcons[i])
        end
    end
	
	Shown = false
end

local codexTooltip = CreateFrame("Frame", nil, GameTooltip)
codexTooltip:SetScript("OnUpdate", Codex_OnTooltipShown)
codexTooltip:SetScript("OnHide", Codex_OnTooltipHidden)
