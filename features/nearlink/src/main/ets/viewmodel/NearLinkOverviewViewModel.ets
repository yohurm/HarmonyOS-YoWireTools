import { AbilityContextRegistry, NearLinkSettingsNavigator } from 'common_platform';
import { NearLinkConstants } from '../constants/NearLinkConstants';
import {
  ReadCdsmBoundaryUseCase,
  ReadNearLinkUnpairBoundaryUseCase
} from '../domain/usecase/NearLinkUseCases';

@ObservedV2
export class NearLinkOverviewViewModel {
  @Trace unpairRefusalVisible: boolean = false;
  @Trace cdsmUnsupportedVisible: boolean = false;

  private readonly readUnpairBoundary: ReadNearLinkUnpairBoundaryUseCase;
  private readonly readCdsmBoundary: ReadCdsmBoundaryUseCase;

  constructor(
    readUnpairBoundary: ReadNearLinkUnpairBoundaryUseCase = new ReadNearLinkUnpairBoundaryUseCase(),
    readCdsmBoundary: ReadCdsmBoundaryUseCase = new ReadCdsmBoundaryUseCase()
  ) {
    this.readUnpairBoundary = readUnpairBoundary;
    this.readCdsmBoundary = readCdsmBoundary;
  }

  load(): void {
    const unpair = this.readUnpairBoundary.execute();
    this.unpairRefusalVisible = unpair.kind === NearLinkConstants.GAP_UNPAIR && unpair.openSettings;
    const cdsm = this.readCdsmBoundary.execute();
    this.cdsmUnsupportedVisible = cdsm.kind === NearLinkConstants.GAP_CDSM_UNSUPPORTED &&
      cdsm.nativeCode === NearLinkConstants.CDSM_UNSUPPORTED_CODE;
  }

  async openSystemSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      await NearLinkSettingsNavigator.openNearLinkSettings(context);
    }
  }
}
