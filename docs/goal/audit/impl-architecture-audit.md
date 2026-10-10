# Implementation & Architecture Audit — HarmonyOS-YoWireTools

**Audit date:** 2026-10-10 (Asia/Shanghai)  
**Trees:** wifi / bt / nl under `/workspace/src/yowiretools-*`  
**Rule bar:** YoAgentDocs `principle.engineering` — 完整数据链路、禁止旧分层打补丁、阶段内零双轨； user ask — **架构清晰、数据链路统一、严禁多位置耦合**

## Method

- Grep `@kit.*` / `@ohos.*` by layer (ui / domain / data / product / common).
- Find UI→Repository, UI Page→UseCase, Domain→DataSource, Domain→`@kit` type imports.
- Multi-place API call sites for scan/connect/advertise.
- Sample 24 high-risk checklist items (8 per module) for owner-class presence.
- Batch class-name presence vs architecture owners (optimistic structural signal — **not** device acceptance).
- Note unsigned HAP compile success from prior box builds.

---

## A. Layering map (as implemented)

| Module | Intended stack | Actual |
| --- | --- | --- |
| Wi‑Fi | ui → viewmodel → usecase → repository contract → datasource/kit bridge | **Partial.** `WifiDebugViewModel` often calls **`WifiNetworkRepository` directly** (38+ call sites) while also owning UseCases. Session use cases import **DataSources/transports** directly. |
| Bluetooth | feature ui/vm → `common/yobluetooth` domain/data | **Split.** Domain/data live in `common/yobluetooth` (OK per many arch docs). **Pages construct UseCases** (GattClientPage, BlePeripheralPage, …). Several UseCases talk to **DataSource/Gateway**, not only Repository contract. `GattServerUseCases` imports **`@kit.ConnectivityKit`**. |
| NearLink | ui/state → usecase → repository → platform datasource | **Partial.** `NearLinkDebugModel` holds **`NearLinkRepository`**. `NearLinkSessionUseCases` / `NearLinkExtendedUseCases` import **platform DataSources** and transports. Repository imports **`ssap` from `@kit.NearLinkKit`**. |

`product/phone` `EntryAbility`: only AbilityKit/ArkUI — **no** Connectivity/Network/NearLink kit (good).

---

## B. Unified data path & multi-place coupling (violations)

Severity: **P0** blocks “架构清晰 / 数据链路统一”.

### Worst violations (top 5)

1. **`WifiDebugViewModel` God-path dual track**  
   - Path: `features/wifi_network/.../ui/viewmodel/WifiDebugViewModel.ets` (~1514 lines)  
   - Imports `WifiNetworkRepository` **and** multiple UseCases.  
   - Dozens of `this.repository.*` calls for state, linked info, IPv4/6, DNS, traceroute, HTTP abort, cooldown, etc.  
   - **Violation:** UI state layer skips use-case-only path; repository becomes a second façade; same concerns reachable from UseCase **and** VM→Repo.

2. **Domain UseCases → platform DataSource / transport (bypass Repository contract)** — systemic  
   - Wi‑Fi: `WifiNetworkSessionUseCases.ets`, `WifiNetworkExtendedUseCases.ets`, `LanDiscoveryFacade.ets` import `MdnsDataSource`, `SsdpDiscoveryDataSource`, `UdpSocketDataSource`, `WebSocketServerDataSource`, TCP/UDP coordinators, etc.  
   - BT: `GattServerUseCases.ets` → `GattServerDataSource`; `BleAdvertiseUseCases.ets` → `BleAdvertiserDataSource`; `SppServerUseCases.ets` → `SppPlatformGateway`; mappers imported into domain (`GattPlatformMapper`).  
   - NL: `NearLinkSessionUseCases.ets` → `NearLinkAdvertisingDataSource`, `SsapClientDataSource`, `SsapServerDataSource`, `DataTransferDataSource`, …  
   - **Violation:** Kit side effects can be triggered from UseCase→DataSource **and** Repository→DataSource (**multi-place**).

3. **BT feature Pages construct UseCases (skip ViewModel / single orchestration)**  
   - `ui/page/GattClientPage.ets` — 9× `new …UseCase()`  
   - `ui/page/BlePeripheralPage.ets` — `StartBleAdvertiseUseCase` / `StopBleAdvertiseUseCase`  
   - `DeviceIdentityPage.ets`, `BluetoothDiagnosticsPage.ets`, `SessionLogPage.ets` similarly  
   - **Violation:** Page-local UseCase instances ⇒ multiple gateway/session lifecycles; not one unified session path.

4. **`GattServerUseCases` domain imports `@kit.ConnectivityKit` types**  
   - Path: `common/yobluetooth/.../domain/usecase/ble/GattServerUseCases.ets`  
   - `import { ble } from '@kit.ConnectivityKit'` — `ble.GattService` / `ble.NotifyCharacteristic` in domain API  
   - **Violation:** Domain polluted with kit types; also constructs/holds `GattServerDataSource` directly.  
   - **Related:** **No `features/bluetooth` UI reference to GattServer** — server use cases exist but **UI not wired** (advertise page only).

5. **`NearLinkRepository` / session stack kit + god state**  
   - `features/nearlink/.../data/repository/NearLinkRepository.ets` imports `ssap` from `@kit.NearLinkKit` (descriptor typing in repository).  
   - `NearLinkDebugModel.ets` (~929 lines) imports Repository and mixes observe + use cases.  
   - On **non-wifi** phase-D trees, `WifiNetworkRepository` still has `import { socket } from '@kit.NetworkKit'` (wifi tree fixed to **no** kit import in repository — **branch divergence / dual codebase**).

### Additional coupling / clarity issues

| Issue | Paths | Notes |
| --- | --- | --- |
| God repositories | `BluetoothRepository.ets` ~1040–1115 lines; `WifiNetworkRepository.ets` ~570; `NearLinkRepository.ets` ~450–529 | Single mega-repo aggregates many kit domains |
| God UI pages | `WifiModulePages.ets` ~907; `SppConnectDialog.ets` ~1015; `NearLinkSessionViews.ets` ~526 | Hard to keep one path per feature |
| Event bridges OK | `NetworkKitEventBridge`, `ConnectivityKitEventBridge` under `data/kit` | Correct layer for subscriptions |
| Wi‑Fi kit calls concentrated | `WifiInfoDataSource` + `NetworkKitEventBridge` hold `wifiManager.*` | Good for WLAN; undermined by VM→Repo sprawl |
| Cross-feature imports | No strong `features/A`→`features/B` import hits in scan | Modules co-exist in each branch with divergent maturity |
| EntryAbility | no wireless kits | Pass |
| Logger sprawl | per-feature `*ScanLogger` / `*EventLogger` + `common/debug_core` | Acceptable if all session lines still go debug_core; verify on merge |

---

## C. Implementation completeness vs checklist (honest)

### Legend
- **wired:** UI/state → (ideally usecase) → data → kit symbol present; behavior plausibly implemented in code  
- **UI-only:** screens/strings exist; kit path missing or not hooked  
- **stub / name-only:** types/enums/comments without full path  
- **compile-only:** builds on box; no device proof  
- **gap-wall:** checklist 缺口/系统 — must show refusal UI (docs OK; code partially present)

### Structural signal (optimistic — class names from architecture found in code)

| Module | “wired” / gap-wall by class presence | Non-wired / partial |
| --- | --- | --- |
| Wi‑Fi | 126 wired + 6 gap-wall = 132/132 | 0 |
| Bluetooth | 79 wired + 10 gap-wall + 2 soft; **7 partial** | BT-062–068 (advertise/GATT server naming), BT-090 |
| NearLink | 114 wired + 6 gap-wall = 120/120 | 0 |

**Do not read the table above as acceptance %.** Class presence ≠ Given/When/Then proven. Device verification checklists in code **do not cite** WN/BT/NL IDs.

### Sampled high-risk items (8×3)

| ID | Structural | Notes |
| --- | --- | --- |
| WN-001/019/040/070/090/110/120 | likely wired | Scan use case + WifiInfoDataSource + bridge exist; VM still dual-path on cooldown/state |
| WN-010 | likely wired | Hotspot / 系统应用 copy in VM; enforce as wall |
| BT-001/009/019/040/055/070/080 | likely wired in yobluetooth | GATT **server** UI missing despite usecase |
| BT-090 | partial / thin | L2CAP mostly `SppSocketKind` / gateway mentions — not a full debug surface |
| NL-001/013/040/055/070/090/110 | likely wired | Scan API is `startScan` in `NearLinkScanDataSource` |
| NL-019 | likely wired | UI + datasource; confirm filter matrix vs NL-019–040 exhaustively later |

### Concrete incompleteness (architecture-relevant)

1. **GATT Server (BT-066–068 area):** DataSource + UseCases present; **zero feature UI references** → treat as **UI-only / unwired**.  
2. **BT Pages bypass VM:** Gatt client / advertise flows are page-local → not “unified”.  
3. **Wi‑Fi VM bypass UseCase:** many reads/writes via repository → not “unified”.  
4. **NL/Wi‑Fi session UseCases bypass repository:** parallel kit entry points.  
5. **Branch drift:** wifi tree cleaned repository kit import; bt/nl trees’ wifi_network still import `@kit.NetworkKit` in repository.  
6. **Acceptance traceability:** `*DeviceVerificationChecklist.ets` use internal ids (`nl-v-01`, …), not checklist IDs.  
7. **Runtime:** prior box `assembleHap` succeeded (unsigned). **No** Phone/NearLink device run in this audit → ceiling is **compile-only** for true completion claims.  
8. **Home feature:** `HomeFeaturePage.ets` only (1 file) — workbench thin vs shell docs.

### Honest completion bands (acceptance-oriented)

| Module | Code skeleton vs checklist owners | Clean unified-path architecture | Device-proven acceptance |
| --- | ---: | ---: | ---: |
| Wi‑Fi | ~55–70% behaviors sketched | **Fail** (dual path) | ~0% (no device) |
| Bluetooth | ~50–65% (SPP/BLE scan/GATT client stronger; GATT server UI weak) | **Fail** (page→usecase, domain→datasource, kit-in-domain) | ~0% |
| NearLink | ~50–65% | **Fail** (state→repo, usecase→datasource, kit-in-repo) | ~0% |

Earlier Goal “~13%” (checked items / device) is **compatible** with this: lots of code, little closed-loop acceptance.

---

## D. What is done well

- Clear feature folders + `common/*` shared platform/storage/youi_kit.  
- Kit usage largely confined to `data/datasource` + `data/kit` bridges for Wi‑Fi WLAN and BT classic/BLE scanners.  
- Architecture markdown per ID is unusually thorough and already calls out anti-patterns (e.g. WN-019: repository must not import NetworkKit — wifi tree matches).  
- EntryAbility clean.  
- Unsigned HAP compile green on this box for all three focus modules (prior run).

---

## E. Fix order (architecture debt first)

See `summary.md`. Short version: **unify one call path per capability** before adding more checklist behaviors.
