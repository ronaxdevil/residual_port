# License inventory

The public package keeps component notices under residual/licenses. The launcher's
upstream MIT notice is included in the port license. The source-root LICENSE is retained
for source repository use and matches the packaged port license.

| Material | Distributed by this port | Notice |
| --- | --- | --- |
| Original Java adaptation host | Yes, as residual-host.jar | LICENSE-residual-host.txt (MIT) |
| Original port support code and documentation | Yes | LICENSE-residual.txt (MIT) |
| Adapted Westonpack launcher example portions | Yes, in Residual.sh | LICENSE-residual.txt (included BinaryCounter MIT notice) |
| Residual screenshot | Yes | NOTICE-residual-assets.txt; original artwork rights retained |
| Handwritten compile-only API declarations | Source only; excluded from host JAR | Source LICENSE, limited to original port contributions |
| libGDX 1.13.1 compile dependencies | Downloaded into ignored build cache; excluded from source uploads and ZIP | Upstream libGDX Apache-2.0 terms remain with the dependency |
| gptokeyb2 | Mapper provided by PortMaster; license retained in this port | LICENSE-gptokeyb.txt (upstream gptokeyb2 license) |
| Weston, Xwayland, Crusty, GL4ES and Java runtime components | Downloaded/provided separately by PortMaster | Their runtime distributions retain their own component notices |
| Original residual.jar, including libGDX/LWJGL/OpenAL and other embedded components | Supplied by the player; excluded from ZIP | Original game and embedded third-party terms remain intact |

LICENSE-gptokeyb.txt is a required notice for this port's packaging, matching the
provided reference layout and the maintainer's requirement. Keep it even though
PortMaster supplies the mapper executable. Its text is copied unchanged from the
PortsMaster/gptokeyb2 upstream LICENSE.txt, matching the launcher's GPTOKEYB2 usage.
Do not remove it when pruning notices for externally supplied dependencies.

LICENSE-residual-host.txt separately identifies the distributed adaptation JAR
under the project's MIT terms. It does not license the proprietary residual.jar.

The standalone GL4ES license is omitted because its library is supplied inside the
separate runtime. BinaryCounter's example notice remains for adapted launcher code.

No full game EULA is presented as a license for the host. No blanket MIT license is
applied to proprietary artwork or external dependencies. If third-party code,
libraries or assets are added to the distributed payload later, review their actual
upstream notices and update this inventory before packaging.

Upstream sources:

- https://github.com/PortsMaster/gptokeyb2/blob/master/LICENSE.txt

- https://github.com/binarycounter/Westonpack/blob/main/LICENSE
- https://github.com/binarycounter/Westonpack/wiki/LibGDX-Example
- https://github.com/libgdx/libgdx/blob/master/LICENSE
- https://portmaster.games/packaging.html
