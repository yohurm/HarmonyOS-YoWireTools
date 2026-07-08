import { DebugLogRecord, SendCommandInput, SendCommandUseCase } from 'feature_debug_core';
import { Result } from 'common_core';

export class SendSppCommandUseCase {
  private readonly sendCommand: SendCommandUseCase;

  constructor(sendCommand: SendCommandUseCase = new SendCommandUseCase()) {
    this.sendCommand = sendCommand;
  }

  async execute(input: SendCommandInput): Promise<Result<DebugLogRecord>> {
    return this.sendCommand.execute(input);
  }
}
