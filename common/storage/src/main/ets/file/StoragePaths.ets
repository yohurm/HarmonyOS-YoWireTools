import { common } from '@kit.AbilityKit';
import { TimeUtil } from 'common_core';

/**
 * Canonical file paths per architecture 05-§6.3.
 */
export class StoragePaths {
  static payloadRoot(context: common.Context): string {
    return `${context.filesDir}/debug_payload`;
  }

  static payloadSessionDir(context: common.Context, sessionId: string, dayStamp?: string): string {
    const day = dayStamp ?? StoragePaths.formatDay(TimeUtil.nowMs());
    return `${StoragePaths.payloadRoot(context)}/${day}/${sessionId}`;
  }

  static exportRoot(context: common.Context): string {
    return `${context.filesDir}/export`;
  }

  static exportSessionDir(context: common.Context, stamp?: string): string {
    const folder = stamp ?? StoragePaths.formatExportStamp(TimeUtil.nowMs());
    return `${StoragePaths.exportRoot(context)}/${folder}`;
  }

  static importTempRoot(context: common.Context): string {
    return `${context.filesDir}/import/tmp`;
  }

  static chunkFileName(index: number): string {
    const text = `${index}`;
    const padded = text.length >= 6 ? text : '0'.repeat(6 - text.length) + text;
    return `chunk-${padded}.bin`;
  }

  private static formatDay(timestampMs: number): string {
    const date = new Date(timestampMs);
    const y = date.getFullYear();
    const m = StoragePaths.pad2(date.getMonth() + 1);
    const d = StoragePaths.pad2(date.getDate());
    return `${y}${m}${d}`;
  }

  private static formatExportStamp(timestampMs: number): string {
    const date = new Date(timestampMs);
    const y = date.getFullYear();
    const m = StoragePaths.pad2(date.getMonth() + 1);
    const d = StoragePaths.pad2(date.getDate());
    const h = StoragePaths.pad2(date.getHours());
    const min = StoragePaths.pad2(date.getMinutes());
    const s = StoragePaths.pad2(date.getSeconds());
    return `${y}${m}${d}-${h}${min}${s}`;
  }

  private static pad2(value: number): string {
    const text = `${value}`;
    return text.length >= 2 ? text : `0${text}`;
  }
}
