import("core.base.option")
import("core.base.json")
import("net.http")

function main()
    local updateinfo = io.load(path.join(os.scriptdir(), "..", "update.txt"))
    local version = updateinfo.version
    local tag = "v" .. version
    local assets = os.iorunv("gh", {"release", "view", tag, "--json", "assets", "--repo", "xmake-io/xmake"})
    print(assets)
    local assets_json = assert(json.decode(assets).assets, "assets not found!")
    print(assets_json)
    os.mkdir("assets")
    for _, asset in ipairs(assets_json) do
        print("download", asset.name)
        http.download(asset.url, path.join("assets", asset.name))
    end
    os.exec("git clone git@github.com:xmake-mirror/xmake-releases.git")
    os.cd("xmake-releases")
end
