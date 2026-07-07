import { describe, it, expect } from '@ohos/hypium';
import { Result } from '../main/ets/result/Result';
import { ResultError } from '../main/ets/result/ResultError';
import { Option } from '../main/ets/option/Option';
import { CancellationTokenSource } from '../main/ets/cancellation/CancellationTokenSource';
import { AsyncSerialQueue } from '../main/ets/queue/AsyncSerialQueue';
import { LimitedConcurrencyExecutor } from '../main/ets/queue/LimitedConcurrencyExecutor';
import { EncodingUtil } from '../main/ets/encoding/EncodingUtil';
import { ByteUtil } from '../main/ets/bytes/ByteUtil';
import { Observable } from '../main/ets/observable/Observable';
import { PageQuery } from '../main/ets/paging/PageQuery';
import { PageResult } from '../main/ets/paging/PageResult';
import { JsonUtil } from '../main/ets/json/JsonUtil';
import { IdGenerator } from '../main/ets/id/IdGenerator';
import { MonotonicClockRegistry } from '../main/ets/time/MonotonicClockRegistry';
import { IMonotonicClock } from '../main/ets/time/IMonotonicClock';
import { TaskExecutorRegistry } from '../main/ets/task/TaskExecutorRegistry';
import { TaskSubmitOptions } from '../main/ets/task/ITaskExecutor';
import { CancellationTokenSource } from '../main/ets/cancellation/CancellationTokenSource';

export default function localUnitTest() {
  describe('CommonCoreLocalUnitTest', () => {
    it('Result_ok_and_fail', 0, () => {
      const ok = Result.ok('value');
      expect(ok.success).assertTrue();
      expect(ok.getOrThrow()).assertEqual('value');

      const fail = Result.failMessage<string>('E1', 'failed');
      expect(fail.success).assertFalse();
      expect(fail.error?.code).assertEqual('E1');
    });

    it('Result_void_success', 0, () => {
      const ok = Result.ok<void>();
      expect(ok.success).assertTrue();
      ok.getOrThrow();
      const mapped = ok.map(() => 42);
      expect(mapped.success).assertTrue();
      expect(mapped.getOrThrow()).assertEqual(42);
    });

    it('Option_some_and_none', 0, () => {
      const some = Option.some(42);
      expect(some.hasValue).assertTrue();
      expect(some.getOrDefault(0)).assertEqual(42);

      const none = Option.none<number>();
      expect(none.hasValue).assertFalse();
      expect(none.getOrDefault(7)).assertEqual(7);
    });

    it('CancellationTokenSource_cancel', 0, () => {
      const source = new CancellationTokenSource();
      let cancelled = false;
      source.register(() => {
        cancelled = true;
      });
      source.cancel();
      expect(source.isCancelled).assertTrue();
      expect(cancelled).assertTrue();
      expect(source.token.isCancellationRequested).assertTrue();
    });

    it('AsyncSerialQueue_serializes_tasks', 0, async () => {
      const queue = new AsyncSerialQueue();
      const order: number[] = [];
      const p1 = queue.enqueue(async () => {
        order.push(1);
        return 1;
      });
      const p2 = queue.enqueue(async () => {
        order.push(2);
        return 2;
      });
      await p1;
      await p2;
      expect(order.length).assertEqual(2);
      expect(order[0]).assertEqual(1);
      expect(order[1]).assertEqual(2);
    });

    it('LimitedConcurrencyExecutor_limits_parallelism', 0, async () => {
      const executor = new LimitedConcurrencyExecutor(1);
      let running = 0;
      let maxRunning = 0;
      const task = async (): Promise<number> => {
        running++;
        maxRunning = Math.max(maxRunning, running);
        await new Promise<void>((resolve) => setTimeout(resolve, 10));
        running--;
        return 1;
      };
      await Promise.all([
        executor.execute(task),
        executor.execute(task)
      ]);
      expect(maxRunning).assertEqual(1);
    });

    it('EncodingUtil_roundtrip', 0, () => {
      const text = 'Hello 世界';
      const hex = EncodingUtil.textToHex(text);
      expect(hex.success).assertTrue();
      const fromHex = EncodingUtil.hexToText(hex.getOrThrow());
      expect(fromHex.getOrThrow()).assertEqual(text);

      const base64 = EncodingUtil.textToBase64(text);
      const fromBase64 = EncodingUtil.base64ToText(base64.getOrThrow());
      expect(fromBase64.getOrThrow()).assertEqual(text);

    });

    it('ByteUtil_concat_and_equals', 0, () => {
      const left = new Uint8Array([1, 2]);
      const right = new Uint8Array([3]);
      const merged = ByteUtil.concat([left, right]);
      expect(merged.length).assertEqual(3);
      expect(ByteUtil.equals(merged, new Uint8Array([1, 2, 3]))).assertTrue();
    });

    it('Observable_subscribe_and_next', 0, () => {
      const observable = new Observable<number>(0);
      let latest = -1;
      const sub = observable.subscribe((value: number) => {
        latest = value;
      });
      observable.next(5);
      expect(latest).assertEqual(5);
      sub.dispose();
      observable.next(9);
      expect(latest).assertEqual(5);
    });

    it('PageResult_hasMore', 0, () => {
      const query = new PageQuery(0, 2);
      const page = new PageResult<string>(['a', 'b'], 5, query);
      expect(page.hasMore).assertTrue();
      const lastPage = new PageResult<string>(['d', 'e'], 5, new PageQuery(3, 2));
      expect(lastPage.hasMore).assertFalse();
    });

    it('JsonUtil_parse_stringify', 0, () => {
      interface Sample {
        name: string;
      }
      const sample: Sample = { name: 'YoWire' };
      const text = JsonUtil.stringify(sample);
      expect(text.success).assertTrue();
      const parsed = JsonUtil.parse<Sample>(text.getOrThrow());
      expect(parsed.getOrThrow().name).assertEqual('YoWire');
    });

    it('IdGenerator_unique_prefix', 0, () => {
      IdGenerator.resetSequenceForTest();
      const id1 = IdGenerator.next('sess');
      const id2 = IdGenerator.next('sess');
      expect(id1.startsWith('sess_')).assertTrue();
      expect(id1 === id2).assertFalse();
    });

    it('MonotonicClockRegistry_injectable', 0, () => {
      class FixedClock implements IMonotonicClock {
        private value: number = 1000;
        nowMs(): number {
          this.value = this.value + 10;
          return this.value;
        }
      }
      MonotonicClockRegistry.register(new FixedClock());
      const first = MonotonicClockRegistry.nowMs();
      const second = MonotonicClockRegistry.nowMs();
      expect(second > first).assertTrue();
      MonotonicClockRegistry.resetForTest();
    });

    it('InlineTaskExecutor_runs_inline', 0, async () => {
      TaskExecutorRegistry.resetForTest();
      const result = await TaskExecutorRegistry.get().execute(async () => 42);
      expect(result).assertEqual(42);
    });

    it('InlineTaskExecutor_respects_cancel_token', 0, async () => {
      TaskExecutorRegistry.resetForTest();
      const source = new CancellationTokenSource();
      source.cancel();
      let failed = false;
      try {
        await TaskExecutorRegistry.get().execute(async () => 1, new TaskSubmitOptions(undefined, '', source.token));
      } catch (_error) {
        failed = true;
      }
      expect(failed).assertTrue();
    });
  });
}
