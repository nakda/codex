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
            GameTooltip:AddLine(" "); 

            local schoolColor = colors[spell.school]

            if spell.name and spell.dispel then
                GameTooltip:AddDoubleLine(spell.name, "Dispel: " .. dispels[spell.dispel], schoolColor.r, schoolColor.g, schoolColor.b, schoolColor.r, schoolColor.g, schoolColor.b, true)
            elseif spell.name then
                GameTooltip:AddLine(spell.name, schoolColor.r, schoolColor.g, schoolColor.b, true)
            else
                GameTooltip:AddLine("Unknown spell")
            end

            if spell.subname then
                GameTooltip:AddLine(spell.subname, 0.8, 0.8, 0.8, true)
            end

            if spell.description then
                GameTooltip:AddLine(Codex_ParseDescription(spell.description), 1, 1, 1, true)
            else
                GameTooltip:AddLine("Unknown spell effect.")
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

local codexTooltip = CreateFrame("Frame", nil, GameTooltip)
codexTooltip:SetScript("OnShow", Codex_OnTooltipShown)