import { PlatformEventType } from './PlatformEventType';
import { TimeUtil } from 'common_core';

/**
 * Normalized platform event payload.
 */
export class PlatformEvent {
  readonly type: PlatformEventType;
  readonly timestampMs: number;
  readonly detail: string;

  constructor(type: PlatformEventType, detail: string = '', timestampMs: number = TimeUtil.nowMs()) {
    this.type = type;
    this.detail = detail;
    this.timestampMs = timestampMs;
  }
}
