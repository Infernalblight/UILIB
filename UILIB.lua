-- UI-only loader (no games, libraries, or main.lua)
local isfile = isfile or function(p) local ok,r=pcall(function()return readfile(p)end) return ok and r~=nil and r~='' end
local delfile = delfile or function(p) writefile(p,'') end

local function downloadFile(path, func)
    if not isfile(path) then
        local ok,res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..
                readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/','')), true)
        end)
        if not ok or res == '404: Not Found' then error(res) end
        if path:find('%.lua$') then
            res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
        end
        writefile(path,res)
    end
    return (func or readfile)(path)
end

local function wipeFolder(path)
    if not isfolder(path) then return end
    for _,file in listfiles(path) do
        if file:find('loader') then continue end
        if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
            delfile(file)
        end
    end
end

for _,folder in {'newvape','newvape/guis','newvape/assets','newvape/profiles'} do
    if not isfolder(folder) then makefolder(folder) end
end

if not shared.VapeDeveloper then
    local _,html = pcall(function() return game:HttpGet('https://github.com/7GrandDadPGN/VapeV4ForRoblox') end)
    local p = html and html:find('currentOid')
    local commit = p and html:sub(p+13,p+52) or 'main'
    if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
        wipeFolder('newvape/guis')
        wipeFolder('newvape/assets')
    end
    writefile('newvape/profiles/commit.txt', commit)
end

-- Only download + run the UI
return loadstring(downloadFile('newvape/guis/new.lua'), 'ui')()
