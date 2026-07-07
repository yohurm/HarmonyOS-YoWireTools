import { describe, it, expect } from '@ohos/hypium';
import { ExportFormat, LogIndexRecord } from 'common_storage';
import { LogDirectionFilter } from '../main/ets/domain/model/LogDirectionFilter';
import { LogCenterFilterUtil } from '../main/ets/domain/service/LogCenterFilterUtil';

function sampleLog(id: string, sessionId: string, module: string, protocol: string, summary: string): LogIndexRecord {
  return new LogIndexRecord(id, sessionId, module, protocol, 'in', 'payload', Date.now(), 0, summary, '');
}

export default function localUnitTest() {
  describe('LogCenterLocalUnitTest', () => {
    it('queryDirection_maps_inbound_outbound', 0, () => {
      expect(LogCenterFilterUtil.queryDirection(LogDirectionFilter.INBOUND)).assertEqual('INBOUND');
      expect(LogCenterFilterUtil.queryDirection(LogDirectionFilter.OUTBOUND)).assertEqual('OUTBOUND');
      expect(LogCenterFilterUtil.queryDirection(LogDirectionFilter.ALL)).assertEqual('');
    });

    it('applyClientFilters_module_protocol_keyword', 0, () => {
      const items: LogIndexRecord[] = [
        sampleLog('1', 's1', 'nearlink', 'ssap', 'hello world'),
        sampleLog('2', 's2', 'wifi', 'tcp', 'other'),
        sampleLog('3', 's3', 'nearlink', 'ssap', 'HELLO again')
      ];
      const filtered = LogCenterFilterUtil.applyClientFilters(items, 'nearlink', 'ssap', 'hello');
      expect(filtered.length).assertEqual(2);
      expect(filtered[0].id).assertEqual('1');
      expect(filtered[1].id).assertEqual('3');
    });

    it('collectSessionIds_merges_existing_and_logs', 0, () => {
      const existing: string[] = ['sess-a'];
      const logs: LogIndexRecord[] = [
        sampleLog('log-1', 'sess-b', 'nearlink', 'ssap', 'hello'),
        sampleLog('log-2', 'sess-a', 'nearlink', 'ssap', 'dup'),
        sampleLog('log-3', 'sess-c', 'wifi', 'tcp', 'warn')
      ];
      const ids = LogCenterFilterUtil.collectSessionIds(logs, existing);
      expect(ids.length).assertEqual(3);
      expect(ids[0]).assertEqual('sess-a');
      expect(ids[1]).assertEqual('sess-b');
      expect(ids[2]).assertEqual('sess-c');
    });

    it('buildStatusMessage_shows_client_filter_hint', 0, () => {
      const message = LogCenterFilterUtil.buildStatusMessage(2, 10, 'hello', '', '');
      expect(message).assertEqual('显示 2 条 · 共 10 条日志');
    });

    it('buildExportOptions_maps_current_filters', 0, () => {
      const options = LogCenterFilterUtil.buildExportOptions(
        ExportFormat.CSV,
        'sess-1',
        LogDirectionFilter.INBOUND,
        'nearlink',
        'ssap',
        ' hello '
      );
      expect(options.format).assertEqual(ExportFormat.CSV);
      expect(options.sessionId).assertEqual('sess-1');
      expect(options.direction).assertEqual('INBOUND');
      expect(options.module).assertEqual('nearlink');
      expect(options.protocol).assertEqual('ssap');
      expect(options.keyword).assertEqual(' hello ');
      expect(options.includePayloadBytes).assertFalse();
    });
  });
}
