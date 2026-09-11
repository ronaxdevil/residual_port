"""Build the Residual PortMaster host and BYO-data ZIP from the owner's Windows JAR."""
import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SHA256 = '8f8caa7dc36f5ab9c7119046ccce87e3f7a2d61680dc60970fa3d2b2d619ee01'

def add(out, source, target):
    entry = zipfile.ZipInfo(target, (2026, 9, 9, 0, 0, 0))
    entry.create_system = 3
    entry.external_attr = (0o100755 if target.endswith('.sh') else 0o100644) << 16
    entry.compress_type = zipfile.ZIP_DEFLATED
    out.writestr(entry, source.read_bytes())

def package():
    from portmaster_package import export
    export(ROOT)
    from verify_package import verify
    verify(ROOT)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game-jar',type=Path)
    parser.add_argument('--jdk',type=Path)
    parser.add_argument('--package-only',action='store_true')
    args = parser.parse_args()
    if args.package_only:
        if not (ROOT/'package/residual/runtime/residual-host.jar').is_file():
            parser.error('Run a full build before --package-only')
        package(); return
    if not args.game_jar or not args.jdk: parser.error('--game-jar and --jdk are required')
    game = args.game_jar.resolve(); jdk = args.jdk.resolve()
    if hashlib.sha256(game.read_bytes()).hexdigest() != SHA256: parser.error('Unsupported game JAR fingerprint')
    suffix = '.exe' if os.name == 'nt' else ''
    javac = jdk/'bin'/('javac'+suffix)
    classes = ROOT/'build/classes'; classes.mkdir(parents=True,exist_ok=True)
    # Require JDK 17+ for --release and emit Java 8-compatible host bytecode.
    compile_cp = ROOT/'build/compile-classpath'
    compile_cp.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(game) as archive:
        for entry in archive.infolist():
            if entry.filename.endswith('.class'):
                target = (compile_cp/entry.filename).resolve()
                target.relative_to(compile_cp.resolve())
                target.parent.mkdir(parents=True,exist_ok=True)
                target.write_bytes(archive.read(entry))
    subprocess.run([str(javac),'--release','8','-Xlint:-options','-encoding','UTF-8','-cp',str(compile_cp),
                    '-d',str(classes),*[str(p) for p in sorted((ROOT/'src').rglob('*.java'))]],check=True)
    runtime = ROOT/'package/residual/runtime'; runtime.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(runtime/'residual-host.jar','w') as out:
        for path in sorted(classes.rglob('*.class')): add(out,path,path.relative_to(classes).as_posix())
    package()

if __name__ == '__main__': main()
