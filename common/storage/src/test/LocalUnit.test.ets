import { describe, it, expect } from '@ohos/hypium';
import { DatabaseSchema } from '../main/ets/rdb/DatabaseSchema';
import { PreferenceKeys } from '../main/ets/constants/PreferenceKeys';
import { StorageConstants } from '../main/ets/constants/StorageConstants';
import { StoragePayloadKind, StoragePayloadRef } from '../main/ets/domain/StoragePayloadRef';
import { RecordMapper } from '../main/ets/rdb/RecordMapper';
import { LogIndexRecord } from '../main/ets/domain/LogIndexRecord';
import { LogExportFormatter } from '../main/ets/export/LogExportFormatter';
import { ExportFormat } from '../main/ets/export/ExportFormat';
import { LogIndexFilterUtil } from '../main/ets/query/LogIndexFilterUtil';
import { StoragePaths } from '../main/ets/file/StoragePaths';
import { LogCleanupPolicy } from '../main/ets/cleanup/LogCleanupPolicy';

export default function localUnitTest() {
  describe('CommonStorageLocalUnitTest', () => {
    it('DatabaseSchema_has_eight_tables', 0, () => {
      const statements = DatabaseSchema.migrationStatements();
      expect(statements.length).assertEqual(9);
      expect(DatabaseSchema.TABLE_PAYLOAD_CHUNK).assertEqual('debug_payload_chunk');
    });

    it('StoragePayloadRef_inline_roundtrip_json', 0, () => {
      const ref = new StoragePayloadRef(StoragePayloadKind.INLINE, 3, 'QUJD');
      const json = RecordMapper.payloadRefToJson(ref);
      const parsed = RecordMapper.payloadRefFromJson(json);
      expect(parsed !== undefined).assertTrue();
      expect(parsed?.storageType).assertEqual(StoragePayloadKind.INLINE);
      expect(parsed?.inlineBytesBase64).assertEqual('QUJD');
    });

    it('LogExportFormatter_csv_escapes_quotes', 0, () => {
      const record = new LogIndexRecord(
        'log_1',
        'sess_1',
        'module',
        'protocol',
        'inbound',
        'bytes',
        1000,
        4,
        'say "hello", world',
        'hex'
      );
      const payloadMap = new Map<string, string>();
      const csv = LogExportFormatter.formatRecords(ExportFormat.CSV, [record], payloadMap);
      expect(csv.indexOf('""hello""') >= 0).assertTrue();
    });

    it('StoragePaths_chunk_file_name', 0, () => {
      expect(StoragePaths.chunkFileName(1)).assertEqual('chunk-000001.bin');
    });

    it('Inline_payload_threshold', 0, () => {
      expect(StorageConstants.INLINE_PAYLOAD_THRESHOLD_BYTES).assertEqual(4096);
    });

    it('LogCleanupPolicy_defaults', 0, () => {
      const policy = new LogCleanupPolicy(30, 512);
      expect(policy.retentionDays).assertEqual(30);
    });

    it('LogIndexFilterUtil_applyClientFilters', 0, () => {
      const items: LogIndexRecord[] = [
        new LogIndexRecord('1', 's1', 'nearlink', 'ssap', 'in', 'payload', 0, 0, 'hello world', ''),
        new LogIndexRecord('2', 's2', 'wifi', 'tcp', 'out', 'payload', 0, 0, 'other', '')
      ];
      const filtered = LogIndexFilterUtil.applyClientFilters(items, 'nearlink', 'ssap', 'hello');
      expect(filtered.length).assertEqual(1);
      expect(filtered[0].id).assertEqual('1');
    });
  });
}
