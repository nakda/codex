local colors = {
    [0] = { r = 1, g = 1, b = 1 },          -- Physical
    [1] = { r = 1, g = 1, b = 0 },          -- Holy
    [2] = { r = 1, g = 0.5, b = 0 },        -- Fire
    [3] = { r = 0, g = 1, b = 0 },          -- Nature
    [4] = { r = 0, g = 1, b = 1 },          -- Frost
    [5] = { r = 0.7, g = 0, b = 0.7 },      -- Shadow
    [6] = { r = 1.0, g = 0.44, b = 0.76 }   -- Arcane
}

local dispels = {
    [1] = "Magic",
    [2] = "Curse",
    [3] = "Disease",
    [4] = "Poison"
}

local icons = {
    [1] = "Interface\\Icons\\Spell_fire_frostresistancetotem", -- Magic
    [2] = "Interface\\Icons\\ability_creature_cursed_03", -- Curse
    [3] = "Interface\\Icons\\Ability_creature_disease_03", -- Disease
    [4] = "Interface\\Icons\\ability_creature_poison_05" -- Poison
}

local codexTooltip = CreateFrame("Frame", nil, GameTooltip)

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
        for i, spell in ipairs(spellList) do
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(" ")

            local schoolColor = colors[spell.school]

            codexTooltip.iconbg:Show()
            if spell.dispel then
                codexTooltip.icon:SetTexture(icons[spell.dispel])
                codexTooltip.iconbg:SetBackdropBorderColor(schoolColor.r, schoolColor.g, schoolColor.b)
            else
                codexTooltip.icon:SetTexture("Interface\\Icons\\Inv_misc_questionmark")
                codexTooltip.iconbg:SetBackdropBorderColor(1, 0, 0)
            end

            local numLines = GameTooltip:NumLines();
	        codexTooltip.iconbg:SetPoint("TOP", GameTooltip:GetName().."TextLeft"..numLines, "BOTTOM", 10, 24)           
            
            if spell.name then
                codexTooltip.name:SetText(spell.name)
                codexTooltip.name:SetTextColor(schoolColor.r, schoolColor.g, schoolColor.b)
            else
                codexTooltip.name:SetText("Unknown spell")
                codexTooltip.name:SetTextColor(0.8, 0.8, 0.8)
            end
            
            if spell.subname then
                codexTooltip.subname:SetText("("..spell.subname..")")
            end

            if spell.description then
                GameTooltip:AddLine(Codex_ParseDescription(spell.description), 0.8, 0.8, 0.8, true)
            else
                GameTooltip:AddLine("Unknown spell effect.", 0.8, 0.8, 0.8)
            end
        end 

        GameTooltip:Show()
    end
end

function Codex_ParseDescription(spellDescription)
    local gender = UnitSex("mouseover") -- 1=Neutrum/Unknown, 2=Male, 3=Female

    if gender == 1 then
        gender = math.random(2 ,3)
    end
    
    return string.gsub(spellDescription, "$g([^:]+):([^;]+);", "%" .. (gender - 1))
end

codexTooltip.iconbg = CreateFrame("Frame", nil, codexTooltip)
codexTooltip.iconbg:SetWidth(26)
codexTooltip.iconbg:SetHeight(26)
codexTooltip.iconbg:SetBackdrop({
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true, tileSize = 12, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})

codexTooltip.icon = codexTooltip:CreateTexture(nil, 'ARTWORK')
codexTooltip.icon:SetWidth(24)
codexTooltip.icon:SetHeight(24)
codexTooltip.icon:SetPoint("TOPLEFT", codexTooltip.iconbg, "TOPLEFT", 2, -2)
codexTooltip.icon:SetPoint("BOTTOMRIGHT", codexTooltip.iconbg, "BOTTOMRIGHT", -2, 2)

codexTooltip.name = codexTooltip:CreateFontString("Status", "LOW", "GameFontNormal")
codexTooltip.name:SetFont(STANDARD_TEXT_FONT, 12)
codexTooltip.name:SetPoint("TOPLEFT", codexTooltip.icon, "TOPRIGHT", 2, 0)

codexTooltip.subname = codexTooltip:CreateFontString("Status", "LOW", "GameFontNormal")
codexTooltip.subname:SetFont(STANDARD_TEXT_FONT, 10)
codexTooltip.subname:SetPoint("BOTTOMLEFT", codexTooltip.icon, "BOTTOMRIGHT", 2, 0)
codexTooltip.subname:SetTextColor(.9, .7, 0)

codexTooltip:SetScript("OnShow", Codex_OnTooltipShown)
codexTooltip:SetScript("OnHide", function()
    codexTooltip.iconbg:ClearAllPoints()
    codexTooltip.iconbg:Hide()
    codexTooltip.icon:SetTexture(nil)
    codexTooltip.name:SetText("")
    codexTooltip.subname:SetText("")    
end)