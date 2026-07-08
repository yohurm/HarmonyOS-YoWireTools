/**
 * Empty list presentation model — business copy is supplied by feature ViewModel / View resources.
 */
export class EmptyStateModel {
  readonly title: ResourceStr;
  readonly message: ResourceStr;
  readonly reasonHint: ResourceStr;
  readonly actionLabel: ResourceStr;
  readonly secondaryActionLabel: ResourceStr;

  constructor(
    title: ResourceStr = $r('app.string.ui_empty_default_title'),
    message: ResourceStr = $r('app.string.ui_empty_default_message'),
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
