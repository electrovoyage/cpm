-- arguments are stored in "arg"

VALID_OPERATIONS = {
    "update",
    "upgrade",
    "install",
    "list"
}

function slice(t, start, end_)
    local t2 = {}
    for index, value in pairs(t) do
        if index >= start and index <= end_ then
            table.insert(t2, value)
        end
    end
    return t2
end

function contains(t, v)
    for index, value in pairs(t) do
        if value == v then
            return true
        end
    end
    return false
end

function doesIndexExist()
    return fs.exists("/cpm/package_index.json")
end

function doesSourcefileExist()
    return fs.exists("/cpm/sources.json")
end

function count(t)
    local i = 0
    for index, value in pairs(t) do
        i = i + 1
    end
    return i
end

--print(textutils.serialize(slice(arg, 2, #arg)))

local operation = arg[1]
if not operation or operation == "help" then
    print([[
Usage:

cpm update - retrieve the latest version of the package index
cpm upgrade - upgrade all installed packages
cpm install <package> - get a new package
cpm list <query> - list all packages matching a query
cpm help - display this
]])

elseif contains(VALID_OPERATIONS, operation) then
    if operation == "update" then
        if not doesSourcefileExist() then
            print("ERROR: /cpm/sources.json doesn't exist! Creating blank one.")
            io.open("/cpm/sources.json", "w"):write(textutils.serializeJSON({
                ['cpm-central'] = 'https://electrovoyage.github.io/cpm-packages/index.json'
            })):close()
        end

        term.write("(Reading sources.json...")
        local f = io.open("/cpm/sources.json", "r")
        local sources = textutils.unserializeJSON(f:read())
        f:close()
        print(" read " .. count(sources) .. " sources.)")

        local newindex = {}
        local packagestotal = 0
        for name, url in pairs(sources) do
            term.write("(Retrieving index " .. name .. "...")
            newindex[name] = textutils.unserializeJSON(http.get(url):readAll())
            local packagesinrepo = count(newindex[name])
            print(" read " .. packagesinrepo .. " packages.)")
            packagestotal = packagestotal + packagesinrepo
        end

        io.open("/cpm/package_index.json", "w"):write(textutils.serializeJSON(newindex)):close()
        print("Read " .. packagestotal .. " packages.")
    end
else
    print("invalid operation " .. operation .. " (run 'cpm help' for help)")
end