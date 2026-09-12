"""Verify the sole distribution archive and its BYO-data boundary."""
import configparser
import io
import json
from pathlib import Path
import struct
import xml.etree.ElementTree as ET
import zipfile
from portmaster_package import public_files

def verify(root):
    root = Path(root)
    assert {p.name for p in (root/'dist').iterdir()} == {'Residual.zip'}
    expected = public_files(root)
    license_dir = root/'package/residual/licenses'
    required_licenses = {'LICENSE-residual.txt', 'LICENSE-residual-host.txt', 'LICENSE-gptokeyb.txt', 'NOTICE-residual-assets.txt'}
    missing = required_licenses - {p.name for p in license_dir.iterdir() if p.is_file()}
    if missing:
        raise ValueError('Missing component notices: ' + ', '.join(sorted(missing)))
    if any(p.is_dir() for p in license_dir.iterdir()):
        raise ValueError('Keep component license files directly inside residual/licenses')
    if (root/'LICENSE').read_bytes() != (license_dir/'LICENSE-residual.txt').read_bytes():
        raise ValueError('Source and packaged port license must match')
    mapper_license = (license_dir/'LICENSE-gptokeyb.txt').read_text(encoding='utf-8')
    if 'GNU GENERAL PUBLIC LICENSE' not in mapper_license or 'Version 2' not in mapper_license:
        raise ValueError('Keep the full upstream gptokeyb2 license in LICENSE-gptokeyb.txt')
    host_license = (license_dir/'LICENSE-residual-host.txt').read_text(encoding='utf-8')
    if 'MIT License' not in host_license or 'Component: residual-host.jar' not in host_license:
        raise ValueError('The host must have its dedicated MIT license notice')
    with zipfile.ZipFile(root/'dist/Residual.zip') as archive:
        assert archive.testzip() is None
        assert len(archive.namelist()) == len(set(archive.namelist())) == len(expected)
        for name, data in expected.items():
            installed = name
            if '/' not in name and name != 'Residual.sh':
                installed = 'residual/' + ('residual.md' if name == 'README.md' else name)
            assert archive.read(installed) == data, installed
            assert (archive.getinfo(installed).external_attr >> 16 & 0o777) == (0o755 if name.endswith('.sh') else 0o644)
            if name.endswith(('.sh', '.ini', '.inc')): assert b'\r' not in data
        assert 'residual/residual.jar' not in archive.namelist()
        assert not any(n.endswith(('.exe', '.dll', '.apk', '.gptk')) for n in archive.namelist())
        with zipfile.ZipFile(io.BytesIO(archive.read('residual/runtime/residual-host.jar'))) as host:
            assert host.testzip() is None
            assert 'org/portmaster/residual/Main.class' in host.namelist()
            assert all(n.startswith('org/portmaster/residual/') and n.endswith('.class') and 'Smoke' not in n for n in host.namelist())
    meta = json.loads(expected['port.json'])
    assert meta['version'] == 4 and meta['name'] == 'residual.zip'
    assert meta['items'] == ['Residual.sh','residual']
    attr = meta['attr']
    assert attr['porter'] == ['Pixelforge Ports (Ronax)']
    assert attr['rtr'] is False and attr['exp'] is False
    assert attr['arch'] == ['aarch64'] and attr['availability'] == 'paid'
    assert attr['runtime'] == ['weston_pkg_0.2.squashfs','zulu17.54.21-ca-jre17.0.13-linux.squashfs']
    assert all(set(s) == {'name','gameurl','developerurl'} for s in attr['store'])
    xml = ET.fromstring(expected['gameinfo.xml'])
    assert xml.findtext('game/path') == './Residual.sh'
    assert xml.findtext('game/image') == './residual/screenshot.png'
    assert struct.unpack('>II', expected['screenshot.png'][16:24]) == (640,480)
    config = configparser.ConfigParser(interpolation=None)
    config.read_string(expected['residual/residual.ini'].decode('utf-8'))
    if not config.has_section('controls'):
        raise ValueError('residual.ini must contain a [controls] section')
    if not any(value.strip() for value in config['controls'].values()):
        raise ValueError('residual.ini must contain at least one nonempty control binding')
    # Archive mappings already match the source byte-for-byte above.
    # Control choices are editable; do not require the original default bindings.
    print('PACKAGE_OK: single Residual.zip, BYO-only payload, metadata, controls, permissions and CRCs')

if __name__ == '__main__':
    verify(Path(__file__).resolve().parents[1])
