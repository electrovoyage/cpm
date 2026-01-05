-- arguments are stored in "arg"

VALID_OPERATIONS = {
    "update",
    "upgrade",
    "install",
    "list"
}

HANDLERS = {
    ["github"] = function(package, data)
        local releasedata = textutils.unserializeJSON(http.get(data.url):readAll())
        local tarball = http.get(releasedata.tarball_url):readAll()
        shell.run("mkdir /tmp")
        io.open(string.format("/tmp/%d.tar", releasedata.id), 'w'):write(tarball):close()
        shell.run(string.format('tar -xf /tpm/%d.tar -C /cpm/%s', releasedata.id, package))
        shell.run(string.format("rm /tmp/%d.tar", releasedata.id))
    end
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

function containsKey(t, k)
    for key, value in pairs(t) do
        if k == key then
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

-- Count entries in table
function count(t)
    local i = 0
    for index, value in pairs(t) do
        i = i + 1
    end
    return i
end

-- Count entries in each table inside of t
function level2count(t)
    local i = 0
    for key, value in pairs(t) do
        i = i + count(value)
    end
    return i
end

function ifNoSourcesMakeSome()
    if not doesSourcefileExist() then
        print("ERROR: /cpm/sources.json doesn't exist! Creating blank one.")
        io.open("/cpm/sources.json", "w"):write(textutils.serializeJSON({
            ['cpm-central'] = 'https://electrovoyage.github.io/cpm-packages/index.json'
        })):close()
    end
end

-- Find repository that has a certain package
function resolve(package, package_index)
    term.write("(Resolving " .. package .. "...")
    for name, source in pairs(package_index) do
        if containsKey(source, package) then
            print(string.format(" found in %s.)", name))
            return source[package]
        end
    end
    return nil
end

function readPackageIndex()
    term.write("(Reading package index...")
    local f = io.open("/cpm/package_index.json", "r")
    local package_index = textutils.unserializeJSON(f:read())
    f:close()
    print(string.format(" read %d packages over %d repositories.)", level2count(package_index), count(package_index)))
    return package_index
end

function doInstall(package, package_index)
    local pkgdata = resolve(package, package_index)
    if not pkgdata then
        print("error: no candidates for package "..package)
        return false
    end
    
    if pkgdata.dependencies then
        for index, dependency in pairs(pkgdata.dependencies) do
            doInstall(dependency, package_index)
        end
    end

    print('installing ' .. package)
    shell.run("mkdir /cpm/packages/" .. package)
    HANDLERS[pkgdata.handler](package, pkgdata)
    print("installed " .. package)
end

function install(packages)
    if not doesIndexExist() then
        print("There is no package index in /cpm! Run 'cpm update' first.")
        return
    end
    for index, package in pairs(packages) do
        if not doInstall(package, readPackageIndex()) then
            return false
        end
    end
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

This CPM has Super Ender Dragon Powers.]])

elseif contains(VALID_OPERATIONS, operation) then
    if operation == "update" then
        ifNoSourcesMakeSome()

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
    elseif operation == "install" then
        install(slice(arg, 2, #arg))
    end
else
    print("invalid operation " .. operation .. " (run 'cpm help' for help)")
end