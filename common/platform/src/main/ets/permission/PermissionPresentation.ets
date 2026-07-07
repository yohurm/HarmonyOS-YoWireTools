/**
 * Generic permission UI presentation supplied by business layer.
 */
export class PermissionPresentation {
  readonly scenarioId: string;
  readonly title: string;
  readonly message: string;
  readonly userAction: string;
  readonly blockedTitle: string;
  readonly blockedMessage: string;
  readonly blockedUserAction: string;

  constructor(
    scenarioId: string,
    title: string,
    message: string,
    userAction: string,
    blockedTitle: string = 'Permission blocked',
    blockedMessage: string = 'Permission was denied. Open settings to enable required permissions.',
    blockedUserAction: string = 'Open settings'
  ) {
    this.scenarioId = scenarioId;
    this.title = title;
    this.message = message;
    this.userAction = userAction;
    this.blockedTitle = blockedTitle;
    this.blockedMessage = blockedMessage;
    this.blockedUserAction = blockedUserAction;
  }
}
