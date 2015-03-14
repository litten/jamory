require("word")
require("tools")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

--正确答案的按钮
local rightBtn
--分数
local score = 0
local bestScore = 0
--中间位置
local centerX = display.left + display.width/2
local centerY = display.top - display.height/2-35
--存档
local configFile = device.writablePath.."save.config"

local colors = {
    white   = cc.c3b(255,255,255),
    red    = cc.c3b(242, 92, 110),
    yellow    = cc.c3b(227, 173, 58),
    green    = cc.c3b(46, 181, 170),
    purple    = cc.c3b(170, 96, 206),
    gray = cc.c4f(0.18, 0.18, 0.2, 1),
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
}
local btnCenter = nil

--处理lua随机数问题
local seed = 0
function MainScene:setSeed()
	if seed%2 == 0 then
		math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
	else
		math.randomseed(os.time())
	end
	seed = seed + 1
	math.random()
end

-- 根据顺序取数组key
function MainScene:getKey(table, idx)
	local count = 0
	local rightKey
	for key, value in pairs(btn) do
		if count == idx then
			rightKey = key
		end
		count = count + 1
	end
	return rightKey
end

-- 建立分数文字
function MainScene:createScore()
	self.scoreLabel = cc.ui.UILabel.new({
        text = score,
        size = 20,
        color = colors["white"],
    })
    self.scoreLabel:align(display.CENTER,display.cx,display.top - 60):addTo(self)

    self.bestLabel = cc.ui.UILabel.new({
        text = "Best Score: "..bestScore,
        size = 14,
        color = colors["white"]
    })
    self.bestLabel:align(display.CENTER,display.cx,display.top - 90):addTo(self)
end

--分数相关
function MainScene:addScore()
	score = score+1
	self.scoreLabel:setString(score)
	if score > bestScore then
		bestScore = score
		self.bestLabel:setString("Best Score: "..bestScore)
	end
	MainScene:saveStatus()
end

function MainScene:clearScore()
	score = 0
	self.scoreLabel:setString(score)
	MainScene:saveStatus()
end

-- 画虚线
function MainScene:drawDot(drawBg, radius, count )
	local angle = 360/count
	for i=1, count, 1 do
		local dotAngle = i*angle
		local dotX = centerX + radius * math.sin(math.rad(dotAngle))
		local dotY = centerY + radius * math.cos(math.rad(dotAngle))
		print(dotX)
		print(dotY)
		print("···")
		drawBg:drawDot({
			x = dotX, 
			y = dotY
		}, 3, cc.c4f(0.2, 0.2, 0.2, 1))
	end
	print(centerX)
	print(centerY)
end
-- 建立按钮
function MainScene:createBtn()
	local drawBg = cc.DrawNode:create()  
 	drawBg:drawSolidCircle({
		x = centerX, 
		y = centerY
	}, 68, 20, 40 , 1, 1, cc.c4f(1, 0.5, 0.6, 1))
	self:drawDot(drawBg, 145, 48)
	self:addChild(drawBg)  

	local draw = cc.DrawNode:create() 
	function draw3()
		draw:clear()
		draw:drawSolidCircle({
			x = centerX, 
			y = centerY
		}, 68, 20, 40 , 1, 1, cc.c4f(0.18, 0.18, 0.2, 0.7))
	end
	function draw2()
		draw:clear()
		draw:drawSolidCircle({
			x = centerX, 
			y = centerY
		}, 68, 20, 40 , 1, 1, cc.c4f(0.18, 0.18, 0.2, 0.4))
	end
	function draw1()
		draw:clear()
		draw:drawSolidCircle({
			x = centerX, 
			y = centerY
		}, 68, 20, 40 , 1, 1, cc.c4f(0.18, 0.18, 0.2, 0.1))
	end
	function draw0()
		draw:clear()
		draw:drawSolidCircle({
			x = centerX, 
			y = centerY
		}, 68, 20, 40 , 1, 1, colors["gray"])
	end
	 
 	draw0()
	self:addChild(draw)  

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
		local disX = centerX
		local disY = centerY - 65
		
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
	            --正确
	            if rightBtn == key then
	            	self:setVal()
	            	self:addScore()
	            else
	            	self:clearScore()
	            	--centerCircle
	            	local actionTo =  cc.JumpBy:create(2, cc.p(0,0), 80, 4)
	            	--draw:runAction(actionTo)  
	            	local timeSpace = 0.04
	            	draw:runAction(
	            		cc.Sequence:create(
	            			cc.DelayTime:create(timeSpace),
	            			cc.CallFunc:create(draw3),
	            			cc.DelayTime:create(timeSpace),
	            			cc.CallFunc:create(draw2),
	            			cc.DelayTime:create(timeSpace),
	            			cc.CallFunc:create(draw1),
	            			cc.DelayTime:create(timeSpace),
	            			cc.CallFunc:create(draw2),
	            			cc.DelayTime:create(timeSpace),
	            			cc.CallFunc:create(draw3),
	            			cc.DelayTime:create(timeSpace),
	            			cc.CallFunc:create(draw0)
	            		)
	            	)
	            end
	        end)
	        :align(display.CENTER_TOP, disX, disY)
	        :addTo(self) 
	end 

    btnCenter = cc.ui.UILabel.new({
        text = "",
        size = 50,
        color = cc.c3b(99, 101, 107),
        background = nil
    })
    :align(display.CENTER,display.cx, centerY):addTo(self)
end

-- 随机塞数值
function MainScene:setVal()
	self:setSeed()
	--按钮展示字符，是三种类型中的一种
	local idxType = math.random(3)-1
	--中间展示字符
	local idxCenter = (idxType + math.random(2))%3
	--答案是四个按钮中的一个
	local idxAns = math.random(4)-1

	local count = 0
	local centerWord = ""
	--中间的词对应正确答案在数组上的顺序
	local centerMatchIdx
	for key, value in pairs(btn) do
		local rand = math.random(wordLen);
		local word
		if idxType == 0 then
			word = wordPing[rand]
		elseif idxType == 1 then
			word = wordPian[rand]
		elseif idxType == 2 then
			word = wordRead[rand]
		end
		
		btn[key]:setButtonLabel(cc.ui.UILabel.new({
        	text = word, 
        	size = 26, 
        	color = colors["white"]
        }))

		if count == idxAns then
			centerMatchIdx = rand
		end
        count = count+1
	end

	if idxCenter == 0 then
		centerWord = wordPing[centerMatchIdx]
	elseif idxCenter == 1 then
		centerWord = wordPian[centerMatchIdx]
	elseif idxCenter == 2 then
		centerWord = wordRead[centerMatchIdx]
	end

	btnCenter:setString(centerWord)
    print(self:getKey(btn, idxAns))
    rightBtn = self:getKey(btn, idxAns)
	print("--------")
end

--读写状态
function MainScene:saveStatus()
    local str = string.format("do local score,bestScore \
                              =%d,%d return score,bestScore end",
                              score,bestScore)
    io.writefile(configFile,str)
end

function MainScene:loadStatus()
    if io.exists(configFile) then
        local str = io.readfile(configFile)
        if str then
            local f = loadstring(str)
            local _score,_bestScore = f()
            if _score and _bestScore then
            	score,bestScore = _score,_bestScore
            end
        end
    end
end
-- 主函数
function MainScene:ctor()
    display.newColorLayer(cc.c4b(34,36,40,255)):addTo(self)
    --数据
    self:loadStatus()
    --布局
    self:createScore()
    self:createBtn()
    --逻辑
    self:setVal()

end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
