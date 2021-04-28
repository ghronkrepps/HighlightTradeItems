local addonName = 'HighlightTradeItems';
local version = '1.0';
local addon = CreateFrame('Button', addonName);
local tip = CreateFrame("GameTooltip","Tooltip",nil,"GameTooltipTemplate")

local defaultSlotWidth, defaultSlotHeight = 68, 68;

htiDefaultConfig = {
    ['enabled'] = 1
}

addon:RegisterEvent('ADDON_LOADED');
addon:RegisterEvent('PLAYER_ENTERING_WORLD');
addon:RegisterEvent('BAG_UPDATE');

addon:SetScript('OnEvent', function(self, event, arg1) self[event](self, arg1) end);

function addon:PLAYER_ENTERING_WORLD()
	if (not htiConfig) then		
		htiConfig = {["enabled"] = true	}
	end	
end

function addon:ADDON_LOADED(arg1)
    if (arg1 == addonName) then
		
        print('|cFFFFFF00Highlight Trade Items v' .. version .. ':|cFFFFFFFF Type /hti for configuration');

        hooksecurefunc('ToggleBackpack', function() addon:backpack_OnShow() end);
        hooksecurefunc('ToggleBag', function(id) addon:bag_OnToggle(id) end);
    end
end

function addon:BAG_UPDATE(arg1)
    addon:refreshBag(arg1);
end

function addon:backpack_OnShow()
    local containerFrame = _G['ContainerFrame1'];

    if (containerFrame.allBags == true) then
        addon:refreshAllBags()
    end
end

function addon:refreshAllBags()
    for bagId = 0, NUM_BAG_SLOTS do
        OpenBag(bagId);
        addon:refreshBag(bagId);
    end
end

function addon:bag_OnToggle(bagId)
    addon:refreshBag(bagId);
end

function addon:refreshBag(bagId)
    local frameId = IsBagOpen(bagId);

    if (frameId) then
        local nbSlots = GetContainerNumSlots(bagId);

        for slot = 1, nbSlots do
            slotFrameId = nbSlots + 1 - slot;
            local slotFrameName = 'ContainerFrame' .. frameId .. 'Item' .. slotFrameId;
            addon:updateContainerSlot(bagId, slot, slotFrameName, htiConfig.enabled);
        end
    end
end

function addon:updateContainerSlot(containerId, slotId, slotFrameName, show)
    local show = show or 1;

    item = _G[slotFrameName];

    if (not item.qborder) then
        item.qborder = addon:createBorder(slotFrameName, item, defaultSlotWidth, defaultSlotHeight);
    end

    local itemId = GetContainerItemID(containerId, slotId);

    if (itemId and show == 1) then
		itemLocation = ItemLocation:CreateFromBagAndSlot(containerId, slotId);
				
		if addon:isItemTradeable(itemLocation) then		
			item.qborder:SetVertexColor(0.39, 1.0, 1.0);
            item.qborder:SetAlpha(1);
            item.qborder:Show();
		else
			item.qborder:Hide();
		end
    else
        item.qborder:Hide();
    end
end

function addon:createBorder(name, parent, width, height, x, y)
    local x = x or 0;
    local y = y or 1;

    local border = parent:CreateTexture(name .. 'Quality', 'OVERLAY');

    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
    border:SetBlendMode('ADD');
    border:SetAlpha(1);
    border:SetHeight(height);
    border:SetWidth(width);
    border:SetPoint('CENTER', parent, 'CENTER', x, y);
    border:Hide();

    return border;
end

function addon:isItemTradeable(itemLocation)
   local itemLink = C_Item.GetItemLink(itemLocation)
   tip:SetOwner(UIParent, "ANCHOR_NONE")
   tip:SetBagItem(itemLocation:GetBagAndSlot())
   for i = 1,tip:NumLines() do
      if(string.find(_G["TooltipTextLeft"..i]:GetText(), string.format(BIND_TRADE_TIME_REMAINING, ".*"))) then
        return true
      end
   end
end

SLASH_HTI1 = "/hti"
SlashCmdList["HTI"] = function(msg)
    msg = string.lower(msg);

    local _, _, cmd, args = string.find(msg, '%s?(%w+)%s?(.*)')

    if (cmd == 'help' or not cmd) then
		print('Highlight Trade Items');
		print('/hti on  - turns tradeable item highlighting on');
		print('/hti off - turns tradeable item highlighting off');
    elseif (cmd == 'on') then
        htiConfig.enabled = 1
		print('Highlight trade items is enabled')        
    elseif (cmd == 'off') then
        htiConfig.enabled = 0
        print('Highlight trade items is disabled')
    end
end