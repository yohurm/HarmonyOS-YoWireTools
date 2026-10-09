import { ssap } from '@kit.NearLinkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';
import { NearLinkAdvParser } from '../../../domain/service/NearLinkAdvParser';
import { NearLinkPayloadRules } from '../../../domain/service/NearLinkScanPolicy';
import { KitEventSubscription } from 'common_platform';

type ConnectionStateListener = (state: ssap.ConnectionChangeState) => void;
type PropertyChangeListener = (property: ssap.Property) => void;
type MtuChangeListener = (mtu: number) => void;

export class SsapClientDataSource {
  private client: ssap.Client | undefined;
  private connectionHandler: ConnectionStateListener | undefined;
  private propertyHandler: PropertyChangeListener | undefined;
  private mtuHandler: MtuChangeListener | undefined;
  private negotiatedMtu: number = NearLinkConstants.DEFAULT_MTU;

  createClient(address: string): Result<void> {
    try {
      this.release();
      this.client = ssap.createClient(address);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_CREATE_FAILED, err));
    }
  }

  getClient(): ssap.Client | undefined {
    return this.client;
  }

  getMtu(): number {
    return this.negotiatedMtu;
  }

  onConnectionStateChange(listener: ConnectionStateListener): Result<void> {
    this.offConnectionStateChange();
    if (this.client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, 'SSAP client not created'));
    }
    const handler = listener;
    this.connectionHandler = handler;
    const client = this.client;
    return KitEventSubscription.subscribe(() => {
      client.on('connectionStateChange', handler);
    }, 'ssap.connectionStateChange');
  }

  offConnectionStateChange(): void {
    if (this.client !== undefined && this.connectionHandler !== undefined) {
      const client = this.client;
      const handler = this.connectionHandler;
      KitEventSubscription.unsubscribe(() => {
        client.off('connectionStateChange', handler);
      }, 'ssap.connectionStateChange');
    }
    this.connectionHandler = undefined;
  }

  async connect(): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, 'SSAP client not created'));
      }
      await this.client.connect();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, err));
    }
  }

  async disconnect(): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.ok(undefined);
      }
      await this.client.disconnect();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, err));
    }
  }

  close(): Result<void> {
    try {
      if (this.client === undefined) {
        return Result.ok(undefined);
      }
      this.client.close();
      this.client = undefined;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, err));
    }
  }

  async getServices(): Promise<Result<ssap.Service[]>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_DISCOVER_FAILED, 'SSAP client not created'));
      }
      const services = await this.client.getServices();
      return Result.ok(services);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_DISCOVER_FAILED, err));
    }
  }

  buildProperty(serviceUuid: string, propertyUuid: string, value: ArrayBuffer = new ArrayBuffer(0)): ssap.Property {
    return {
      serviceUuid: serviceUuid,
      propertyUuid: propertyUuid,
      value: value
    };
  }

  async readProperty(serviceUuid: string, propertyUuid: string): Promise<Result<string>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_READ_FAILED, 'SSAP client not created'));
      }
      const request = this.buildProperty(serviceUuid, propertyUuid);
      const response = await this.client.readProperty(request);
      return Result.ok(NearLinkAdvParser.toHex(new Uint8Array(response.value)));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_READ_FAILED, err));
    }
  }

  async writeByOperation(
    serviceUuid: string,
    propertyUuid: string,
    data: ArrayBuffer,
    operation: number,
    withResponse: boolean
  ): Promise<Result<void>> {
    if (!NearLinkPayloadRules.writeAllowed(operation, withResponse)) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.WRITE_TYPE_UNSUPPORTED,
        'api=writeProperty'
      ));
    }
    const writeType = withResponse ?
      ssap.PropertyWriteType.WRITE :
      ssap.PropertyWriteType.WRITE_NO_RESPONSE;
    return this.writeProperty(serviceUuid, propertyUuid, data, writeType);
  }

  async writeProperty(
    serviceUuid: string,
    propertyUuid: string,
    data: ArrayBuffer,
    writeType: ssap.PropertyWriteType = ssap.PropertyWriteType.WRITE
  ): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_WRITE_FAILED, 'api=writeProperty'));
      }
      const request = this.buildProperty(serviceUuid, propertyUuid, data);
      await this.client.writeProperty(request, writeType);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_WRITE_FAILED, err));
    }
  }

  async notifyByOperation(
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean,
    operation: number,
    hasClientConfig: boolean
  ): Promise<Result<void>> {
    if (enable && !NearLinkPayloadRules.canNotify(operation, hasClientConfig)) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.NOTIFY_UNSUPPORTED,
        'api=setPropertyNotification'
      ));
    }
    return this.setPropertyNotification(serviceUuid, propertyUuid, enable);
  }

  async setPropertyNotification(serviceUuid: string, propertyUuid: string, enable: boolean): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_NOTIFY_FAILED, 'SSAP client not created'));
      }
      const request = this.buildProperty(serviceUuid, propertyUuid);
      await this.client.setPropertyNotification(request, enable);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_NOTIFY_FAILED, err));
    }
  }

  async requestMtuSize(mtu: number): Promise<Result<number>> {
    if (mtu < NearLinkConstants.MIN_MTU || mtu > NearLinkConstants.MAX_MTU) {
      return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_MTU_RANGE, 'MTU out of range'));
    }
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_MTU_FAILED, 'SSAP client not created'));
      }
      await this.client.requestMtuSize(mtu);
      return Result.ok(this.negotiatedMtu);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_MTU_FAILED, err));
    }
  }

  onPropertyChange(listener: PropertyChangeListener): Result<void> {
    this.offPropertyChange();
    if (this.client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_NOTIFY_FAILED, 'SSAP client not created'));
    }
    const handler = listener;
    this.propertyHandler = handler;
    const client = this.client;
    return KitEventSubscription.subscribe(() => {
      client.on('propertyChange', handler);
    }, 'ssap.propertyChange');
  }

  offPropertyChange(): void {
    if (this.client !== undefined && this.propertyHandler !== undefined) {
      const client = this.client;
      const handler = this.propertyHandler;
      KitEventSubscription.unsubscribe(() => {
        client.off('propertyChange', handler);
      }, 'ssap.propertyChange');
    }
    this.propertyHandler = undefined;
  }

  onMtuChange(listener: MtuChangeListener): Result<void> {
    this.offMtuChange();
    if (this.client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_MTU_FAILED, 'SSAP client not created'));
    }
    this.mtuHandler = (mtu: number) => {
      this.negotiatedMtu = mtu;
      listener(mtu);
    };
    const handler = this.mtuHandler;
    const client = this.client;
    return KitEventSubscription.subscribe(() => {
      client.on('mtuChange', handler);
    }, 'ssap.mtuChange');
  }

  offMtuChange(): void {
    if (this.client !== undefined && this.mtuHandler !== undefined) {
      const client = this.client;
      const handler = this.mtuHandler;
      KitEventSubscription.unsubscribe(() => {
        client.off('mtuChange', handler);
      }, 'ssap.mtuChange');
    }
    this.mtuHandler = undefined;
  }

  release(): void {
    this.offPropertyChange();
    this.offConnectionStateChange();
    this.offMtuChange();
    void this.disconnect();
    this.close();
    this.negotiatedMtu = NearLinkConstants.DEFAULT_MTU;
  }
}
