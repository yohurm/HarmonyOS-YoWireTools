/**
 * Navigation shell tier per V2 IA: controls bottom tab visibility and header semantics.
 */
export enum YoNavDestinationKind {
  /** Root tab destinations: workbench, module overview, more hub — show bottom tabs. */
  ROOT_TAB = 0,
  /** Module secondary list/config — hide bottom tabs, show back. */
  MODULE = 1,
  /** Device/session/object detail — hide bottom tabs. */
  OBJECT = 2,
  /** Terminal/workbench pages — hide bottom tabs, session chrome. */
  TERMINAL = 3,
  /** Sheet/dialog — no app shell chrome. */
  MODAL = 4
}
