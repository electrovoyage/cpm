TAR_UNARCHIVER_URL = "https://raw.githubusercontent.com/MCJack123/CC-Archive/refs/heads/master/tar.lua"

print("About to install cpm: CC Package Manager. Are you sure?\nPress Y to confirm or any other key to cancel.")

local event, key = os.pullEvent("key")
if key ~= keys.y then 
    print("Cancelled.")
    exit()
end

print("Installing.")
print("Step 1: install github.com/MCJack123/CC-Archive/tar.lua")
shell.run("cd /")
shell.run("wget " .. TAR_UNARCHIVER_URL)
print("Done!")

print("Step 2: download github.com/electrovoyage/cpm")
local data = textutils.unserializeJSON(http.get("https://api.github.com/repos/electrovoyage/cpm/releases/latest"):readAll())
local downloadURL = data.assets[1].url
shell.run("wget " .. downloadURL .. " /cpm/cpm.lua")

print("Step 3: add cpm command alias")
shell.setAlias("cpm", "/cpm/cpm")

print("Done!")