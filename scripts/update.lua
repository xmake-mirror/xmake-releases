import("core.base.option")
import("core.base.json")
import("net.http")

function main()
    local updateinfo = io.load(path.join(os.scriptdir(), "..", "update.txt"))
    local version = updateinfo.version
    local assets = os.iorunv("gh", {"release", "view", "v" .. version, "--json", "assets", "--repo", "xmake-io/xmake"})
    local assets_json = assert(json.decode(assets).assets, "assets not found!")
    local ok = try {function() os.exec("git checkout %s", version); return true end}
    if not ok then
        print("new branch %s", version)
        os.exec("git branch %s", version)
        os.exec("git checkout %s", version)
        os.rm("*|.git")
    end
    os.mkdir("assets")
    for _, asset in ipairs(assets_json) do
        http.download(asset.url, path.join("assets", asset.name))
    end
    print("preparing files ..")
    os.cp("assets/xmake-v" .. version .. ".gz.run", ".")
    os.cp("assets/xmake-v" .. version .. ".xz.run", ".")
    os.cp("assets/xmake-v" .. version .. ".tar.gz", ".")
    os.cp("assets/xmake-v" .. version .. ".zip", ".")
    os.cp("assets/xmake-v" .. version .. ".win32.exe", ".")
    os.cp("assets/xmake-v" .. version .. ".win64.exe", ".")
    os.rm("assets")
    os.exec("zip xmake-v" .. version .. ".win32.exe.zip xmake-v" .. version .. ".win32.exe")
    os.exec("zip xmake-v" .. version .. ".win64.exe.zip xmake-v" .. version .. ".win64.exe")
    os.rm("xmake-v" .. version .. ".win32.exe")
    os.rm("xmake-v" .. version .. ".win64.exe")
    os.exec("git add -A")
    os.exec("git commit -a -m \"update %s\"", version)
    os.exec("git push git@github.com:xmake-mirror/xmake-releases.git %s", version)
    os.exec("git push git@gitee.com:xmake-mirror/xmake-releases.git %s", version)
    os.exec("git push git@gitlab.com:xmake-mirror/xmake-releases.git %s", version)
end
