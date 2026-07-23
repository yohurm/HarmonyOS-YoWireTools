import { Result, ResultError, Subscription } from 'common_core';
import { RepeatPolicy } from '../domain/model/CommandTemplate';
import { SendCommandInput, SendCommandUseCase } from '../usecase/CommandUseCases';
import { ITransportSession } from '../transport/TransportContracts';

interface RepeatJob {
  readonly sessionId: string;
  timerId: number;
  readonly startedAtMs: number;
  sentCount: number;
}

/**
 * Manages periodic command sending lifecycle per architecture §6.3.
 */
export class RepeatCommandCoordinator {
  private static instance: RepeatCommandCoordinator | undefined;
  private readonly jobs: Map<string, RepeatJob> = new Map();
  private readonly sendCommand: SendCommandUseCase;
  private readonly runningListeners: (() => void)[] = [];

  private constructor(sendCommand: SendCommandUseCase = new SendCommandUseCase()) {
    this.sendCommand = sendCommand;
  }

  static getInstance(): RepeatCommandCoordinator {
    if (RepeatCommandCoordinator.instance === undefined) {
      RepeatCommandCoordinator.instance = new RepeatCommandCoordinator();
    }
    return RepeatCommandCoordinator.instance;
  }

  async start(
    jobId: string,
    input: SendCommandInput,
    policy: RepeatPolicy
  ): Promise<Result<void>> {
    this.stop(jobId);
    if (policy.intervalMs <= 0) {
      return Result.fail(new ResultError('YW-CMD-2001', 'Repeat interval must be positive'));
    }
    const first = await this.sendCommand.execute(input);
    if (!first.success && policy.stopOnError) {
      return Result.fail(first.error ?? new ResultError('YW-CMD-2002', 'Initial repeat send failed'));
    }
    const startedAtMs = Date.now();
    const job: RepeatJob = {
      sessionId: input.sessionId,
      timerId: -1,
      startedAtMs: startedAtMs,
      sentCount: 1
    };
    job.timerId = setInterval(() => {
      void this.tick(jobId, input, policy);
    }, policy.intervalMs);
    this.jobs.set(jobId, job);
    this.notifyRunningChange();
    return Result.ok(undefined);
  }

  stop(jobId: string): void {
    const job = this.jobs.get(jobId);
    if (job === undefined) {
      return;
    }
    if (job.timerId >= 0) {
      clearInterval(job.timerId);
    }
    this.jobs.delete(jobId);
    this.notifyRunningChange();
  }

  stopAllForSession(sessionId: string): void {
    const toStop: string[] = [];
    this.jobs.forEach((job: RepeatJob, jobId: string) => {
      if (job.sessionId === sessionId) {
        toStop.push(jobId);
      }
    });
    for (let i = 0; i < toStop.length; i++) {
      this.stop(toStop[i]);
    }
  }

  isRunning(jobId: string): boolean {
    return this.jobs.has(jobId);
  }

  hasAnyRunning(): boolean {
    return this.jobs.size > 0;
  }

  runningCount(): number {
    return this.jobs.size;
  }

  subscribeRunningChange(listener: () => void): Subscription {
    this.runningListeners.push(listener);
    return new Subscription((): void => {
      const index = this.runningListeners.indexOf(listener);
      if (index >= 0) {
        this.runningListeners.splice(index, 1);
      }
    });
  }

  stopAll(): void {
    const ids: string[] = [];
    this.jobs.forEach((_job: RepeatJob, jobId: string) => {
      ids.push(jobId);
    });
    for (let i = 0; i < ids.length; i++) {
      this.stop(ids[i]);
    }
  }

  private async tick(jobId: string, input: SendCommandInput, policy: RepeatPolicy): Promise<void> {
    const job = this.jobs.get(jobId);
    if (job === undefined) {
      return;
    }
    if (policy.maxCount > 0 && job.sentCount >= policy.maxCount) {
      this.stop(jobId);
      return;
    }
    if (policy.maxDurationMs > 0 && Date.now() - job.startedAtMs >= policy.maxDurationMs) {
      this.stop(jobId);
      return;
    }
    const sent = await this.sendCommand.execute(input);
    job.sentCount = job.sentCount + 1;
    if (!sent.success && policy.stopOnError) {
      this.stop(jobId);
    }
    this.notifyRunningChange();
  }

  private notifyRunningChange(): void {
    for (let i = 0; i < this.runningListeners.length; i++) {
      this.runningListeners[i]();
    }
  }
}

export class StartRepeatCommandUseCase {
  private readonly coordinator: RepeatCommandCoordinator;

  constructor(coordinator: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance()) {
    this.coordinator = coordinator;
  }

  async execute(jobId: string, input: SendCommandInput, policy: RepeatPolicy): Promise<Result<void>> {
    return this.coordinator.start(jobId, input, policy);
  }
}

export class StopRepeatCommandUseCase {
  private readonly coordinator: RepeatCommandCoordinator;

  constructor(coordinator: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance()) {
    this.coordinator = coordinator;
  }

  execute(jobId: string): Result<void> {
    this.coordinator.stop(jobId);
    return Result.ok(undefined);
  }

  stopForSession(sessionId: string): Result<void> {
    this.coordinator.stopAllForSession(sessionId);
    return Result.ok(undefined);
  }
}
