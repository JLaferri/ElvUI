local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub, next = gsub, next
local hooksecurefunc = hooksecurefunc

local function ReplaceTextColor(text, r, g, b)
	if r ~= 1 or g ~= 1 or b ~= 1 then
		text:SetTextColor(1, 1, 1)
	end
end

local GossipTextColors = {
	['000000'] = 'ffffff',
	['414141'] = '7b8489',
}

local function ReplaceGossipColor(color)
	return '|cFF' .. (GossipTextColors[color] or color)
end

local function ReplaceGossipFormat(button, textFormat, text, skip)
	if skip or not text or text == '' then return end

	local formatText, formatCount = gsub(textFormat, '|c[fF][fF](%x%x%x%x%x%x)', ReplaceGossipColor)
	if formatCount > 0 then
		button:SetFormattedText(formatText, text, true)
	end
end

local function ReplaceGossipText(button, text)
	if not text or text == '' then return end

	local startText = text

	local iconText, iconCount = gsub(text, ':32:32:0:0', ':32:32:0:0:64:64:5:59:5:59')
	if iconCount > 0 then text = iconText end

	local colorText, colorCount = gsub(text, '|c[fF][fF](%x%x%x%x%x%x)', ReplaceGossipColor)
	if colorCount > 0 then text = colorText end

	if startText ~= text then
		button:SetFormattedText('%s', text, true)
	end
end

local function ItemTextPage_SetTextColor(pageText, headerType, r, g, b)
	if r ~= 1 or g ~= 1 or b ~= 1 then
		pageText:SetTextColor(headerType, 1, 1, 1)
	end
end

local function GreetingPanel_Update(frame)
	for _, button in next, { frame.ScrollTarget:GetChildren() } do
		if not button.IsSkinned then
			if button.GreetingText then
				button.GreetingText:SetTextColor(1, 1, 1)
				hooksecurefunc(button.GreetingText, 'SetTextColor', ReplaceTextColor)
			end

			local fontString = button.GetFontString and button:GetFontString()
			if fontString then
				fontString:SetTextColor(1, 1, 1)
				hooksecurefunc(fontString, 'SetTextColor', ReplaceTextColor)

				ReplaceGossipText(button, button:GetText())
				hooksecurefunc(button, 'SetText', ReplaceGossipText)
				hooksecurefunc(button, 'SetFormattedText', ReplaceGossipFormat)
			end

			button.IsSkinned = true
		end
	end
end

local function createParchment(frame)
	local tex = frame:CreateTexture(nil, 'ARTWORK')
	tex:SetTexture([[Interface\QuestFrame\QuestBG]])
	tex:SetTexCoord(0, 0.586, 0.02, 0.655)
	return tex
end

function S:GossipFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gossip) then return end

	local GossipFrame = _G.GossipFrame
	S:HandlePortraitFrame(GossipFrame, true)
	S:HandleScrollBar(_G.ItemTextScrollFrameScrollBar)
	S:HandleCloseButton(_G.ItemTextCloseButton)

	local GreetingPanel = _G.GossipFrame.GreetingPanel
	S:HandleTrimScrollBar(GreetingPanel.ScrollBar)
	S:HandleButton(GreetingPanel.GoodbyeButton, true)

	GreetingPanel:StripTextures()
	GreetingPanel:CreateBackdrop('Transparent')
	GreetingPanel.backdrop:Point('TOPLEFT', GreetingPanel.ScrollBox, 0, 0)
	GreetingPanel.backdrop:Point('BOTTOMRIGHT', GreetingPanel.ScrollBox, 0, 80)

	local ItemTextFrame = _G.ItemTextFrame
	ItemTextFrame:StripTextures()
	ItemTextFrame:CreateBackdrop('Transparent')
	ItemTextFrame.backdrop:ClearAllPoints()
	ItemTextFrame.backdrop:Point('TOPLEFT', ItemTextFrame, 5, -10)
	ItemTextFrame.backdrop:Point('BOTTOMRIGHT', ItemTextFrame, -25, 45)

	local ItemTextScrollFrame = _G.ItemTextScrollFrame
	ItemTextScrollFrame:DisableDrawLayer('ARTWORK')
	ItemTextScrollFrame:DisableDrawLayer('BACKGROUND')

	GossipFrame.backdrop:ClearAllPoints()
	GossipFrame.backdrop:Point('TOPLEFT', GreetingPanel.ScrollBox, -10, 70)
	GossipFrame.backdrop:Point('BOTTOMRIGHT', GreetingPanel.ScrollBox, 40, 40)

	S:HandleNextPrevButton(_G.ItemTextNextPageButton)
	S:HandleNextPrevButton(_G.ItemTextPrevPageButton)

	if E.private.skins.parchmentRemoverEnable then
		_G.QuestFont:SetTextColor(1, 1, 1)
		_G.ItemTextPageText:SetTextColor('P', 1, 1, 1)

		hooksecurefunc(_G.ItemTextPageText, 'SetTextColor', ItemTextPage_SetTextColor)
		hooksecurefunc(GreetingPanel.ScrollBox, 'Update', GreetingPanel_Update)

		if GossipFrame.Background then
			GossipFrame.Background:Hide()
		end
	else
		local spellTex = createParchment(GreetingPanel)
		spellTex:SetInside(GreetingPanel.backdrop)
		GreetingPanel.spellTex = spellTex

		local itemTex = createParchment(ItemTextFrame)
		itemTex:SetInside(ItemTextScrollFrame, -5)
		ItemTextFrame.itemTex = itemTex
	end
end

S:AddCallback('GossipFrame')
