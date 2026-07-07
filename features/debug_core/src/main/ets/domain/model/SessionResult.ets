/**
 * Session completion result.
 */
export class SessionResult {
  readonly success: boolean;
  readonly summary: string;
  readonly attributes: Record<string, string | number | boolean>;

  constructor(
    success: boolean,
    summary: string,
    attributes: Record<string, string | number | boolean> = {}
  ) {
    this.success = success;
    this.summary = summary;
    this.attributes = attributes;
  }
}
