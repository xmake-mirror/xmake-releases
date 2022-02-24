import("core.base.option")
import("core.base.json")
import("net.http")

function main()
    local updateinfo = io.load(path.join(os.scriptdir(), "..", "update.txt"))
    local version = updateinfo.version
    local tag = "v" .. version
    local assets = os.iorunv("gh", {"release", "view", tag, "--json", "assets", "--repo", "xmake-io/xmake"})
    local assets_json = assert(json.decode(assets).assets, "assets not found!")
    os.mkdir("assets")
    for _, asset in ipairs(assets_json) do
        http.download(asset.url, path.join("assets", asset.name))
    end
    os.exec("git clone git@github.com:xmake-mirror/xmake-releases.git")
    os.cd("xmake-releases")
    local ok = try {function() os.exec("git checkout %s", tag); return true end}
    if not ok then
        os.exec("git branch %s", tag)
        os.exec("git checkout %s", tag)
        os.rm("*")
    end
    os.cp("../assets/xmake-" .. tag .. ".gz.run", ".")
    os.cp("../assets/xmake-" .. tag .. ".xz.run", ".")
    os.cp("../assets/xmake-" .. tag .. ".tar.gz", ".")
    os.cp("../assets/xmake-" .. tag .. ".zip", ".")
    os.exec("zip xmake-" .. tag .. ".win32.exe.zip ../assets/xmake-" .. tag .. ".win32.exe")
    os.exec("zip xmake-" .. tag .. ".win64.exe.zip ../assets/xmake-" .. tag .. ".win64.exe")
    os.exec("git status")
end
