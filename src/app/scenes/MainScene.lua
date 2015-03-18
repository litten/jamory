require("word")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local fontPath = "fonts/KozMinPr6N.ttf"
--正确答案的按钮
local rightBtn
local rightIdx
--分数
local score = 0
local bestScore = 0
--中间位置
local centerX = display.left + display.width/2
local centerY = display.top - display.height/2-35
--存档
local configFile = device.writablePath.."save.config"

local colors = {
    white   = cc.c3b(225 ,225 ,225 , 1),
    whiteLight   = cc.c3b(204 ,204 ,204 , 1),
    red    = cc.c4f(242/255, 92/255, 110/255, 1),
    yellow    = cc.c4f(227/255, 173/255, 58/255, 1),
    green    = cc.c4f(46/255, 181/255, 170/255, 1),
    purple    = cc.c4f(170/255, 96/255, 206/255, 1),
    gray7 = cc.c4f(50/255, 52/255, 56/255, 0.7),
    gray4 = cc.c4f(50/255, 52/255, 56/255, 0.4),
    gray1 = cc.c4f(50/255, 52/255, 56/255, 0.1),
    gray  = cc.c4f(50/255, 52/255, 56/255, 1),
}
local btnColors = {
	purple    = colors["purple"],
	green    = colors["green"],
    red    = colors["red"],
    yellow    = colors["yellow"],
}
local btnImgs = {
    purple = "purple.png",
    green = "green.png",
    red = "red.png",
    yellow = "yellow.png",
}
local btn = {
	purple = "",
    green = "",
    red = "",
    yellow = "",
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
        size = 60,
        color = colors["whiteLight"],
    })
    self.scoreLabel:align(display.CENTER,display.cx,display.top - 120):addTo(self)

    self.bestLabel = cc.ui.UILabel.new({
        text = "Best Score: "..bestScore,
        size = 24,
        color = colors["whiteLight"]
    })
    self.bestLabel:align(display.CENTER,display.cx,display.top - 180):addTo(self)
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
function MainScene:drawDot(drawBg, radius, count , size , color)
	local angle = 360/count
	for i=1, count, 1 do
		local dotAngle = i*angle
		local dotX = centerX + radius * math.sin(math.rad(dotAngle))
		local dotY = centerY + radius * math.cos(math.rad(dotAngle))
		drawBg:drawDot({
			x = dotX, 
			y = dotY
		}, size , color)
	end
end

-- 建立按钮
function MainScene:createBtn()

	--按钮大小
	local size = 110
	local radius = 260

	local drawBg = cc.DrawNode:create()  
 	drawBg:drawSolidCircle({
		x = centerX, 
		y = centerY
	}, 150, 20, 40 , 1, 1, colors["red"])
	self:drawDot(drawBg, radius, 48, 6, colors["gray"])
	self:addChild(drawBg)  

	local draw = cc.DrawNode:create() 
	function draw3()
		draw:clear()
		draw:drawSolidCircle({
			x = centerX, 
			y = centerY
		}, 150, 20, 40 , 1, 1, colors["gray7"])
	end
	function draw2()
		draw:clear()
		draw:drawSolidCircle({
			x = centerX, 
			y = centerY
		}, 150, 20, 40 , 1, 1, colors["gray4"])
	end
	function draw1()
		draw:clear()
		draw:drawSolidCircle({
			x = centerX, 
			y = centerY
		}, 150, 20, 40 , 1, 1, colors["gray1"])
	end
	function draw0()
		draw:clear()
		draw:drawSolidCircle({
			x = centerX, 
			y = centerY
		}, 150, 20, 40 , 1, 1, colors["gray"])
	end
	 
 	draw0()

	self:addChild(draw)  

	--间隔
	
	local angle = 360/4
	local i = 1
	for key,val in pairs(btnImgs) do
		local images = {
	    	normal = val,
	        pressed = val,
	        disabled = val,
		}
		local dotAngle = i*angle - 45
		local dotX = centerX + radius * math.sin(math.rad(dotAngle))
		local dotY = centerY + radius * math.cos(math.rad(dotAngle)) + size/2
		--画按钮
		btn[key] = cc.ui.UIPushButton.new(images)
		:setButtonSize(size, size)
		:align(display.CENTER_TOP, dotX, dotY)
	    :onButtonPressed(function(event)
            event.target:setScale(1.2)
	        event.target:setPositionY(dotY+ (size*0.2)/2)
	    end)
	    :onButtonRelease(function(event)
            event.target:setScale(1.0)
            event.target:setPositionY(dotY)
            --正确
            local clickStr = event.target:getButtonLabel():getString()
            local rightStr = btn[rightBtn]:getButtonLabel():getString()
            if clickStr == rightStr then
            	self:btnAnm()
            	self:addScore()
            	
            	local rightMusic = "sound/"..rightIdx..".mp3"
            	audio.playSound(rightMusic, false)
            else
            	self:clearScore()
            	audio.playSound(MUSIC.errMusic, false)
 
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
		:addTo(self) 

	    btn[key]:setOpacity(0)
		i = i + 1
	end
	
    btnCenter = cc.LabelTTF:create("", fontPath, 100)
   	btnCenter:setColor(cc.c3b(139, 131, 137))
    btnCenter:align(display.CENTER,display.cx, centerY):addTo(self)
end

-- 按钮动画
function MainScene:btnAnm()
	local function startSetVal()
		self:setVal()
	end

	local function creatAction(count)
		local elm = 0.1
		local timeSpace = 0.3
		local action
		if count == 3 then
			action = cc.Sequence:create(
				cc.FadeOut:create(0.1+count*elm),
				cc.CallFunc:create(startSetVal),
				cc.DelayTime:create(timeSpace),
				cc.FadeIn:create(0.3+count*elm)
			)
		else
			action = cc.Sequence:create(
				cc.FadeOut:create(0.1+count*elm),
				cc.DelayTime:create(timeSpace),
				cc.FadeIn:create(0.3+count*elm)
			)
		end
		return action
	end

	local count = 0
	for key, value in pairs(btn) do
		value:runAction(creatAction(count))
		count = count+1
	end
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
		
		-- local btnLabel = cc.ui.UILabel.new({
		-- 	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
  --       	text = word, 
  --       	size = 60,
  --       	color = colors["white"]
  --       })

  --       local btnLabel2 = cc.Label:createWithTTF(
  --       	word, 
  --       	fontPath, 
  --       	60
  --       )

        local btnLabel3 = cc.LabelTTF:create(word, fontPath, 60);
		btn[key]:setButtonLabel(btnLabel3)

		if count == idxAns then
			centerMatchIdx = rand
		end
        count = count+1
	end

	-- 中间的文字
	if idxCenter == 0 then
		centerWord = wordPing[centerMatchIdx]
	elseif idxCenter == 1 then
		centerWord = wordPian[centerMatchIdx]
	elseif idxCenter == 2 then
		centerWord = wordRead[centerMatchIdx]
	end

	-- 容错处理，由于日语某几个音的重复
	print(btn["green"]:getButtonLabel():getString())

	btnCenter:setString(centerWord)
	print(rightIdx)
    print(self:getKey(btn, idxAns))
    rightBtn = self:getKey(btn, idxAns)
    rightIdx = centerMatchIdx
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

--事件
function MainScene:bind(node)
	local function onrelease(code, event)
		if code == cc.KeyCode.KEY_BACK then
			cc.Director:getInstance():endToLua()
		elseif code == cc.KeyCode.KEY_HOME then
			cc.Director:getInstance():endToLua()
		elseif code == 77 then
			cc.Director:getInstance():endToLua()
		end
	end
	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
	local eventDispatcher = node:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
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
    self:btnAnm()
    --事件
    self:bind(self)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
