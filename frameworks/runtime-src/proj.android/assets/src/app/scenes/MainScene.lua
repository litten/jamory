
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local colors = {
    white   = cc.c3b(255,255,255),
    red    = cc.c3b(242, 92, 110),
    yellow    = cc.c3b(227, 173, 58),
    green    = cc.c3b(46, 181, 170),
    purple    = cc.c3b(170, 96, 206),
    gray = cc.c3b(66, 67, 71),
}
local btnImgs = {
    purple = "purple.png",
    green = "green.png",
    red = "red.png",
    yellow = "yellow.png",
}
local btn = {
	purple = nil,
    green = nil,
    red = nil,
    yellow = nil,
    gray = nil,
}
-- 建立分数文字
function MainScene:createScore()
	self.scoreLabel = cc.ui.UILabel.new({
        text = "0",
        size = 20,
        color = colors["white"],
    })
    self.scoreLabel:align(display.CENTER,display.cx,display.top - 60):addTo(self)

    self.bestLabel = cc.ui.UILabel.new({
        text = "Best Score: 0",
        size = 14,
        color = colors["white"],
    })
    print(cc.ui)
    self.bestLabel:align(display.CENTER,display.cx,display.top - 90):addTo(self)
end

-- 建立按钮
function MainScene:createBtn()
	--按钮大小
	local size = 65
	--间隔
	local space = 100

	for key, value in pairs(btnImgs) do  
	    local images = {
	    	normal = value,
	        pressed = value,
	        disabled = value,
		}
		local disX = display.left + display.width/2
		local disY = display.top - display.height/2 - 100
		
		if key == 'red' then
			disX = disX - space
		elseif key == 'purple' then
			disX = disX + space
		elseif key == 'yellow' then
			disX = disX - space
			disY = disY + (space*2)
		elseif key == 'green' then
			disX = disX + space
			disY = disY + (space*2)
		end
	    btn[key] = cc.ui.UIPushButton.new(images)
	        :setButtonSize(size, size)
	        :onButtonPressed(function(event)
	            event.target:setScale(1.2)
	            event.target:setPositionY(disY+ (size*0.2)/2)
	        end)
	        :onButtonRelease(function(event)
	            event.target:setScale(1.0)
	            event.target:setPositionY(disY)
	        end)
	        :onButtonClicked(function(event)
	            -- self:enterNextScene()
	            -- event.target:setPositionY(disY-100)
	        end)
	        :align(display.CENTER_TOP, disX, disY)
	        :addTo(self) 
	end 

	btn["gray"] = cc.ui.UIPushButton.new("gray.png")
	        :setButtonSize(168, 168)
	        :setButtonLabel(cc.ui.UILabel.new({
	        	text = "哈", 
	        	size = 50, 
	        	color = colors["gray"]
	        }))
	        :setButtonLabelOffset(0, 65)
        	:setButtonLabelAlignment(display.CENTER)
	        :align(display.CENTER_TOP, display.left + display.width/2, display.top - display.height/2 + 50)
	        :addTo(self) 
end

-- 主函数
function MainScene:ctor()
    -- cc.ui.UILabel.new({
    --         UILabelType = 2, text = "Hello, World", size = 64})
    --     :align(display.CENTER, display.cx, display.cy)
    --     :addTo(self)
    display.newColorLayer(cc.c4b(34,36,40, 255)):addTo(self)
    self:createScore()
    self:createBtn()
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
