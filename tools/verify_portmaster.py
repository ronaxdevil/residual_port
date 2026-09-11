"""Verify that the generated PortMaster tree matches the public inputs."""
from pathlib import Path
from portmaster_package import public_files
from verify_package import verify

root = Path(__file__).resolve().parents[1]
verify(root)
tree = root/'ports/residual'
expected = public_files(root)
actual = {p.relative_to(tree).as_posix():p.read_bytes() for p in tree.rglob('*') if p.is_file()}
assert actual == expected
print('PORTMASTER_TREE_OK: public repository layout matches source inputs')
