/**
 * 空列表展示模型 — 业务文案由特性 ViewModel / View 资源提供。
 */
export class YoEmptyStateModel {
  readonly title: ResourceStr;
  readonly message: ResourceStr;
  readonly reasonHint: ResourceStr;
  readonly actionLabel: ResourceStr;
  readonly secondaryActionLabel: ResourceStr;

  constructor(
    title: ResourceStr = $r('app.string.youi_empty_default_title'),
    message: ResourceStr = $r('app.string.youi_empty_default_message'),
    reasonHint: ResourceStr = '',
    actionLabel: ResourceStr = '',
    secondaryActionLabel: ResourceStr = ''
  ) {
    this.title = title;
    this.message = message;
    this.reasonHint = reasonHint;
    this.actionLabel = actionLabel;
    this.secondaryActionLabel = secondaryActionLabel;
  }
}
