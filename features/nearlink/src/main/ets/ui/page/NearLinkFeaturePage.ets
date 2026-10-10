import { NearLinkRepository } from '../../data/repository/NearLinkRepository';
import { NearLinkDestination } from '../../domain/model/NearLinkScreenCategory';
import { NearLinkDebugModel } from '../state/NearLinkDebugModel';
import { NearLinkCdsmView } from '../view/NearLinkCdsmView';
import { NearLinkDetailView } from '../view/NearLinkDetailView';
import { NearLinkLogView } from '../view/NearLinkLogView';
import { NearLinkRootView } from '../view/NearLinkRootView';
import { NearLinkScanView } from '../view/NearLinkScanView';
import {
  NearLinkAdvertisingView,
  NearLinkPairingView,
  NearLinkPortView,
  NearLinkSsapClientView,
  NearLinkSsapServerView
} from '../view/NearLinkSessionViews';

@ComponentV2
export struct NearLinkFeaturePage {
  @Local vm: NearLinkDebugModel = new NearLinkDebugModel(NearLinkRepository.getInstance());

  aboutToAppear(): void {
    void this.vm.onAppear();
  }

  aboutToDisappear(): void {
    void this.vm.onDisappear();
  }

  build() {
    if (this.vm.destination === NearLinkDestination.SCAN) {
      NearLinkScanView({ vm: this.vm })
    } else if (this.vm.destination === NearLinkDestination.DETAIL) {
      NearLinkDetailView({ vm: this.vm })
    } else if (this.vm.destination === NearLinkDestination.ADVERTISING) {
      NearLinkAdvertisingView({ vm: this.vm })
    } else if (this.vm.destination === NearLinkDestination.SSAP_CLIENT) {
      NearLinkSsapClientView({ vm: this.vm })
    } else if (this.vm.destination === NearLinkDestination.SSAP_SERVER) {
      NearLinkSsapServerView({ vm: this.vm })
    } else if (this.vm.destination === NearLinkDestination.PORT) {
      NearLinkPortView({ vm: this.vm })
    } else if (this.vm.destination === NearLinkDestination.PAIRING) {
      NearLinkPairingView({ vm: this.vm })
    } else if (this.vm.destination === NearLinkDestination.LOG) {
      NearLinkLogView({ vm: this.vm })
    } else if (this.vm.destination === NearLinkDestination.CDSM) {
      NearLinkCdsmView({ vm: this.vm })
    } else {
      NearLinkRootView({ vm: this.vm })
    }
  }
}
