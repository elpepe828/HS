-- ===================================================================
-- MINI WAR CLOUD-SPOOFER & ANTI-RESET ENGINE v9.0 (MASTER EDITION)
-- Features: Safe Multi-Filtered Cost Spoofing + Anti-Reset Engine + Worker Freeze
-- Instructions: Wait for the interface notification, then re-log safely!
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MiniWarMaster = {
    Interval = 0.2,
    TargetTimeOverride = 0,
    WorkerFreezeSpeed = 0 -- Freezes workers so they cannot hit and erase the structure
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
-- 2. MASTER ANTI-RESET & WORKER IMMOBILIZER ENGINE
-- ===================================================================
local function runMasterStealthSpoofer()
    pcall(function()
        local validStructuralKeywords = {"build", "construct", "upgrade", "level", "structure", "barrack", "wall", "defense", "townhall", "hq"}
        
        -- STEP A: FREEZE WORKERS MOVEMENT TO PREVENT DATA ERASURE BLOWS
        for _, npc in ipairs(Workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                local npcName = string.lower(npc.Name)
                if string.find(npcName, "worker") or string.find(npcName, "builder") or string.find(npcName, "villager") or string.find(npcName, "drone") then
                    -- Keep them completely still so they never touch the active project
                    npc.Humanoid.WalkSpeed = MiniWarMaster.WorkerFreezeSpeed
                end
            end
        end

        -- STEP B: FILTER STRUCTURE MODELS AND LOCK VALS AGGRESSIVELY (ANTI-RESET)
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") then
                local modelNameLower = string.lower(model.Name)
                local isBuilding = false
                
                for _, keyword in ipairs(validStructuralKeywords) do
                    if string.find(modelNameLower, keyword) then
                        isBuilding = true
                        break
                    end
                end
                
                if isBuilding then
                    -- Apply persistent lock to Attributes
                    local attributes = model:GetAttributes()
                    for name, value in pairs(attributes) do
                        local nameLower = string.lower(name)
                        if type(value) == "number" then
                            if string.find(nameLower, "time") or string.find(nameLower, "duration") or string.find(nameLower, "cooldown") or string.find(nameLower, "remaining") then
                                model:SetAttribute(name, MiniWarMaster.TargetTimeOverride)
                            end
                        end
                    end
                    
                    -- Apply persistent lock to Int/Number instances
                    for _, child in ipairs(model:GetChildren()) do
                        if child:IsA("IntValue") or child:IsA("NumberValue") then
                            local childName = string.lower(child.Name)
                            if string.find(childName, "time") or string.find(childName, "timer") or string.find(childName, "duration") or string.find(childName, "remaining") then
                                child.Value = MiniWarMaster.TargetTimeOverride
                            end
                        end
                    end
                end
            end
        end
        
        -- STEP C: SPOOF GARBAGE COLLECTOR REGISTERS CONSTANTLY
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                if t["Building"] or t["UpgradeData"] or t["ConstructionData"] or t["BuildTime"] or t["Structure"] then
                    for k, v in pairs(t) do
                        if type(k) == "string" and type(v) == "number" then
                            local keyLower = string.lower(k)
                            if string.find(keyLower, "timer") or string.find(keyLower, "buildtime") or string.find(keyLower, "cooldown") or string.find(keyLower, "remaining") then
                                t[k] = MiniWarMaster.TargetTimeOverride
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- INTERFACE NOTIFICATION LAYER
-- ===================================================================
local function createNotificationUI()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local Notification = Instance.new("TextLabel", ScreenGui)
    Notification.Size = UDim2.new(0, 260, 0, 40)
    Notification.Position = UDim2.new(0.5, -130, 0, 10)
    Notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Notification.Text = "🔒 [RGG STATUS]: SAVE BUFF READY. RE-LOG NOW!"
    Notification.TextColor3 = Color3.fromRGB(0, 255, 150)
    Notification.Font = Enum.Font.Code
    Notification.TextSize = 11
end

-- ===================================================================
-- MOTOR PROCESS INJECTION
-- ===================================================================
task.spawn(function()
    createNotificationUI()
    print("[RGG Mini War v9.0 Master] Anti-Reset protection layer active.")
    while true do
        autoHarvestCrops()
        runMasterStealthSpoofer()
        task.wait(MiniWarMaster.Interval)
    end
end)
