/**
 * Generic permission UI presentation supplied by business layer.
 */
export class PermissionPresentation {
  readonly scenarioId: string;
  readonly title: ResourceStr;
  readonly message: ResourceStr;
  readonly userAction: ResourceStr;
  readonly blockedTitle: ResourceStr;
  readonly blockedMessage: ResourceStr;
  readonly blockedUserAction: ResourceStr;

  constructor(
    scenarioId: string,
    title: ResourceStr,
    message: ResourceStr,
    userAction: ResourceStr,
    blockedTitle: ResourceStr = $r('app.string.perm_blocked_title'),
    blockedMessage: ResourceStr = $r('app.string.perm_blocked_message'),
    blockedUserAction: ResourceStr = $r('app.string.perm_blocked_action_open_settings')
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
