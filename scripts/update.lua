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
    -- publish to xmake-releases
    print("publish to xmake-releases ..")
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
    --os.exec("git push git@github.com:xmake-mirror/xmake-releases.git %s", version)
    os.exec("git push git@gitee.com:xmake-mirror/xmake-releases.git %s", version)
    os.exec("git push git@gitlab.com:xmake-mirror/xmake-releases.git %s", version)
    os.exit()
    -- publish to aur
    print("publish to aur ..")
    local sha256 = hash.sha256("xmake-v" .. version .. ".tar.gz")
    os.cd("..")
    os.exec("git clone ssh://aur@aur.archlinux.org/xmake.git xmake-aur")
    os.cd("xmake-aur")
    io.gsub("PKGBUILD", "pkgver=%d+%.%d+%.%d+", "pkgver=" .. version)
    io.gsub("PKGBUILD", "sha256sums=%('.-'%)", "sha256sums=('" .. sha256 .. "')")
    io.gsub(".SRCINFO", "%d+%.%d+%.%d+", version)
    io.gsub(".SRCINFO", "sha256sums = %w+", "sha256sums = " .. sha256)
    os.exec("git diff")
    os.exec("git add -A")
    os.exec("git commit -a -m \"update %s\"", version)
    os.exec("git push origin master")
    -- publish to mingw-packages
    --[[
    os.cd("..")
    os.exec("git clone https://github.com/waruqi/MINGW-packages.git")
    version = "2.6.1"
    os.cd("MINGW-packages")
    os.exec("git branch xmake-%s", version)
    os.exec("git checkout xmake-%s", version)
    io.gsub("mingw-w64-xmake/PKGBUILD", "pkgver=%d+%.%d+%.%d+", "pkgver=" .. version)
    io.gsub("mingw-w64-xmake/PKGBUILD", "sha256sums=%('.-'%)", "sha256sums=('" .. sha256 .. "')")
    os.exec("git diff")
    os.exec("git add -A")
    os.exec("git commit -a -m \"xmake: %s\"", version)
    os.execv("gh", {"pr", "create", "--head", "xmake-" .. version, "--title", "xmake: " .. version, "--body", ""})
    ]]
end
