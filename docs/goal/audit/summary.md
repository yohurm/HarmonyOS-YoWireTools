# Audit Summary — YoWireTools Docs & Implementation

**Date:** 2026-10-10 (Asia/Shanghai)  
**Deliverables:**
- `docs/goal/audit/doc-completeness.md`
- `docs/goal/audit/impl-architecture-audit.md`
- `docs/goal/audit/summary.md` (this file)

Independent local audit for cross-check against Project Goal PR audit.

---

## Top findings

### Docs — largely complete
1. **350/350** checklist IDs have matching architecture files (WN 132, BT 98, NL 120). **No missing arch IDs.**
2. UI design docs **mention every checklist ID** (screen-grouped). Research notes present for all three.
3. Residual doc issues are process/quality: Wi‑Fi & NearLink checklists still `draft`; BT `shell-navigation.md` has empty `checklist: []`; design/impl PRs still open; device verification ETS files don’t map WN/BT/NL IDs.

### Implementation — skeleton rich, architecture not unified
4. User bar **“数据链路统一 / 严禁多位置耦合” is currently failing** despite much code and green unsigned HAP builds.
5. Structural owner classes exist for most IDs, but **ViewModels/Pages bypass UseCases**, and **UseCases bypass Repository** into DataSources — classic dual-track (forbidden by YoAgentDocs engineering principle §2–3).
6. GATT Server path is a showcase gap: domain/datasource exist, **no Bluetooth UI wiring**.
7. Device acceptance remains **unproven** on this box → do not claim ≥90% feature completion.

---

## Worst 5 coupling violations

| # | Violation | Primary paths |
| ---: | --- | --- |
| 1 | Wi‑Fi VM dual track: ViewModel → Repository **and** UseCases | `features/wifi_network/.../ui/viewmodel/WifiDebugViewModel.ets` |
| 2 | Domain UseCases → DataSource/transport (bypass repository contract) — Wi‑Fi/BT/NL | e.g. `WifiNetworkSessionUseCases.ets`, `GattServerUseCases.ets`, `NearLinkSessionUseCases.ets` |
| 3 | BT Pages `new …UseCase()` (skip ViewModel / shared lifecycle) | `GattClientPage.ets`, `BlePeripheralPage.ets`, `DeviceIdentityPage.ets`, … |
| 4 | Domain imports ConnectivityKit types + DataSource | `common/yobluetooth/.../domain/usecase/ble/GattServerUseCases.ets` |
| 5 | NearLink Repository kit types + DebugModel→Repository; branch drift of Wi‑Fi repo kit import | `NearLinkRepository.ets`, `NearLinkDebugModel.ets`; bt/nl trees’ `WifiNetworkRepository.ets` still `@kit.NetworkKit` |

---

## Recommended fix order (architecture debt first)

1. **Freeze new checklist behaviors** until one path is restored per module:  
   `UI → ViewModel/State → UseCase → RepositoryContract → DataSource/KitBridge → Kit`.
2. **Wi‑Fi:** Refactor `WifiDebugViewModel` to call **only** UseCases; move cooldown/state/read helpers behind use cases or query ports on the contract — delete VM→Repo shortcuts. Keep kit only in datasource/bridge (already mostly true).
3. **Bluetooth:**  
   - Stop constructing UseCases in Pages; route through ViewModels.  
   - Rewrite `GattServerUseCases` / `BleAdvertiseUseCases` / `SppServerUseCases` to depend on **repository contracts**, not DataSources; move `ble.*` types to data mappers / domain DTOs.  
   - Wire **GATT Server UI** or explicitly mark BT-066–068 as not shipped.
4. **NearLink:** Same as Wi‑Fi — `NearLinkDebugModel` should not own Repository; session use cases must not import platform DataSources; keep `ssap` out of repository API surface.
5. **Unify branches:** Merge/rebase phase-D trees so wifi/bt/nl don’t carry divergent repository kit imports; land design PRs so `main` is one source of truth.
6. **Traceability:** Map `*DeviceVerificationChecklist` items to WN/BT/NL IDs; only then run device acceptance and tick checklist boxes.
7. **Then** resume full-scale behavior fill toward 90% — after dual tracks are gone (YoAgentDocs: 每一阶段无双轨).

---

## Cross-check notes for Goal agent

- Doc ID coverage claim should match: **no missing architecture files**.
- Any Goal claim of “high % implemented” must separate: (a) file/class presence, (b) unified-path compliance, (c) device Given/When/Then. This audit: (a) high, (b) fail, (c) ~0.
- Prior box compile success is **compile-only**, not acceptance.
