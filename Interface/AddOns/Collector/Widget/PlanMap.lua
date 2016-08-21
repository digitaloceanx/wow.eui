
BuildEnv(...)

local PlanMap = Addon:NewClass('PlanMap', Addon:GetClass('Map'))

function PlanMap:Constructor()
    self.tiles = {}
    self.overs = setmetatable({}, {__index = function(t, i)
        t[i] = self:CreateTexture(nil, 'OVERLAY')
        return t[i]
    end})

    for i = 1, GetNumberOfDetailTiles() do
        self.tiles[i] = self:CreateTexture(nil, 'BACKGROUND')
    end

    if not self.ModelFrame then
        local ModelFrame = CreateFrame('Frame', nil, UIParent) do
            ModelFrame:SetFrameStrata('TOOLTIP')
            ModelFrame:SetBackdrop{
                bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
                edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
                tileSize = 16, edgeSize = 16, tile = true
            }
            ModelFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
            ModelFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
            ModelFrame:SetSize(160, 185)
            ModelFrame:SetPoint('TOPRIGHT', 0, 0)
            ModelFrame:Hide()
        end

        local Model = CreateFrame('PlayerModel', nil, ModelFrame) do
            Model:SetSize(150, 150)
            Model:SetPoint('TOP', 0, -5)
            Model:SetRotation(-MODELFRAME_DEFAULT_ROTATION)
        end

        local ModelName = ModelFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall') do
            ModelName:SetPoint('BOTTOMLEFT', 10, 10)
            ModelName:SetPoint('BOTTOMRIGHT', -10, 10)
            ModelName:SetWordWrap(false)
        end

        PlanMap.Model = Model
        PlanMap.ModelFrame = ModelFrame
        PlanMap.ModelName = ModelName
    end

    self:SetBlipSize(24)

    self:SetScript('OnSizeChanged', self.OnSizeChanged)
    self:SetScript('OnShow', self.Refresh)
end

function PlanMap:OnSizeChanged()
    local w, h = 1024/1002, 768/668
    local width, height = self:GetSize()
    local tileSize = max(width*w/4, height*h/3)
    local x, y = (width-tileSize*4/w)/2, (height-tileSize*3/h)/2

    self.tileRadio = tileSize/256
    self.tileSize = tileSize
    self:SetOffset(x, y)
    self:UpdateTilesSize()
    self:Refresh()
end

function PlanMap:UpdateTilesSize()
    local tileSize = self.tileSize
    local x, y = self:GetOffset()

    for i, tile in ipairs(self.tiles) do
        local pos = i-1
        tile:ClearAllPoints()
        tile:SetSize(tileSize, tileSize)
        tile:SetPoint('TOPLEFT', pos%4*tileSize+x, -floor(pos/4)*tileSize+y)
    end
end

local function getOverlayInfo(path, texName, texID)
    if type(texName) == 'number' then
        return GetMapOverlayInfo(texName)
    else
        return path .. texName, mod(texID, 2^10), mod(floor(texID / 2^10), 2^10), mod(floor(texID / 2^20), 2^10), floor(texID / 2^30)
    end
end

function PlanMap:UpdateTiles()
    local mapName, textureHeight, _, isMicroDungeon, microDungeonMapName = GetMapInfo()
    if isMicroDungeon and (not microDungeonMapName or microDungeonMapName == '') then
        return
    end

    local dungeonLevel = GetCurrentMapDungeonLevel()
    if DungeonUsesTerrainMap() then
        dungeonLevel = dungeonLevel - 1
    end

    local tileSize = self.tileSize
    local tileRadio = self.tileRadio
    local x, y = self:GetOffset()

    local mapWidth, mapHeight = self:GetSize()
    local mapID, isContinent = GetCurrentMapAreaID()
    local fileName, path do
        if not isMicroDungeon then
            path = [[Interface\WorldMap\]]..mapName..[[\]]
            fileName = mapName
        else
            path = [[Interface\WorldMap\MicroDungeon\]]..mapName..[[\]]..microDungeonMapName..[[\]]
            fileName = microDungeonMapName
        end
        if dungeonLevel > 0 then
            fileName = fileName .. dungeonLevel .. '_'
        end
    end

    for i = 1, GetNumberOfDetailTiles() do
        self.tiles[i]:SetTexture(path..fileName..i)
    end

    local t = MAP_DATA[mapName] and MAP_DATA[mapName] or {}
    if next(MAP_DATA) then
        for i = 1, GetNumMapOverlays() do
            tinsert(t, i)
        end
    end

    local textureCount = 0
    -- for i = 1, GetNumMapOverlays() do
        -- local textureName, textureWidth, textureHeight, offsetX, offsetY = GetMapOverlayInfo(i)
    for texName, texID in pairs(t) do
        -- local textureName = path .. texName
        -- local textureWidth, textureHeight, offsetX, offsetY = mod(texID, 2^10), mod(floor(texID / 2^10), 2^10), mod(floor(texID / 2^20), 2^10), floor(texID / 2^30)

        local textureName, textureWidth, textureHeight, offsetX, offsetY = getOverlayInfo(path, texName, texID)

        if textureName and textureName ~= '' then
            offsetX = offsetX * tileRadio + x
            offsetY = offsetY * tileRadio + y
            textureWidth = textureWidth * tileRadio
            textureHeight = textureHeight * tileRadio

            local numTexturesWide = ceil(textureWidth/tileSize)
            local numTexturesTall = ceil(textureHeight/tileSize)

            local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
            for j = 1, numTexturesTall do
                if j < numTexturesTall then
                    texturePixelHeight = tileSize
                    textureFileHeight = tileSize
                else
                    texturePixelHeight = mod(textureHeight, tileSize)
                    if texturePixelHeight == 0 then
                        texturePixelHeight = tileSize
                    end
                    textureFileHeight = 16
                    while(textureFileHeight < texturePixelHeight) do
                        textureFileHeight = textureFileHeight * 2
                    end
                end
                for k = 1, numTexturesWide do
                    textureCount = textureCount + 1
                    local texture = self.overs[textureCount]
                    if k < numTexturesWide then
                        texturePixelWidth = tileSize
                        textureFileWidth = tileSize
                    else
                        texturePixelWidth = mod(textureWidth, tileSize)
                        if ( texturePixelWidth == 0 ) then
                            texturePixelWidth = tileSize
                        end
                        textureFileWidth = 16
                        while(textureFileWidth < texturePixelWidth) do
                            textureFileWidth = textureFileWidth * 2
                        end
                    end
                    texture:SetWidth(texturePixelWidth)
                    texture:SetHeight(texturePixelHeight)
                    texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
                    texture:SetPoint('TOPLEFT', offsetX + (tileSize * (k-1)), -(offsetY + (tileSize * (j - 1))))
                    texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k))
                    texture:Show()
                end
            end
        end
    end
    for i = textureCount+1, #self.overs do
        self.overs[i]:Hide()
    end
end

function PlanMap:UpdateBlips()
    local item = self.plan:GetObject()
    for i, v in ipairs(item:GetAcquireList()) do
        if v:IsType(GameObject) then
            self:DrawObject(v, self.area, item)
        end
    end
end

function PlanMap:Update()
    if not self.area then
        return
    end
    SetMapByID(self.area:GetMapID())
    SetDungeonMapLevel(self.area:GetLevel() + (DungeonUsesTerrainMap() and 1 or 0))

    self.area = Area:Get(Addon:GetCurrentAreaInfo())

    self:Clear()

    if self.tileSize then
        self:UpdateTiles()
        self:UpdateBlips()
    end
    
    SetMapToCurrentZone()
end

function PlanMap:SetInfo(area, plan)
    self.area = area
    self.plan = plan
    self:Refresh()
end

function PlanMap:GetArea()
    return self.area
end

function PlanMap:BlipOnEnter(blip)
    local name = blip:GetObject():GetName()
    local id = blip:GetObject():GetDisplay()

    if id then
        self.Model:SetDisplayInfo(id)
        self.ModelName:SetText(name)
        self.ModelFrame:ClearAllPoints()
        self.ModelFrame:SetPoint('BOTTOMLEFT', blip, 'TOPRIGHT')
        self.ModelFrame:Show()
    elseif name then
        GameTooltip:SetOwner(blip, 'ANCHOR_RIGHT')
        GameTooltip:SetText(name)
        GameTooltip:Show()
    else
        self:BlipOnLeave()
    end
end

function PlanMap:BlipOnLeave()
    self.ModelFrame:Hide()
    GameTooltip:Hide()
end
