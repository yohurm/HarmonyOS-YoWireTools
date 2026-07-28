import { Result, ResultError } from 'common_core';
import {
  CreateSessionInput,
  CreateSessionUseCase,
  DebugSession,
  StartSessionUseCase
} from 'debug_core';

/**
 * Creates and starts a debug session for bluetooth operations.
 */
export class BluetoothSessionBootstrap {
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;

  constructor(
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.createSession = createSession;
    this.startSession = startSession;
  }

  async createAndStart(input: CreateSessionInput): Promise<Result<DebugSession>> {
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const started = await this.startSession.execute(created.value.id);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    return Result.ok(created.value);
  }
}
