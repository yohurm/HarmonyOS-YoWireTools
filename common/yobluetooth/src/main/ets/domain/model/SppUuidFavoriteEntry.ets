/**
 * One favorited SPP service UUID (custom-UUID dialog).
 * Wire format (Preferences line): uuid|label|updatedAtMs
 */
export class SppUuidFavoriteEntry {
  readonly uuid: string;
  readonly label: string;
  readonly updatedAtMs: number;

  constructor(uuid: string, label: string, updatedAtMs: number) {
    this.uuid = uuid;
    this.label = label;
    this.updatedAtMs = updatedAtMs;
  }

  displayTitle(): string {
    if (this.label.trim().length > 0) {
      return this.label.trim();
    }
    return SppUuidFavoriteEntry.shortUuid(this.uuid);
  }

  toLine(): string {
    return `${this.uuid}|${this.label}|${this.updatedAtMs}`;
  }

  static fromLine(line: string): SppUuidFavoriteEntry | undefined {
    const parts = line.split('|');
    if (parts.length < 3) {
      return undefined;
    }
    const uuid = SppUuidFavoriteEntry.normalizeUuid(parts[0]);
    if (uuid.length === 0) {
      return undefined;
    }
    const updatedAtMs = parseInt(parts[2], 10);
    if (Number.isNaN(updatedAtMs)) {
      return undefined;
    }
    return new SppUuidFavoriteEntry(uuid, parts[1] ?? '', updatedAtMs);
  }

  static normalizeUuid(raw: string): string {
    return raw.trim().toLowerCase();
  }

  static shortUuid(uuid: string): string {
    const normalized = SppUuidFavoriteEntry.normalizeUuid(uuid);
    if (normalized.length <= 8) {
      return normalized;
    }
    return normalized.substring(0, 8);
  }

  static isPlausibleUuid(raw: string): boolean {
    const normalized = SppUuidFavoriteEntry.normalizeUuid(raw);
    if (normalized.length === 36) {
      return SppUuidFavoriteEntry.isHexGroup(normalized, 0, 8) &&
        normalized.charAt(8) === '-' &&
        SppUuidFavoriteEntry.isHexGroup(normalized, 9, 4) &&
        normalized.charAt(13) === '-' &&
        SppUuidFavoriteEntry.isHexGroup(normalized, 14, 4) &&
        normalized.charAt(18) === '-' &&
        SppUuidFavoriteEntry.isHexGroup(normalized, 19, 4) &&
        normalized.charAt(23) === '-' &&
        SppUuidFavoriteEntry.isHexGroup(normalized, 24, 12);
    }
    if (normalized.length === 32) {
      return SppUuidFavoriteEntry.isHexGroup(normalized, 0, 32);
    }
    return false;
  }

  private static isHexGroup(text: string, start: number, length: number): boolean {
    const end = start + length;
    if (end > text.length) {
      return false;
    }
    for (let i = start; i < end; i++) {
      const c = text.charCodeAt(i);
      const isDigit = c >= 0x30 && c <= 0x39;
      const isLower = c >= 0x61 && c <= 0x66;
      if (!isDigit && !isLower) {
        return false;
      }
    }
    return true;
  }
}
