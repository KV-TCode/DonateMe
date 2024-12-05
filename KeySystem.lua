local Library = {}
function getData(link)
	local data = request({
		url = link,
		Method = "GET",
		Headers = {
			["x-uptime-check"] = "sc1pnzhtj9ch54lmabdfglmwvlw7xmbisfmryknnz8",
			["x-content-type"] = "c2mxcg5asfrqounontrstufirgzhte1xvkx3n3hnyklzzm1swutotitaod0",
			["user-agent"] = "pandaauth",
		}
	})

	if data.StatusCode == 200 then
		return data.Body
	end
end
function Library:Get() 
	return "https://pandadevelopment.net/v2_validation/getkey?service=tchub&hwid=" .. game:GetService("RbxAnalyticsService"):GetClientId()
end
function Library:Check(clientKey)
	local a = getData("https://pandadevelopment.net/v2_validation" .. "?hwid=" .. game:GetService("RbxAnalyticsService"):GetClientId() .. "&service=tchub&key=" .. clientKey)
	
	local success, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(a)
	end)
	if success and data["V2_Authentication"] == "success" then
		return true
	end
	return false
end

return Library
