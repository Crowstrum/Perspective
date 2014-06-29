--[[ TODO: 
		Set All does not properly work
		New Category
		New Module
		Set Category to Module
]]

local GeminiAddon = Apollo.GetPackage("Gemini:Addon-1.1").tPackage

local PerspectiveOptions = GeminiAddon:NewAddon("PerspectiveOptions", "Perspective")

local Perspective

local L = {}
	
function PerspectiveOptions:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self 

	return o
end

function PerspectiveOptions:OnInitialize()

	self.profile = "default"

	-- Load our localization
	L = GeminiAddon:GetAddon("PerspectiveLocale"):LoadLocalization()

	Perspective = GeminiAddon:GetAddon("Perspective")

	-- Load our default values
	local defaults = self:LoadDefaults()

	-- Load the default values into the db.
	self.db = Apollo.GetPackage("Gemini:DB-1.0").tPackage:New(self, defaults)

	-- Load the xml document
	self.xmlDoc = XmlDoc.CreateFromFile("Perspective.xml")

	-- Options window
    self.Options = Apollo.LoadForm(self.xmlDoc, "Options", nil, self)
    
    -- Options categories list
    self.CategoryList = self.Options:FindChild("CategoryList"):FindChild("Categories"):FindChild("List")
    
    -- Options modules list
    self.ModuleList = self.Options:FindChild("CategoryList"):FindChild("Modules"):FindChild("List")

    -- Options category editor
    self.CategoryEditor = self.Options:FindChild("CategoryEditor")

    -- Register our addon with the interface menu.
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", 		"OnInterfaceMenuListHasLoaded", self)
	Apollo.RegisterEventHandler("InterfaceMenuClicked", 			"OnInterfaceMenuClicked", self)

	-- Register the slash command	
    Apollo.RegisterSlashCommand("perspective", "ShowOptions", self)
end

function PerspectiveOptions:OnEnable()
	self:InitializeOptions()

	if Apollo.GetAddon("Rover") then
		SendVarToRover("PerspectiveOptions", self)
	end
end

function PerspectiveOptions:LoadDefaults()
	return {
		profile = {
			default = {
				settings = { 
					disabled = false,
					max = 10,
					drawTimer = 30,
					slowTimer = 1,
					fastTimer = 100 },
				names = {
					[L["Return Teleporter"]]			= { category = "instancePortal" },
					[L["Bruxen"]]						= { category = "instancePortal",	display = L["Ship to Thayd"] },
					[L["Gus Oakby"]]					= { category = "instancePortal",	display = L["Ship to Crimson Badlands"] },
					[L["Lilly Startaker"]]				= { category = "instancePortal",	display = L["Ship to Grimvault"] },
					[L["Transportation Expert Conner"]]	= { category = "instancePortal",	display = L["Ship to Farside"] },
					[L["Warrant Officer Burke"]]		= { category = "instancePortal",	display = L["Ship to Whitevale"] },
					[L["Empirius"]]						= { category = "wotwChampion" },
					[L["Sagittaurus"]]					= { category = "wotwChampion" },
					[L["Lectro"]]						= { category = "wotwChampion" },
					[L["Krule"]]						= { category = "wotwChampion" },
					[L["Zappo"]]						= { category = "wotwChampion" },
					[L["Ignacio"]]						= { category = "wotwChampion" },
					[L["Police Patrolman"]]				= { category = "cowPolice" },
					[L["Police Constable"]]				= { category = "cowPolice" }
				},
				categories = {
					default = {
						disabled = false,
						disableInCombat = false,
						disableOccluded = false,
						display = false,
						font = "CRB_Pixel_O",
						fontColor = "ffffffff",
						icon = "IconSprites:Icon_Windows32_UI_CRB_InterfaceMenu_Map",
						iconColor = "ffffffff",
						iconHeight = 48,
						iconWidth = 48,
						limitBy = "category", -- valid options are nil, "name", "category", "quest", "challenge"
						lineColor = "ffffffff",
						lineWidth = 2,
						max = 2,
						maxLines = 1,
						minDistance = 0,
						maxDistance = 9999,
						zDistance = 9999,
						showDistance = true,
						showIcon = true,
						showName = true,
						showLineOutline = true,
						showLines = true,
						showLinesOffscreen = true,
						rangeColor = "ffffffff",
						rangeIcon = false,
						rangeFont = false,
						rangeLine = false,
						rangeLimit = 15	},
					all = {
						header = L["Set All"], 
						module = L["All"] },
					target = {
						header = L["Target"],
						module = L["Miscellaneous"],
						disabled = true,				
						lineColor = "ffff00ff",
						iconColor = "ffff00ff",
						icon = "PerspectiveSprites:Circle-Outline",
						maxIcons = 1,
						maxLines = 1,
						iconHeight = 24,
						iconWidth = 24,
						rangeColor = "ffffccff",
						rangeLine = true,
						rangeIcon = true },
					group = {
						header = L["Group"],
						module = L["Player"],
						fontColor = "ff7482c1",
						lineColor = "ff7482c1",
						iconColor = "ff7482c1",
						icon = "IconSprites:Icon_Windows32_UI_CRB_InterfaceMenu_Character",
						showLines = false,
						maxLines = 4,
						max = 4,
						useRange = true,
						rangeColor = "ff00ff00",
						rangeIcon = true,
						rangeLine = true,
						rangeFont = true },
					guild = {
						header = L["Guild"],
						module = L["Player"],
						fontColor = "ff00ff00",
						lineColor = "ff00ff00",
						iconColor = "ff00ff00",
						icon = "IconSprites:Icon_Windows32_UI_CRB_InterfaceMenu_GroupFinder",
						showLines = false },
					friendly = {
						header = L["Friendly Normal"],
						module = L["NPC"],
						disabled = true,
						fontColor = "ff00ff00",
						lineColor = "ff00ff00",
						iconColor = "ff00ff00",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 8,
						iconWidth = 8 },	
					friendlyPrime = {
						header = L["Friendly Prime"],
						module = L["NPC"],
						disabled = true,
						fontColor = "ff00ff00",
						lineColor = "ff00ff00",
						iconColor = "ff00ff00",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 16,
						iconWidth = 16 },	
					friendlyElite = {
						header = L["Friendly Elite"],
						module = L["NPC"],
						disabled = true,
						fontColor = "ff00ff00",
						lineColor = "ff00ff00",
						iconColor = "ff00ff00",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 32,
						iconWidth = 32 },
					neutral = {
						header = L["Neutral Normal"],
						module = L["NPC"],
						disabled = true,
						fontColor = "ffffff00",
						lineColor = "ffffff00",
						iconColor = "ffffff00",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 8,
						iconWidth = 8 },	
					neutralPrime = {
						header = L["Neutral Prime"],
						module = L["NPC"],
						disabled = true,
						fontColor = "ffffff00",
						lineColor = "ffffff00",
						iconColor = "ffffff00",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 16,
						iconWidth = 16 },	
					neutralElite = {
						header = L["Neutral Elite"],
						module = L["NPC"],
						disabled = true,
						fontColor = "ffffff00",
						lineColor = "ffffff00",
						iconColor = "ffffff00",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 32,
						iconWidth = 32 },	
					hostile = {
						header = L["Hostile Normal"],
						module = L["NPC"],
						fontColor = "ffff0000",
						lineColor = "ffff0000",
						iconColor = "ffff0000",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 8,
						iconWidth = 8,
						rangeIcon = true,
						rangeColor = "ffff00ff"	},
					hostilePrime = {
						header = L["Hostile Prime"],
						module = L["NPC"],
						fontColor = "ffff0000",
						lineColor = "ffff0000",
						iconColor = "ffff0000",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 16,
						iconWidth = 16,
						rangeIcon = true,
						rangeColor = "ffff00ff"	},
					hostileElite = {
						header = L["Hostile Elite"],
						module = L["NPC"],
						fontColor = "ffff0000",
						lineColor = "ffff0000",
						iconColor = "ffff0000",
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						max = 10,
						iconHeight = 32,
						iconWidth = 32,
						rangeIcon = true,
						rangeColor = "ffff00ff"	},
					questObjective = {
						header = L["Objective"],
						module = L["Quest"],
						icon = "PerspectiveSprites:QuestObjective",
						max = 3,
						limitBy = "category",
						lineColor = "ffff8000" },
					questNew = {
						header = L["Start"],
						module = L["Quest"],
						icon = "ClientSprites:MiniMapNewQuest",
						lineColor = "ff00ff00" },
					questTalkTo = {
						header = L["Talk To"],
						module = L["Quest"],
						icon = "IconSprites:Icon_MapNode_Map_Chat",
						iconColor = "ffff8000",
						lineColor = "ffff8000" },
					questReward = {
						header = L["Complete"],
						module = L["Quest"],
						icon = "IconSprites:Icon_MapNode_Map_Checkmark",
						lineColor = "ff00ff00" },	
					questLocation = {
						header = L["Quest Location"],
						module = L["Quest"],
						limitBy = "quest",
						max = 1,
						drawLine = false,
						icon = "Crafting_CoordSprites:sprCoord_AdditivePreviewSmall",
						iconWidth = 64,
						iconHeight = 64	},
					eventLocation = {
						header = L["Event Location"],
						module = L["Quest"],
						limitBy = "quest",
						max = 1,
						drawLine = false,
						icon = "Crafting_CoordSprites:sprCoord_AdditiveTargetRed",
						iconWidth = 64,
						iconHeight = 64	},
					challenge = {
						header = L["Objective"],
						module = L["Challenge"],
						icon = "PerspectiveSprites:QuestObjective",
						lineColor = "ffff0000",
						iconColor = "ffff0000" },
					farmer = {
						header = L["Farmer"],
						module = L["Harvest"],
						max = 5,
						fontColor = "ffffff00",
						icon = "IconSprites:Icon_MapNode_Map_Node_Plant",
						lineColor = "ffffff00" },
					miner = {
						header = L["Miner"],
						module = L["Harvest"],
						max = 5,
						fontColor = "ff0078ce",
						icon = "IconSprites:Icon_MapNode_Map_Node_Mining",
						lineColor = "ff0078ce" },
					relichunter = {
						header = L["Relic Hunter"],
						module = L["Harvest"],
						max = 5,
						fontColor = "ffff7fed",
						icon = "IconSprites:Icon_MapNode_Map_Node_Relic",
						lineColor = "ffff7fed" },
					survivalist = {
						header = L["Survivalist"],
						module = L["Harvest"],
						max = 5,
						fontColor = "ffce9967",
						icon = "IconSprites:Icon_MapNode_Map_Node_Tree",
						lineColor = "ffce9967" },
					flightPath = {
						header = L["Flight Path"],
						module = L["Travel"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_Taxi",
						showLines = false },
					instancePortal = {
						header = L["Portal"],
						module = L["Travel"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_Portal",
						max = 10,
						showLines = false },
					bindPoint = {
						header = L["Bind Point"],
						module = L["Travel"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_Gate",
						showLines = false },
					marketplace = {
						header = L["Commodities Exchange"],
						module = L["Town"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_CommoditiesExchange",
						showLines = false },
					auctionHouse = {
						header = L["Auction House"],
						module = L["Town"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_AuctionHouse",
						showLines = false },
					mailBox = {
						header = L["Mailbox"],
						module = L["Town"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_Mailbox",
						showLines = false },
					vendor = {
						header = L["Vendor"],
						module = L["Town"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_Vendor",
						showLines = false },
					craftingStation = {
						header = L["Crafting Station"],
						module = L["Town"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_Tradeskill",
						showLines = false },
					tradeskillTrainer = {
						header = L["Tradeskill Trainer"],
						module = L["Town"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_Trainer",
						showLines = false },
					dye = {
						header = L["Appearance Modifier"],
						module = L["Town"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_DyeSpecialist",
						showLines = false },
					bank = {
						header = L["Bank"],
						module = L["Town"],
						fontColor = "ffabf8cb",
						icon = "IconSprites:Icon_MapNode_Map_Bank",
						showLines = false },
					dungeon = {
						header = L["Dungeon"],
						module = L["Travel"],
						fontColor = "ff00ffff",
						icon = "IconSprites:Icon_MapNode_Map_Dungeon",
						showLines = false },
					lore = {
						header = L["Lore"],
						module = L["Miscellaneous"],
						fontColor  = "ff7abcff",
						icon = "CRB_MegamapSprites:sprMap_IconCompletion_Lore_Stretch",
						lineColor = "ff7abcff",
						showLines = true,
						maxLines = 1 },
					pathLocation = {
						header = L["Mission Location"],
						module = L["Path"],
						limitBy = "path",
						max = 1,
						iconColor = "ffffffff",
						drawLine = false,
						iconHeight = 64,
						iconWidth = 64,
						max = 1 },
					scientist = {
						header = L["Scientist"],
						module = L["Path"],
						fontColor = "ffc759ff",
						icon = "CRB_PlayerPathSprites:spr_Path_Scientist_Stretch",
						lineColor = "ffc759ff",
						showLines = false,
						maxLines = 1 },
					scientistScans = {
						header = L["Scientist Scans"],
						module = L["Path"],
						fontColor = "ffc759ff",
						icon = "CRB_PlayerPathSprites:spr_Path_Scientist_Stretch",
						lineColor = "ffc759ff",
						maxLines = 1 },
					solider = {
						header = L["Soldier"],
						module = L["Path"],
						fontColor = "ffc759ff",
						icon = "CRB_PlayerPathSprites:spr_Path_Soldier_Stretch",
						lineColor = "ffc759ff",
						maxLines = 1 },
					settler = {
						header = L["Settler"],
						module = L["Path"],
						fontColor = "ffc759ff",
						icon = "CRB_PlayerPathSprites:spr_Path_Settler_Stretch",
						lineColor = "ffc759ff",
						maxLines = 1 },
					settlerResources = {
						header = L["Settler Resources"],
						module = L["Path"],
						fontColor = "ffc759ff",
						icon = "CRB_PlayerPathSprites:spr_Path_Settler_Stretch",
						lineColor = "ffc759ff",
						maxLines = 1 },
					explorer = {
						header = L["Explorer"],
						module = L["Path"],
						fontColor = "ffc759ff",
						icon = "CRB_PlayerPathSprites:spr_Path_Explorer_Stretch",
						lineColor = "ffc759ff",
						maxLines = 1 },
					questLoot = {
						header = L["Loot"],
						module = L["Quest"],
						icon = "ClientSprites:GroupLootIcon",
						showLines = false,
						iconWidth = 32,
						iconHeight = 32 },
					subdue = {
						header = L["Weapon Subdue"],
						module = L["Miscellaneous"],
						lineColor = "ffff8000",
						iconColor = "ffff8000",
						icon = "ClientSprites:GroupWarriorIcon",
						lineWidth = 10,
						iconHeight = 32,
						iconWidth = 32 },
					wotwChampion = {
						header = L["Enemy Champion"],
						module = L["War of the Wilds"],
						icon = "IconSprites:Icon_MapNode_Map_PvP_BattleAlert",
						showLines = false },
					[L["Energy Node"]] = {
						header = L["Energy Node"],
						module = L["War of the Wilds"],
						icon = "CRB_InterfaceMenuList:spr_InterfaceMenuList_SilverFlagStretch",
						showLines = false },
					[L["Moodie Totem"]] = {
						header = L["Moodie Totem"],
						module = L["War of the Wilds"],
						icon = "CRB_InterfaceMenuList:spr_InterfaceMenuList_RedFlagStretch",
						iconColor = "ffff3300",
						showLines = false },
					[L["Skeech Totem"]] = {
						header = L["Skeech Totem"],
						module = L["War of the Wilds"],
						icon = "CRB_InterfaceMenuList:spr_InterfaceMenuList_BlueFlagStretch",
						showLines = false },
					cowPolice = {
						header = L["Police"],
						module = L["Crimelords of Whitevale"],
						icon = "PerspectiveSprites:Circle-Outline",
						showLines = false,
						showName = false,
						showDistance = false,
						iconColor = "ff00ff00" },
				},
				markers = {
					--[[quest = {
						header = L["Quest"],
						icon = "Crafting_CoordSprites:sprCoord_AdditivePreviewSmall",
						iconHeight = 64,
						iconWidth = 64,
						font = "CRB_Pixel_O",
						fontColor = "ffffffff",
						maxPer = 1,
						inAreaRange = 100,
					},]]
					--[[path = {
						header = L["Path"],
						soldierIcon = "CRB_PlayerPathSprites:spr_Path_Solider_Stretch",
						settlerIcon = "CRB_PlayerPathSprites:spr_Path_Settler_Stretch",
						explorerIcon = "CRB_PlayerPathSprites:spr_Path_Explorer_Stretch",
						scientistIcon ="CRB_PlayerPathSprites:spr_Path_Scientist_Stretch",
						iconHeight = 64,
						iconWidth = 64,
						font = "CRB_Pixel_O",
						fontColor = "ffffffff",
						maxPer = 1,
					},]]
					--[[event = {
						header = L["Event"],
						icon = "Crafting_CoordSprites:sprCoord_AdditiveTargetRed",
						iconHeight = 64,
						iconWidth = 64,
						font = "CRB_Pixel_O",
						fontColor = "ffffffff",
						maxPer = 1,
						inAreaRange = 100,
					},	]]
				},
				blacklist = {},
			}
		}
	}
end

function PerspectiveOptions:GetOptionValue(ui, option, category)
	local category = category or ui.category or "default"

	-- Get the category option value
	if self.db.profile[self.profile].categories[category] and
		self.db.profile[self.profile].categories[category][option] ~= nil then
		return self.db.profile[self.profile].categories[category][option]
	-- Failback to the default option value
	elseif self.db.defaults.profile[self.profile].categories.default[option] ~= nil then
		if category == "pathLocation" and option == "icon" then
			return self:GetPathIcon()
		else
			return self.db.defaults.profile[self.profile].categories.default[option]
		end
	end
	
	return nil
end

function PerspectiveOptions:GetPathIcon()
	local path

	if PlayerPathLib.GetPlayerPathType() == PlayerPathLib.PlayerPathType_Explorer then
		path = "Explorer"
	elseif PlayerPathLib.GetPlayerPathType() == PlayerPathLib.PlayerPathType_Scientist then
		path = "Scientist"
	elseif PlayerPathLib.GetPlayerPathType() == PlayerPathLib.PlayerPathType_Settler then
		path = "Settler"
	elseif PlayerPathLib.GetPlayerPathType() == PlayerPathLib.PlayerPathType_Solider then
		path = "Soldier"
	end

	return "CRB_PlayerPathSPrites:spr_Path_" .. path .. "_Stretch"
end

function PerspectiveOptions:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "Perspective", {"InterfaceMenuClicked", "", "IconSprites:Icon_Windows32_UI_CRB_InterfaceMenu_Map"})
end

function PerspectiveOptions:OnInterfaceMenuClicked(arg1, arg2, arg3)
	self.Options:Show(not self.Options:IsShown(), true)
end

---------------------------------------------------------------------------------------------------
-- UI Functions
---------------------------------------------------------------------------------------------------

function PerspectiveOptions:OnConfigure()
	self.Options:Show(true, true)
end

function PerspectiveOptions:OnShowOptions()
	self.Options:Show(true, true)
end

function PerspectiveOptions:OnCloseButton()
	self.Options:Show(false, true)
end

function PerspectiveOptions:CColorToString(color)
	return string.format("FF%02X%02X%02X", 
		math.floor(color.r * 255 + 0.5), 
		math.floor(color.g * 255 + 0.5), 
		math.floor(color.b * 255 + 0.5))
end

function PerspectiveOptions:StringToCColor(str)
	local r, g, b = 0, 0, 0
	
	str = string.sub(str, 3)

	local val = tonumber(str, 16)

	if val then
		r = math.floor(val / 65536) 
		g = math.floor(val / 256) % 256
		b = val % 256
	end

	return CColor.new(r / 255, g / 255, b / 255, 1)
end

function PerspectiveOptions:ArrangeChildren(window, type)
	local sort = function (a, b) 
		a = a:GetData().sortValue
		b = b:GetData().sortValue

		a = (a == "_first" and " " or a) or "zzzz"
		b = (b == "_first" and " " or b) or "zzzz"

		return a < b
	end

	window:ArrangeChildrenVert(0, sort)
end

function PerspectiveOptions:InitializeOptions()

	-- Options header buttons
	local categories = self.Options:FindChild("CategoriesButton")
	local settings = self.Options:FindChild("SettingsButton")

	-- Only run these actions on the first initialize
	if not self.initialized then
		-- Load the window position
		local pos = self.db.profile.position

		if pos ~= nil then
			self.Options:SetAnchorOffsets(pos.left, pos.top, pos.right, pos.bottom)
		end

		-- Setup the event handlers for the options window
		self.Options:AddEventHandler("WindowMoved", 		"OnOptions_AnchorsChanged")
		self.Options:AddEventHandler("WindowSizeChanged", 	"OnOptions_AnchorsChanged")
		self.Options:FindChild("NewButton"):AddEventHandler("ButtonSignal",		"OnOptions_NewClicked")
		self.Options:FindChild("DefaultButton"):AddEventHandler("ButtonSignal",	"OnOptions_DefaultClicked")


		categories:AddEventHandler("ButtonCheck", 	"OnOptions_HeaderButtonChecked")
		categories:AddEventHandler("ButtonUncheck",	"OnOptions_HeaderButtonChecked")

		settings:AddEventHandler("ButtonCheck", 	"OnOptions_HeaderButtonChecked")
		settings:AddEventHandler("ButtonUncheck", 	"OnOptions_HeaderButtonChecked")

		-- Initialize the category editor
		self.CategoryEditor:FindChild("Back"):AddEventHandler("ButtonSignal", "CategoryEditor_OnBackClick")

		-- Set the categories header button as checked.
		categories:SetCheck(true)
	end

	-- Initialize the categories
	for category, cat in pairs(self.db.profile[self.profile].categories) do
		if category ~= "default" then
			-- Create the category buttons
			self:CategoryItem_Init(category, cat.module)

			-- Create the module buttons
			self:ModuleItem_Init(category, cat.module)
		end
	end

	-- Check to make sure all our items still exist
	for i, item in pairs(self.CategoryList:GetChildren()) do
		if not self.db.profile[self.profile].categories[item:GetData().category] then
			item:Destroy()
		end
	end

	-- Initialize the settings 
	self:SettingsTimer_Init("DrawUpdate", "drawTimer", 0, "ms", 1000, 	"OnTimerTicked_Draw")
	self:SettingsTimer_Init("FastUpdate", "fastTimer", 1, "ms", 1000, 	"OnTimerTicked_Fast")
	self:SettingsTimer_Init("SlowUpdate", "slowTimer", 1, "secs", 1,	"OnTimerTicked_Slow")	

	-- Sort the lists.
	self:ArrangeChildren(self.CategoryList)
	self:ArrangeChildren(self.ModuleList)

	if not self.initialized then
		-- Set the All module as the selected module
		self.module = L["All"]
		-- Set the module button as checked.
		self.ModuleList:FindChild("ModuleItem_" .. self.module):FindChild("Button"):SetCheck(true)
	end

	-- Let the addon know we are now fully initialized.
	self.initialized = true
end

function PerspectiveOptions:ModuleItem_Init(category, module)
	module = module or "Unknown"

	local item = self.ModuleList:FindChild("ModuleItem_" .. module)

	if not item then
		-- Create a new module item.
		item = Apollo.LoadForm(self.xmlDoc, "ModuleItem", self.ModuleList, self)

		-- Set the name for the item.
		item:SetName("ModuleItem_" .. module)

		-- Get the sortBy value.
		local sortBy = module == L["All"] and "_first" or module

		-- Set the data for the item.
		item:SetData({ module = module, sortValue = sortBy })
		
		local button = item:FindChild("Button")
		button:SetData(module)
		button:AddEventHandler("ButtonCheck", "ModuleItem_Checked")
		button:AddEventHandler("ButtonUncheck", "ModuleItem_Checked")

		local text = button:GetPixieInfo(1)
		text.strText = module
		text.flagsText = { DT_VCENTER = true }
		button:UpdatePixie(1, text)
	end

	return item
end

function PerspectiveOptions:ModuleItem_Checked(handler, control, button)
	-- Get the module for the item
	local module = control:GetData()

	-- Iterrate the category items and show only the items for the selected module.
	for index, item in pairs(self.CategoryList:GetChildren()) do
		-- Get the module for the list item.
		local m = item:GetData().module

		-- If the module matches or we are showing all, then show the item, otherwise hide it.
		if m == module or module == L["All"] or m == L["All"] then
			item:Show(true, true)
		else
			item:Show(false, true)
		end
	end

	if self.module and self.module ~= module then
		-- Uncheck the previous module button
		self.ModuleList:FindChild("ModuleItem_" .. self.module):FindChild("Button"):SetCheck(false)
	end

	-- Save the selected module for later.
	self.module = module

	-- Arrange the list items.
	self:ArrangeChildren(self.CategoryList)

	-- Scroll the list to the top
	self.CategoryList:SetVScrollPos(0)
end

function PerspectiveOptions:CategoryItem_Init(category, module)
	
	local item = self.CategoryList:FindChild("CategoryItem_" .. category)

	local button

	if not item then
		-- Create a new category item.
		item = Apollo.LoadForm(self.xmlDoc, "CategoryItem", self.CategoryList, self)

		-- Set the name for the item.
		item:SetName("CategoryItem_" .. category)

		-- Get the sortBy value.
		local sortBy = category == "all" and "_first" or self:GetOptionValue(nil, "header", category)

		-- Set the data for the item.
		item:SetData({ 
			category = category, 
			module = module,
			sortValue = sortBy
		})

		button = item:FindChild("Button")
		button:SetData(category)
		button:AddEventHandler("ButtonSignal", "CategoryItem_Clicked")
	else
		button = item:FindChild("Button")
	end

	local icon = button:GetPixieInfo(1)
	icon.strSprite = self:GetOptionValue(nil, "icon", category)
	icon.cr = self:GetOptionValue(nil, "iconColor", category)
	button:UpdatePixie(1, icon)

	local text= button:GetPixieInfo(2)
	text.strText = self:GetOptionValue(nil, "header", category)
	text.flagsText = { DT_VCENTER = true }
	button:UpdatePixie(2, text)

	return item
end

function PerspectiveOptions:CategoryItem_Clicked(handler, control, button)
	-- Show the category editor.
	self:CategoryEditor_Show(control:GetData())
end

function PerspectiveOptions:CategoryEditor_Show(category)

	local function loadCheck(name, category, option)
		-- Get the control by name
		local control = self.CategoryEditor:FindChild(name .. "Check")

		-- Disable the line checks
		if option == "showLines" or
			option == "showLineOutline" or
			option == "showLinesOffscreen" then
			if category == "pathLocation" or 
				category == "questLocation" or
				category == "eventLocation" or
				category == "challengeLocation" then
				control:Enable(false)
			else
				control:Enable(true)
			end
		end		

		-- Set the check value.
		control:SetCheck(self:GetOptionValue(nil, option, category))

		-- Make sure we haven't already set the event handlers
		if not control:GetData() then
			--Setup the event handlers
			control:AddEventHandler("ButtonCheck", 		"CategoryEditor_OnChecked")
			control:AddEventHandler("ButtonUncheck", 	"CategoryEditor_OnChecked")	
		end

		-- Set the data for the control.
		control:SetData({ category = category, option = option })
	end

	local function loadText(name, category, option, isNumber)
		-- Get the control by name
		local control = self.CategoryEditor:FindChild(name .. "Text")

		-- Set the text value.
		control:SetText(self:GetOptionValue(nil,  option, category) or "")

		-- Make sure we haven't already set the event handlers
		if not control:GetData() then
			--Setup the event handlers
			control:AddEventHandler("EditBoxReturn", 	"CategoryEditor_OnReturn")
			control:AddEventHandler("EditBoxTab", 		"CategoryEditor_OnReturn")
			control:AddEventHandler("EditBoxEscape", 	"CategoryEditor_OnEscape")
		end
		
		-- Set the data for the control.
		control:SetData({ category = category, option = option, isNumber = isNumber })
	end

	local function loadDropDown(name, category, option)
		-- Get the control by name
		local control = self.CategoryEditor:FindChild(name .. "DropDownButton")

		-- Disable the line texts
		if option == "limitBy" then
			if category == "pathLocation" or 
				category == "questLocation" or
				category == "eventLocation" or
				category == "challengeLocation" then
				control:Enable(false)
			else
				control:Enable(true)
			end
		end		

		-- Get the menu associated with the control
		local menu = self.CategoryEditor:FindChild(name .. "DropDownMenu")

		-- Set the control value.
		control:SetText(self:GetOptionValue(nil, option, category))

		-- Make sure we haven't already set the event handlers
		if not control:GetData() then
			control:AddEventHandler("ButtonSignal", "CategoryEditor_OnDropDown")

			for k, v in pairs(menu:GetChildren()) do
				v:AddEventHandler("ButtonCheck", 	"CategoryEditor_OnDropDownItem")
				v:AddEventHandler("ButtonUncheck", 	"CategoryEditor_OnDropDownItem")
			end
		end

		-- Set the data for the control.
		control:SetData({ category = category, option = option, menu = menu })

		-- Set the data for the menu.
		menu:SetData({ button = control })
	end

	local function loadColor(name, category, option)
		-- Get the control by name
		local control = self.CategoryEditor:FindChild(name .. "Button")

		-- Get the color for the control
		local color =  self:GetOptionValue(nil, option, category)

		-- Set the color for the control
		control:SetBGColor(color)
			
		-- Makre sure we haven't already set the event handlers
		if not control:GetData() then
			control:AddEventHandler("ButtonSignal", "CategoryEditor_OnColorClick")
		end

		-- Set the data for the control.
		control:SetData({ category = category, option = option, color = color })
	end

	local header = 	self:GetOptionValue(nil, "header", 		category)
	local icon = 	self:GetOptionValue(nil, "icon", 		category)
	local color = 	self:GetOptionValue(nil, "iconColor", 	category)

	self.CategoryEditor:FindChild("Category"):SetText(header)
	self.CategoryEditor:FindChild("Icon"):SetSprite(icon)
	self.CategoryEditor:FindChild("Icon"):SetBGColor(color)

	local whitelist = self:GetOptionValue(nil, "whitelist", category)
	
	-- Set the rename text
	self.CategoryEditor:FindChild("RenameText"):SetText(category)
	
	-- Show the rename edit box if this is a whitelist item
	self.CategoryEditor:FindChild("RenameTextBG"):Show(whitelist, true)
	
	-- Show the category name if this is not a whitelist item
	self.CategoryEditor:FindChild("Category"):Show(not whitelist, true)

	loadCheck("Disable", 			category, "disabled")
	loadCheck("CombatDisable", 		category, "disableInCombat")
	loadCheck("ShowIcon", 			category, "showIcon")
	loadCheck("ShowName", 			category, "showName")
	loadCheck("ShowDistance", 		category, "showDistance")
	loadCheck("ShowLines", 			category, "showLines")
	loadCheck("ShowOutline", 		category, "showLineOutline")
	loadCheck("ShowOffScreenLine", 	category, "showLinesOffscreen")
	loadCheck("RangeFont", 			category, "rangeFont")
	loadCheck("RangeIcon", 			category, "rangeIcon")
	loadCheck("RangeLine", 			category, "rangeLine")

	loadText("Font", 				category, "font", 			false)
	loadText("Icon", 				category, "icon", 			false)
	loadText("IconHeight",			category, "iconHeight", 	true)
	loadText("IconWidth", 			category, "iconWidth", 		true)
	loadText("MaxIcons", 			category, "max", 			true)
	loadText("MaxLines", 			category, "maxLines", 		true)
	loadText("LineWidth", 			category, "lineWidth", 		true)
	loadText("ZDistance",			category, "zDistance", 		true)
	loadText("MinDistance",			category, "minDistance", 	true)
	loadText("MaxDistance",			category, "maxDistance", 	true)
	loadText("Display", 			category, "display", 		false)
	loadText("RangeLimit",			category, "rangeLimit",		true)

	loadColor("FontColor",			category, "fontColor")
	loadColor("IconColor", 			category, "iconColor")
	loadColor("LineColor", 			category, "lineColor")
	loadColor("RangeColor", 		category, "rangeColor")

	loadDropDown("LimitBy",			category, "limitBy")

	self.ModuleList:GetParent():Show(false, true)
	self.CategoryList:GetParent():Show(false, true)
	self.CategoryEditor:Show(true, true)
end

function PerspectiveOptions:CategoryEditor_OnBackClick(handler, control, button)
	self.CategoryEditor:Show(false, true)
	self.ModuleList:GetParent():Show(true, true)
	self.CategoryList:GetParent():Show(true, true)
end

function PerspectiveOptions:CategoryEditor_OnChecked(handler, control, button)
	-- Get the control's data
	local data = control:GetData()
	
	-- Get the control's value
	local val = control:IsChecked()

	-- Check to see if we need to set the value for all categories
	if data.category == "all" then
		for category, cat in pairs(self.db.profile[self.profile].categories) do
			if self.module == L["All"] or cat.module == self.module then
				cat[data.option] = val
			end
		end
	else
		self.db.profile[self.profile].categories[data.category][data.option] = val	
	end

	-- Update all the ui options.
	Perspective:UpdateOptions()
end

function PerspectiveOptions:CategoryEditor_OnReturn(handler, control)
	-- Get the control's data
	local data = control:GetData()

	-- Get the control's value
	local val = control:GetText()

	-- Check to see if the textbox is expecting a number
	if data.isNumber then
		if not tonumber(val) then
			val = self:GetOptionValue(nil, data.option, data.category)
		else
			val = tonumber(val)
		end
	end

	-- If the option is blank, load the default setting.
	if val == "" then 
		val = self:GetOptionValue(nil, data.option, data.category)
	end

	-- Check to see if we need to set the value for all categories
	if data.category == "all" then
		for category, cat in pairs(self.db.profile[self.profile].categories) do
			if category == "all" or cat.module == self.module then
				cat[data.option] = val

				if data.option == "icon" then
					self:CategoryEditor_UpdateIcon(category)
				end
			end
		end
	else
		self.db.profile[self.profile].categories[data.category][data.option] = val	

		if data.option == "icon" then
			self:CategoryEditor_UpdateIcon(data.category)
		end
	end

	-- Update all the ui options.
	Perspective:UpdateOptions()
end

function PerspectiveOptions:CategoryItem_OnEscape(handler, control)
	-- Get the control's data
	local data = control:GetData()
	
	-- Load the previous value
	control:SetText(self:GetOptionValue(nil, data.option, data.category))
end

function PerspectiveOptions:CategoryEditor_OnDropDown(handler, control, button)
	-- Get the control's data.
	local data = control:GetData()

	-- Set the selected value
	for k, v in pairs(data.menu:GetChildren()) do
		if v:GetText() == control:GetText() then
			v:SetCheck(true)
		else
			v:SetCheck(false)
		end
	end

	-- Show the menu and bring it to the top
	data.menu:Show(true, true)--:BringChildToTop(data.menu)
end

function PerspectiveOptions:CategoryEditor_OnDropDownItem(handler, control, button)
	-- Get the data for the control
	local data = control:GetParent():GetData()

	-- Get the button that called the menu
	local button = data.button

	-- Get the data for the button
	data = button:GetData()

	-- Get the text of the selected dropdownmenu button
	local val = control:GetText()

	-- Update the button text for the caller button
	button:SetText(val)

	-- Hide the dropdownmenu immediately
	control:GetParent():Show(false, true)

	-- Update the settings.
	if data.category == "all" then
		for category, cat in pairs(self.db.profile[self.profile].categories) do
			if self.module == L["All"] or cat.module == self.module then
				cat[data.option] = val
			end
		end
	else
		self.db.profile[self.profile].categories[data.category][data.option] = val
	end

	-- Update all the ui options.
	Perspective:UpdateOptions()
end

function PerspectiveOptions:CategoryEditor_OnColorClick(handler, control, button)

	local function setColor(data)
		-- Convert the color back to str
		local color = self:CColorToString(self.color)
		
		-- Set the control color
		control:SetBGColor(color)

		-- Update the settings
		if data.category == "all" then
			for category, cat in pairs(self.db.profile[self.profile].categories) do
				if category == data.category or cat.module == self.module then
					cat[data.option] = color

					if data.option == "iconColor" then
						self:CategoryEditor_UpdateIcon(category)
					end
				end
			end
		else
			self.db.profile[self.profile].categories[data.category][data.option] = color

			if data.option == "iconColor" then
				self:CategoryEditor_UpdateIcon(data.category)
			end
		end

		-- Update all the ui options.
		Perspective:UpdateOptions() 
	end

	-- Get the data for the control
	local data = control:GetData()

	-- Convert the color string
	self.color = self:StringToCColor(data.color)

	-- Show the color picker.
	if ColorPicker then
		ColorPicker.AdjustCColor(self.color, false, setColor, data)
	else
		ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Realm, "This option requires the ColorPicker addon to be installed.")
	end
end

function PerspectiveOptions:CategoryEditor_UpdateIcon(category)
	-- Get our category item button
	local button  = self.CategoryList:FindChild("CategoryItem_" .. category):FindChild("Button")

	-- Get the icon and icon color.
	local icon = self:GetOptionValue(nil, "icon", category)
	local iconColor = self:GetOptionValue(nil, "iconColor", category)

	-- Update the category editor icon.
	self.CategoryEditor:FindChild("Icon"):SetBGColor(iconColor)
	self.CategoryEditor:FindChild("Icon"):SetSprite(icon)

	-- Update our icon pixie
	local pixie = button:GetPixieInfo(1)
	pixie.strSprite = icon
	pixie.cr = iconColor
	button:UpdatePixie(1, pixie)
end



















--[[
function PerspectiveOptions:InitializeWindow_NewCategory()
	-- Setup the event handlers for the newcategory window
	local ok = self.NewCategory:FindChild("OKButton")
	local cancel = self.NewCategory:FindChild("CancelButton")

	ok:AddEventHandler("ButtonSignal", 			"OnNewCategory_OKClicked")
	cancel:AddEventHandler("ButtonSignal",		"OnNewCategory_CancelClicked")
end
]]

function PerspectiveOptions:SettingsTimer_Init(control, value, numDecimal, unit, divBy, tickFunc)
	local slider = self.Options:FindChild(control .. "Slider")
	local text = self.Options:FindChild(control .. "Text")

	local val = Apollo.FormatNumber(self.db.profile[self.profile].settings[value], numDecimal)

	-- Associate the text control with the slider.
	slider:SetData({ 
		text = text, 
		value = value, 
		numDecimal = numDecimal, 
		unit = unit,
		divBy = divBy,
		tickFunc = tickFunc 
	})

	-- Set the slider value.
	slider:SetValue(val)

	-- Set the text value.
	text:SetText(val .. " " .. unit)

	-- Set the event handler
	slider:AddEventHandler("SliderBarChanged", "SettingsTimer_OnChanged")
end



---------------------------------------------------------------------------------------------------
-- Options Events
---------------------------------------------------------------------------------------------------

function PerspectiveOptions:OnOptions_AnchorsChanged()
	local l, t, r, b = self.Options:GetAnchorOffsets()

	self.db.profile.position = {
		left = l,
		top = t,
		right = r,
		bottom = b
	}
end

--[[function PerspectiveOptions:OnOptions_NewClicked(handler, control, button)
	self.NewCategory:FindChild("NameText"):SetText("")
	self.NewCategory:FindChild("DisplayText"):SetText("")
	self.NewCategory:Show(true, true)
end]]

function PerspectiveOptions:OnOptions_DefaultClicked(handler, control, button)
	self.db:ResetDB()

	self:InitializeOptions()

	Perspective:UpdateOptions()
end

function PerspectiveOptions:OnOptions_HeaderButtonChecked(handler, control, button)
	local panels = {
		"Categories",
		--"Markers",
		--"Blacklist",
		"Settings"
	}

	for k, v in pairs(panels) do
		if v .. "Button" == control:GetName() then
			self.Options:FindChild(v):Show(true, true)
		else
			self.Options:FindChild(v):Show(false, true)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- NewCategory Events
---------------------------------------------------------------------------------------------------
--[[
function PerspectiveOptions:OnNewCategory_OKClicked(handler, control, button)
	local name = self.NewCategory:FindChild("NameText"):GetText()
	local display = self.NewCategory:FindChild("DisplayText"):GetText()

	if display == "" then
		display = nil
	end

	self.db.profile[self.profile].categories[name] = self.db.profile[self.profile].categories[name] or {
		header = "Unit Name - " .. name,
		whitelist = true,
		display = display
	}

	self:CategoryItem_Init(name, "Unit Name - " .. name, true)

	self:CategoryItems_Arrange("header")

	self.NewCategory:Show(false, true)
end

function PerspectiveOptions:OnNewCategory_CancelClicked(handler, control, button)
	self.NewCategory:Show(false, true)
end
]]
---------------------------------------------------------------------------------------------------
-- CategoryItem Events
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Settings Events
---------------------------------------------------------------------------------------------------

function PerspectiveOptions:SettingsTimer_OnChanged(handler, control, button)
	-- Get the control's data.
	local data = control:GetData()

	-- Get the timer vale
	local val = Apollo.FormatNumber(control:GetValue(), data.numDecimal)

	-- Get the control's text.
	data.text:SetText(val .. " " .. data.unit)

	-- Save the value.
	self.db.profile[self.profile].settings[data.value] = val

	-- Set the timer in Perspective
	Perspective[data.value]:Set(val / data.divBy, true, data.tickFunc, self)
end
