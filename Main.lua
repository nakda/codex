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

function Codex_OnTooltipShown()
    -- Make sure the unit is not another player, and we can attack it (otherwise we wouldn't really need the info)
    if UnitIsPlayer("mouseover") or not UnitCanAttack("player", "mouseover") then
        return
    end

    -- Make sure we retrieve a name from the unit (to search the database)
    local unitName = UnitName("mouseover")
    if not unitName then
        return
    end

    local spellList = Codex_CreatureSpells[unitName]
    if spellList then
        for i = 0, 4 do
            if spellList[i] then
                -- Create a separator to make some space between each spell
                GameTooltip:AddLine(" ");

                -- Use a double line for the spell name and icon
                GameTooltip:AddDoubleLine(Codex_GetSpellName(spellList[i]), " ")

                -- Create a spell icon UI if it doesn't exist
                if not spellIcons[i] then
                    spellIcons[i] = Codex_CreateSpellIcon()
                end

                local schoolColor = schoolColors[spellList[i].school]

                -- Set the proper spell icon, school and description
                Codex_SetSpellIcon(spellIcons[i], spellList[i], schoolColor)
                GameTooltip:AddLine(Codex_GetSpellSchool(spellList[i]), schoolColor.r, schoolColor.g, schoolColor.b, true)     
                GameTooltip:AddLine(Codex_GetSpellDescription(spellList[i]), 1, 1, 1, true)     

                -- Make sure the spell icon is visible
                Codex_ShowSpellIcon(spellIcons[i])
            elseif spellIcons[i] then
                -- Hide the spell icon if 
                Codex_HideSpellIcon(spellIcons[i])
            end
        end

        -- Force refresh GameTooltip size
        GameTooltip:Show()
    end
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
        local gender = UnitSex("mouseover") -- 1=Neutrum/Unknown, 2=Male, 3=Female

        if gender == 1 then
            gender = math.random(2 ,3)
        end

        return string.gsub(spell.description, "$g([^:]+):([^;]+);", "%" .. (gender - 1))
    else
        return "Unknown spell effect."
    end
end

function Codex_CreateSpellIcon()
    local texture = GameTooltip:CreateTexture(nil, "OVERLAY")
    texture:SetWidth(21)
    texture:SetHeight(21)

    texture.border = CreateFrame("Frame", nil, GameTooltip)
    texture.border:SetPoint("TOPLEFT", texture, "TOPLEFT", -2, 2)
    texture.border:SetPoint("BOTTOMRIGHT", texture, "BOTTOMRIGHT", 2, -2)
    texture.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12})

    return texture
end

function Codex_SetSpellIcon(spellIcon, spell, borderColor)
    spellIcon:SetPoint("RIGHT", "GameTooltipTextRight"..GameTooltip:NumLines(), "RIGHT", 0, -9)

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
    spellIcon:SetTexture(nil)
    spellIcon:Hide()
    spellIcon.border:Hide()
end

function Codex_OnTooltipHidden()
    for i = 0, 4 do
        if spellIcons[i] then
            Codex_HideSpellIcon(spellIcons[i])
        end
    end
end

local codexTooltip = CreateFrame("Frame", nil, GameTooltip)
codexTooltip:SetScript("OnShow", Codex_OnTooltipShown)
codexTooltip:SetScript("OnHide", Codex_OnTooltipHidden)
