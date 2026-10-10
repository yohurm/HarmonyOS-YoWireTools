import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Observable, Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { NetworkStateSnapshot } from '../../domain/model/NetworkStateSnapshot';

type NetworkStateListener = (snapshot: NetworkStateSnapshot) => void;

/**
 * Wraps net.connection APIs for network state observation.
 */
export class NetworkConnectionDataSource {
  private static instance: NetworkConnectionDataSource | undefined;
  private netHandler: ((data: connection.NetConnectionPropertyInfo) => void) | undefined;
  private netListener: NetworkStateListener | undefined;
  private netConnection: connection.NetConnection | undefined;
  private readonly stateObservable: Observable<NetworkStateSnapshot>;

  private constructor() {
    this.stateObservable = new Observable<NetworkStateSnapshot>(
      new NetworkStateSnapshot(false, 'none', '')
    );
  }

  static getInstance(): NetworkConnectionDataSource {
    if (NetworkConnectionDataSource.instance === undefined) {
      NetworkConnectionDataSource.instance = new NetworkConnectionDataSource();
    }
    return NetworkConnectionDataSource.instance;
  }

  observeNetworkState(): Observable<NetworkStateSnapshot> {
    return this.stateObservable;
  }

  async getDefaultNet(): Promise<Result<NetworkStateSnapshot>> {
    try {
      const netHandle = await connection.getDefaultNet();
      const hasNet = netHandle.netId >= 0;
      const snapshot = new NetworkStateSnapshot(hasNet, `${netHandle.netId}`, '');
      this.stateObservable.next(snapshot);
      return Result.ok(snapshot);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.NO_INTERNET, err));
    }
  }

  startListening(listener: NetworkStateListener): void {
    this.stopListening();
    this.netListener = listener;
    void this.getDefaultNet().then((result) => {
      if (result.success && result.value !== undefined && this.netListener !== undefined) {
        this.netListener(result.value);
      }
    });
  }

  stopListening(): void {
    this.netConnection = undefined;
    this.netHandler = undefined;
    this.netListener = undefined;
  }
}
