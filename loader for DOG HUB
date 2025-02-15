local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- สร้าง GUI หลัก
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "DOGHUBLoader"
LoaderGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- สร้างพื้นหลัง
local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BackgroundTransparency = 0.5
Background.Parent = LoaderGui

-- สร้างเฟรมโหลด
local LoaderFrame = Instance.new("Frame")
LoaderFrame.Name = "LoaderFrame"
LoaderFrame.Size = UDim2.new(0, 300, 0, 150)
LoaderFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
LoaderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LoaderFrame.Parent = LoaderGui

-- ทำมุมโค้ง
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = LoaderFrame

-- สร้างข้อความหัว
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "DOG HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = LoaderFrame

-- แถบโหลด
local LoadBar = Instance.new("Frame")
LoadBar.Name = "LoadBar"
LoadBar.Size = UDim2.new(0, 0, 0, 10)
LoadBar.Position = UDim2.new(0.1, 0, 0.6, 0)
LoadBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
LoadBar.Parent = LoaderFrame

local LoadBarCorner = Instance.new("UICorner")
LoadBarCorner.CornerRadius = UDim.new(0, 5)
LoadBarCorner.Parent = LoadBar

-- ข้อความสถานะ
local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.8, 0)
Status.Text = "กำลังโหลด..."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 16
Status.Font = Enum.Font.GothamSemibold
Status.BackgroundTransparency = 1
Status.Parent = LoaderFrame

-- ฟังก์ชันโหลด
local function StartLoading()
    local loadTween = TweenService:Create(LoadBar, 
        TweenInfo.new(2, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0.8, 0, 0, 10)}
    )
    
    loadTween:Play()
    wait(0.5)
    Status.Text = "กำลังเริ่มต้น..."
    wait(0.5)
    Status.Text = "กำลังโหลดระบบ..."
    wait(0.5)
    Status.Text = "กำลังเตรียมพร้อม..."
    wait(0.5)
    Status.Text = "เสร็จสิ้น!"
    
    -- โหลดสคริปต์หลัก
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Munichop784/Dog-hub/main/main.lua"))()
    
    -- ลบตัวโหลดออก
    wait(0.5)
    LoaderGui:Destroy()
end

StartLoading()
