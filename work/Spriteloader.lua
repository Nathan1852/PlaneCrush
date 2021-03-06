sprite = {}
sprite.objects = {}

function sprite.calculateSprite(path, file)
	local name = string.sub(file, 1, string.len(file)-4)
	local ending = string.sub(file, string.len(file)-3,string.len(file))
	if ending ~= ".png" then
		print("[SPRITE]: "..file.." is not a valid Image file! It will be ignored")
		return "Ignore"
	elseif sprite.objects[name] then
    	print("[SPRITE]: "..tostring(file).." is already calculated! Please check your files")
    	return "Known"
    else
    	print("[SPRITE]: Succesfully calculated Hitbox for "..file)
    	return "Sum",sprite.calcHitbox(path)
	end
end

function sprite.calcHitbox(path)
	local box = loadSprite(path)
	local boxShoot = {}
	local boxFire = {}
	for i,v in pairs(box.map) do
		boxShoot[i] = {}
		for j=1,string.len(v) do
			if tostring(string.sub(v,j,j)) == "1" then
				boxShoot[i][j] = true
				table.insert(boxFire, {x=i,y=j,state=true})
			else
			    boxShoot[i][j] = false
			end
		end
	end
	return boxShoot, boxFire, {w=box.width,h=box.height}
end

function loadSprite(s)
   local s = love.image.newImageData(s)
   local w,h = s:getWidth(),s:getHeight()  -- gets image width and height
   local batch = {} -- Converts the sprite into a sort of binary table...0 matches pixels with transparency
      for y = 0,h-1 do batch[y+1] = ''
         for x = 0,w-1 do
         local _,_,_,a = s:getPixel(x,y)
         batch[y+1] = ((a == 0) and batch[y+1]..' ' or batch[y+1]..'1')
         end
      end
      return { -- Returns a custom structure
               map = batch,  -- the 'binary' sprite
               width = w,  -- width
               height = h, -- height  
            }
end

function thread()
	local request = love.thread.newChannel("request")
	local answer = love.thread.newChannel("answer")

	while true do
		local string = {request:pop()}
		local path = tostring(string[1])
		local file = tostring(string[2])
		if love.filesystem.exists(path) and file and tostring(type(file)) == "string" then
			local t = {sprite.calculateSprite(path,file)}
			answer:supply("boxShoot")
			for i,v in pairs(t[1]) do
				answer:supply(tostring(i))
				answer:supply(v)
			end
			answer:supply("boxFire")
			answer:supply(t[2])
			answer:supply("width")
			answer:supply(t[3].w)
			answer:supply("height")
			answer:supply(t[3].h)
			answer:supply("End")
		else
			answer:supply("No File")
		end
	end
end

thread()