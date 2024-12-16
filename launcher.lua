-- Booting up the library --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() 

-- Creating a Window -- 
local Window = Rayfield:CreateWindow({
    Name = "Project Solstice",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Project Solstice",
    LoadingSubtitle = "by veneepl",
    Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = false,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = "https://raw.githubusercontent.com/VeNePL/projectsolstice/refs/heads/main/public_key.txt" -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })

-- Main --
local TabMAIN = Window:CreateTab("Main", 4483362458) -- Title, Image
local ParagraphVER = TabMAIN:CreateParagraph({Title = "Project Solstice", Content = "Version: 1.00"})


-- Auto --
local TabAF = Window:CreateTab("Automatic", 4483362458) -- Title, Image

local SectionAR = TabAF:CreateSection("Auto Roll The Dice")
local isRolling = false -- Zmienna kontrolująca stan toggle
local Toggle = TabAF:CreateToggle({ -- Dodaj toggle do sekcji
    Name = "Roll Eggs",
    CurrentValue = false,
    Flag = "EggRollToggle",
    Callback = function(state)
        isRolling = state
        if isRolling then
            --print("Egg Roll: Włączony")
            spawn(function()
                while isRolling do
                    -- Wywołanie serwera
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Eggs_Roll"):InvokeServer()
                    end)
                    if not success then
                        --warn("Błąd podczas wywoływania serwera: " .. err)
                    end
                    -- Dodaj opóźnienie, aby nie przeciążyć serwera
                    wait(0.25)
                end
            end)
        else
            --print("Egg Roll: Wyłączony")
        end
    end,
})

local SectionAB = TabAF:CreateSection("Auto Break Breakables")
local Paragraph = TabAF:CreateParagraph({Title = "Please make sure you have show other pets", Content = "disabled in settings for autofarm to work!"})

local Toggle = TabAF:CreateToggle({
    Name = "Wykonaj dla Breakables i Peta",
    Callback = function(isOn)
        if isOn then
            -- Ścieżka do breakables
            local breakablesFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Breakables")
            local petsFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Pets")

            local breakableNumbers = {} -- Tablica na numerki breakables
            local petNumbers = {} -- Tablica na numerki petów

            -- Szukanie numerków w breakables
            for _, group in pairs(breakablesFolder:GetChildren()) do
                if group:IsA("Model") or group:IsA("Folder") or group:IsA("Configuration") then
                    table.insert(breakableNumbers, group.Name) -- Dodaj nazwę grupy (numer breakable)
                end
            end

            -- Szukanie numerków w pets
            for _, pet in pairs(petsFolder:GetChildren()) do
                if pet:IsA("Model") then
                    table.insert(petNumbers, pet.Name) -- Dodaj nazwę modelu (numer peta)
                end
            end

            -- Sprawdzamy, czy znaleziono breakables i pety
            if #breakableNumbers == 0 then
                warn("Nie znaleziono żadnych breakables!")
                return
            end

            if #petNumbers == 0 then
                warn("Nie znaleziono żadnych petów!")
                return
            end

            -- Funkcja do wykonywania operacji dla wybranego breakable i petów
            local function executeForBreakableAndPets(selectedBreakable)
                -- Wypisanie wybranego breakable i peta w konsoli
                print("Wybrano breakable:", selectedBreakable)

                for _, selectedPet in ipairs(petNumbers) do
                    print("Wybrano peta:", selectedPet)

                    -- Wykonanie funkcji Pets_SetTargetBulk dla wybranego breakable i peta
                    local args1 = {
                        [1] = {
                            [selectedPet] = {
                                ["t"] = 2,          -- Typ celu
                                ["v"] = tonumber(selectedBreakable)  -- Numer wybranego breakable
                            }
                        }
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Pets_SetTargetBulk"):FireServer(unpack(args1))

                    -- Wykonanie funkcji Breakables_JoinPetBulk dla wybranego breakable i peta
                    local args2 = {
                        [1] = {
                            [selectedPet] = tonumber(selectedBreakable)  -- Numer wybranego breakable
                        }
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk"):FireServer(unpack(args2))
                end
            end

            -- Główna pętla, która będzie działać, dopóki toggle jest włączony
            while isOn do
                -- Wybór losowego breakable
                local selectedBreakable = breakableNumbers[math.random(1, #breakableNumbers)]

                -- Wykonanie operacji dla wybranego breakable i wszystkich petów
                executeForBreakableAndPets(selectedBreakable)

                -- Czekamy na zniszczenie breakable (tzn. kiedy zniknie)
                local breakableModel = breakablesFolder:WaitForChild(selectedBreakable)

                -- Funkcja do sprawdzenia, czy breakable zostało zniszczone i wybór nowego
                local function waitForBreakableDestruction()
                    local destroyed = false
                    breakableModel.AncestryChanged:Connect(function(_, parent)
                        if not parent then
                            -- Breakable zostało zniszczone
                            print("Zniszczono breakable:", selectedBreakable)

                            -- Usuwamy z listy breakableNumbers
                            for i, v in ipairs(breakableNumbers) do
                                if v == selectedBreakable then
                                    table.remove(breakableNumbers, i)
                                    break
                                end
                            end

                            -- Jeśli lista breakables jest pusta, zakończ działanie toggle
                            if #breakableNumbers == 0 then
                                print("Brak dostępnych breakables, toggle zostanie wyłączone.")
                                Toggle:SetValue(false)  -- Wyłącz toggle
                            end
                            destroyed = true
                        end
                    end)
                    -- Czekamy na zniszczenie breakable
                    while not destroyed do
                        wait(0.1)  -- Małe oczekiwanie, żeby nie blokować wątku
                    end
                end

                -- Czekamy na zniszczenie breakable przed wylosowaniem nowego
                waitForBreakableDestruction()

                -- Czekanie na następną iterację (dodajemy opóźnienie, aby nie wywoływać za szybko)
                wait(2)  -- Możesz dostosować czas oczekiwania
            end
        end
    end
})





local SectionAF = TabAF:CreateSection("Auto Eat Fruits") -- auto fruit eating
local Toggle = TabAF:CreateToggle({
    Name = "Auto Consume Fruits",
    CurrentValue = false,
    Flag = "AutoConsumeToggle",
    Callback = function(state)
        isConsuming = state
        if isConsuming then
            spawn(function()
                while isConsuming do
                    -- Wykonanie wywołania serwera dla każdego owocu
                    local fruits = {
                        "1d7f42de70524146a2c2b9398ee555a5", -- Owoc 1
                        "4ddfeb5030b847c38602cf8b8d7d11c1", -- Owoc 2
                        "80bde943da984126854fe6027546ee0d", -- Owoc 3
                        "30e1c817c4394675beeb156e00a0476f", -- Owoc 4
                        "dff7217793d64f73ac85c5de048e062c"  -- Owoc 5
                    }

                    -- Iteruj przez owoce
                    for _, fruitId in ipairs(fruits) do
                        local success, err = pcall(function()
                            local args = {
                                [1] = fruitId,
                                [2] = 1
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Fruits: Consume"):InvokeServer(unpack(args))
                        end)
                        if not success then
                            warn("Błąd podczas wywoływania serwera: " .. err)
                        end
                        -- Dodaj opóźnienie, aby nie przeciążyć serwera
                        wait(0.25) -- 0.25 sekundy opóźnienia między wywołaniami
                    end

                    -- Czekaj 3 minuty i 3 sekundy przed kolejnym cyklem
                    wait(183) -- 183 sekundy = 3 minuty 3 sekundy
                end
            end)
        else
            --print("Auto Consume: Wyłączony")
        end
    end,
})
local SectionAPM = TabAF:CreateSection("Auto Buy Potion") -- auto potion buy
local Toggle = TabAF:CreateToggle({
    Name = "Auto Purchase Potion",
    CurrentValue = false,
    Flag = "PotionPurchaseToggle",
    Callback = function(state)
        isPurchasing = state
        if isPurchasing then
            spawn(function()
                while isPurchasing do
                    -- Wykonaj zakup 10 razy co 3 sekundy
                    for i = 1, 10 do
                        local success, err = pcall(function()
                            local args = {
                                [1] = "PotionVendingMachine"
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("VendingMachines_Purchase"):InvokeServer(unpack(args))
                        end)
                        if not success then
                            warn("Błąd podczas wywoływania serwera: " .. err)
                        end
                        -- Czekaj 3 sekundy przed kolejnym zakupem
                        wait(3)
                    end

                    -- Czekaj 60 sekund przed rozpoczęciem kolejnego cyklu
                    wait(60) -- 60 sekundy = 1 minuta
                end
            end)
        else
            --print("Auto Purchase: Wyłączony")
        end
    end,
})



-- Misc --
local TabMisc = Window:CreateTab("Miscellanous", 4483362458) -- Title, Image

local SectionPLAYER = TabMisc:CreateSection("Player Movement")
local Slider = TabMisc:CreateSlider({
    Name = "Player Speed",
    Range = {16, 250},  -- Minimalna wartość 16, maksymalna 250
    Increment = 1,  -- Możliwość zmiany co 1
    Suffix = "Speed",
    CurrentValue = 16,  -- Domyślna wartość to 16
    Flag = "SpeedSlider",  -- Unikalny identyfikator dla tego slidera
    Callback = function(Value)
        -- Pobieramy lokalnego gracza
        local player = game.Players.LocalPlayer
        if player and player.Character then
            -- Pobieramy humanoida gracza
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value  -- Ustawiamy prędkość na wartość suwaka
            end
        end
    end,
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Tworzymy Slider
local Slider = TabMisc:CreateSlider({
   Name = "Prędkość Poruszania",
   Range = {16, 250}, -- Minimalna i maksymalna wartość
   Increment = 1, -- Dokładność zmiany
   Suffix = "Speed", -- Dodatek wyświetlany po wartości
   CurrentValue = 16, -- Wartość domyślna
   Flag = "Slider1", -- Unikalny identyfikator
   Callback = function(Value)
       -- Funkcja wewnętrzna zajmująca się prędkością
       local function UpdateWalkSpeed()
           local character = player.Character or player.CharacterAdded:Wait()
           local humanoid = character:FindFirstChild("Humanoid")
           if humanoid then
               humanoid.WalkSpeed = Value
           end
       end

       -- Obsługa zmiany prędkości po puszczeniu slidera
       Slider.MouseUp:Connect(UpdateWalkSpeed)

       -- Obsługa respawnu gracza
       player.CharacterAdded:Connect(function(newCharacter)
           local humanoid = newCharacter:WaitForChild("Humanoid")
           humanoid.WalkSpeed = Value -- Przywraca wartość slidera przy respawnie
       end)
   end,
})



local SectionDESTROY = TabMisc:CreateSection("Destroy The GUI")
local Button = TabMisc:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
    Rayfield:Destroy() -- The function that takes place when the button is pressed
    end,
 })



