local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/synolope/meepcracked/main/ui-engine.lua"))()

local function loopwrap(func,int)
	local connect = nil
	return function(b)
		if connect then
			connect:Disconnect()
			connect = nil
		end
		if b then
			local i = 0
			connect = game.RunService.Heartbeat:Connect(function()
				i = i + 1
				if tonumber(int) then
					if i%int == 0 then
						func()
					end
				else
					func()
				end
			end)
		end
	end
end

local function getclosestplr()
	local LP = game.Players.LocalPlayer
	local c = LP.Character

	local closedist = nil
	local closeplr = nil
	if c then
		local root = c:FindFirstChild("HumanoidRootPart")
		if root then
			for _,plr in pairs(game.Players:GetPlayers()) do
			    if plr ~= LP then 
				local pc = plr.Character
				if pc then
					local proot = pc:FindFirstChild("HumanoidRootPart")
					if proot then
						local dist = (root.Position - proot.Position).Magnitude
						if not closedist or dist < closedist then
							closedist = dist
							closeplr = plr
						end
					end
				end
				end
			end
		end
	end
	return closeplr
end

local function checkdir()
    if not isfolder("meepcracked") then
        makefolder("meepcracked")
    end
end

local guiname = "MeepCracked"

if identifyexecutor then
    guiname = guiname .. " - " .. identifyexecutor()
    
end

local Window = library:AddWindow(guiname, {
	main_color = Color3.fromRGB(245, 117, 66),
	min_size = Vector2.new(500, 600),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
})

local Welcome = Window:AddTab("Welcome")
Welcome:AddLabel("Thank you for using MeepCracked.")
Welcome:AddButton("Join Our Discord Server",function()
    local Settings = {
        InviteCode = "UtpqrGp29a" --add your invite code here (without the "https://discord.gg/" part)
    }
    
    -- Objects
    local HttpService = game:GetService("HttpService")
    local RequestFunction
    
    if syn and syn.request then
        RequestFunction = syn.request
    elseif request then
        RequestFunction = request
    elseif http and http.request then
        RequestFunction = http.request
    elseif http_request then
        RequestFunction = http_request
    end
    
    local DiscordApiUrl = "http://127.0.0.1:%s/rpc?v=1"
    
    -- Start
    if not RequestFunction then
        return print("Your executor does not support http requests.")
    end
    
    for i = 6453, 6464 do
        local DiscordInviteRequest = function()
            local Request = RequestFunction({
                Url = string.format(DiscordApiUrl, tostring(i)),
                Method = "POST",
                Body = HttpService:JSONEncode({
                    nonce = HttpService:GenerateGUID(false),
                    args = {
                        invite = {code = Settings.InviteCode},
                        code = Settings.InviteCode
                    },
                    cmd = "INVITE_BROWSER"
                }),
                Headers = {
                    ["Origin"] = "https://discord.com",
                    ["Content-Type"] = "application/json"
                }
            })
        end
        spawn(DiscordInviteRequest)
    end
end)
local Throwing = Window:AddTab("Throwing")
local Action = Window:AddTab("Action Items")
local Local = Window:AddTab("Local")
Local:AddLabel("( This is only for you. No one else can see these changes. )")

local items = {
	["Spitball"] = 1178,
	["Snowball (Cum)"] = 932,
	["Egg"] = 602,
	["Golden Egg"] = 1122
}

local selecteditem = nil

local Dropdown = Throwing:AddDropdown("Throwing Item", function(itemname)
	selecteditem = items[itemname]
end)

for i,v in pairs(items) do
	Dropdown:Add(i)
end

local function hit(player)
	if selecteditem and player.Character and player.Character:FindFirstChild("Head") then
		local targetpos = player.Character.Head.Position
		local Global = require(game:GetService("ReplicatedStorage").Global)
		game:GetService("ReplicatedStorage").ConnectionEvent:FireServer(226, game:GetService("HttpService"):JSONEncode({selecteditem,Global.ConcatenateVector3(targetpos),Global.ConcatenateVector3(targetpos),Global.ConcatenateVector3(targetpos),0}))
	end
end

local function throwall()
	for _,player in pairs(game.Players:GetPlayers()) do
		hit(player)
	end
end

Throwing:AddButton("Throw At Clostest Player",function()
	hit(getclosestplr())
end)
Throwing:AddButton("Throw At All Players",throwall)
Throwing:AddSwitch("Loop Throw At All Players",loopwrap(throwall,10))

Local:AddSwitch("Anti Snowball Screen",loopwrap(function()
	local t = require(game.Players.LocalPlayer.PlayerGui:WaitForChild("ThrowingItemGui"):WaitForChild("ThrowingItemGUI"))
	t.SetHitByContainerEnabled(false)
end))

local actionitems = {}

local selectedaitem = nil

for i,v in pairs(require(game.ReplicatedStorage.AssetList)) do
	if v and v.ActionItemParentAssetId then
		actionitems[v.Title] = i
	end
end

local Dropdown = Action:AddDropdown("Action Item", function(itemname)
	selectedaitem = actionitems[itemname]
end)

for i,v in pairs(actionitems) do
	Dropdown:Add(i)
end

Action:AddButton("Equip Item",function()
	if selectedaitem then
		game.Players.LocalPlayer.VirtualWorldFunctions.RequestActionItem:Invoke(selectedaitem)
	end
end)

Action:AddSwitch("Spam Equip",loopwrap(function()
	if selectedaitem then
		game.Players.LocalPlayer.VirtualWorldFunctions.RequestActionItem:Invoke(selectedaitem)
	end
end))

Local:AddTextBox("Set World Background Music ID",function(id)
    if tonumber(id) then
        checkdir()
        writefile("meepcracked\\bgmusic.txt",id)
        require(game:GetService("ReplicatedStorage").ClientClasses.VirtualWorld).SetBackgroundMusic(id,.5,true)
    end
end)

checkdir()

if isfile("meepcracked\\bgmusic.txt") then
    require(game:GetService("ReplicatedStorage"):WaitForChild("ClientClasses"):WaitForChild("VirtualWorld")).SetBackgroundMusic(readfile("meepcracked\\bgmusic.txt"),.5,true)
end

Welcome:Show()
library:FormatWindows()