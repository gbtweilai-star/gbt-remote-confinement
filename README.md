# remote_confinement

**One capability bit from GBT V8, packaged standalone.** No. 302 of 341,
`tentacle` domain (Tentacle).

<p>
<img alt="python" src="https://img.shields.io/badge/python-3.9%2B-blue">
<img alt="license" src="https://img.shields.io/badge/license-MIT-green">
<img alt="deps" src="https://img.shields.io/badge/runtime%20dependencies-0-brightgreen">
</p>

> **执行者隔离**（主人 2026-10-09 点破：「沙盒隔离的是被测试的靶标，没隔离执行的人」）：exec 中继若在宿主以主人账号跑，云端敲的命令就跑在真机上。op=assess/verdict 现读执行身份（whoami+是否提权）与三条隔离路（Docker 守护/WSL 发行版/低权账号）**并真验每条能不能跑**；ttl 读看门狗（中继最长 TTL）；grant **只查**主人发的 remote_device 票（AI 不发）；guard 是启中继前的最后一道闸：**未隔离 + 无票 ⇒ 一律拒启**（fail-closed），拒了说清怎么开。本件已焊进 desktop_commander.remote_start。

That description is copied verbatim from the registry. `tests/test_spec.py` pins it,
so documentation drift fails the build instead of shipping quietly.

## What this package actually is

It is the **contract** for one capability: its name, its parameters, the values it
accepts, and whether it can change state that cannot be restored. It is not the
implementation — that lives in the runtime this bit was extracted from.

So `run()` goes through a narrow `Backend` protocol, and the default backend is a
stub that **says so**:

```
status="validated"   backend="stub"   data={"executed": false}
```

Never `status="ok"`. A stub that reports success is worse than no stub, because the
caller stops looking for the real thing.

## Install

```bash
git clone https://github.com/gbtweilai-star/gbt-remote-confinement.git
cd gbt-remote-confinement
python -m pip install -e ".[dev]"
```

## Use

```bash
python -m gbt_remote_confinement info                  # capability card
python -m gbt_remote_confinement spec --json           # machine-readable contract
python -m gbt_remote_confinement check --payload '{}'
python -m gbt_remote_confinement run   --payload '{}'
```

Real `info` output from this machine:

```text
remote_confinement  (tentacle)  v1.0.0
----------------------------------------
**执行者隔离**（主人 2026-10-09 点破：「沙盒隔离的是被测试的靶标，没隔离执行的人」）：exec 中继若在宿主以主人账号跑，云端敲的命令就跑在真机上。op=assess/verdict 现读执行身份（whoami+是否提权）与三条隔离路（Docker 守护/WSL 发行版/低权账号）**并真验每条能不能跑**；ttl 读看门狗（中继最长 TTL）；grant **只查**主人发的 remote_device 票（AI 不发）；guard 是启中继前的最后一道闸：**未隔离 + 无票 ⇒ 一律拒启**（fail-closed），拒了说清怎么开。本件已焊进 desktop_commander.remote_start。

gated      : True   <- needs explicit consent
external   : False
multi-op   : True
params     : (none)
values     : (multi-op, but the registry does not enumerate them)
```

Wire a real implementation:

```python
from gbt_remote_confinement import run

class MyBackend:
    name = "my-backend"
    def invoke(self, cap, payload):
        return {"cap": cap, "handled": sorted(payload)}

result = run({}, backend=MyBackend())
assert result.status == "ok"
```

## Parameters

| name | required | notes |
|---|---|---|
| — | no | the registry declares no required parameters |

Registry hint (`params_hint`): (empty)

**注册表标注 `multi_op: true`，但没有枚举具体取值。**本包不替它编造取值清单——这种缺口应当在注册表源头补，而不是在文档里圆。

Types are deliberately absent: the registry does not declare them, and an invented
type is worse than no type, because callers believe it.

## Boundaries

- Gated: this bit is marked `safe: false` in the registry — it can change state that no inverse action restores.
- No external service dependency declared.
- Multi-op (`multi_op: true`): several sub-actions share one name — read `op` before calling.
- No implementation ships here. Bring a backend; the protocol is one method.

## What this is not

Not a wrapper around a hosted API. Not a model. Not a promise that calling it does
anything on its own. It is the typed seam plus the validation, which is the part that
stays correct even when the implementation changes.

## Tests

```bash
python -m pytest
```

```text
20 passed, 3 skipped in 0.14s
```

## Provenance

| field | value |
|---|---|
| capability | `remote_confinement` |
| domain | `tentacle` |
| handler | `remote_confinement` |
| safe | `False` (gated = `True`) |
| external | `False` |
| atlas page | [tentacle/remote_confinement](https://github.com/gbtweilai-star/gbt-caps/blob/main/caps/tentacle/remote_confinement.md) |
| full index | [https://github.com/gbtweilai-star/gbt-caps](https://github.com/gbtweilai-star/gbt-caps) |

The parent README says 348 capabilities; an AST pass over the registry enumerates
`341 + 0 unimplemented + 0 disabled = 341`. The extra 7 are historical duplicates.
Numbering here follows 341 and matches the `gbt-caps` index one-to-one.

## License

MIT.
