TAR_UNARCHIVER_URL = "https://raw.githubusercontent.com/MCJack123/CC-Archive/refs/heads/master/tar.lua"

print("About to install cpm: CC Package Manager. Are you sure?\nPress Y to confirm or any other key to cancel.")

local event, key = os.pullEvent("key")
if key ~= keys.y then 
    print("Cancelled.")
    exit()
end

shell.run("mkdir /cpm")

print("Installing.")
print("Step 1: install github.com/MCJack123/CC-Archive/tar.lua")
shell.run("wget " .. TAR_UNARCHIVER_URL .. " /cpm/tar.lua")
print("Done!")

print("Step 2: download github.com/electrovoyage/cpm")
local data = textutils.unserializeJSON(http.get("https://api.github.com/repos/electrovoyage/cpm/releases/latest"):readAll())
local downloadURL = data.assets[1].browser_download_url
shell.run("wget " .. downloadURL .. " /cpm/cpm.lua")

print("Step 3: add command aliases for cpm and tar")
shell.run("mkdir /startup")
io.open("/cpm/aliases.json", "w"):write(textutils.serializeJSON({
    ["cpm"] = "/cpm/cpm",
    ["tar"] = "/cpm/tar"
})):close()

io.open("/startup/cpm_aliases.lua", "w"):write([[
-- cpm: CC Package Manager
local f = io.open('/cpm/aliases.json', 'r')
local aliases = textutils.unserializeJSON(f:read())
f:close()
for key, value in pairs(aliases) do
    shell.setAlias(key, value)
end
]]):close()

print("Done!")