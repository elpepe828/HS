-- ===================================================================
-- MINI WAR UTILITY SCRIPT (STANDALONE VERSION FOR DELTA)
-- Features: Auto-Collector Loop + Instant Construction Bypass
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- [ CONFIGURATION PLATFORM ]
local MiniWarConfig = {
    AutoCollectEnabled = true,
    InstantBuildEnabled = true,
    CollectInterval = 0.5 -- Teleports/Clicks resources every 0.5 seconds
}

-- 1. AUTO-COLLECTOR ENGINE
local function runAutoCollector()
    if not MiniWarConfig.AutoCollectEnabled then return end
    
    pcall(function()
        -- Scan the map for dropping resources, crates, or cash nodes
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)
            
            -- Detect common resource dropping patterns in Mini War
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                local part = obj.Parent
                if string.find(nameLower, "resource") or string.find(nameLower, "coin") or string.find(nameLower, "drop") or string.find(nameLower, "crate") or string.find(nameLower, "supply") then
                    -- Safely fire the proximity touch to collect instantly
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 0)
                        task.wait(0.01)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 1)
                    end
                end
            end
        end
    end)
end

-- 2. INSTANT CONSTRUCTION BYPASS
local function runInstantConstruction()
    if not MiniWarConfig.InstantBuildEnabled then return end
    
    pcall(function()
        -- Scan for active building structures or progress bars in memory
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local nameLower = string.lower(obj.Name)
                
                -- Intercept construction timer blocks and progress variables
                if string.find(nameLower, "progress") or string.find(nameLower, "buildtime") or string.find(nameLower, "timer") or string.find(nameLower, "construction") then
                    -- If it's a remaining time value, force it to zero
                    if string.find(nameLower, "time") or string.find(nameLower, "remain") then
                        obj.Value = 0
                    else
                        -- If it's a progression scale value (0 to 100), force it to maximum
                        if obj.Value < 100 then
                            obj.Value = 100
                        end
                    end
                end
            end
        end
        
        -- Scan Player UI for active building sliders to finish them client-side
        if LocalPlayer:FindFirstChild("PlayerGui") then
            for _, ui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if ui:IsA("TextLabel") or ui:IsA("TextBox") then
                    if string.find(string.lower(ui.Text), "building") or string.find(string.lower(ui.Text), "constructing") then
                        ui.Text = "Completed!"
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- CORE EXECUTION LOOP (RUNS SECURELY IN ISOLATED THREADS)
-- ===================================================================
task.spawn(function()
    print("[Mini War Utility] Script successfully loaded and running.")
    while true do
        runAutoCollector()
        runInstantConstruction()
        task.wait(MiniWarConfig.CollectInterval)
    end
end)
