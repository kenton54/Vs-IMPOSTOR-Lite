function valuesplit(input, sep) --thanks SilverSnow
	if sep == nil then
		sep = '%s'
	end
	local t={}
	for str in string.gmatch(input,"([^"..sep.."]+)") do
		table.insert(t,str)
	end
	return t
end

-- default values just in case
local zoomtype = 'custom'
local zoomamount = 0.9
local zoomduration = 0.5
local tween = 'linear'

function onEvent(name,v1,v2)
	if name == "Bitto's zoom event" then
		if v1 == 'regular' then
			--debugPrint(v2)
			setProperty("defaultCamZoom", v2)
		end
		
		if v1 == 'custom' then
			local table=valuesplit(v2,",")
		
			zoomtype = v1
			zoomamount = table[1]	
			zoomduration = table[2]
			tween = table[3]

		
			--debugPrint(zoomamount .. ' ',zoomduration .. ' ',tween .. ' ')
			doTweenZoom('BittoZoom', 'camGame', zoomamount, zoomduration, tween)
		end
	end
end

function onTweenCompleted(name)
	if name == 'BittoZoom' then
		setProperty("defaultCamZoom",getProperty('camGame.zoom'))
	end
end