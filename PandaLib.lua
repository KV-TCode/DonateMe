local PandaAuth = {}

local uptimeCheck = "sc1pnzhtj9ch54lmabdfglmwvlw7xmbisfmryknnz8"
local content = "c2mxcg5asfrqounontrstufirgzhte1xvkx3n3hnyklzzm1swutotitaod0"
local agent = "pandaauth"

getgenv().Panda_ProcessingStat = false

local server_configuration = "https://pandadevelopment.net"

local validation_service = server_configuration .. "/v2_validation"

local function Get_RequestData(data_link)
    if getgenv().Panda_ProcessingStat then
        warn("Your Command has been Throttle, Please Wait....")
        return "No_Data"
    end

    getgenv().Panda_ProcessingStat = true
    local DataResponse = request({
        Url = data_link,
        Method = "GET",
        Headers = {
            ["x-uptime-check"] = uptimeCheck,
            ["x-content-type"] = content,
            ["user-agent"] = agent
        }
    })

    getgenv().Panda_ProcessingStat = false

    if DataResponse.StatusCode == 200 then
        return DataResponse.Body
    else
        return "No_Data"
    end
end

local function GetHardwareID(service)

    local client_id = game:GetService("RbxAnalyticsService"):GetClientId()
    local success, jsonData =
        pcall(
        function()
            return game:GetService("HttpService"):JSONDecode(
                Get_RequestData(server_configuration .. "/serviceapi?service=" .. service .. "&command=getconfig")
            )
        end
    )
    if success then
        if jsonData.AuthMode == "playerid" then
            return tostring(game:GetService("Players").LocalPlayer.UserId)
        elseif jsonData.AuthMode == "hwidplayer" then
            return client_id .. game:GetService("Players").LocalPlayer.UserId
        elseif jsonData.AuthMode == "hwidonly" then
            return client_id
        elseif jsonData.AuthMode == "fingerprint" then
            local GetFingerprint = Get_RequestData(server_configuration .. "/fingerprint")
            return tostring(GetFingerprint)
        else
            return game:GetService("Players").LocalPlayer.UserId
        end
    else
        return client_id
    end
end

function PandaAuth:GetKey(Exploit)
    return server_configuration .. "/getkey?service=" .. Exploit .. "&hwid=" .. GetHardwareID(Exploit)
end

function PandaAuth:ValidateKey(serviceID, ClientKey)
    if ClientKey == "" then
        return false
    end
    local Data =
        Get_RequestData(
        validation_service .. "?hwid=" .. GetHardwareID(serviceID) .. "&service=" .. serviceID .. "&key=" .. ClientKey
    )
    if Data == "No_Data" then
        return false
    end
    local success, data =
        pcall(
        function()
            return game:GetService("HttpService"):JSONDecode(Data)
        end
    )
    if success and data["V2_Authentication"] == "success" then
        return true
    end
    return false
end

function PandaAuth:ValidatePremiumKey(serviceID, ClientKey)
    if ClientKey == "" then
        return false
    end
    local Data =
        Get_RequestData(
        validation_service .. "?hwid=" .. GetHardwareID(serviceID) .. "&service=" .. serviceID .. "&key=" .. ClientKey
    )
    if Data == "No_Data" then
        return false
    end
    local success, data =
        pcall(
        function()
            return game:GetService("HttpService"):JSONDecode(Data)
        end
    )
    if success and data["V2_Authentication"] == "success" and data["Key_Information"]["Premium_Mode"] == true then
        return true
    end
    return false
end

return PandaAuth
