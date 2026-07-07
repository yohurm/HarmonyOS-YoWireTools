import { DiagnosticStepResult, NetworkDiagnosticPlan } from '../domain/model/NetworkDiagnosticModels';
import { RunNetworkDiagnosticsUseCase } from '../domain/usecase/WifiNetworkUseCases';

@ObservedV2
export class NetworkDiagnosticsViewModel {
  @Trace targetHost: string = 'www.example.com';
  @Trace targetPort: number = 80;
  @Trace running: boolean = false;
  @Trace results: DiagnosticStepResult[] = [];
  @Trace statusMessage: string = '';

  private readonly runDiagnostics: RunNetworkDiagnosticsUseCase = new RunNetworkDiagnosticsUseCase();

  async runAction(): Promise<void> {
    this.running = true;
    this.statusMessage = 'Running diagnostics...';
    const plan = new NetworkDiagnosticPlan(this.targetHost, this.targetPort);
    const result = await this.runDiagnostics.execute(plan);
    if (result.success && result.value !== undefined) {
      this.results = result.value;
      this.statusMessage = 'Diagnostics complete';
    } else {
      this.statusMessage = result.error?.message ?? 'Diagnostics failed';
    }
    this.running = false;
  }
}
