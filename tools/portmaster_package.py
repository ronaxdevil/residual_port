"""Assemble the single BYO-data install archive from an explicit public file list."""
from pathlib import Path
import json
import zipfile

def public_files(root):
    package = root / 'package'
    names = ['Residual.sh', 'port.json', 'README.md', 'gameinfo.xml', 'screenshot.png',
             'residual/display.inc', 'residual/residual.ini', 'residual/runtime/residual-host.jar']
    names += [p.relative_to(package).as_posix()
              for p in sorted((package / 'residual/licenses').iterdir()) if p.is_file()]
    return {name: (package / name).read_bytes() for name in names}

def export(root):
    root = Path(root)
    files = public_files(root)
    tree = root / 'ports/residual'
    manifest = root / 'build/portmaster-export.json'
    manifest.parent.mkdir(exist_ok=True)
    previous = json.loads(manifest.read_text(encoding='utf-8')) if manifest.exists() else []
    for name in previous:
        path = (tree / name).resolve()
        path.relative_to(tree.resolve())
        if name not in files and path.is_file():
            path.unlink()
    for name, data in files.items():
        target = tree / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
    manifest.write_text(json.dumps(sorted(files)), encoding='utf-8')
    dist = root / 'dist'
    dist.mkdir(exist_ok=True)
    destination = dist / 'Residual.zip'
    temporary = root / 'build/Residual.zip'
    with zipfile.ZipFile(temporary, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
        for name, data in sorted(files.items()):
            installed = name
            if '/' not in name and name != 'Residual.sh':
                installed = 'residual/' + ('residual.md' if name == 'README.md' else name)
            info = zipfile.ZipInfo(installed, (2026, 9, 11, 0, 0, 0))
            info.create_system = 3
            info.external_attr = (0o100755 if name.endswith('.sh') else 0o100644) << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, data)
    temporary.replace(destination)
    print('Built', destination)

if __name__ == '__main__':
    export(Path(__file__).resolve().parents[1])
