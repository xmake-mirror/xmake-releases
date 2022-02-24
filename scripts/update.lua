import("core.base.option")
import("core.base.json")
import("net.http")

function main()
    local updateinfo = io.load(path.join(os.scriptdir(), "..", "update.txt"))
    local version = updateinfo.version
    local assets = os.iorunv("gh", {"release", "view", "v" .. version, "--json", "assets", "--repo", "xmake-io/xmake"})
    local assets_json = assert(json.decode(assets).assets, "assets not found!")
    os.mkdir("assets")
    for _, asset in ipairs(assets_json) do
        http.download(asset.url, path.join("assets", asset.name))
    end
    os.exec("git clone git@github.com:xmake-mirror/xmake-releases.git")
    os.cd("xmake-releases")
    local ok = try {function() os.exec("git checkout %s", version); return true end}
    if not ok then
        os.exec("git branch %s", version)
        os.exec("git checkout %s", version)
        os.rm("*")
    end
    os.cp("../assets/xmake-v" .. version .. ".gz.run", ".")
    os.cp("../assets/xmake-v" .. version .. ".xz.run", ".")
    os.cp("../assets/xmake-v" .. version .. ".tar.gz", ".")
    os.cp("../assets/xmake-v" .. version .. ".zip", ".")
    os.exec("zip xmake-v" .. version .. ".win32.exe.zip ../assets/xmake-v" .. version .. ".win32.exe")
    os.exec("zip xmake-v" .. version .. ".win64.exe.zip ../assets/xmake-v" .. version .. ".win64.exe")
    os.exec("git status")
end
