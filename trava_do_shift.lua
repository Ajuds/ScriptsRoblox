-- Roblox Shift Lock Simulator
-- LocalScript - Coloque em StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Estado da trava
local shiftLockActive = false

-- Função para alternar a trava
local function toggleShiftLock()
    shiftLockActive = not shiftLockActive
end

-- Função para processar texto conforme a trava
local function processText(text)
    if shiftLockActive then
        return string.upper(text)
    end
    return text
end

-- Capturar tecla M para alternar
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.M then
        toggleShiftLock()
    end
end)

-- Interceptar entrada de texto em TextBoxes
local function setupTextBox(textBox)
    if not textBox:IsA("TextBox") then return end
    
    local originalText = ""
    local cursorPosition = 0
    
    textBox.Focused:Connect(function()
        originalText = textBox.Text
    end)
    
    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        if not textBox:IsFocused() then return end
        
        local newText = textBox.Text
        local processedText = processText(newText)
        
        if processedText ~= newText then
            textBox.Text = processedText
        end
        
        originalText = textBox.Text
    end)
end

-- Aplicar a todos os TextBoxes existentes e futuros
local function scanForTextBoxes(parent)
    for _, child in pairs(parent:GetChildren()) do
        setupTextBox(child)
        scanForTextBoxes(child)
    end
end

-- Configurar TextBoxes existentes
scanForTextBoxes(playerGui)

-- Configurar TextBoxes que forem criados
playerGui.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("TextBox") then
        setupTextBox(descendant)
    end
end)

-- Configurar chat (se acessível)
local function setupChat()
    local chatGui = playerGui:FindFirstChild("Chat")
    if chatGui then
        scanForTextBoxes(chatGui)
    end
end

-- Tentar configurar chat quando estiver disponível
spawn(function()
    while not playerGui:FindFirstChild("Chat") do
        wait(1)
    end
    setupChat()
end)

-- Interceptar entrada de chat diretamente (método alternativo)
local chatInputConnection
local function setupChatInput()
    if chatInputConnection then
        chatInputConnection:Disconnect()
    end
    
    chatInputConnection = UserInputService.TextBoxFocused:Connect(function(textBox)
        if textBox.Name == "ChatBar" or textBox.Parent.Name:find("Chat") then
            setupTextBox(textBox)
        end
    end)
end

setupChatInput()

-- Função para verificar estado (para debug)
_G.isShiftLockActive = function()
    return shiftLockActive
end

-- Função para alternar manualmente (para debug)
_G.toggleShiftLock = function()
    toggleShiftLock()
end
