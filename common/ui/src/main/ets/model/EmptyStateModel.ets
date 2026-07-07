/**
 * Empty list presentation model — business copy is supplied by feature ViewModel.
 */
export class EmptyStateModel {
  readonly title: string;
  readonly message: string;
  readonly reasonHint: string;
  readonly actionLabel: string;
  readonly secondaryActionLabel: string;

  constructor(
    title: string = '',
    message: string = '',
    reasonHint: string = '',
    actionLabel: string = '',
    secondaryActionLabel: string = ''
  ) {
    this.title = title;
    this.message = message;
    this.reasonHint = reasonHint;
    this.actionLabel = actionLabel;
    this.secondaryActionLabel = secondaryActionLabel;
  }
}
