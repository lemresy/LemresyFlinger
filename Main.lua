
local Prefix = ";"
local Duration = 150
--[[
Commands:
;targetname - flings the target, just use the prefix and name
;sp - teleports to spawnlocation
;fixcam - fixes camera
you can always rerun the script anytime, its not gonna glitch out
]]
--[[
todo:

]]
local function Message(Text)
	warn(Text)
	game.StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = Text,
		Color = Color3.fromRGB(255, 0, 0),
		TextSize = 20
	})
end
local Plr = game:GetService("Players").LocalPlayer
local Running = false
local SpawnPoint = workspace:FindFirstChildOfClass("SpawnLocation",true) and workspace:FindFirstChildOfClass("SpawnLocation",true) or CFrame.new(0,20,0)
if shared.ChatEvent then shared.ChatEvent:Disconnect() end
local function Fling(TargetName)
	local Target = game:GetService("Players"):FindFirstChild(TargetName)
	if not Target then
		Message("Error! Target isn't in game")
		return
	end
	if Target.Name == Plr.Name then
		Message("Error! You Targetted yourself")
		return
	end
	Message("Currently Targetted: "..TargetName)
	local Stop = false
	local MA = math.random
	local Character = Plr["Character"] or Plr["CharacterAdded"]:Wait()
	local Root = Character:WaitForChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	local TargetChar = workspace:FindFirstChild(Target.Name) or workspace:FindFirstChild("Players"):WaitForChild(Target.Name)
	local TargetHum = TargetChar:FindFirstChildWhichIsA("Humanoid")
	if TargetHum.Sit == true then
		Message("Error! (Target is sitting)")
		return
	end
	Running = true
	local OldCamera = workspace.CurrentCamera.CameraSubject
	workspace.CurrentCamera.CameraSubject = TargetHum
	local TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart") or TargetChar:FindFirstChild("Torso") or TargetChar:FindFirstChild("UpperTorso")
	local TargetHead = TargetChar:WaitForChild("Head")
	local OldPos = Root.CFrame
	local Noclip = game:GetService("RunService").Stepped:Connect(function()
		for _, v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end)
	local Thrust = Instance.new("BodyThrust")
	Thrust.Force = Vector3.new(12500,0,12500)
	Thrust.Location = Vector3.new(-10,5,10)
	Thrust.Parent = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	local HB = game:GetService("RunService").Heartbeat:Connect(function()
		if Humanoid.Sit == true then Humanoid.Sit = false end
		Root.CFrame = TargetRoot.CFrame * CFrame.new(MA(-4,4),0,MA(-4,4))
		if Root.Position.Y <= workspace.FallenPartsDestroyHeight + 200 then
			Stop = true
			Character:MoveTo(SpawnPoint.Position)
		end
	end)
	for i = 0, 150+Duration do
		if TargetHead.RotVelocity.Magnitude >= 40 then
			Message("Flinged ".. TargetName); Stop = true
			break
		end
		if i == 150+Duration then
			Message("Failed to fling."); Stop = true
			break
		end
		task.wait(0.02)
	end
	while Stop == true do
		task.spawn(function()
			task.wait(1)
			workspace.CurrentCamera.CameraSubject = OldCamera
		end)
		Thrust:Destroy()
		Noclip:Disconnect()
		HB:Disconnect()
		Root.Anchored = false
		Stop = false
		for i = 0,4 do
			Root.Velocity = Vector3.new()
			Root.RotVelocity = Vector3.new()
			Character:MoveTo(OldPos.Position)
			task.wait(0.2)
		end
		Running = false
		break
	end
end
shared.ChatEvent = Plr.Chatted:Connect(function(Message)
	if string.match(Message, Prefix) then
		local NewMessage = string.split(Message, Prefix)
		for _,v in pairs(game:GetService("Players"):GetChildren()) do
			if (string.match(string.lower(v.Name), string.lower(NewMessage[2])) or string.find(string.lower(v.DisplayName), string.lower(NewMessage[2]))) and NewMessage[2] ~= "back" and NewMessage[2] ~= "fixcam" then
				task.spawn(function()
					if Running == false then Fling(v.Name) end
				end)
			end
		end
		if NewMessage[2] == "back" then
			local Character = Plr["Character"] or Plr["CharacterAdded"]:Wait()
			local Root = Character:WaitForChild("HumanoidRootPart")
			for i = 0,3 do
				Root.Velocity = Vector3.new()
				Root.RotVelocity = Vector3.new()
				Character:MoveTo(SpawnPoint.Position)
				task.wait(0.2)
			end
		end
		if NewMessage[2] == "fixcam" then
			local Character = Plr["Character"] or Plr["CharacterAdded"]:Wait()
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
			workspace.CurrentCamera.CameraSubject = Humanoid
		end
	end
end)
Message("FE Flinger --// Made by Lemresy")
