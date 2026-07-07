/**
 * DDL for 8 RDB tables per architecture §5.3 and 05-§6.1.
 */
export class DatabaseSchema {
  static readonly TABLE_SESSION: string = 'debug_session';
  static readonly TABLE_LOG_INDEX: string = 'debug_log_index';
  static readonly TABLE_PAYLOAD_CHUNK: string = 'debug_payload_chunk';
  static readonly TABLE_COMMAND_TEMPLATE: string = 'command_template';
  static readonly TABLE_COMMAND_HISTORY: string = 'command_history';
  static readonly TABLE_DEVICE_FAVORITE: string = 'device_favorite';
  static readonly TABLE_CAPABILITY_RESULT: string = 'capability_result';
  static readonly TABLE_APP_SETTING: string = 'app_setting';

  static migrationStatements(): string[] {
    return [
      `CREATE TABLE IF NOT EXISTS ${DatabaseSchema.TABLE_SESSION} (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        module TEXT NOT NULL,
        protocol TEXT NOT NULL,
        target_id TEXT,
        display_name TEXT NOT NULL,
        state TEXT NOT NULL,
        start_at_ms INTEGER NOT NULL,
        end_at_ms INTEGER,
        result TEXT,
        error TEXT,
        attributes TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS ${DatabaseSchema.TABLE_LOG_INDEX} (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        module TEXT NOT NULL,
        protocol TEXT NOT NULL,
        direction TEXT NOT NULL,
        record_type TEXT NOT NULL,
        timestamp_ms INTEGER NOT NULL,
        payload_ref TEXT,
        payload_size INTEGER NOT NULL,
        summary TEXT NOT NULL,
        display_hint TEXT NOT NULL,
        app_code TEXT,
        native_code TEXT,
        attributes TEXT
      )`,
      `CREATE INDEX IF NOT EXISTS idx_log_session_time ON ${DatabaseSchema.TABLE_LOG_INDEX}(session_id, timestamp_ms)`,
      `CREATE TABLE IF NOT EXISTS ${DatabaseSchema.TABLE_PAYLOAD_CHUNK} (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        chunk_path TEXT NOT NULL,
        chunk_index INTEGER NOT NULL,
        chunk_offset INTEGER NOT NULL,
        chunk_length INTEGER NOT NULL,
        sha256 TEXT,
        created_at_ms INTEGER NOT NULL
      )`,
      `CREATE TABLE IF NOT EXISTS ${DatabaseSchema.TABLE_COMMAND_TEMPLATE} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        module TEXT,
        protocol TEXT,
        payload_encoding TEXT NOT NULL,
        payload TEXT NOT NULL,
        line_ending TEXT NOT NULL,
        write_mode TEXT NOT NULL,
        repeat_policy TEXT,
        timeout_ms INTEGER NOT NULL,
        tags TEXT,
        created_at_ms INTEGER NOT NULL,
        updated_at_ms INTEGER NOT NULL
      )`,
      `CREATE TABLE IF NOT EXISTS ${DatabaseSchema.TABLE_COMMAND_HISTORY} (
        id TEXT PRIMARY KEY,
        template_id TEXT,
        session_id TEXT NOT NULL,
        module TEXT,
        protocol TEXT,
        payload TEXT NOT NULL,
        payload_encoding TEXT,
        sent_at_ms INTEGER NOT NULL,
        result TEXT,
        attributes TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS ${DatabaseSchema.TABLE_DEVICE_FAVORITE} (
        id TEXT PRIMARY KEY,
        module TEXT NOT NULL,
        protocol TEXT,
        display_name TEXT NOT NULL,
        alias TEXT,
        address TEXT,
        address_type TEXT,
        host TEXT,
        port INTEGER,
        uuid TEXT,
        attributes TEXT,
        updated_at_ms INTEGER NOT NULL
      )`,
      `CREATE TABLE IF NOT EXISTS ${DatabaseSchema.TABLE_CAPABILITY_RESULT} (
        capability_id TEXT PRIMARY KEY,
        module TEXT NOT NULL,
        status TEXT NOT NULL,
        reason TEXT,
        required_permission TEXT,
        api_level TEXT,
        native_code TEXT,
        verified_at_ms INTEGER NOT NULL
      )`,
      `CREATE TABLE IF NOT EXISTS ${DatabaseSchema.TABLE_APP_SETTING} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at_ms INTEGER NOT NULL
      )`
    ];
  }
}
