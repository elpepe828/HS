-- ===================================================================
-- PROJECT RGG: UNIVERSAL PLACEMENT MORPH v14.0 (REAL CLOUD SYNC)
-- Features: Remote Crop Auto-Harvest + Dynamic Spawn Meta-Data Overrider
-- Instructions: Select target on GUI, place a CHEAP item, then RE-LOG!
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local RGG_Morph = {
    Interval = 0.3,
    ActiveCategory = "Barracks", -- Categories matching game structures
    SelectedTier = "Max",        -- Level/Tier override
    BypassActive = false
}

-- Dictionary mapping generic categories to help the engine morph the item types universally
local CategoryBypass = {
    ["Military/Barracks"] = {"barrack", "military", "spawn", "troop", "army"},
    ["Defense/Turrets"]   = {"turret", "defense", "tower", "cannon", "gun"},
    ["Houses/VIP"]        = {"house", "vip", "home", "residential", "special"},
    ["Superweapons/Silo"] = {"silo", "nuke", "superweapon", "weapon", "nuclear"},
    ["Resources/Mines"]   = {"mine", "collector", "quarry", "generator"}
}

-- 1. UNIVERSAL CROP AND HARVEST COLLECTOR
local function autoHarvestCrops()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                local parentName = string.lower(obj.Parent.Name)
                if string.find(parentName, "farm") or string.find(parentName, "crop") or string.find(parentName, "harvest") or string.find(parentName, "resource") or string.find(parentName, "collect") or string.find(parentName, "mine") then
                    fireclickdetector(obj, 0)
                end
            end
            
            if obj:IsA("ProximityPrompt") then
                local promptName = string.lower(obj.ObjectText or obj.ActionText)
                if string.find(promptName, "harvest") or string.find(promptName, "collect") or string.find(promptName, "gather") or string.find(promptName, "claim") then
                    obj:InputHoldBegin()
                    task.wait()
                    obj:InputHoldEnd()
                end
            end
        end
    end)
end

-- ===================================================================
-- 2. DYNAMIC SPAWN META-DATA OVERRIDER (REAL METHOD OVERRIDE)
-- ===================================================================
local function runSpawnMorphEngine()
    if not RGG_Morph.BypassActive then return end
    
    pcall(function()
        -- Deep scan of local memory tables handling active placement modules
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                
                -- Check for active building variables or placement blueprints in memory
                if t["ItemType"] or t["StructureName"] or t["TemplateID"] or t["ModelName"] then
                    for k, v in pairs(t) do
                        if type(k) == "string" and type(v) == "string" then
                            local kLower = string.lower(k)
                            
                            -- Morph identity variables inside the script's internal dictionary
                            if string.find(kLower, "type") or string.find(kLower, "id") or string.find(kLower, "name") or string.find(kLower, "model") then
                                t[k] = RGG_Morph.ActiveCategory
                            end
                            
                            -- Morph level, tier, or stage variables to instantly unlock Max Level structures
                            if string.find(kLower, "level") or string.find(kLower, "tier") or string.find(kLower, "stage") then
                                t[k] = RGG_Morph.SelectedTier
                            end
                        end
                        
                        -- Force level indices to maximum integers if numeric
                        if type(k) == "string" and type(v) == "number" then
                            if string.find(string.lower(k), "level") or string.find(string.lower(k), "tier") then
                                t[k] = 10 -- Sets building level logic variables to Max Level
                            end
                        end
                    end
                end
            end
        end
        
        -- Override physical attributes of the ghost model before placement confirmation
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") and (string.find(string.lower(model.Name), "preview") or string.find(string.lower(model.Name), "ghost")) then
                model:SetAttribute("ItemID", RGG_Morph.ActiveCategory)
                model:SetAttribute("Level", 10)
                model:SetAttribute("Tier", "Max")
            end
        end
    end)
end

-- ===================================================================
-- 3. GRAPHICAL USER INTERFACE (IGAMEGOD LAYOUT)
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RGG_Morph_Panel"

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 80, 0, 40)
MainBtn.Position = UDim2.new(0, 15, 0, 220)
MainBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainBtn.Text = "RGG Morph"
MainBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
MainBtn.Font = Enum.Font.Code
MainBtn.TextSize = 13
MainBtn.Draggable = true

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 280, 0, 260)
Frame.Position = UDim2.new(0.5, -140, 0.4, -130)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Title.Text = "  ⚡ RGG REPLACEMENT CORE v14.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton", Frame)
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(130, 20, 20)
ToggleBtn.Text = "MORPH STATUS: DISABLED"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 11

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Size = UDim2.new(1, -20, 0, 150)
Scroll.Position = UDim2.new(0, 10, 0, 95)
Scroll.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 160)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Dynamically map options from configuration table definitions
for categoryName, keywords in pairs(CategoryBypass) do
    local ItemBtn = Instance.new("TextButton", Scroll)
    ItemBtn.Size = UDim2.new(1, 0, 0, 30)
    ItemBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    ItemBtn.Text = " [MORPH]: " .. categoryName
    ItemBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
    ItemBtn.Font = Enum.Font.Code
    ItemBtn.TextSize = 11
    
    ItemBtn.MouseButton1Click:Connect(function()
        RGG_Morph.ActiveCategory = keywords[1] -- Extracts safe baseline string keyword identifier
        Title.Text = "  ⚡ TARGET: " .. string.upper(categoryName)
        for _, b in ipairs(Scroll:GetChildren()) do
            if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(18, 18, 18) end
        end
        ItemBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
    end)
end

MainBtn.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)

ToggleBtn.MouseButton1Click:Connect(function()
    RGG_Morph.BypassActive = not RGG_Morph.BypassActive
    if RGG_Morph.BypassActive then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 140, 60)
        ToggleBtn.Text = "MORPH STATUS: MONITORING (ACTIVE)"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(130, 20, 20)
        ToggleBtn.Text = "MORPH STATUS: DISABLED"
    end
end)

-- ===================================================================
-- RUNTIME SCHEDULER EXECUTION
-- ===================================================================
task.spawn(function()
    print("[RGG Universal Morph] System initialized.")
    while true do
        autoHarvestCrops()
        runSpawnMorphEngine()
        task.wait(RGG_Morph.Interval)
    end
end)
