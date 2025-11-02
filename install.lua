TAR_UNARCHIVER_URL = "https://raw.githubusercontent.com/MCJack123/CC-Archive/refs/heads/master/tar.lua"

print("About to install cpm: CC Package Manager. Are you sure?\nPress Y to confirm or any other key to cancel.")

local event, key = os.pullEvent("key")
if key ~= "y" then 
    print("Cancelled.")
    exit() 
end

print("Installing.")
print("Step 1: install github.com/MCJack123/CC-Archive/tar.lua")
shell.run("cd /")
shell.run("wget " .. TAR_UNARCHIVER_URL)
print("Done!")

print("Step 2a: download github.com/electrovoyage/cpm")
local data = textutils.deserializeJSON(http.get("https://api.github.com/repos/electrovoyage/cpm/releases/latest"))
local downloadURL = data.tarball_url
shell.run("mkdir /tmp/cpm-installer")
shell.run("cd /tmp/cpm-installer")
shell.run("wget " .. downloadURL .. " downloaded.tar")

print("Step 2b: unarchive download")
shell.run("/tar -xf /tmp/cpm-installer/downloaded.tar -C /tmp/cpm-installer/unpacked1")