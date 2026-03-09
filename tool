-- HaiHub Enhanced v4.4 - Full Under TP + FullBright

-- ✅ Full Features Restored (Combat, ESP, Movement, Graphics, Server, etc.)

-- ✅ Modified Player TP to float under target (With Slider)

-- ✅ Added FullBright (Night Vision) for horror games



local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()



local Window = Fluent:CreateWindow({

    Title = "HaiHub Enhanced",

    SubTitle = "v4.4 - FullBright Edition",

    TabWidth = 160,

    Size = UDim2.fromOffset(580, 460),

    Acrylic = true,

    Theme = "Dark",

    MinimizeKey = Enum.KeyCode.LeftControl

})



local Tabs = {

    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }), 

    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),

    PlayerTP = Window:AddTab({ Title = "Player TP", Icon = "users" }),

    Waypoints = Window:AddTab({ Title = "Waypoints", Icon = "map-pin" }),

    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),

    Camera = Window:AddTab({ Title = "Camera", Icon = "camera" }),

    Performance = Window:AddTab({ Title = "Performance", Icon = "activity" }),

    Position = Window:AddTab({ Title = "Position", Icon = "compass" }),

    Graphics = Window:AddTab({ Title = "Graphics", Icon = "image" }),

    Server = Window:AddTab({ Title = "Server", Icon = "server" }),

    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })

}



local Options = Fluent.Options



--[[ COMBAT TAB (REMASTERED AIMBOT - GOD MODE LOCK) ]]--

do

    local Players = game:GetService("Players")

    local RunService = game:GetService("RunService")

    local UserInputService = game:GetService("UserInputService")

    local Workspace = game:GetService("Workspace")

    local Camera = Workspace.CurrentCamera

    local LP = Players.LocalPlayer

    local Mouse = LP:GetMouse()



    local aimbot = {

        enabled = false,

        locking = false,

        target = nil,

        part = "Head",

        fov = 120,

        smoothness = 0.5, -- 0 = Instant, 1 = Very Slow

        prediction = 0.135, -- ค่ามาตรฐานสำหรับ Roblox

        usePrediction = true,

        teamCheck = true,

        wallCheck = true,

        showFOV = true,

        key = Enum.UserInputType.MouseButton2

    }



    -- FOV Circle

    local fovCircle = Drawing.new("Circle")

    fovCircle.Color = Color3.fromRGB(255, 255, 255)

    fovCircle.Thickness = 1

    fovCircle.NumSides = 90

    fovCircle.Radius = aimbot.fov

    fovCircle.Visible = false

    fovCircle.Filled = false

    fovCircle.Transparency = 1



    -- Check Wall

    local function isVisible(target, part)

        if not aimbot.wallCheck then return true end

        local origin = Camera.CFrame.Position

        local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude

        local raycastParams = RaycastParams.new()

        raycastParams.FilterDescendantsInstances = {LP.Character, Camera}

        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        

        local result = Workspace:Raycast(origin, direction, raycastParams)

        if result then

            return result.Instance:IsDescendantOf(target)

        end

        return false -- ถ้า Raycast ไม่ชนอะไรเลยในระยะ แปลว่ามองเห็น (หรือระยะไกลมาก) แต่ปลอดภัยไว้ก่อนคือ false ถ้าไม่ hit target

    end



    -- Get Closest Target

    local function getTarget()

        local bestTarget = nil

        local bestDist = aimbot.fov



        for _, player in pairs(Players:GetPlayers()) do

            if player ~= LP and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild(aimbot.part) then

                

                -- Team Check

                if aimbot.teamCheck and player.Team == LP.Team then continue end



                local targetPart = player.Character[aimbot.part]

                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                

                if onScreen then

                    local mousePos = UserInputService:GetMouseLocation()

                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude



                    if dist < bestDist then

                        if isVisible(player.Character, targetPart) then

                            bestTarget = player.Character

                            bestDist = dist

                        end

                    end

                end

            end

        end

        return bestTarget

    end



    -- Aimbot Loop

    RunService.RenderStepped:Connect(function()

        -- Update FOV

        fovCircle.Visible = aimbot.showFOV and aimbot.enabled

        fovCircle.Radius = aimbot.fov

        fovCircle.Position = UserInputService:GetMouseLocation()



        if aimbot.enabled and aimbot.locking then

            -- ถ้าเป้าหมายตาย หรือหายไป ให้หาใหม่ หรือถ้ายังไม่มีเป้าหมาย

            if not aimbot.target or not aimbot.target:FindFirstChild("Humanoid") or aimbot.target.Humanoid.Health <= 0 then

                aimbot.target = getTarget()

            end



            if aimbot.target and aimbot.target:FindFirstChild(aimbot.part) then

                local targetPart = aimbot.target[aimbot.part]

                

                -- คำนวณตำแหน่ง (Prediction Logic)

                local targetPos = targetPart.Position

                if aimbot.usePrediction and aimbot.target:FindFirstChild("HumanoidRootPart") then

                    local velocity = aimbot.target.HumanoidRootPart.AssemblyLinearVelocity

                    targetPos = targetPos + (velocity * aimbot.prediction)

                end



                -- Wall Check ซ้ำอีกรอบเพื่อความชัวร์ตอนล็อคค้าง

                if isVisible(aimbot.target, targetPart) then

                    local currentCF = Camera.CFrame

                    local targetCF = CFrame.lookAt(currentCF.Position, targetPos)

                    

                    -- Smoothness Logic (Inverse: Slider สูง = ช้า/เนียน, Slider ต่ำ = เร็ว)

                    -- แปลงค่า Smoothness จาก UI (0-1) ให้ใช้งานได้จริง

                    -- UI: 1 = ช้ามาก (Alpha ต่ำ), 0 = เร็วมาก (Alpha สูง)

                    local sensitivity = 1 - aimbot.smoothness

                    if sensitivity < 0.05 then sensitivity = 0.05 end -- กันค้าง



                    Camera.CFrame = currentCF:Lerp(targetCF, sensitivity)

                else

                    -- ถ้าศัตรูวิ่งเข้ากำแพง ปล่อยล็อค

                    aimbot.target = nil

                end

            end

        else

            aimbot.target = nil

        end

    end)



    -- Input Handling

    UserInputService.InputBegan:Connect(function(input, gameProcessed)

        if not aimbot.enabled or gameProcessed then return end

        if input.UserInputType == aimbot.key or input.KeyCode == aimbot.key then

            aimbot.locking = true

        end

    end)



    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == aimbot.key or input.KeyCode == aimbot.key then

            aimbot.locking = false

            aimbot.target = nil -- Reset target when key released

        end

    end)



    -- UI Construction

    Tabs.Combat:AddParagraph({

        Title = "🎯 God Mode Aimbot",

        Content = "ระบบล็อคเป้าใหม่! ล็อคแม่นกว่าเดิม พร้อมระบบคำนวณทิศทาง (Prediction)"

    })



    local AimbotToggle = Tabs.Combat:AddToggle("AimbotToggle", {

        Title = "Enable Aimbot",

        Default = false

    })

    AimbotToggle:OnChanged(function(Value) aimbot.enabled = Value end)



    local FOVToggle = Tabs.Combat:AddToggle("ShowFOV", {

        Title = "Show FOV",

        Default = true

    })

    FOVToggle:OnChanged(function(Value) aimbot.showFOV = Value end)



    local TeamCheckToggle = Tabs.Combat:AddToggle("TeamCheck", {

        Title = "Team Check",

        Default = true

    })

    TeamCheckToggle:OnChanged(function(Value) aimbot.teamCheck = Value end)



    local WallCheckToggle = Tabs.Combat:AddToggle("WallCheck", {

        Title = "Wall Check",

        Default = true

    })

    WallCheckToggle:OnChanged(function(Value) aimbot.wallCheck = Value end)



    -- Prediction Settings

    local PredToggle = Tabs.Combat:AddToggle("PredToggle", {

        Title = "Use Prediction",

        Description = "คำนวณทิศทางล่วงหน้า (แก้ปัญหายิงไม่โดนตอนวิ่ง)",

        Default = true

    })

    PredToggle:OnChanged(function(Value) aimbot.usePrediction = Value end)



    Tabs.Combat:AddSlider("PredAmount", {

        Title = "Prediction Amount",

        Description = "ความไกลในการเผื่อเป้า (0.135 คือค่ามาตรฐาน)",

        Default = 0.135,

        Min = 0.01,

        Max = 0.5,

        Rounding = 3,

        Callback = function(Value) aimbot.prediction = Value end

    })



    -- General Settings

    Tabs.Combat:AddDropdown("TargetPart", {

        Title = "Target Part",

        Values = {"Head", "UpperTorso", "HumanoidRootPart"},

        Default = 1,

        Callback = function(Value) aimbot.part = Value end

    })



    Tabs.Combat:AddSlider("FOVRadius", {

        Title = "FOV Radius",

        Default = 120,

        Min = 10,

        Max = 800,

        Rounding = 0,

        Callback = function(Value) aimbot.fov = Value end

    })



    Tabs.Combat:AddSlider("Smoothness", {

        Title = "Smoothness",

        Description = "ความเนียน (0 = ล็อคทันที / 1 = ล็อคช้าๆ)",

        Default = 0.5,

        Min = 0,

        Max = 0.95,

        Rounding = 2,

        Callback = function(Value) aimbot.smoothness = Value end

    })



    Tabs.Combat:AddKeybind("AimbotKey", {

        Title = "Aimbot Key",

        Mode = "Hold",

        Default = "MouseButton2",

        ChangedCallback = function(New) aimbot.key = New end

    })

end



--[[ ESP TAB (REMASTERED FOR REAL-TIME + COLOR PICKER) ]]--

do

    local Players = game:GetService("Players")

    local RunService = game:GetService("RunService")

    local LP = Players.LocalPlayer



    local espState = {

        enabled = false,

        refreshRate = 0, -- 0 = Realtime (RenderStepped)

        connections = {}

    }



    Tabs.ESP:AddParagraph({

        Title = "👁️ Real-time ESP",

        Content = "มองทะลุกำแพง เห็นทุกคน 100%\nเช็คแบบ Real-time (คนเข้าใหม่/เกิดใหม่ เห็นหมด)"

    })



    local ESPToggle = Tabs.ESP:AddToggle("ESPToggle", {

        Title = "Enable ESP",

        Description = "เปิด/ปิด การมองเห็นผู้เล่น",

        Default = false

    })



    local ESPColor = Tabs.ESP:AddColorpicker("ESPColor", {

        Title = "ESP Fill Color",

        Description = "เลือกสีของตัวละคร",

        Default = Color3.fromRGB(255, 0, 0)

    })



    local ESPOutlineColor = Tabs.ESP:AddColorpicker("ESPOutlineColor", {

        Title = "ESP Outline Color",

        Description = "เลือกสีขอบ",

        Default = Color3.fromRGB(255, 255, 255)

    })



    -- ฟังก์ชันสร้าง Highlight

    local function createHighlight(character)

        if not character then return end

        

        -- ลบอันเก่าถ้ามี

        local old = character:FindFirstChild("HaiHubESP")

        if old then old:Destroy() end



        local highlight = Instance.new("Highlight")

        highlight.Name = "HaiHubESP"

        highlight.Adornee = character

        highlight.FillColor = Options.ESPColor.Value -- ใช้ค่าสีจาก Colorpicker

        highlight.OutlineColor = Options.ESPOutlineColor.Value -- ใช้ค่าสีขอบจาก Colorpicker

        highlight.FillTransparency = 0.5

        highlight.OutlineTransparency = 0

        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- มองทะลุกำแพง

        highlight.Parent = character

    end



    -- อัพเดทสีทันทีเมื่อมีการเปลี่ยนแปลง

    ESPColor:OnChanged(function()

        for _, player in pairs(Players:GetPlayers()) do

            if player.Character then

                local hl = player.Character:FindFirstChild("HaiHubESP")

                if hl then

                    hl.FillColor = Options.ESPColor.Value

                end

            end

        end

    end)



    ESPOutlineColor:OnChanged(function()

        for _, player in pairs(Players:GetPlayers()) do

            if player.Character then

                local hl = player.Character:FindFirstChild("HaiHubESP")

                if hl then

                    hl.OutlineColor = Options.ESPOutlineColor.Value

                end

            end

        end

    end)



    -- ฟังก์ชันอัพเดท ESP (Core Loop)

    local function updateESP()

        if not espState.enabled then return end

        

        for _, player in pairs(Players:GetPlayers()) do

            if player ~= LP and player.Character then

                local char = player.Character

                -- เช็คว่ามี ESP หรือยัง ถ้าไม่มีให้สร้างใหม่ทันที

                if not char:FindFirstChild("HaiHubESP") then

                    createHighlight(char)

                end

            end

        end

    end



    local function startESP()

        if espState.enabled then return end

        espState.enabled = true



        -- Loop 1: ดักจับผู้เล่นใหม่

        table.insert(espState.connections, Players.PlayerAdded:Connect(function(player)

            player.CharacterAdded:Connect(function(character)

                if espState.enabled then

                    task.wait(0.2) -- รอโหลดโมเดลแปปนึง

                    createHighlight(character)

                end

            end)

        end))



        -- Loop 2: ดักจับตัวละครที่เกิดใหม่ของผู้เล่นที่มีอยู่แล้ว

        for _, player in pairs(Players:GetPlayers()) do

            if player ~= LP then

                table.insert(espState.connections, player.CharacterAdded:Connect(function(character)

                    if espState.enabled then

                        task.wait(0.2)

                        createHighlight(character)

                    end

                end))

                -- สร้างให้คนที่ยืนอยู่แล้วทันที

                if player.Character then

                    createHighlight(player.Character)

                end

            end

        end



        -- Loop 3: Real-time Checker (กันพลาด)

        -- เช็คทุกเฟรมเพื่อให้แน่ใจว่าทุกคนมี Highlight ตลอดเวลา

        table.insert(espState.connections, RunService.Stepped:Connect(function()

            updateESP()

        end))

        

        Fluent:Notify({ Title = "ESP", Content = "ESP เปิดใช้งาน (Real-time Mode)", Duration = 2 })

    end



    local function stopESP()

        espState.enabled = false

        

        -- ลบ Connection ทั้งหมด

        for _, conn in pairs(espState.connections) do

            conn:Disconnect()

        end

        espState.connections = {}



        -- ลบ Highlight ทั้งหมด

        for _, player in pairs(Players:GetPlayers()) do

            if player.Character then

                local hl = player.Character:FindFirstChild("HaiHubESP")

                if hl then hl:Destroy() end

            end

        end

        

        Fluent:Notify({ Title = "ESP", Content = "ESP ปิดใช้งาน", Duration = 2 })

    end



    ESPToggle:OnChanged(function()

        if Options.ESPToggle.Value then 

            startESP() 

        else 

            stopESP() 

        end

    end)

end



--[[ PLAYER TELEPORT TAB (MODIFIED FOR UNDER TP) ]]--

do

    local Players = game:GetService("Players")

    local TweenService = game:GetService("TweenService")

    local LP = Players.LocalPlayer



    local tpState = {

        followEnabled = false,

        followTarget = nil,

        offsetY = 5, -- ค่าเริ่มต้นระยะห่าง (Under Distance)

    }



    local function getPlayerList()

        local list = {}

        for _, player in pairs(Players:GetPlayers()) do

            if player ~= LP then table.insert(list, player.Name) end

        end

        return list

    end



    local function teleportToPlayer(targetPlayer, instant)

        if not targetPlayer or not targetPlayer.Character then

            Fluent:Notify({ Title = "Player TP", Content = "ไม่พบผู้เล่นหรือตัวละคร", Duration = 3 })

            return

        end



        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")



        if not targetRoot or not myRoot then

            Fluent:Notify({ Title = "Player TP", Content = "ไม่สามารถวาปได้", Duration = 3 })

            return

        end



        -- คำนวณ CFrame ให้ไปอยู่ใต้เท้า (ลบ Y) ตามระยะที่ตั้งไว้

        local targetCFrame = targetRoot.CFrame * CFrame.new(0, -tpState.offsetY, 0)



        if instant then

            myRoot.CFrame = targetCFrame

        else

            local distance = (myRoot.Position - targetCFrame.Position).Magnitude

            local time = distance / 150

            local tween = TweenService:Create(myRoot, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCFrame})

            tween:Play()

        end

        Fluent:Notify({ Title = "Player TP", Content = "วาปไปใต้เท้า " .. targetPlayer.Name, Duration = 2 })

    end



    local function startFollowPlayer(targetPlayer)

        if tpState.followEnabled then tpState.followEnabled = false task.wait(0.2) end

        if not targetPlayer or not targetPlayer.Character then

            Fluent:Notify({ Title = "Player TP", Content = "ไม่พบผู้เล่น", Duration = 3 })

            return

        end



        tpState.followEnabled = true

        tpState.followTarget = targetPlayer



        task.spawn(function()

            while tpState.followEnabled and tpState.followTarget do

                local targetRoot = tpState.followTarget.Character and tpState.followTarget.Character:FindFirstChild("HumanoidRootPart")

                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

                

                if targetRoot and myRoot then 

                    -- วาปตามใต้เท้าตลอดเวลา

                    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, -tpState.offsetY, 0) 

                end

                task.wait() -- เร็วขึ้นเพื่อให้ติดเท้าเนียนๆ

            end

        end)

        Fluent:Notify({ Title = "Player TP", Content = "กำลังติดตามใต้เท้า " .. targetPlayer.Name, Duration = 3 })

    end



    local function stopFollowPlayer()

        if not tpState.followEnabled then return end

        tpState.followEnabled = false

        tpState.followTarget = nil

        Fluent:Notify({ Title = "Player TP", Content = "หยุดติดตาม", Duration = 2 })

    end



    Tabs.PlayerTP:AddParagraph({

        Title = "Player Teleport (Under Feet)",

        Content = "วาปไปหาผู้เล่นโดยลอยอยู่ใต้เท้า (Under Map)\nสามารถปรับระยะความลึกได้"

    })



    local PlayerDropdown = Tabs.PlayerTP:AddDropdown("PlayerSelect", {

        Title = "เลือกผู้เล่น",

        Values = getPlayerList(),

        Multi = false,

        Default = 1,

    })



    Players.PlayerAdded:Connect(function() task.wait(0.5) PlayerDropdown:SetValues(getPlayerList()) end)

    Players.PlayerRemoving:Connect(function() task.wait(0.5) PlayerDropdown:SetValues(getPlayerList()) end)



    Tabs.PlayerTP:AddButton({

        Title = "Refresh Player List",

        Description = "อัพเดทรายชื่อผู้เล่น",

        Callback = function()

            PlayerDropdown:SetValues(getPlayerList())

            Fluent:Notify({ Title = "Player TP", Content = "อัพเดทรายชื่อแล้ว", Duration = 2 })

        end

    })



    -- Slider สำหรับปรับระยะความลึก

    Tabs.PlayerTP:AddSlider("TPHeightOffset", {

        Title = "Under Distance (Studs)",

        Description = "ระยะห่างใต้เท้า (ยิ่งมากยิ่งลึก)",

        Default = 5,

        Min = 0,

        Max = 50,

        Rounding = 1,

        Callback = function(Value)

            tpState.offsetY = Value

        end

    })



    Tabs.PlayerTP:AddButton({

        Title = "Teleport (Instant)",

        Description = "วาปไปใต้เท้าทันที",

        Callback = function()

            local selectedName = Options.PlayerSelect.Value

            if selectedName then teleportToPlayer(Players:FindFirstChild(selectedName), true) end

        end

    })



    Tabs.PlayerTP:AddButton({

        Title = "Teleport (Smooth)",

        Description = "วาปไปใต้เท้าแบบนุ่มนวล",

        Callback = function()

            local selectedName = Options.PlayerSelect.Value

            if selectedName then teleportToPlayer(Players:FindFirstChild(selectedName), false) end

        end

    })



    local FollowToggle = Tabs.PlayerTP:AddToggle("FollowToggle", {

        Title = "Follow Player (Under)",

        Description = "ติดตามใต้เท้าผู้เล่นอัตโนมัติ",

        Default = false

    })



    FollowToggle:OnChanged(function()

        if Options.FollowToggle.Value then

            local selectedName = Options.PlayerSelect.Value

            if selectedName then startFollowPlayer(Players:FindFirstChild(selectedName))

            else Options.FollowToggle:SetValue(false) end

        else stopFollowPlayer() end

    end)

end



--[[ WAYPOINTS TAB ]]--

do

    local Players = game:GetService("Players")

    local TweenService = game:GetService("TweenService")

    local LP = Players.LocalPlayer



    local waypoints = {

        [1] = { name = "Waypoint 1", position = nil, set = false },

        [2] = { name = "Waypoint 2", position = nil, set = false },

        [3] = { name = "Waypoint 3", position = nil, set = false },

        [4] = { name = "Waypoint 4", position = nil, set = false },

        [5] = { name = "Waypoint 5", position = nil, set = false },

    }



    local waypointDisplays = {}

    local selectedWaypoint = 1



    local function getCurrentPosition()

        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then

            return LP.Character.HumanoidRootPart.CFrame

        end

        return nil

    end



    local function teleportToWaypoint(index, instant)

        if not waypoints[index] or not waypoints[index].set then

            Fluent:Notify({ Title = "Waypoints", Content = "หมุด " .. index .. " ยังไม่ได้ตั้งค่า!", Duration = 3 })

            return

        end



        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

        if not myRoot then

            Fluent:Notify({ Title = "Waypoints", Content = "ไม่พบตัวละคร", Duration = 3 })

            return

        end



        local targetCFrame = waypoints[index].position



        if instant then

            myRoot.CFrame = targetCFrame

        else

            local distance = (myRoot.Position - targetCFrame.Position).Magnitude

            local speed = 150

            local time = distance / speed

            local tween = TweenService:Create(myRoot, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCFrame})

            tween:Play()

        end



        Fluent:Notify({ Title = "Waypoints", Content = "วาปไปหมุด " .. index .. " (" .. waypoints[index].name .. ")", Duration = 2 })

    end



    local function setWaypoint(index)

        local pos = getCurrentPosition()

        if not pos then

            Fluent:Notify({ Title = "Waypoints", Content = "ไม่สามารถบันทึกตำแหน่งได้", Duration = 3 })

            return

        end



        waypoints[index].position = pos

        waypoints[index].set = true



        local posVec = pos.Position

        local posStr = string.format("X: %.1f, Y: %.1f, Z: %.1f", posVec.X, posVec.Y, posVec.Z)



        if waypointDisplays[index] then

            waypointDisplays[index]:SetDesc("✅ " .. posStr)

        end



        Fluent:Notify({ Title = "Waypoints", Content = "บันทึกหมุด " .. index .. " แล้ว!\n" .. posStr, Duration = 3 })

    end



    local function clearWaypoint(index)

        waypoints[index].position = nil

        waypoints[index].set = false



        if waypointDisplays[index] then

            waypointDisplays[index]:SetDesc("❌ ยังไม่ได้ตั้งค่า")

        end



        Fluent:Notify({ Title = "Waypoints", Content = "ลบหมุด " .. index .. " แล้ว", Duration = 2 })

    end



    local function clearAllWaypoints()

        for i = 1, 5 do

            waypoints[i].position = nil

            waypoints[i].set = false

            if waypointDisplays[i] then

                waypointDisplays[i]:SetDesc("❌ ยังไม่ได้ตั้งค่า")

            end

        end

        Fluent:Notify({ Title = "Waypoints", Content = "ลบหมุดทั้งหมดแล้ว", Duration = 2 })

    end



    Tabs.Waypoints:AddParagraph({

        Title = "🗺️ Waypoint System",

        Content = "ระบบปักหมุด 5 จุด\nบันทึกตำแหน่งและวาปกลับได้ตลอดเวลา"

    })



    local WaypointDropdown = Tabs.Waypoints:AddDropdown("WaypointSelect", {

        Title = "เลือกหมุด",

        Values = {"Waypoint 1", "Waypoint 2", "Waypoint 3", "Waypoint 4", "Waypoint 5"},

        Multi = false,

        Default = 1,

    })



    WaypointDropdown:OnChanged(function(Value)

        for i = 1, 5 do

            if Value == "Waypoint " .. i then

                selectedWaypoint = i

                break

            end

        end

    end)



    Tabs.Waypoints:AddButton({

        Title = "📍 ปักหมุดตำแหน่งปัจจุบัน",

        Description = "บันทึกตำแหน่งปัจจุบันไปยังหมุดที่เลือก",

        Callback = function()

            setWaypoint(selectedWaypoint)

        end

    })



    Tabs.Waypoints:AddButton({

        Title = "⚡ วาปไปหมุด (ทันที)",

        Description = "วาปไปยังหมุดที่เลือกแบบทันที",

        Callback = function()

            teleportToWaypoint(selectedWaypoint, true)

        end

    })



    Tabs.Waypoints:AddButton({

        Title = "🌊 วาปไปหมุด (Smooth)",

        Description = "วาปไปยังหมุดที่เลือกแบบนุ่มนวล",

        Callback = function()

            teleportToWaypoint(selectedWaypoint, false)

        end

    })



    Tabs.Waypoints:AddButton({

        Title = "🗑️ ลบหมุดที่เลือก",

        Description = "ลบหมุดที่เลือกอยู่",

        Callback = function()

            clearWaypoint(selectedWaypoint)

        end

    })



    Tabs.Waypoints:AddButton({

        Title = "🗑️ ลบหมุดทั้งหมด",

        Description = "ลบหมุดทั้ง 5 จุด",

        Callback = function()

            clearAllWaypoints()

        end

    })



    Tabs.Waypoints:AddParagraph({

        Title = "📋 สถานะหมุดทั้งหมด",

        Content = "ดูตำแหน่งที่บันทึกไว้"

    })



    for i = 1, 5 do

        waypointDisplays[i] = Tabs.Waypoints:AddParagraph({

            Title = "หมุด " .. i,

            Content = "❌ ยังไม่ได้ตั้งค่า"

        })

    end

end



--[[ MOVEMENT TAB (ADDED SPEED & INF JUMP) ]]--

do

    local Players = game:GetService("Players")

    local RunService = game:GetService("RunService")

    local UIS = game:GetService("UserInputService")

    local TweenService = game:GetService("TweenService")

    local LP = Players.LocalPlayer



    -- ========== WALKSPEED (NEW) ==========

    local speedState = {

        enabled = false,

        speed = 16,

        connection = nil

    }



    local function toggleSpeed(state)

        speedState.enabled = state

        if state then

            -- ใช้ Heartbeat เพื่อล็อคความเร็วตลอดเวลา (กันเกมปรับคืน)

            speedState.connection = RunService.Heartbeat:Connect(function()

                if LP.Character and LP.Character:FindFirstChild("Humanoid") then

                    LP.Character.Humanoid.WalkSpeed = speedState.speed

                end

            end)

        else

            if speedState.connection then 

                speedState.connection:Disconnect() 

                speedState.connection = nil

            end

            if LP.Character and LP.Character:FindFirstChild("Humanoid") then

                LP.Character.Humanoid.WalkSpeed = 16 -- คืนค่าปกติ

            end

        end

    end



    -- ========== INFINITE JUMP (NEW) ==========

    local infJumpEnabled = false

    local infJumpConnection = nil



    local function toggleInfJump(state)

        infJumpEnabled = state

        if state then

            infJumpConnection = UIS.JumpRequest:Connect(function()

                if LP.Character and LP.Character:FindFirstChild("Humanoid") then

                    LP.Character.Humanoid:ChangeState("Jumping")

                end

            end)

        else

            if infJumpConnection then 

                infJumpConnection:Disconnect() 

                infJumpConnection = nil

            end

        end

    end



    -- ========== UI for Speed & Jump ==========

    Tabs.Movement:AddParagraph({

        Title = "⚡ Character Modifiers",

        Content = "ปรับความเร็วและกระโดด"

    })



    local SpeedToggle = Tabs.Movement:AddToggle("SpeedToggle", {

        Title = "Enable WalkSpeed",

        Description = "เปิด/ปิด การวิ่งไว",

        Default = false

    })



    local SpeedSlider = Tabs.Movement:AddSlider("SpeedValue", {

        Title = "Speed Value",

        Description = "ปรับระดับความเร็ว",

        Default = 50,

        Min = 16,

        Max = 500, -- Already 500

        Rounding = 0,

        Callback = function(Value)

            speedState.speed = Value

        end

    })



    SpeedToggle:OnChanged(function()

        toggleSpeed(Options.SpeedToggle.Value)

    end)



    local InfJumpToggle = Tabs.Movement:AddToggle("InfJumpToggle", {

        Title = "Infinite Jump",

        Description = "กระโดดกลางอากาศได้ไม่จำกัด",

        Default = false

    })



    InfJumpToggle:OnChanged(function()

        toggleInfJump(Options.InfJumpToggle.Value)

    end)



    -- ========== ENHANCED NOCLIP ==========

    local noClipState = {

        enabled = false,

        connections = {},

        antiFling = true,

    }



    local function startNoClip()

        if noClipState.enabled then return end

        noClipState.enabled = true



        -- Main NoClip Loop

        table.insert(noClipState.connections, RunService.Stepped:Connect(function()

            if LP.Character then

                for _, part in pairs(LP.Character:GetDescendants()) do

                    if part:IsA("BasePart") then

                        part.CanCollide = false

                    end

                end

            end

        end))



        -- Anti-Fling System

        if noClipState.antiFling then

            table.insert(noClipState.connections, RunService.Heartbeat:Connect(function()

                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then

                    local hrp = LP.Character.HumanoidRootPart

                    if hrp.AssemblyLinearVelocity.Magnitude > 150 then

                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

                    end

                end

            end))

        end



        Fluent:Notify({ Title = "NoClip", Content = "NoClip เปิดแล้ว! ทะลุกำแพงได้\n✅ Anti-Fling", Duration = 3 })

    end



    local function stopNoClip()

        if not noClipState.enabled then return end

        noClipState.enabled = false



        for _, conn in pairs(noClipState.connections) do

            conn:Disconnect()

        end

        noClipState.connections = {}



        if LP.Character then

            for _, part in pairs(LP.Character:GetDescendants()) do

                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then

                    part.CanCollide = true

                end

            end

        end



        Fluent:Notify({ Title = "NoClip", Content = "NoClip ปิดแล้ว", Duration = 2 })

    end



    -- ========== NORMAL FLY (BodyVelocity) ==========

    local normalFly = {

        enabled = false,

        speed = 50,

        bv = nil,

        bg = nil,

        connections = {},

        keys = {W=false,A=false,S=false,D=false,Space=false,LeftShift=false},

    }



    local function startNormalFly()

        if normalFly.enabled then return end

        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end

        

        normalFly.enabled = true

        local hrp = LP.Character.HumanoidRootPart

        local hum = LP.Character:FindFirstChildOfClass("Humanoid")



        if hum then

            hum.PlatformStand = true

        end



        normalFly.bv = Instance.new("BodyVelocity")

        normalFly.bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        normalFly.bv.Velocity = Vector3.new(0, 0, 0)

        normalFly.bv.Parent = hrp



        normalFly.bg = Instance.new("BodyGyro")

        normalFly.bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

        normalFly.bg.CFrame = hrp.CFrame

        normalFly.bg.Parent = hrp



        table.insert(normalFly.connections, RunService.Heartbeat:Connect(function()

            if not normalFly.enabled or not hrp.Parent then return end

            

            local cam = workspace.CurrentCamera

            local dir = Vector3.new()

            

            if normalFly.keys.W then dir += cam.CFrame.LookVector end

            if normalFly.keys.S then dir -= cam.CFrame.LookVector end

            if normalFly.keys.D then dir += cam.CFrame.RightVector end

            if normalFly.keys.A then dir -= cam.CFrame.RightVector end

            

            if dir.Magnitude > 0 then dir = dir.Unit end

            

            local upDown = 0

            if normalFly.keys.Space then upDown += 1 end

            if normalFly.keys.LeftShift then upDown -= 1 end

            

            normalFly.bv.Velocity = (dir * normalFly.speed) + Vector3.new(0, upDown * normalFly.speed, 0)

            normalFly.bg.CFrame = cam.CFrame

        end))



        Fluent:Notify({ Title = "Normal Fly", Content = "บินแบบปกติเปิดแล้ว!\nWSAD + Space/Shift", Duration = 3 })

    end



    local function stopNormalFly()

        if not normalFly.enabled then return end

        normalFly.enabled = false



        for _, conn in pairs(normalFly.connections) do

            conn:Disconnect()

        end

        normalFly.connections = {}



        if normalFly.bv then normalFly.bv:Destroy() normalFly.bv = nil end

        if normalFly.bg then normalFly.bg:Destroy() normalFly.bg = nil end



        if LP.Character then

            local hum = LP.Character:FindFirstChildOfClass("Humanoid")

            if hum then

                hum.PlatformStand = false

            end

        end



        Fluent:Notify({ Title = "Normal Fly", Content = "บินแบบปกติปิดแล้ว", Duration = 2 })

    end



    -- ========== TWEEN FLY ==========

    local tweenFly = {

        enabled = false,

        speed = 80,

        step = 0.06,

        keys = {W=false,A=false,S=false,D=false,Up=false,Down=false},

        root = nil,

        hum = nil,

        drive = nil,

        tweenConn = nil,

    }



    local function bindCharacter(char)

        tweenFly.hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 10)

        tweenFly.root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 10)

    end



    bindCharacter(LP.Character or LP.CharacterAdded:Wait())



    LP.CharacterAdded:Connect(function(char)

        task.wait(0.5)

        bindCharacter(char)

        if tweenFly.enabled then

            tweenFly.enabled = false

            task.wait(0.5)

            startTweenFly()

        end

        if noClipState.enabled then

            noClipState.enabled = false

            startNoClip()

        end

        if normalFly.enabled then

            normalFly.enabled = false

            task.wait(0.5)

            startNormalFly()

        end

        if speedState.enabled then

            toggleSpeed(true)

        end

    end)



    local function getDirs()

        local cam = workspace.CurrentCamera

        local look = cam.CFrame.LookVector

        local right = cam.CFrame.RightVector

        local flatLook = Vector3.new(look.X, 0, look.Z)

        local flatRight = Vector3.new(right.X, 0, right.Z)

        if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end

        if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end



        local dir = Vector3.zero

        if tweenFly.keys.W then dir += flatLook end

        if tweenFly.keys.S then dir -= flatLook end

        if tweenFly.keys.D then dir += flatRight end

        if tweenFly.keys.A then dir -= flatRight end

        if dir.Magnitude > 0 then dir = dir.Unit end



        local up = 0

        if tweenFly.keys.Up then up += 1 end

        if tweenFly.keys.Down then up -= 1 end



        return dir, up, flatLook

    end



    function startTweenFly()

        if tweenFly.enabled or not tweenFly.root or not tweenFly.hum then return end

        tweenFly.enabled = true



        pcall(function()

            tweenFly.hum.AutoRotate = false

            tweenFly.hum.WalkSpeed = 0

            tweenFly.hum.JumpPower = 0

        end)



        local prevAnchor = tweenFly.root.Anchored

        tweenFly.root.Anchored = true



        if tweenFly.drive then pcall(function() tweenFly.drive:Destroy() end) end

        tweenFly.drive = Instance.new("CFrameValue")

        tweenFly.drive.Value = tweenFly.root.CFrame



        tweenFly.tweenConn = tweenFly.drive.Changed:Connect(function(cf)

            if tweenFly.root then tweenFly.root.CFrame = cf end

        end)



        task.spawn(function()

            while tweenFly.enabled and tweenFly.root and tweenFly.drive do

                local dir, up, flatLook = getDirs()

                local pos = tweenFly.drive.Value.Position

                local delta = (dir * tweenFly.speed + Vector3.new(0, up * tweenFly.speed, 0)) * tweenFly.step

                local targetPos = pos + delta

                local targetCF = CFrame.lookAt(targetPos, targetPos + (flatLook.Magnitude>0 and flatLook or Vector3.new(0,0,-1)))



                local tw = TweenService:Create(tweenFly.drive, TweenInfo.new(tweenFly.step, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = targetCF})

                tw:Play()



                task.wait(tweenFly.step * 0.95)

            end

            pcall(function() tweenFly.root.Anchored = prevAnchor end)

        end)



        Fluent:Notify({ Title = "Tween Fly", Content = "Tween Fly เปิดแล้ว!\nWSAD + Space/Alt", Duration = 3 })

    end



    local function stopTweenFly()

        if not tweenFly.enabled then return end

        tweenFly.enabled = false



        pcall(function()

            if tweenFly.tweenConn then tweenFly.tweenConn:Disconnect() end

            tweenFly.tweenConn = nil

        end)



        pcall(function() if tweenFly.drive then tweenFly.drive:Destroy() end end)



        pcall(function()

            tweenFly.hum.AutoRotate = true

            tweenFly.hum.WalkSpeed = 16

            tweenFly.hum.JumpPower = 50

        end)



        Fluent:Notify({ Title = "Tween Fly", Content = "Tween Fly ปิดแล้ว", Duration = 2 })

    end



    -- Input handling for both fly modes

    UIS.InputBegan:Connect(function(inp, gameProcessed)

        if gameProcessed then return end

        local kc = inp.KeyCode

        

        -- Normal Fly keys

        if kc == Enum.KeyCode.W then normalFly.keys.W = true

        elseif kc == Enum.KeyCode.A then normalFly.keys.A = true

        elseif kc == Enum.KeyCode.S then normalFly.keys.S = true

        elseif kc == Enum.KeyCode.D then normalFly.keys.D = true

        elseif kc == Enum.KeyCode.Space then normalFly.keys.Space = true

        elseif kc == Enum.KeyCode.LeftShift then normalFly.keys.LeftShift = true

        end

        

        -- Tween Fly keys

        if kc == Enum.KeyCode.W then tweenFly.keys.W = true

        elseif kc == Enum.KeyCode.A then tweenFly.keys.A = true

        elseif kc == Enum.KeyCode.S then tweenFly.keys.S = true

        elseif kc == Enum.KeyCode.D then tweenFly.keys.D = true

        elseif kc == Enum.KeyCode.Space then tweenFly.keys.Up = true

        elseif kc == Enum.KeyCode.LeftAlt then tweenFly.keys.Down = true

        end

    end)



    UIS.InputEnded:Connect(function(inp, gameProcessed)

        local kc = inp.KeyCode

        

        -- Normal Fly keys

        if kc == Enum.KeyCode.W then normalFly.keys.W = false

        elseif kc == Enum.KeyCode.A then normalFly.keys.A = false

        elseif kc == Enum.KeyCode.S then normalFly.keys.S = false

        elseif kc == Enum.KeyCode.D then normalFly.keys.D = false

        elseif kc == Enum.KeyCode.Space then normalFly.keys.Space = false

        elseif kc == Enum.KeyCode.LeftShift then normalFly.keys.LeftShift = false

        end

        

        -- Tween Fly keys

        if kc == Enum.KeyCode.W then tweenFly.keys.W = false

        elseif kc == Enum.KeyCode.A then tweenFly.keys.A = false

        elseif kc == Enum.KeyCode.S then tweenFly.keys.S = false

        elseif kc == Enum.KeyCode.D then tweenFly.keys.D = false

        elseif kc == Enum.KeyCode.Space then tweenFly.keys.Up = false

        elseif kc == Enum.KeyCode.LeftAlt then tweenFly.keys.Down = false

        end

    end)



    -- UI Elements for Flight/NoClip

    Tabs.Movement:AddParagraph({

        Title = "🚫 Enhanced NoClip",

        Content = "ทะลุกำแพงและวัตถุทั้งหมด + Anti-Fling\nเดินผ่านทุกอย่างได้อย่างปลอดภัย"

    })



    local NoClipToggle = Tabs.Movement:AddToggle("NoClipToggle", {

        Title = "Enable NoClip",

        Description = "เปิด/ปิดโหมดทะลุกำแพง (มี Anti-Fling)",

        Default = false

    })



    NoClipToggle:OnChanged(function()

        if Options.NoClipToggle.Value then startNoClip() else stopNoClip() end

    end)



    local AntiFlingToggle = Tabs.Movement:AddToggle("AntiFlingToggle", {

        Title = "Anti-Fling",

        Description = "ป้องกันการโดนปาออกไป",

        Default = true

    })



    AntiFlingToggle:OnChanged(function()

        noClipState.antiFling = Options.AntiFlingToggle.Value

        if noClipState.enabled then

            stopNoClip()

            task.wait(0.1)

            startNoClip()

        end

    end)



    Tabs.Movement:AddParagraph({

        Title = "✈️ Normal Fly (BodyVelocity)",

        Content = "บินแบบปกติ เหมาะสำหรับความเร็วสูง\nControls: WASD + Space (ขึ้น) / Shift (ลง)"

    })



    local NormalFlyToggle = Tabs.Movement:AddToggle("NormalFlyToggle", {

        Title = "Enable Normal Fly",

        Description = "บินแบบปกติ (BodyVelocity)",

        Default = false

    })



    NormalFlyToggle:OnChanged(function()

        if Options.NormalFlyToggle.Value then 

            if tweenFly.enabled then

                Options.TweenFlyToggle:SetValue(false)

            end

            startNormalFly() 

        else 

            stopNormalFly() 

        end

    end)



    local NormalSpeedSlider = Tabs.Movement:AddSlider("NormalFlySpeed", {

        Title = "Normal Fly Speed",

        Description = "ปรับความเร็วบินแบบปกติ",

        Default = 50,

        Min = 10,

        Max = 500, -- Updated to 500

        Rounding = 1,

        Callback = function(Value) normalFly.speed = Value end

    })



    Tabs.Movement:AddParagraph({

        Title = "🌊 Tween Fly (Anti-Cheat Bypass)",

        Content = "บินแบบนุ่มนวล ป้องกัน Anti-Cheat\nControls: WASD + Space (ขึ้น) / Alt (ลง)"

    })



    local TweenFlyToggle = Tabs.Movement:AddToggle("TweenFlyToggle", {

        Title = "Enable Tween Fly",

        Description = "บินแบบ Tween (ป้องกัน Anti-Cheat)",

        Default = false

    })



    TweenFlyToggle:OnChanged(function()

        if Options.TweenFlyToggle.Value then 

            if normalFly.enabled then

                Options.NormalFlyToggle:SetValue(false)

            end

            startTweenFly() 

        else 

            stopTweenFly() 

        end

    end)



    local TweenSpeedSlider = Tabs.Movement:AddSlider("TweenFlySpeed", {

        Title = "Tween Fly Speed",

        Description = "ปรับความเร็วบินแบบ Tween",

        Default = 80,

        Min = 10,

        Max = 500, -- Updated to 500

        Rounding = 1,

        Callback = function(Value) tweenFly.speed = Value end

    })



    Tabs.Movement:AddButton({

        Title = "🛑 Stop All Flight",

        Description = "หยุดการบินทั้งหมดทันที",

        Callback = function()

            if normalFly.enabled then Options.NormalFlyToggle:SetValue(false) end

            if tweenFly.enabled then Options.TweenFlyToggle:SetValue(false) end

            Fluent:Notify({ Title = "Movement", Content = "หยุดการบินทั้งหมดแล้ว", Duration = 2 })

        end

    })

end



--[[ CAMERA TAB - Spectator/Freecam Mode ]]--

do

    local Players = game:GetService("Players")

    local RunService = game:GetService("RunService")

    local UIS = game:GetService("UserInputService")

    local LP = Players.LocalPlayer

    local Camera = workspace.CurrentCamera



    local freecam = {

        enabled = false,

        speed = 50,

        shiftMultiplier = 2.5,

        showCharacter = true, -- เพิ่มตัวแปรนี้

        keys = {W=false, A=false, S=false, D=false, E=false, Q=false, Shift=false},

        

        -- Saved states

        savedCFrame = nil,

        savedFOV = nil,

        savedCameraType = nil,

        savedCameraSubject = nil,

        

        -- Camera control

        cameraCFrame = nil,

        mouseX = 0,

        mouseY = 0,

        

        -- Connections

        connections = {},

    }



    local function updateFreecam(dt)

        if not freecam.enabled then return end

        

        -- Calculate movement direction

        local cam = Camera

        local moveVector = Vector3.new()

        

        if freecam.keys.W then moveVector += cam.CFrame.LookVector end

        if freecam.keys.S then moveVector -= cam.CFrame.LookVector end

        if freecam.keys.D then moveVector += cam.CFrame.RightVector end

        if freecam.keys.A then moveVector -= cam.CFrame.RightVector end

        if freecam.keys.E then moveVector += Vector3.new(0, 1, 0) end

        if freecam.keys.Q then moveVector -= Vector3.new(0, 1, 0) end

        

        if moveVector.Magnitude > 0 then

            moveVector = moveVector.Unit

        end

        

        -- Apply speed multiplier for Shift

        local currentSpeed = freecam.speed

        if freecam.keys.Shift then

            currentSpeed = currentSpeed * freecam.shiftMultiplier

        end

        

        -- Update camera position

        local newPos = freecam.cameraCFrame.Position + (moveVector * currentSpeed * dt)

        

        -- Keep the rotation (from mouse)

        freecam.cameraCFrame = CFrame.new(newPos) * (freecam.cameraCFrame - freecam.cameraCFrame.Position)

        

        -- Apply to camera

        cam.CFrame = freecam.cameraCFrame

    end



    local function onMouseMove(input)

        if not freecam.enabled then return end

        

        local sensitivity = 0.003

        freecam.mouseX = freecam.mouseX - (input.Delta.X * sensitivity)

        freecam.mouseY = math.clamp(freecam.mouseY - (input.Delta.Y * sensitivity), -math.pi/2 + 0.01, math.pi/2 - 0.01)

        

        -- Apply rotation

        local rotationX = CFrame.Angles(0, freecam.mouseX, 0)

        local rotationY = CFrame.Angles(freecam.mouseY, 0, 0)

        

        freecam.cameraCFrame = CFrame.new(freecam.cameraCFrame.Position) * rotationX * rotationY

    end



    local function startFreecam()

        if freecam.enabled then return end

        freecam.enabled = true

        

        -- Save current camera state

        freecam.savedCFrame = Camera.CFrame

        freecam.savedFOV = Camera.FieldOfView

        freecam.savedCameraType = Camera.CameraType

        freecam.savedCameraSubject = Camera.CameraSubject

        

        -- Initialize freecam position

        freecam.cameraCFrame = Camera.CFrame

        freecam.mouseX = 0

        freecam.mouseY = 0

        

        -- Set camera to scriptable

        Camera.CameraType = Enum.CameraType.Scriptable

        

        -- Freeze character movement

        if LP.Character then

            local hum = LP.Character:FindFirstChildOfClass("Humanoid")

            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")

            

            if hum then

                hum.WalkSpeed = 0

                hum.JumpPower = 0

                hum.JumpHeight = 0

                hum.AutoRotate = false

            end

            

            if hrp then

                hrp.Anchored = true

            end

        end

        

        -- Hide/Show character based on setting

        if LP.Character and not freecam.showCharacter then

            for _, part in pairs(LP.Character:GetDescendants()) do

                if part:IsA("BasePart") then

                    part.LocalTransparencyModifier = 1

                elseif part:IsA("Decal") or part:IsA("Texture") then

                    part.Transparency = 1

                end

            end

        end

        

        -- Input handling

        table.insert(freecam.connections, UIS.InputBegan:Connect(function(input, gameProcessed)

            if gameProcessed then return end

            local key = input.KeyCode

            

            if key == Enum.KeyCode.W then freecam.keys.W = true

            elseif key == Enum.KeyCode.A then freecam.keys.A = true

            elseif key == Enum.KeyCode.S then freecam.keys.S = true

            elseif key == Enum.KeyCode.D then freecam.keys.D = true

            elseif key == Enum.KeyCode.E then freecam.keys.E = true

            elseif key == Enum.KeyCode.Q then freecam.keys.Q = true

            elseif key == Enum.KeyCode.LeftShift then freecam.keys.Shift = true

            end

        end))

        

        table.insert(freecam.connections, UIS.InputEnded:Connect(function(input, gameProcessed)

            local key = input.KeyCode

            

            if key == Enum.KeyCode.W then freecam.keys.W = false

            elseif key == Enum.KeyCode.A then freecam.keys.A = false

            elseif key == Enum.KeyCode.S then freecam.keys.S = false

            elseif key == Enum.KeyCode.D then freecam.keys.D = false

            elseif key == Enum.KeyCode.E then freecam.keys.E = false

            elseif key == Enum.KeyCode.Q then freecam.keys.Q = false

            elseif key == Enum.KeyCode.LeftShift then freecam.keys.Shift = false

            end

        end))

        

        table.insert(freecam.connections, UIS.InputChanged:Connect(function(input, gameProcessed)

            if input.UserInputType == Enum.UserInputType.MouseMovement then

                onMouseMove(input)

            end

        end))

        

        -- Update loop

        table.insert(freecam.connections, RunService.RenderStepped:Connect(updateFreecam))

        

        -- Lock mouse to center

        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

        

        Fluent:Notify({ 

            Title = "Freecam", 

            Content = "Spectator Mode เปิดแล้ว!\n🎮 WASD = เคลื่อนที่\n⬆️ E = ขึ้น | Q = ลง\n⚡ Shift = เร็วขึ้น\n🖱️ Mouse = หมุนกล้อง", 

            Duration = 5 

        })

    end



    local function stopFreecam()

        if not freecam.enabled then return end

        freecam.enabled = false

        

        -- Disconnect all connections

        for _, conn in pairs(freecam.connections) do

            conn:Disconnect()

        end

        freecam.connections = {}

        

        -- Unfreeze character movement

        if LP.Character then

            local hum = LP.Character:FindFirstChildOfClass("Humanoid")

            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")

            

            if hum then

                hum.WalkSpeed = 16

                hum.JumpPower = 50

                hum.JumpHeight = 7.2

                hum.AutoRotate = true

            end

            

            if hrp then

                hrp.Anchored = false

            end

        end

        

        -- Restore camera

        if freecam.savedCameraType then

            Camera.CameraType = freecam.savedCameraType

        end

        if freecam.savedCameraSubject then

            Camera.CameraSubject = freecam.savedCameraSubject

        end

        if freecam.savedFOV then

            Camera.FieldOfView = freecam.savedFOV

        end

        

        -- Restore mouse behavior

        UIS.MouseBehavior = Enum.MouseBehavior.Default

        

        -- Show character again

        if LP.Character then

            for _, part in pairs(LP.Character:GetDescendants()) do

                if part:IsA("BasePart") then

                    part.LocalTransparencyModifier = 0

                elseif part:IsA("Decal") or part:IsA("Texture") then

                    part.Transparency = 0

                end

            end

        end

        

        -- Reset all keys

        for k, _ in pairs(freecam.keys) do

            freecam.keys[k] = false

        end

        

        Fluent:Notify({ Title = "Freecam", Content = "Spectator Mode ปิดแล้ว", Duration = 2 })

    end



    -- Handle character respawn

    LP.CharacterAdded:Connect(function()

        if freecam.enabled then

            task.wait(0.5)

            freecam.enabled = false

            for _, conn in pairs(freecam.connections) do

                pcall(function() conn:Disconnect() end)

            end

            freecam.connections = {}

        end

    end)



    -- UI Elements

    Tabs.Camera:AddParagraph({

        Title = "📷 Spectator Mode (Freecam)",

        Content = "โหมดผู้ชมแบบ Minecraft\nกล้องแยกจากตัวละคร บินลอยไปมาได้อิสระ\nเหมาะสำหรับถ่ายภาพและสำรวจแมพ"

    })



    local FreecamToggle = Tabs.Camera:AddToggle("FreecamToggle", {

        Title = "Enable Spectator Mode",

        Description = "เปิด/ปิดโหมดกล้องอิสระ",

        Default = false

    })



    FreecamToggle:OnChanged(function()

        if Options.FreecamToggle.Value then 

            startFreecam() 

        else 

            stopFreecam() 

        end

    end)



    local ShowCharToggle = Tabs.Camera:AddToggle("ShowCharToggle", {

        Title = "Show Character",

        Description = "แสดงตัวละครตัวเองในโหมด Freecam",

        Default = true

    })



    ShowCharToggle:OnChanged(function()

        freecam.showCharacter = Options.ShowCharToggle.Value

        

        if freecam.enabled and LP.Character then

            if freecam.showCharacter then

                -- Show character

                for _, part in pairs(LP.Character:GetDescendants()) do

                    if part:IsA("BasePart") then

                        part.LocalTransparencyModifier = 0

                    elseif part:IsA("Decal") or part:IsA("Texture") then

                        part.Transparency = 0

                    end

                end

            else

                -- Hide character

                for _, part in pairs(LP.Character:GetDescendants()) do

                    if part:IsA("BasePart") then

                        part.LocalTransparencyModifier = 1

                    elseif part:IsA("Decal") or part:IsA("Texture") then

                        part.Transparency = 1

                    end

                end

            end

            

            Fluent:Notify({ 

                Title = "Freecam", 

                Content = freecam.showCharacter and "แสดงตัวละคร" or "ซ่อนตัวละคร", 

                Duration = 2 

            })

        end

    end)



    Tabs.Camera:AddParagraph({

        Title = "🎮 การควบคุม",

        Content = [[

• WASD - เคลื่อนที่กล้อง (ตัวละครอยู่นิ่ง)

• E - บินขึ้น

• Q - บินลง

• Shift - เพิ่มความเร็ว

• Mouse - หมุนกล้อง



📌 ตัวละครจะอยู่นิ่งไม่เดิน

📌 เหมาะสำหรับถ่ายภาพ 360°

        ]]

    })



    local SpeedSlider = Tabs.Camera:AddSlider("FreecamSpeed", {

        Title = "Camera Speed",

        Description = "ความเร็วกล้อง (ปกติ)",

        Default = 50,

        Min = 5,

        Max = 500, -- Updated to 500

        Rounding = 1,

        Callback = function(Value) 

            freecam.speed = Value 

        end

    })



    local ShiftMultSlider = Tabs.Camera:AddSlider("FreecamShiftMult", {

        Title = "Shift Speed Multiplier",

        Description = "ตัวคูณความเร็วเมื่อกด Shift",

        Default = 2.5,

        Min = 1.5,

        Max = 5,

        Rounding = 1,

        Callback = function(Value) 

            freecam.shiftMultiplier = Value 

        end

    })



    local FOVSlider = Tabs.Camera:AddSlider("FreecamFOV", {

        Title = "Field of View (FOV)",

        Description = "ปรับมุมมอง (70 = ปกติ)",

        Default = 70,

        Min = 30,

        Max = 120,

        Rounding = 1,

        Callback = function(Value) 

            if freecam.enabled then

                Camera.FieldOfView = Value

            end

        end

    })



    Tabs.Camera:AddButton({

        Title = "🔄 Reset Camera Position",

        Description = "รีเซ็ตตำแหน่งกล้องไปที่ตัวละคร",

        Callback = function()

            if freecam.enabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then

                freecam.cameraCFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 10)

                freecam.mouseX = 0

                freecam.mouseY = 0

                Fluent:Notify({ Title = "Freecam", Content = "รีเซ็ตตำแหน่งกล้องแล้ว", Duration = 2 })

            end

        end

    })



    Tabs.Camera:AddButton({

        Title = "📸 Recommended Settings",

        Description = "ตั้งค่าแนะนำสำหรับถ่ายภาพ",

        Callback = function()

            Options.FreecamSpeed:SetValue(30)

            Options.FreecamShiftMult:SetValue(3)

            Options.FreecamFOV:SetValue(80)

            if freecam.enabled then

                Camera.FieldOfView = 80

            end

            Fluent:Notify({ 

                Title = "Freecam", 

                Content = "ตั้งค่าสำหรับถ่ายภาพแล้ว!\nSpeed: 30 | FOV: 80", 

                Duration = 3 

            })

        end

    })



    Tabs.Camera:AddParagraph({

        Title = "💡 Tips",

        Content = [[

• ตัวละครจะนิ่งและ Anchor

• กล้องแยกออกไปได้อิสระ

• เหมาะถ่ายภาพมุมสูง/มุมพิเศษ

• กด Shift ค้างไว้เพื่อบินเร็วขึ้น

• ปรับ FOV สูงขึ้นเพื่อมุมมองกว้าง

• ใช้ความเร็วต่ำเมื่อถ่ายรูประยะใกล้

• เปิด "Show Character" เพื่อเห็นตัวเอง

        ]]

    })

end



--[[ PERFORMANCE TAB - Real-time Cache Cleaner & FPS Optimizer ]]--

do

    local RunService = game:GetService("RunService")

    local ContentProvider = game:GetService("ContentProvider")

    local Stats = game:GetService("Stats")



    local performance = {

        autoClearCache = false,

        clearInterval = 30, -- seconds

        lastClear = 0,

        

        autoGC = false,

        gcInterval = 60,

        lastGC = 0,

        

        removeDebris = false,

        

        connections = {},

        

        stats = {

            fps = 0,

            ping = 0,

            memory = 0,

            instanceCount = 0,

        }

    }



    -- ========== CACHE CLEARING ==========

    local function clearCache()

        local cleared = 0

        

        -- Clear ContentProvider cache

        pcall(function()

            for _, obj in pairs(ContentProvider:GetChildren()) do

                pcall(function() obj:Destroy() end)

                cleared = cleared + 1

            end

        end)

        

        -- Clear old particles

        for _, obj in pairs(workspace:GetDescendants()) do

            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then

                if not obj.Enabled then

                    pcall(function() obj:Destroy() end)

                    cleared = cleared + 1

                end

            end

        end

        

        -- Clear old sounds

        for _, obj in pairs(workspace:GetDescendants()) do

            if obj:IsA("Sound") then

                if not obj.Playing and obj.TimePosition == 0 then

                    pcall(function() obj:Destroy() end)

                    cleared = cleared + 1

                end

            end

        end

        

        return cleared

    end



    local function forceGarbageCollection()

        pcall(function()

            setfpscap(1)

            task.wait(1)

            setfpscap(999)

        end)

        

        -- Manual GC

        for i = 1, 5 do

            pcall(function()

                collectgarbage("collect")

            end)

            task.wait(0.1)

        end

    end



    local function removeDebris()

        local removed = 0

        local debris = game:GetService("Debris")

        

        for _, obj in pairs(workspace:GetDescendants()) do

            -- Remove old explosions

            if obj:IsA("Explosion") then

                pcall(function() obj:Destroy() end)

                removed = removed + 1

            end

            

            -- Remove old parts with Debris tag

            if obj:IsA("BasePart") and obj:FindFirstChild("DebrisTag") then

                pcall(function() obj:Destroy() end)

                removed = removed + 1

            end

        end

        

        return removed

    end



    local function optimizeWorkspace()

        -- Remove duplicate parts

        local positions = {}

        local removed = 0

        

        for _, obj in pairs(workspace:GetDescendants()) do

            if obj:IsA("BasePart") and obj.Transparency >= 0.99 then

                local pos = tostring(obj.Position)

                if positions[pos] then

                    pcall(function() obj:Destroy() end)

                    removed = removed + 1

                else

                    positions[pos] = true

                end

            end

        end

        

        return removed

    end



    -- ========== STATISTICS MONITORING ==========

    local function updateStats()

        -- FPS

        performance.stats.fps = math.floor(1 / RunService.RenderStepped:Wait())

        

        -- Ping

        pcall(function()

            performance.stats.ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

        end)

        

        -- Memory (MB)

        pcall(function()

            performance.stats.memory = math.floor(Stats:GetTotalMemoryUsageMb())

        end)

        

        -- Instance Count

        performance.stats.instanceCount = #workspace:GetDescendants()

    end



    -- ========== AUTO CLEANER LOOP ==========

    local function startAutoCleaner()

        if performance.autoClearCache then return end

        performance.autoClearCache = true

        

        table.insert(performance.connections, RunService.Heartbeat:Connect(function()

            local currentTime = tick()

            

            -- Auto Clear Cache

            if currentTime - performance.lastClear >= performance.clearInterval then

                local cleared = clearCache()

                performance.lastClear = currentTime

                

                if performance.removeDebris then

                    removeDebris()

                end

                

                print("[Performance] Auto cleared " .. cleared .. " cached items")

            end

            

            -- Auto Garbage Collection

            if performance.autoGC and currentTime - performance.lastGC >= performance.gcInterval then

                forceGarbageCollection()

                performance.lastGC = currentTime

                print("[Performance] Auto Garbage Collection executed")

            end

        end))

        

        Fluent:Notify({ 

            Title = "Performance", 

            Content = "Auto Cache Cleaner เปิดแล้ว!\nจะเคลียแคชอัตโนมัติทุก " .. performance.clearInterval .. " วินาที", 

            Duration = 4 

        })

    end



    local function stopAutoCleaner()

        if not performance.autoClearCache then return end

        performance.autoClearCache = false

        

        for _, conn in pairs(performance.connections) do

            conn:Disconnect()

        end

        performance.connections = {}

        

        Fluent:Notify({ Title = "Performance", Content = "Auto Cache Cleaner ปิดแล้ว", Duration = 2 })

    end



    -- ========== UI ELEMENTS ==========

    Tabs.Performance:AddParagraph({

        Title = "⚡ Real-time Performance Monitor",

        Content = "ติดตามประสิทธิภาพเกมแบบ Real-time\nเคลียแคช GC และลดแล็กอัตโนมัติ"

    })



    -- Stats Display

    local FPSDisplay = Tabs.Performance:AddParagraph({

        Title = "🎮 FPS (Frames Per Second)",

        Content = "0 FPS"

    })



    local PingDisplay = Tabs.Performance:AddParagraph({

        Title = "📶 Ping (Network Latency)",

        Content = "0 ms"

    })



    local MemoryDisplay = Tabs.Performance:AddParagraph({

        Title = "💾 Memory Usage",

        Content = "0 MB"

    })



    local InstanceDisplay = Tabs.Performance:AddParagraph({

        Title = "📦 Instance Count",

        Content = "0 objects"

    })



    -- Stats Update Loop

    task.spawn(function()

        while true do

            updateStats()

            FPSDisplay:SetDesc(performance.stats.fps .. " FPS")

            PingDisplay:SetDesc(performance.stats.ping .. " ms")

            MemoryDisplay:SetDesc(performance.stats.memory .. " MB")

            InstanceDisplay:SetDesc(performance.stats.instanceCount .. " objects")

            task.wait(1)

        end

    end)



    Tabs.Performance:AddParagraph({

        Title = "🧹 Cache Cleaner",

        Content = "เคลียแคชเพื่อลดแล็กและกระตุก\nทำงานแบบ Real-time ไม่รบกวนการเล่น"

    })



    local AutoClearToggle = Tabs.Performance:AddToggle("AutoClearToggle", {

        Title = "Auto Clear Cache",

        Description = "เคลียแคชอัตโนมัติตามเวลาที่กำหนด",

        Default = false

    })



    AutoClearToggle:OnChanged(function()

        if Options.AutoClearToggle.Value then 

            startAutoCleaner() 

        else 

            stopAutoCleaner() 

        end

    end)



    local ClearIntervalSlider = Tabs.Performance:AddSlider("ClearInterval", {

        Title = "Clear Interval (seconds)",

        Description = "ระยะเวลาระหว่างการเคลียแคช",

        Default = 30,

        Min = 10,

        Max = 300,

        Rounding = 0,

        Callback = function(Value) 

            performance.clearInterval = Value 

        end

    })



    local RemoveDebrisToggle = Tabs.Performance:AddToggle("RemoveDebrisToggle", {

        Title = "Auto Remove Debris",

        Description = "ลบวัตถุเศษเหลือทิ้งอัตโนมัติ",

        Default = false

    })



    RemoveDebrisToggle:OnChanged(function()

        performance.removeDebris = Options.RemoveDebrisToggle.Value

    end)



    Tabs.Performance:AddButton({

        Title = "🧹 Clear Cache Now",

        Description = "เคลียแคชทันที (Manual)",

        Callback = function()

            local cleared = clearCache()

            Fluent:Notify({ 

                Title = "Performance", 

                Content = "เคลียแคชแล้ว: " .. cleared .. " items", 

                Duration = 3 

            })

        end

    })



    Tabs.Performance:AddParagraph({

        Title = "🗑️ Garbage Collection",

        Content = "บังคับเก็บขยะหน่วยความจำ\nช่วยลดการใช้ RAM"

    })



    local AutoGCToggle = Tabs.Performance:AddToggle("AutoGCToggle", {

        Title = "Auto Garbage Collection",

        Description = "เก็บขยะหน่วยความจำอัตโนมัติ",

        Default = false

    })



    AutoGCToggle:OnChanged(function()

        performance.autoGC = Options.AutoGCToggle.Value

    end)



    local GCIntervalSlider = Tabs.Performance:AddSlider("GCInterval", {

        Title = "GC Interval (seconds)",

        Description = "ระยะเวลาระหว่างการเก็บขยะ",

        Default = 60,

        Min = 30,

        Max = 300,

        Rounding = 0,

        Callback = function(Value) 

            performance.gcInterval = Value 

        end

    })



    Tabs.Performance:AddButton({

        Title = "🗑️ Force Garbage Collection",

        Description = "บังคับเก็บขยะทันที (อาจกระตุกชั่วคราว)",

        Callback = function()

            Fluent:Notify({ 

                Title = "Performance", 

                Content = "กำลังเก็บขยะ... รอสักครู่", 

                Duration = 2 

            })

            forceGarbageCollection()

            task.wait(1)

            Fluent:Notify({ 

                Title = "Performance", 

                Content = "เก็บขยะเสร็จแล้ว!", 

                Duration = 2 

            })

        end

    })



    Tabs.Performance:AddParagraph({

        Title = "🔧 Workspace Optimizer",

        Content = "เพิ่มประสิทธิภาพ Workspace\nลบวัตถุที่ไม่จำเป็น"

    })



    Tabs.Performance:AddButton({

        Title = "🔧 Optimize Workspace",

        Description = "ลบ Parts โปร่งใส และวัตถุซ้ำซ้อน",

        Callback = function()

            local removed = optimizeWorkspace()

            Fluent:Notify({ 

                Title = "Performance", 

                Content = "เพิ่มประสิทธิภาพแล้ว!\nลบวัตถุ: " .. removed .. " objects", 

                Duration = 3 

            })

        end

    })



    Tabs.Performance:AddButton({

        Title = "🧨 Remove All Debris",

        Description = "ลบวัตถุเศษเหลือทั้งหมด",

        Callback = function()

            local removed = removeDebris()

            Fluent:Notify({ 

                Title = "Performance", 

                Content = "ลบเศษเหลือแล้ว: " .. removed .. " items", 

                Duration = 3 

            })

        end

    })



    Tabs.Performance:AddParagraph({

        Title = "⚡ Quick Presets",

        Content = "ตั้งค่าสำเร็จรูปสำหรับสถานการณ์ต่างๆ"

    })



    Tabs.Performance:AddButton({

        Title = "🚀 Maximum Performance",

        Description = "เปิดทุกอย่างเพื่อประสิทธิภาพสูงสุด",

        Callback = function()

            Options.AutoClearToggle:SetValue(true)

            Options.ClearInterval:SetValue(20)

            Options.RemoveDebrisToggle:SetValue(true)

            Options.AutoGCToggle:SetValue(true)

            Options.GCInterval:SetValue(45)

            

            Fluent:Notify({ 

                Title = "Performance", 

                Content = "🚀 Maximum Performance Mode เปิดแล้ว!\n• Auto Clear: 20s\n• Auto GC: 45s\n• Remove Debris: ON", 

                Duration = 4 

            })

        end

    })



    Tabs.Performance:AddButton({

        Title = "⚖️ Balanced Mode",

        Description = "สมดุลระหว่างประสิทธิภาพกับความเสถียร",

        Callback = function()

            Options.AutoClearToggle:SetValue(true)

            Options.ClearInterval:SetValue(45)

            Options.RemoveDebrisToggle:SetValue(false)

            Options.AutoGCToggle:SetValue(true)

            Options.GCInterval:SetValue(90)

            

            Fluent:Notify({ 

                Title = "Performance", 

                Content = "⚖️ Balanced Mode เปิดแล้ว!", 

                Duration = 3 

            })

        end

    })



    Tabs.Performance:AddButton({

        Title = "💤 Disable All Optimization",

        Description = "ปิดการเพิ่มประสิทธิภาพทั้งหมด",

        Callback = function()

            Options.AutoClearToggle:SetValue(false)

            Options.RemoveDebrisToggle:SetValue(false)

            Options.AutoGCToggle:SetValue(false)

            

            Fluent:Notify({ 

                Title = "Performance", 

                Content = "ปิดการเพิ่มประสิทธิภาพทั้งหมดแล้ว", 

                Duration = 2 

            })

        end

    })



    Tabs.Performance:AddParagraph({

        Title = "💡 Tips",

        Content = [[

• ใช้ Auto Clear Cache ช่วยลดแล็ก

• GC ทุก 60-90 วินาที = สมดุลดี

• Interval สั้นเกินไป = อาจกระตุก

• Maximum Mode = เครื่องสเปคต่ำ

• Balanced Mode = เครื่องสเปคปกติ

        ]]

    })

end



--[[ POSITION TAB ]]--

do

    local Players = game:GetService("Players")

    local RunService = game:GetService("RunService")

    local LP = Players.LocalPlayer



    local positionState = {

        tracking = false,

        currentPos = Vector3.new(0, 0, 0),

        connection = nil,

    }



    local PositionDisplay = { X = nil, Y = nil, Z = nil }



    local function updatePosition()

        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then

            local pos = LP.Character.HumanoidRootPart.Position

            positionState.currentPos = pos

            if PositionDisplay.X then PositionDisplay.X:SetDesc(string.format("%.3f", pos.X)) end

            if PositionDisplay.Y then PositionDisplay.Y:SetDesc(string.format("%.3f", pos.Y)) end

            if PositionDisplay.Z then PositionDisplay.Z:SetDesc(string.format("%.3f", pos.Z)) end

        else

            if PositionDisplay.X then PositionDisplay.X:SetDesc("N/A") end

            if PositionDisplay.Y then PositionDisplay.Y:SetDesc("N/A") end

            if PositionDisplay.Z then PositionDisplay.Z:SetDesc("N/A") end

        end

    end



    local function startTracking()

        if positionState.tracking then return end

        positionState.tracking = true

        if positionState.connection then positionState.connection:Disconnect() end

        positionState.connection = RunService.Heartbeat:Connect(updatePosition)

    end



    local function stopTracking()

        if not positionState.tracking then return end

        positionState.tracking = false

        if positionState.connection then

            positionState.connection:Disconnect()

            positionState.connection = nil

        end

    end



    LP.CharacterAdded:Connect(function()

        if positionState.tracking then

            task.wait(0.5)

            positionState.connection:Disconnect()

            positionState.connection = RunService.Heartbeat:Connect(updatePosition)

        end

    end)



    Tabs.Position:AddParagraph({

        Title = "Position Tracker",

        Content = "Real-time character position tracking\nAuto-updates even after respawn"

    })



    local TrackToggle = Tabs.Position:AddToggle("TrackToggle", {

        Title = "Enable Tracking",

        Default = false

    })



    TrackToggle:OnChanged(function()

        if Options.TrackToggle.Value then startTracking() else stopTracking() end

    end)



    Tabs.Position:AddParagraph({ Title = "Current Position", Content = "Position will update when tracking is enabled" })



    PositionDisplay.X = Tabs.Position:AddParagraph({ Title = "X Position", Content = "0.000" })

    PositionDisplay.Y = Tabs.Position:AddParagraph({ Title = "Y Position", Content = "0.000" })

    PositionDisplay.Z = Tabs.Position:AddParagraph({ Title = "Z Position", Content = "0.000" })



    Tabs.Position:AddButton({

        Title = "Copy Position (Vector3)",

        Description = "Copy current position as Vector3.new(x, y, z)",

        Callback = function()

            local pos = positionState.currentPos

            local posString = string.format("Vector3.new(%.3f, %.3f, %.3f)", pos.X, pos.Y, pos.Z)

            if setclipboard then

                setclipboard(posString)

                Fluent:Notify({ Title = "Position Tracker", Content = "Position copied to clipboard!", Duration = 3 })

            else

                Fluent:Notify({ Title = "Position Tracker", Content = "Clipboard not supported", Duration = 3 })

            end

        end

    })



    Tabs.Position:AddButton({

        Title = "Copy Position (Numbers)",

        Description = "Copy as X, Y, Z format",

        Callback = function()

            local pos = positionState.currentPos

            local posString = string.format("%.3f, %.3f, %.3f", pos.X, pos.Y, pos.Z)

            if setclipboard then

                setclipboard(posString)

                Fluent:Notify({ Title = "Position Tracker", Content = "Position copied as numbers!", Duration = 3 })

            else

                Fluent:Notify({ Title = "Position Tracker", Content = "Clipboard not supported", Duration = 3 })

            end

        end

    })

end



--[[ GRAPHICS TAB ]]--

do

    local Lighting = game:GetService("Lighting")

    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    local RunService = game:GetService("RunService") -- Added RunService for FullBright



    -- ========== ULTRA LOW GRAPHICS ==========

    local saved = {

        lighting = {},

        instances = {},

        terrain = {},

        applied = false,

    }



    local function saveProp(inst, prop, val)

        if not saved.instances[inst] then saved.instances[inst] = {} end

        if saved.instances[inst][prop] == nil then saved.instances[inst][prop] = val end

    end



    local function setSafe(inst, prop, val)

        local ok = pcall(function() inst[prop] = val end)

        if ok then saveProp(inst, prop, inst[prop]) end

    end



    local function applyUltra()

        if saved.applied then return end

        saved.applied = true



        for _, prop in pairs({"Brightness", "ClockTime", "FogEnd", "GlobalShadows", "OutdoorAmbient", "Technology"}) do

            if saved.lighting[prop] == nil then saved.lighting[prop] = Lighting[prop] end

        end



        Lighting.Brightness = 2

        Lighting.ClockTime = 14

        Lighting.FogEnd = 9e9

        Lighting.GlobalShadows = false

        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

        Lighting.Technology = Enum.Technology.Compatibility



        for _, obj in pairs(Lighting:GetChildren()) do

            if obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") then

                obj.Enabled = false

            end

        end



        if Terrain then

            if saved.terrain.WaterWaveSize == nil then saved.terrain.WaterWaveSize = Terrain.WaterWaveSize end

            if saved.terrain.WaterWaveSpeed == nil then saved.terrain.WaterWaveSpeed = Terrain.WaterWaveSpeed end

            if saved.terrain.WaterReflectance == nil then saved.terrain.WaterReflectance = Terrain.WaterReflectance end

            if saved.terrain.WaterTransparency == nil then saved.terrain.WaterTransparency = Terrain.WaterTransparency end



            Terrain.WaterWaveSize = 0

            Terrain.WaterWaveSpeed = 0

            Terrain.WaterReflectance = 0

            Terrain.WaterTransparency = 0

        end



        for _, obj in pairs(workspace:GetDescendants()) do

            if obj:IsA("Part") or obj:IsA("Union") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") then

                setSafe(obj, "Material", Enum.Material.Plastic)

                setSafe(obj, "Reflectance", 0)

            elseif obj:IsA("Decal") or obj:IsA("Texture") then

                setSafe(obj, "Transparency", 1)

            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then

                setSafe(obj, "Enabled", false)

            elseif obj:IsA("Explosion") then

                setSafe(obj, "BlastPressure", 1)

                setSafe(obj, "BlastRadius", 1)

            elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") or obj:IsA("Sparkles") then

                setSafe(obj, "Enabled", false)

            elseif obj:IsA("MeshPart") then

                setSafe(obj, "Material", Enum.Material.Plastic)

                setSafe(obj, "Reflectance", 0)

                setSafe(obj, "TextureID", "")

            end

        end

    end



    local function restoreGraphics()

        if not saved.applied then return end



        for prop, val in pairs(saved.lighting) do pcall(function() Lighting[prop] = val end) end



        if Terrain then

            for prop, val in pairs(saved.terrain) do pcall(function() Terrain[prop] = val end) end

        end



        for inst, props in pairs(saved.instances) do

            for prop, val in pairs(props) do pcall(function() inst[prop] = val end) end

        end



        for _, obj in pairs(Lighting:GetChildren()) do

            if obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") then

                obj.Enabled = true

            end

        end



        saved.applied = false

    end



    -- ========== FULL BRIGHT (NIGHT VISION) ==========

    local fullBrightLoop = nil



    local function enableFullBright()

        if fullBrightLoop then return end

        

        -- ใช้ Loop เพื่อบังคับแสงตลอดเวลา (กันเกมปรับคืน)

        fullBrightLoop = RunService.RenderStepped:Connect(function()

            Lighting.Brightness = 2

            Lighting.ClockTime = 14

            Lighting.FogEnd = 9e9

            Lighting.GlobalShadows = false

            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

            Lighting.Ambient = Color3.fromRGB(255, 255, 255)

        end)

    end



    local function disableFullBright()

        if fullBrightLoop then

            fullBrightLoop:Disconnect()

            fullBrightLoop = nil

            

            -- คืนค่าแสงแบบคร่าวๆ (ถ้าไม่ได้เปิด Ultra Low Graphics)

            if not saved.applied then

                Lighting.Brightness = 1

                Lighting.ClockTime = 14

                Lighting.GlobalShadows = true

                Lighting.FogEnd = 10000

                Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)

                Lighting.Ambient = Color3.fromRGB(127, 127, 127)

            end

        end

    end



    -- ========== GRAPHICS ENHANCEMENTS ==========

    local enhancements = {

        bloom = nil,

        sunRays = nil,

        colorCorrection = nil,

        depthOfField = nil,

        atmosphere = nil,

    }



    local function createBloom()

        if enhancements.bloom then return end

        enhancements.bloom = Instance.new("BloomEffect")

        enhancements.bloom.Intensity = 0.4

        enhancements.bloom.Size = 24

        enhancements.bloom.Threshold = 0.8

        enhancements.bloom.Parent = Lighting

    end



    local function removeBloom()

        if enhancements.bloom then

            enhancements.bloom:Destroy()

            enhancements.bloom = nil

        end

    end



    local function createSunRays()

        if enhancements.sunRays then return end

        enhancements.sunRays = Instance.new("SunRaysEffect")

        enhancements.sunRays.Intensity = 0.15

        enhancements.sunRays.Spread = 0.4

        enhancements.sunRays.Parent = Lighting

    end



    local function removeSunRays()

        if enhancements.sunRays then

            enhancements.sunRays:Destroy()

            enhancements.sunRays = nil

        end

    end



    local function createColorCorrection()

        if enhancements.colorCorrection then return end

        enhancements.colorCorrection = Instance.new("ColorCorrectionEffect")

        enhancements.colorCorrection.Brightness = 0.05

        enhancements.colorCorrection.Contrast = 0.1

        enhancements.colorCorrection.Saturation = 0.2

        enhancements.colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)

        enhancements.colorCorrection.Parent = Lighting

    end



    local function removeColorCorrection()

        if enhancements.colorCorrection then

            enhancements.colorCorrection:Destroy()

            enhancements.colorCorrection = nil

        end

    end



    local function createDepthOfField()

        if enhancements.depthOfField then return end

        enhancements.depthOfField = Instance.new("DepthOfFieldEffect")

        enhancements.depthOfField.FarIntensity = 0.3

        enhancements.depthOfField.FocusDistance = 10

        enhancements.depthOfField.InFocusRadius = 20

        enhancements.depthOfField.NearIntensity = 0.5

        enhancements.depthOfField.Parent = Lighting

    end



    local function removeDepthOfField()

        if enhancements.depthOfField then

            enhancements.depthOfField:Destroy()

            enhancements.depthOfField = nil

        end

    end



    local function createAtmosphere()

        if enhancements.atmosphere then return end

        enhancements.atmosphere = Instance.new("Atmosphere")

        enhancements.atmosphere.Density = 0.3

        enhancements.atmosphere.Offset = 0.25

        enhancements.atmosphere.Color = Color3.fromRGB(199, 199, 199)

        enhancements.atmosphere.Decay = Color3.fromRGB(106, 112, 125)

        enhancements.atmosphere.Glare = 0

        enhancements.atmosphere.Haze = 0

        enhancements.atmosphere.Parent = Lighting

    end



    local function removeAtmosphere()

        if enhancements.atmosphere then

            enhancements.atmosphere:Destroy()

            enhancements.atmosphere = nil

        end

    end



    local function improveWater()

        if Terrain then

            Terrain.WaterWaveSize = 0.15

            Terrain.WaterWaveSpeed = 10

            Terrain.WaterReflectance = 0.1

            Terrain.WaterTransparency = 0.9

        end

    end



    local function enableShadows()

        Lighting.GlobalShadows = true

        Lighting.Technology = Enum.Technology.Future

    end



    local function improveSky()

        Lighting.Ambient = Color3.fromRGB(0, 0, 0)

        Lighting.Brightness = 2

        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)

        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)

        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)

        Lighting.ClockTime = 14

    end



    -- ========== UI ELEMENTS ==========

    Tabs.Graphics:AddParagraph({

        Title = "🔦 Visibility (Night Vision)",

        Content = "โหมดมองเห็นในที่มืด เหมาะสำหรับเกมผี\nช่วยให้มองเห็นชัดเจน ลบหมอกและเงา"

    })



    local FullBrightToggle = Tabs.Graphics:AddToggle("FullBrightToggle", {

        Title = "FullBright (Night Vision)",

        Description = "เปิดแสงสว่างสูงสุด (มองเห็นในที่มืด)",

        Default = false

    })



    FullBrightToggle:OnChanged(function()

        if Options.FullBrightToggle.Value then 

            enableFullBright()

        else 

            disableFullBright()

        end

    end)



    Tabs.Graphics:AddParagraph({

        Title = "📉 Ultra Low Graphics (FPS Boost)",

        Content = "ลดกราฟิกเพื่อเพิ่ม FPS สูงสุด\nเหมาะสำหรับเครื่องสเปคต่ำ"

    })



    local GraphicsToggle = Tabs.Graphics:AddToggle("GraphicsToggle", {

        Title = "Ultra Low Graphics",

        Default = false

    })



    GraphicsToggle:OnChanged(function()

        if Options.GraphicsToggle.Value then applyUltra() else restoreGraphics() end

    end)



    Tabs.Graphics:AddButton({

        Title = "Apply Ultra Graphics",

        Description = "Maximum FPS boost",

        Callback = function()

            applyUltra()

            Options.GraphicsToggle:SetValue(true)

        end

    })



    Tabs.Graphics:AddButton({

        Title = "Restore Graphics",

        Description = "Return to original settings",

        Callback = function()

            restoreGraphics()

            Options.GraphicsToggle:SetValue(false)

        end

    })



    Tabs.Graphics:AddParagraph({

        Title = "✨ Graphics Enhancements",

        Content = "ทำให้เกมสวยขึ้นด้วยเอฟเฟกต์แสงและสี\nเปิดปิดแต่ละอันได้อิสระ"

    })



    local BloomToggle = Tabs.Graphics:AddToggle("BloomToggle", {

        Title = "Bloom Effect",

        Description = "แสงเรืองแรง ทำให้ภาพสว่างและสวยขึ้น",

        Default = false

    })



    BloomToggle:OnChanged(function()

        if Options.BloomToggle.Value then createBloom() else removeBloom() end

    end)



    local SunRaysToggle = Tabs.Graphics:AddToggle("SunRaysToggle", {

        Title = "Sun Rays Effect",

        Description = "แสงแดดส่องผ่าน สร้างบรรยากาศสวยงาม",

        Default = false

    })



    SunRaysToggle:OnChanged(function()

        if Options.SunRaysToggle.Value then createSunRays() else removeSunRays() end

    end)



    local ColorCorrectionToggle = Tabs.Graphics:AddToggle("ColorCorrectionToggle", {

        Title = "Color Correction",

        Description = "ปรับสี ความสว่าง คอนทราสต์",

        Default = false

    })



    ColorCorrectionToggle:OnChanged(function()

        if Options.ColorCorrectionToggle.Value then createColorCorrection() else removeColorCorrection() end

    end)



    local DepthOfFieldToggle = Tabs.Graphics:AddToggle("DepthOfFieldToggle", {

        Title = "Depth of Field (Blur)",

        Description = "เบลอพื้นหลัง สร้างมิติให้ภาพ",

        Default = false

    })



    DepthOfFieldToggle:OnChanged(function()

        if Options.DepthOfFieldToggle.Value then createDepthOfField() else removeDepthOfField() end

    end)



    local AtmosphereToggle = Tabs.Graphics:AddToggle("AtmosphereToggle", {

        Title = "Atmosphere",

        Description = "สร้างบรรยากาศอากาศ หมอกบางๆ",

        Default = false

    })



    AtmosphereToggle:OnChanged(function()

        if Options.AtmosphereToggle.Value then createAtmosphere() else removeAtmosphere() end

    end)



    Tabs.Graphics:AddParagraph({

        Title = "🌊 Quick Presets",

        Content = "ตั้งค่าสำเร็จรูปสำหรับสถานการณ์ต่างๆ"

    })



    Tabs.Graphics:AddButton({

        Title = "🎨 Cinematic Mode",

        Description = "เอฟเฟกต์เต็มที่ เหมาะกับถ่ายรูป/วิดีโอ",

        Callback = function()

            Options.BloomToggle:SetValue(true)

            Options.SunRaysToggle:SetValue(true)

            Options.ColorCorrectionToggle:SetValue(true)

            Options.DepthOfFieldToggle:SetValue(true)

            Options.AtmosphereToggle:SetValue(true)

            enableShadows()

            improveSky()

            improveWater()

            Fluent:Notify({ 

                Title = "Graphics", 

                Content = "🎬 Cinematic Mode เปิดแล้ว!\nเอฟเฟกต์ทั้งหมดถูกเปิดใช้งาน", 

                Duration = 3 

            })

        end

    })



    Tabs.Graphics:AddButton({

        Title = "🌟 Balanced Mode",

        Description = "สมดุลระหว่างความสวยกับประสิทธิภาพ",

        Callback = function()

            Options.BloomToggle:SetValue(true)

            Options.SunRaysToggle:SetValue(false)

            Options.ColorCorrectionToggle:SetValue(true)

            Options.DepthOfFieldToggle:SetValue(false)

            Options.AtmosphereToggle:SetValue(true)

            enableShadows()

            improveSky()

            Fluent:Notify({ 

                Title = "Graphics", 

                Content = "⚖️ Balanced Mode เปิดแล้ว!", 

                Duration = 3 

            })

        end

    })



    Tabs.Graphics:AddButton({

        Title = "🌊 Improve Water Quality",

        Description = "ปรับปรุงน้ำให้สวยขึ้น",

        Callback = function()

            improveWater()

            Fluent:Notify({ 

                Title = "Graphics", 

                Content = "น้ำสวยขึ้นแล้ว!", 

                Duration = 2 

            })

        end

    })



    Tabs.Graphics:AddButton({

        Title = "☀️ Enable Shadows",

        Description = "เปิดเงาและเทคโนโลยีแสงสูงสุด",

        Callback = function()

            enableShadows()

            Fluent:Notify({ 

                Title = "Graphics", 

                Content = "เงาเปิดแล้ว! (Future Lighting)", 

                Duration = 2 

            })

        end

    })



    Tabs.Graphics:AddButton({

        Title = "🔄 Disable All Effects",

        Description = "ปิดเอฟเฟกต์ทั้งหมด",

        Callback = function()

            Options.BloomToggle:SetValue(false)

            Options.SunRaysToggle:SetValue(false)

            Options.ColorCorrectionToggle:SetValue(false)

            Options.DepthOfFieldToggle:SetValue(false)

            Options.AtmosphereToggle:SetValue(false)

            Fluent:Notify({ 

                Title = "Graphics", 

                Content = "ปิดเอฟเฟกต์ทั้งหมดแล้ว", 

                Duration = 2 

            })

        end

    })



    -- Sliders for fine-tuning

    Tabs.Graphics:AddParagraph({

        Title = "🎛️ Fine Tuning",

        Content = "ปรับละเอียดเอฟเฟกต์แต่ละตัว"

    })



    local BloomIntensity = Tabs.Graphics:AddSlider("BloomIntensity", {

        Title = "Bloom Intensity",

        Default = 0.4,

        Min = 0,

        Max = 1,

        Rounding = 2,

        Callback = function(Value) 

            if enhancements.bloom then 

                enhancements.bloom.Intensity = Value 

            end

        end

    })



    local SunRaysIntensity = Tabs.Graphics:AddSlider("SunRaysIntensity", {

        Title = "Sun Rays Intensity",

        Default = 0.15,

        Min = 0,

        Max = 1,

        Rounding = 2,

        Callback = function(Value) 

            if enhancements.sunRays then 

                enhancements.sunRays.Intensity = Value 

            end

        end

    })



    local Saturation = Tabs.Graphics:AddSlider("Saturation", {

        Title = "Color Saturation",

        Default = 0.2,

        Min = -1,

        Max = 1,

        Rounding = 2,

        Callback = function(Value) 

            if enhancements.colorCorrection then 

                enhancements.colorCorrection.Saturation = Value 

            end

        end

    })

end



--[[ SERVER TAB ]]--

do

    local TeleportService = game:GetService("TeleportService")

    local HttpService = game:GetService("HttpService")

    local Players = game:GetService("Players")

    local LP = Players.LocalPlayer



    local CONFIG = {

        TARGET_JOB_ID = "",

        RETRY_DELAY = 0.75,

        DEBUG_LOG = true,

    }



    local hopState = { isHopping = false, targetJobId = "" }



    local function dlog(...) if CONFIG.DEBUG_LOG then print("[Server Hop]", ...) end end

    local function getCurrentJobId() return game.JobId or "" end



    local function rejoinCurrentServer()

        dlog("Rejoining current server...")

        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)

    end



    local function hopToJobId(targetJobId)

        if not targetJobId or targetJobId == "" then dlog("No target JobId set!") return end



        hopState.isHopping = true

        hopState.targetJobId = targetJobId

        dlog("Starting hop to JobId:", targetJobId)



        task.spawn(function()

            while hopState.isHopping do

                local currentJobId = getCurrentJobId()

                if currentJobId == targetJobId then

                    dlog("Successfully reached target server!")

                    hopState.isHopping = false

                    break

                end



                dlog("Attempting teleport to target JobId...")

                local success, err = pcall(function()

                    TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LP)

                end)

                if not success then dlog("Teleport failed:", err) end

                task.wait(CONFIG.RETRY_DELAY)

            end

        end)

    end



    local function getRandomServer()

        local success, result = pcall(function()

            local apiUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

            return HttpService:JSONDecode(game:HttpGet(apiUrl))

        end)



        if success and result.data then

            local servers = {}

            for _, server in pairs(result.data) do

                if server.id ~= game.JobId and server.playing < server.maxPlayers then

                    table.insert(servers, server.id)

                end

            end

            if #servers > 0 then return servers[math.random(1, #servers)] end

        end

        return nil

    end



    local function hopToRandomServer()

        local randomJobId = getRandomServer()

        if randomJobId then

            dlog("Hopping to random server:", randomJobId)

            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomJobId, LP)

        else

            dlog("No available servers found!")

        end

    end



    Tabs.Server:AddParagraph({

        Title = "Server Management",

        Content = "Server hopping and rejoining tools\nRejoin = reconnect to current server"

    })



    Tabs.Server:AddParagraph({ Title = "Current Server ID", Content = "JobId: " .. getCurrentJobId() })



    local TargetJobIdInput = Tabs.Server:AddInput("TargetJobId", {

        Title = "Target Server ID",

        Default = "",

        Placeholder = "Enter JobId to hop to...",

        Numeric = false,

        Finished = false,

        Callback = function(Value) CONFIG.TARGET_JOB_ID = Value end

    })



    Tabs.Server:AddButton({

        Title = "Copy Current JobId",

        Description = "Copy current server ID to clipboard",

        Callback = function()

            local jobId = getCurrentJobId()

            setclipboard(jobId)

            Fluent:Notify({ Title = "Server Hop", Content = "Copied JobId: " .. jobId, Duration = 3 })

        end

    })



    Tabs.Server:AddButton({

        Title = "Set Target = Current",

        Description = "Set current server as target",

        Callback = function()

            local jobId = getCurrentJobId()

            CONFIG.TARGET_JOB_ID = jobId

            TargetJobIdInput:SetValue(jobId)

            Fluent:Notify({ Title = "Server Hop", Content = "Target set to current server", Duration = 3 })

        end

    })



    Tabs.Server:AddButton({

        Title = "Rejoin Current Server",

        Description = "Reconnect to the same server",

        Callback = function() rejoinCurrentServer() end

    })



    Tabs.Server:AddButton({

        Title = "Hop to Target Server",

        Description = "Hop to the specified JobId",

        Callback = function()

            if CONFIG.TARGET_JOB_ID and CONFIG.TARGET_JOB_ID ~= "" then

                hopToJobId(CONFIG.TARGET_JOB_ID)

            else

                Fluent:Notify({ Title = "Server Hop", Content = "Please set a target JobId first!", Duration = 3 })

            end

        end

    })



    Tabs.Server:AddButton({

        Title = "Random Server Hop",

        Description = "Hop to a random available server",

        Callback = function() hopToRandomServer() end

    })



    local AutoHopToggle = Tabs.Server:AddToggle("AutoHop", {

        Title = "Auto Hop to Target",

        Default = false

    })



    AutoHopToggle:OnChanged(function()

        if Options.AutoHop.Value then

            if CONFIG.TARGET_JOB_ID and CONFIG.TARGET_JOB_ID ~= "" then

                hopToJobId(CONFIG.TARGET_JOB_ID)

            else

                Fluent:Notify({ Title = "Server Hop", Content = "Please set a target JobId first!", Duration = 3 })

                Options.AutoHop:SetValue(false)

            end

        else

            hopState.isHopping = false

        end

    end)



    Tabs.Server:AddSlider("HopDelay", {

        Title = "Retry Delay",

        Description = "Delay between hop attempts (seconds)",

        Default = 0.75,

        Min = 0.1,

        Max = 5,

        Rounding = 2,

        Callback = function(Value) CONFIG.RETRY_DELAY = Value end

    })

end



-- Addons: SaveManager & InterfaceManager

SaveManager:SetLibrary(Fluent)

InterfaceManager:SetLibrary(Fluent)



SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})



InterfaceManager:SetFolder("FluentScriptHub")

SaveManager:SetFolder("FluentScriptHub/specific-game")



InterfaceManager:BuildInterfaceSection(Tabs.Settings)

SaveManager:BuildConfigSection(Tabs.Settings)



Window:SelectTab(9) -- Auto Select Graphics Tab



Fluent:Notify({

    Title = "HaiHub Enhanced v4.4",

    Content = "FullBright Enabled!",

    Duration = 7

})



SaveManager:LoadAutoloadConfig()
