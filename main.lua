local currentTitleCategory = "main"
local currentTitleIndex = 1

local TitleAssets

local Alphabet = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}

local Audio = {
    Sounds = {},
    Music = {}
}

local function GetRandomNumber(MinValue, MaxValue)
    if not MinValue or type(MinValue) ~= "number" then
        return print("Invalid MinValue for `GetRandomNumber()` method, please provide a valid numeric value!")
    end

    if not MaxValue or type(MaxValue) ~= "number" then
        return print("Invalid MaxValue for `GetRandomNumber()` method, please provide a valid numeric value!")
    end

    math.randomseed(os.time())
    return math.random() and math.random() and math.random() and math.random(MinValue, MaxValue)
end

local function GetRandomString(MaxLength)
    if not MaxLength or type(MaxLength) ~= "number" then
        return print("Could not use MaxLength: " .. tostring(MaxLength) .. " due to it either not being provided or the value provided not being a number value!\nPlease only provide a number value for the `GetRandomString()` method!")
    end

    local str = ""

    for i = 1, MaxLength do
        str = str .. Alphabet[math.random(1, #Alphabet)]
    end

    return str
end

local function LoadAudio(Filepath, IsMusic, EntryName)
    if not Filepath or type(Filepath) ~= "string" then
        return print("Could not use Filepath: " .. tostring(Filepath) .. " within the `LoadAudio()` function!\nPlease provide a valid String value!")
    end

    if type(IsMusic) ~= "boolean" then
        return print("Could not use `IsMusic` value: " .. tostring(IsMusic) .. " within the `LoadAudio()` function!\nPlease provide aa valid Boolean value!")
    end

    local data = love.filesystem.getInfo(Filepath)

    if data.type ~= "file" then
        return print("`LoadAudio()` could not dictate that file with path: " .. tostring(Filepath) .. " is, in actuality, a file.\nPlease make sure you've written the filepath in correctly!")
    end

    if not EntryName or type(EntryName) ~= "string" then
        EntryName = GetRandomString(10)
    end

    local audioData = nil

    if IsMusic then
        audioData = love.audio.newSource(Filepath, "stream")
        Audio.Music[EntryName] = audioData
    else
        audioData = love.audio.newSource(Filepath, "static")
        Audio.Sounds[EntryName] = audioData
    end

    return audioData
end

local function SwitchFrame(Target)
    if not Target or type(Target) ~= "string" then
        return print("Could not use Target: " .. tostring(Target) .. " in `SwitchFrame` function!")
    end

    if not TitleAssets.Indexes[Target] or type(TitleAssets.Indexes[Target]) ~= "table" then
        return print("Could not find Target: " .. tostring(Target) .. " within `TitleAssets.Indexes`!")
    end

    currentTitleIndex = 1
    currentTitleCategory = Target
end

TitleAssets = {
    Settings = {
        Cursor = ">",
        XOffset = 15,
        YOffset = 20,
        BackgroundColor = {
           r = 0,
           g = 0,
           b = 0
        }
    },
   
    Indexes = {
        ["main"] = {
            [1] = {
                Text = "Play Game",
                Method = function()
                    SwitchFrame("play")
                end
            },
    
            [2] = {
                Text = "Settings",
                Method = function()
                    SwitchFrame("settings")
                end
            },
    
            [3] = {
                Text = "Credits",
                Method = function()
                    SwitchFrame("credits")
                end
            },
    
            [4] = {
                Text = "Exit Game",
                Method = function()
                    SwitchFrame("exit")
                end
            }
        },

        ["play"] = {
            [1] = {
                Text = "Start Game",
                Method = function()
                    print("START GAME HERE!")
                end
            },
            
            [2] = {
                Text = "Back to Main Menu",
                Method = function()
                    SwitchFrame("main")
                end,
            }
        },

        ["settings"] = {
            [1] = {
                Text = "Back to Main Menu",
                Method = function()
                    SwitchFrame("main")
                end,
            }
        },

        ["credits"] = {
            [1] = {
                Text = "Back to Main Menu",
                Method = function()
                    SwitchFrame("main")
                end,
            }
        },

        ["exit"] = {
            [1] = {
                Text = "Yes, I'd like to quit!",
                Method = function()
                    love.event.quit()
                end
            },

            [2] = {
                Text = "No, I don't want to quit.",
                Method = function()
                    SwitchFrame("main") 
                end
            }
        }
    }
}

local function CycleUp()
    local target = currentTitleIndex - 1
    local playSound = true

    if target < 1 then
        target = 1
        playSound = false
    end

    currentTitleIndex = target

    if not playSound then
        return
    end

    if Audio.Sounds.Highlight.isPlaying then
        Audio.Sounds.Highlight:stop()
    end

    Audio.Sounds.Highlight:play()
end

local function CycleDown()
    local target = currentTitleIndex + 1
    local playSound = true

    if target > #TitleAssets.Indexes[currentTitleCategory] then
        target = #TitleAssets.Indexes[currentTitleCategory]
        playSound = false
    end

    currentTitleIndex = target

    if not playSound then
        return
    end

    if Audio.Sounds.Highlight.isPlaying then
        Audio.Sounds.Highlight:stop()
    end

    Audio.Sounds.Highlight:play()
end

local function SelectIndex()
    local target = TitleAssets.Indexes[currentTitleCategory][currentTitleIndex]

    if not target or type(target) ~= "table" then
        return
    end

    if Audio.Sounds.Select.isPlaying then
        Audio.Sounds.Select:stop()
    end

    Audio.Sounds.Select:play()

    target.Method()
end

local KeyMethods = {
    ["update"] = {
        -- >> [TODO] INSERT UPDATE KEYBINDS HERE!
    },

    ["poll"] = {
        ["up"] = CycleUp,
        ["down"] = CycleDown,

        ["w"] = CycleUp,
        ["s"] = CycleDown,

        ["return"] = SelectIndex,
        ["space"] = SelectIndex,

        ["escape"] = function()
            love.event.quit()
        end
    }
}

function love.load()
    local sound = LoadAudio("assets/audio/sounds/select.mp3", false, "Select")
    sound:setVolume(0.5)

    sound = LoadAudio("assets/audio/sounds/highlight.mp3", false, "Highlight")
    sound:setVolume(0.5)

    local choices = {
        [1] = "lease",
        [2] = "frutiger"
    }

    local music = LoadAudio("assets/audio/music/" .. choices[GetRandomNumber(1, #choices)] .. ".mp3", true)
    
    music:setVolume(0.25)
    music:setLooping(true)
    
    music:play()
end

function love.keypressed(key)
    local method = KeyMethods["poll"][key]

    if not method or type(method) ~= "function" then
        return
    end

    method()
end

function love.keyreleased(key)
    
end

function love.quit()
    print("QUITTING!")
end

function love.update(deltaTime)
   for key, method in pairs(KeyMethods["update"]) do
        if love.keyboard.isDown(key) then
            method()
        end
   end
end

function love.draw()
    local r, g, b = love.math.colorFromBytes(
        TitleAssets.Settings.BackgroundColor.r,
        TitleAssets.Settings.BackgroundColor.g,
        TitleAssets.Settings.BackgroundColor.b
    )
    
    love.graphics.setBackgroundColor(r, g, b)

    for index, data in pairs(TitleAssets.Indexes[currentTitleCategory]) do
        local preText = ""
        
        if index == currentTitleIndex then
            preText = TitleAssets.Settings.Cursor .. " "
        end

        love.graphics.print(
            preText .. data.Text, 
            TitleAssets.Settings.XOffset, 
            TitleAssets.Settings.YOffset * index
        )
    end
end