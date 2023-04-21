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

local textures = {}

function Codex_OnTooltipShown()
    if UnitIsPlayer("mouseover") or not UnitCanAttack("player", "mouseover") then
        return
    end

    local unitName = UnitName("mouseover")
    if not unitName then
        return
    end

    local spellList = Codex_CreatureSpells[unitName]
    if spellList then
        for i = 0, 4 do
            if spellList[i] then
                GameTooltip:AddLine(" "); 
                GameTooltip:AddDoubleLine(Codex_GetSpellName(spellList[i]), " ")
                Codex_AddSpellIcon(i, GameTooltip:NumLines(), spellList[i])
                textures[i].border:Show()
                local schoolColor = schoolColors[spellList[i].school]
                GameTooltip:AddLine(Codex_GetSpellSchool(spellList[i]), schoolColor.r, schoolColor.g, schoolColor.b, true)     
                GameTooltip:AddLine(Codex_GetSpellDescription(spellList[i]), 1, 1, 1, true)     
            elseif textures[i] then
                textures[i]:SetTexture(nil)
            end
        end
        -- for i, spell in ipairs(spellList) do
        --     GameTooltip:AddLine(" "); 
        --     GameTooltip:AddDoubleLine(Codex_GetSpellName(spell), " ")
        --     Codex_AddSpellIcon(i, GameTooltip:NumLines(), spell)
        --     local schoolColor = schoolColors[spell.school]
        --     GameTooltip:AddLine(Codex_GetSpellSchool(spell), schoolColor.r, schoolColor.g, schoolColor.b, true)     
        --     GameTooltip:AddLine(Codex_GetSpellDescription(spell), 1, 1, 1, true)           
        -- end 

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

function Codex_AddSpellIcon(spellIndex, lineIndex, spell)
    if not textures[spellIndex] then
        local texture = GameTooltip:CreateTexture(nil, "OVERLAY")
        texture:SetWidth(21)
        texture:SetHeight(21)
        textures[spellIndex] = texture

        texture.border = CreateFrame("Frame", nil, GameTooltip)
        texture.border:SetPoint("TOPLEFT", texture, "TOPLEFT", -2, 2)
        texture.border:SetPoint("BOTTOMRIGHT", texture, "BOTTOMRIGHT", 2, -2)
        texture.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12})
    end

    textures[spellIndex]:SetPoint("RIGHT", "GameTooltipTextRight"..lineIndex, "RIGHT", 0, -9)

    if spell.icon then
        textures[spellIndex]:SetTexture(spell.icon)
        local schoolColors = schoolColors[spell.school]
        textures[spellIndex].border:SetBackdropBorderColor(schoolColors.r, schoolColors.g, schoolColors.b)
    else
        textures[spellIndex]:SetTexture("Interface\\Icons\\Inv_misc_questionmark")
        textures[spellIndex].border:SetBackdropBorderColor(1, 0, 0)
    end
end

function Codex_OnTooltipHidden()
    for i = 0, 4 do
        if textures[i] then
            textures[i]:SetTexture(nil)
            textures[i].border:Hide()
        end
    end
end

local codexTooltip = CreateFrame("Frame", nil, GameTooltip)
codexTooltip:SetScript("OnShow", Codex_OnTooltipShown)
codexTooltip:SetScript("OnHide", Codex_OnTooltipHidden)
