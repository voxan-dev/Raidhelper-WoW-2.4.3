local check_libraries
do
	local global_libs = {
		"LibStub",
		"LibDataBroker-1.1",
		-- "DoesNotExist-Global",
		}
function check_libraries ()
		local missing = {}

		for _, name in ipairs(global_libs) do
			if not _G[name] then
				table.insert(missing, name)
			end
		end

		if #missing > 0 then
			local message = ("Grid was unable to find the following libraries:\n%s"):format(table.concat(missing, ", "))

			StaticPopupDialogs["GRID_MISSING_LIBS"] = {
				text = message,
				button1 = "Okay",
				timeout = 0,
				whileDead = 1,
			}

			StaticPopup_Show("GRID_MISSING_LIBS")
		end
	end		
end		
		
local Raidhelper = "Raidhelper"
local LDB = LibStub("LibDataBroker-1.1")
local icon = "Interface\\Icons\\Ability_Warrior_BattleShout"

local dataobj = LDB:NewDataObject(Raidhelper, {
    type = "launcher",
    label = Raidhelper,
    icon = icon,
    OnClick = function(self, button)
        if button == "LeftButton" then
            if RaidhelperFrame:IsShown() then
                RaidhelperFrame:Hide()
            else
                RaidhelperFrame:Show()
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText(Raidhelper)
        tooltip:AddLine("Click to toggle GUI")
    end,
})

-- Create GUI frame
local frame = CreateFrame("Frame", "RaidhelperFrame", UIParent)
frame:SetWidth(200)
frame:SetHeight(100)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", frame.StartMoving)
frame:SetScript("OnMouseUp", frame.StopMovingOrSizing)
frame:Hide()
frame:RegisterForDrag("LeftButton")
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
frame:SetBackdropBorderColor(1, 1, 1, 1)

frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Create buttons for functions
local showHideBtn = CreateFrame("Button", "ShowHideBtn", frame, "UIPanelButtonTemplate")
showHideBtn:SetWidth(100)
showHideBtn:SetHeight(25)
showHideBtn:SetPoint("TOPLEFT", 10, -10)
showHideBtn:SetText("Show/Hide GUI")
showHideBtn:SetScript("OnClick", function() if frame:IsShown() then frame:Hide() else frame:Show() end end)

local readyCheckBtn = CreateFrame("Button", "ReadyCheckBtn", frame, "UIPanelButtonTemplate")
readyCheckBtn:SetWidth(100)
readyCheckBtn:SetHeight(25)
readyCheckBtn:SetPoint("TOPLEFT", 10, -40)
readyCheckBtn:SetText("Ready Check")
readyCheckBtn:SetScript("OnClick", function() DoReadyCheck() end)

-- Function for 10s countdown in raid warning chat
function countdownTenSec()
    local frame = CreateFrame("Frame")
	local count = 10

	frame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 1 then
			if count > 0 then
				SendChatMessage("Countdown: " .. count, "RAID_WARNING")
			else
				SendChatMessage("Countdown finished!", "RAID_WARNING")
				self:SetScript("OnUpdate", nil)
			end
			count = count - 1
			self.elapsed = 0
		end
	end)
end

-- Function for 5s countdown in raid warning chat
function countdownFiveSec()
    local frame = CreateFrame("Frame")
	local count = 5

	frame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 1 then
			if count > 0 then
				SendChatMessage("Countdown: " .. count, "RAID_WARNING")
			else
				SendChatMessage("Countdown finished!", "RAID_WARNING")
				self:SetScript("OnUpdate", nil)
			end
			count = count - 1
			self.elapsed = 0
		end
	end)
end

-- Create buttons for countdowns
local countdown10Btn = CreateFrame("Button", "Countdown10Btn", frame, "UIPanelButtonTemplate")
countdown10Btn:SetWidth(100)
countdown10Btn:SetHeight(25)
countdown10Btn:SetPoint("TOPLEFT", 10, -70)
countdown10Btn:SetText("10 Sec Countdown")
countdown10Btn:SetScript("OnClick", function() countdownTenSec() end)

local countdown5Btn = CreateFrame("Button", "Countdown5Btn", frame, "UIPanelButtonTemplate")
countdown5Btn:SetWidth(100)
countdown5Btn:SetHeight(25)
countdown5Btn:SetPoint("TOPLEFT", 10, -100)
countdown5Btn:SetText("5 Sec Countdown")
countdown5Btn:SetScript("OnClick", function() countdownFiveSec() end)

SLASH_RH1 = "/rh"

-- Function to handle the slash command
SlashCmdList["RH"] = function()
    if GetAddOnMetadata("Raidhelper", "Title") then
        RaidhelperFrame:Show()
        DEFAULT_CHAT_FRAME:AddMessage("GUI shown with /rh command for Raidhelper addon.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("Raidhelper addon not found.")
    end
end

