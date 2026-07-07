/**
 * Holds the active UIContext bound when the main window is ready.
 * Static dialogs (e.g. RiskConfirmDialog) must use this instead of deprecated AlertDialog.show.
 */
export class UIContextRegistry {
  private static instance: UIContextRegistry | undefined;
  private uiContext: UIContext | undefined;

  static getInstance(): UIContextRegistry {
    if (UIContextRegistry.instance === undefined) {
      UIContextRegistry.instance = new UIContextRegistry();
    }
    return UIContextRegistry.instance;
  }

  bind(uiContext: UIContext): void {
    this.uiContext = uiContext;
  }

  get(): UIContext | undefined {
    return this.uiContext;
  }

  static resetForTest(): void {
    UIContextRegistry.instance = undefined;
  }
}
