import { ssap } from '@kit.NearLinkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { KitEventSubscription } from 'common_platform';
import { NearLinkAdvParser } from '../../../domain/service/NearLinkAdvParser';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { NearLinkPayloadRules } from '../../../domain/service/NearLinkScanPolicy';
import { SsapServerWriteRecord } from '../../../domain/model/SsapServerWriteRecord';

type WriteListener = (record: SsapServerWriteRecord) => void;
type ReadListener = (requestId: number, address: string, propertyUuid: string) => void;

export class SsapServerDataSource {
  private server: ssap.Server | undefined;
  private readonly serviceUuids: string[] = [];
  private closed: boolean = true;
  private writeListener: WriteListener | undefined;
  private readListener: ReadListener | undefined;

  isOpen(): boolean {
    return this.server !== undefined && !this.closed;
  }

  listServices(): string[] {
    const copy: string[] = [];
    for (let i = 0; i < this.serviceUuids.length; i++) {
      copy.push(this.serviceUuids[i]);
    }
    return copy;
  }

  open(): Result<void> {
    try {
      this.server = ssap.createServer();
      this.closed = false;
      this.subscribe();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_CREATE_FAILED, err));
    }
  }

  addPlainService(serviceUuid: string, propertyUuid: string, operation: number): Result<void> {
    const descriptor: ssap.PropertyDescriptor = {
      serviceUuid: serviceUuid,
      propertyUuid: propertyUuid,
      value: new ArrayBuffer(0),
      descriptorType: ssap.PropertyDescriptorType.CLIENT_PROPERTY_CONFIG,
      isWriteable: true
    };
    const property: ssap.Property = {
      serviceUuid: serviceUuid,
      propertyUuid: propertyUuid,
      value: new ArrayBuffer(0),
      descriptors: [descriptor],
      operation: operation
    };
    const service: ssap.Service = {
      serviceUuid: serviceUuid,
      properties: [property]
    };
    return this.addService(service);
  }

  addService(service: ssap.Service): Result<void> {
    if (this.server === undefined || this.closed) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=addService'));
    }
    try {
      this.server.addService(service);
      this.serviceUuids.push(service.serviceUuid);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_DISCOVER_FAILED, err));
    }
  }

  respondRead(requestId: number, address: string, value: ArrayBuffer): Result<void> {
    return this.sendResponse(requestId, address, value);
  }

  respondWrite(requestId: number, address: string): Result<void> {
    return this.sendResponse(requestId, address, new ArrayBuffer(0));
  }

  notifyPlain(
    address: string,
    serviceUuid: string,
    propertyUuid: string,
    operation: number,
    value: ArrayBuffer
  ): Promise<Result<void>> {
    const property: ssap.Property = {
      serviceUuid: serviceUuid,
      propertyUuid: propertyUuid,
      value: value,
      descriptors: [],
      operation: operation
    };
    return this.notify(address, property, operation);
  }

  notify(address: string, property: ssap.Property, operation: number): Promise<Result<void>> {
    if ((operation & NearLinkConstants.OP_NOTIFY) === 0) {
      return Promise.resolve(Result.fail(new ResultError(
        NearLinkErrorCodes.NOTIFY_UNSUPPORTED,
        'api=notifyPropertyChanged'
      )));
    }
    if (this.server === undefined || this.closed) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=notifyPropertyChanged')));
    }
    const server = this.server;
    return server.notifyPropertyChanged(address, property).then(() => {
      return Result.ok(undefined);
    }).catch((error: BusinessError) => {
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_NOTIFY_FAILED, error));
    });
  }

  close(): Result<void> {
    if (this.server === undefined) {
      this.closed = true;
      return Result.ok(undefined);
    }
    try {
      this.server.close();
      this.closed = true;
      this.server = undefined;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, err));
    }
  }

  removeService(serviceUuid: string): Result<void> {
    if (this.server === undefined || this.closed) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=removeService'));
    }
    try {
      this.server.removeService(serviceUuid);
      const next: string[] = [];
      for (let i = 0; i < this.serviceUuids.length; i++) {
        if (this.serviceUuids[i] !== serviceUuid) {
          next.push(this.serviceUuids[i]);
        }
      }
      this.serviceUuids.length = 0;
      for (let i = 0; i < next.length; i++) {
        this.serviceUuids.push(next[i]);
      }
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_DISCOVER_FAILED, err));
    }
  }

  onWrite(listener: WriteListener): void {
    this.writeListener = listener;
  }

  onRead(listener: ReadListener): void {
    this.readListener = listener;
  }

  private sendResponse(requestId: number, address: string, value: ArrayBuffer): Result<void> {
    if (this.server === undefined || this.closed) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=sendResponse'));
    }
    try {
      this.server.sendResponse({ address: address, requestId: requestId, value: value });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SSAP_WRITE_FAILED, err));
    }
  }

  private subscribe(): void {
    if (this.server === undefined) {
      return;
    }
    const server = this.server;
    KitEventSubscription.subscribe(() => {
      server.on('propertyRead', (request: ssap.PropertyReadRequest) => {
        if (this.readListener !== undefined) {
          this.readListener(request.requestId, request.address, request.propertyUuid);
        }
      });
    }, 'ssap.server.propertyRead');
    KitEventSubscription.subscribe(() => {
      server.on('propertyWrite', (request: ssap.PropertyWriteRequest) => {
        const responded = request.writeType === ssap.PropertyWriteType.WRITE;
        const valueHex = NearLinkAdvParser.toHex(new Uint8Array(request.value));
        const writeType = responded ? 'WRITE' : 'WRITE_NO_RESPONSE';
        if (responded) {
          this.sendResponse(request.requestId, request.address, new ArrayBuffer(0));
        }
        if (this.writeListener !== undefined) {
          this.writeListener(new SsapServerWriteRecord(
            request.requestId,
            request.address,
            request.propertyUuid,
            valueHex,
            writeType,
            responded
          ));
        }
      });
    }, 'ssap.server.propertyWrite');
  }
}
