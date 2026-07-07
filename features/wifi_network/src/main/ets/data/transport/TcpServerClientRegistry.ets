import { socket } from '@kit.NetworkKit';

import { IdGenerator, Result, ResultError } from 'common_core';

import { TcpServerClientRecord } from '../../domain/model/SocketModels';



/**

 * Tracks accepted TCP server clients per architecture 03-§6.2.

 */

export class TcpServerClientRegistry {

  private readonly clients: Map<string, socket.TCPSocketConnection> = new Map();

  private readonly records: TcpServerClientRecord[] = [];



  add(connection: socket.TCPSocketConnection): TcpServerClientRecord {

    const id = IdGenerator.next('tcpc');

    this.clients.set(id, connection);

    const record = new TcpServerClientRecord(id, `client-${this.records.length + 1}`, 0);

    this.records.push(record);

    return record;

  }



  getConnection(clientId: string): socket.TCPSocketConnection | undefined {

    return this.clients.get(clientId);

  }



  listRecords(): TcpServerClientRecord[] {

    return this.records.slice();

  }



  updateLastMessage(clientId: string, message: string): void {

    for (let i = 0; i < this.records.length; i++) {

      if (this.records[i].id === clientId) {

        this.records[i] = new TcpServerClientRecord(

          this.records[i].id,

          this.records[i].remoteAddress,

          this.records[i].remotePort,

          this.records[i].connectedAtMs,

          message

        );

        break;

      }

    }

  }



  async sendText(clientId: string, text: string): Promise<Result<void>> {

    const client = this.clients.get(clientId);

    if (client === undefined) {

      return Result.fail(new ResultError('YW-WIFI-2001', 'Client not found'));

    }

    try {

      await client.send({ data: text });

      return Result.ok(undefined);

    } catch (error) {

      const err = error as Error;

      return Result.fail(new ResultError('YW-WIFI-2002', err.message));

    }

  }



  async disconnect(clientId: string): Promise<void> {

    const client = this.clients.get(clientId);

    if (client !== undefined) {

      try {

        await client.close();

      } catch (_error) {

      }

      this.clients.delete(clientId);

    }

    const next: TcpServerClientRecord[] = [];

    for (let i = 0; i < this.records.length; i++) {

      if (this.records[i].id !== clientId) {

        next.push(this.records[i]);

      }

    }

    this.records.length = 0;

    for (let i = 0; i < next.length; i++) {

      this.records.push(next[i]);

    }

  }



  async closeAll(): Promise<void> {

    const ids: string[] = [];

    this.clients.forEach((_value: socket.TCPSocketConnection, key: string) => {

      ids.push(key);

    });

    for (let i = 0; i < ids.length; i++) {

      await this.disconnect(ids[i]);

    }

    this.clients.clear();

    this.records.length = 0;

  }

}

