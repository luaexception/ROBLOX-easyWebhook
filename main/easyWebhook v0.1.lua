local easyFunctions = {}
local http = game:GetService("HttpService")
local displayMessages = false

local validDatatypes = {
	["content"] = {typeis = "string", length = 2000},
	["username"] = {typeis = "string", length = 256},
	["avatar_url"] = {typeis = "string", length = 256},
	["embeds"] = {typeis = "table", length = 10}
}

function easyFunctions:Warn(message)
    if not displayMessages then
        warn("easyWebhook | " .. message)
    end
end

function easyFunctions:CheckHTTPEnabled()
	local request
	local ok, msg = pcall(function()
		request = http:GetAsync('https://google.com')
	end)
	return ok
end

function easyFunctions:CheckIsDataType(datatype)
	for datatypetree, _ in pairs(validDatatypes) do
		if datatypetree == datatype then
			return true
		end
	end
	return false
end

return function(url, settings)
	-- check https enabled
	assert(easyFunctions:CheckHTTPEnabled(), "easyWebhook | HTTPS is not enabled! Enable this setting via game settings.")
	local mainfunctions = {}
		
    -- settings
    displayMessages = settings.HidePrints or false
    
    -- functions
	function mainfunctions:PostAsync(data)
		if data then
			local foundContent = false
			for datatype, datainformation in pairs(data) do
				datatype = datatype:lower()
				if easyFunctions:CheckIsDataType(datatype) then
					if datatype == "content" and datainformation ~= nil then
						foundContent = true
					end
					if #datainformation > validDatatypes[datatype].length then
						easyFunctions:Warn(string.format("easyWebhook | %s exceeds the limit (%i) by %i", datatype, validDatatypes[datatype].length, #datainformation - validDatatypes[datatype].length))
						return
					end
				end
			end
			if foundContent then
				local data = http:JSONEncode(data)
				local requestresponse
				local ok, msg = pcall(function()
					requestresponse = http:PostAsync(url, data, Enum.HttpContentType.ApplicationJson, false)
				end)
				if not ok then
					easyFunctions:Warn("easyWebhook | " .. msg)
					return false
				else
					return true
				end
			else
				easyFunctions:Warn("easyWebhook | no content type provided or data provided for content.")
				return false
			end
		else
			easyFunctions:Warn("easyWebhook | No data was sent to function..")
			return false
		end
	end
	
	return mainfunctions
end
