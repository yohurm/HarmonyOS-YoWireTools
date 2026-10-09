import { wifiManager } from '@kit.ConnectivityKit';
import { http, mdns, socket, webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result } from 'common_core';
import { KitEventSubscription } from 'common_platform';

/**
 * Network Kit event bridge per WSL wifiManager / mdns / socket / webSocket docs.
 * All kit on()/off() calls live here so DataSources stay throw-safe.
 */
export class NetworkKitEventBridge {
  static subscribeWifiStateChange(handler: (state: number) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      wifiManager.on('wifiStateChange', handler);
    }, 'wifiManager.wifiStateChange');
  }

  static unsubscribeWifiStateChange(handler: (state: number) => void): void {
    KitEventSubscription.unsubscribe(() => {
      wifiManager.off('wifiStateChange', handler);
    }, 'wifiManager.wifiStateChange');
  }

  static subscribeWifiConnectionChange(handler: () => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      wifiManager.on('wifiConnectionChange', handler);
    }, 'wifiManager.wifiConnectionChange');
  }

  static unsubscribeWifiConnectionChange(handler: () => void): void {
    KitEventSubscription.unsubscribe(() => {
      wifiManager.off('wifiConnectionChange', handler);
    }, 'wifiManager.wifiConnectionChange');
  }

  static subscribeWifiScanStateChange(handler: (state: number) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      wifiManager.on('wifiScanStateChange', handler);
    }, 'wifiManager.wifiScanStateChange');
  }

  static unsubscribeWifiScanStateChange(handler: (state: number) => void): void {
    KitEventSubscription.unsubscribe(() => {
      wifiManager.off('wifiScanStateChange', handler);
    }, 'wifiManager.wifiScanStateChange');
  }

  static subscribeWifiRssiChange(handler: (rssi: number) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      wifiManager.on('wifiRssiChange', handler);
    }, 'wifiManager.wifiRssiChange');
  }

  static unsubscribeWifiRssiChange(handler: (rssi: number) => void): void {
    KitEventSubscription.unsubscribe(() => {
      wifiManager.off('wifiRssiChange', handler);
    }, 'wifiManager.wifiRssiChange');
  }

  static subscribeWifiConnectionState(handler: (state: number) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      wifiManager.on('wifiConnectionChange', handler);
    }, 'wifiManager.wifiConnectionState');
  }

  static unsubscribeWifiConnectionState(handler: (state: number) => void): void {
    KitEventSubscription.unsubscribe(() => {
      wifiManager.off('wifiConnectionChange', handler);
    }, 'wifiManager.wifiConnectionState');
  }

  static subscribeMdnsServiceFound(
    service: mdns.DiscoveryService,
    handler: (info: mdns.LocalServiceInfo) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      service.on('serviceFound', handler);
    }, 'mdns.serviceFound');
  }

  static unsubscribeMdnsServiceFound(
    service: mdns.DiscoveryService,
    handler: (info: mdns.LocalServiceInfo) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      service.off('serviceFound', handler);
    }, 'mdns.serviceFound');
  }

  static subscribeMdnsServiceLost(
    service: mdns.DiscoveryService,
    handler: (info: mdns.LocalServiceInfo) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      service.on('serviceLost', handler);
    }, 'mdns.serviceLost');
  }

  static unsubscribeMdnsServiceLost(
    service: mdns.DiscoveryService,
    handler: (info: mdns.LocalServiceInfo) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      service.off('serviceLost', handler);
    }, 'mdns.serviceLost');
  }

  static subscribeUdpMessage(
    udp: socket.UDPSocket,
    handler: (value: socket.SocketMessageInfo) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      udp.on('message', handler);
    }, 'udp.message');
  }

  static unsubscribeUdpMessage(
    udp: socket.UDPSocket,
    handler: (value: socket.SocketMessageInfo) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      udp.off('message', handler);
    }, 'udp.message');
  }

  static subscribeTcpMessage(
    tcp: socket.TCPSocket,
    handler: (value: socket.SocketMessageInfo) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      tcp.on('message', handler);
    }, 'tcp.message');
  }

  static unsubscribeTcpMessage(
    tcp: socket.TCPSocket,
    handler: (value: socket.SocketMessageInfo) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      tcp.off('message', handler);
    }, 'tcp.message');
  }

  static subscribeTcpClose(tcp: socket.TCPSocket, handler: () => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      tcp.on('close', handler);
    }, 'tcp.close');
  }

  static unsubscribeTcpClose(tcp: socket.TCPSocket, handler: () => void): void {
    KitEventSubscription.unsubscribe(() => {
      tcp.off('close', handler);
    }, 'tcp.close');
  }

  static subscribeTlsMessage(
    tls: socket.TLSSocket,
    handler: (value: socket.SocketMessageInfo) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      tls.on('message', handler);
    }, 'tls.message');
  }

  static unsubscribeTlsMessage(
    tls: socket.TLSSocket,
    handler: (value: socket.SocketMessageInfo) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      tls.off('message', handler);
    }, 'tls.message');
  }

  static subscribeTlsClose(tls: socket.TLSSocket, handler: () => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      tls.on('close', handler);
    }, 'tls.close');
  }

  static unsubscribeTlsClose(tls: socket.TLSSocket, handler: () => void): void {
    KitEventSubscription.unsubscribe(() => {
      tls.off('close', handler);
    }, 'tls.close');
  }

  static subscribeMulticastMessage(
    multicast: socket.MulticastSocket,
    handler: (value: socket.SocketMessageInfo) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      multicast.on('message', handler);
    }, 'multicast.message');
  }

  static unsubscribeMulticastMessage(
    multicast: socket.MulticastSocket,
    handler: (value: socket.SocketMessageInfo) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      multicast.off('message', handler);
    }, 'multicast.message');
  }

  static subscribeWebSocketOpen(client: webSocket.WebSocket, handler: () => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('open', handler);
    }, 'webSocket.open');
  }

  static unsubscribeWebSocketOpen(client: webSocket.WebSocket, handler: () => void): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('open', handler);
    }, 'webSocket.open');
  }

  static subscribeWebSocketMessage(
    client: webSocket.WebSocket,
    handler: (err: BusinessError, value: string | ArrayBuffer) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('message', handler);
    }, 'webSocket.message');
  }

  static unsubscribeWebSocketMessage(
    client: webSocket.WebSocket,
    handler: (err: BusinessError, value: string | ArrayBuffer) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('message', handler);
    }, 'webSocket.message');
  }

  static subscribeWebSocketClose(client: webSocket.WebSocket, handler: () => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('close', handler);
    }, 'webSocket.close');
  }

  static unsubscribeWebSocketClose(client: webSocket.WebSocket, handler: () => void): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('close', handler);
    }, 'webSocket.close');
  }

  static subscribeWebSocketError(
    client: webSocket.WebSocket,
    handler: (err: BusinessError) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('error', handler);
    }, 'webSocket.error');
  }

  static unsubscribeWebSocketError(
    client: webSocket.WebSocket,
    handler: (err: BusinessError) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('error', handler);
    }, 'webSocket.error');
  }

  static subscribeWebSocketServerConnect(
    server: webSocket.WebSocketServer,
    handler: (connection: webSocket.WebSocketConnection) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      server.on('connect', handler);
    }, 'webSocketServer.connect');
  }

  static unsubscribeWebSocketServerConnect(
    server: webSocket.WebSocketServer,
    handler: (connection: webSocket.WebSocketConnection) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      server.off('connect', handler);
    }, 'webSocketServer.connect');
  }

  static subscribeWebSocketServerMessage(
    server: webSocket.WebSocketServer,
    handler: (message: webSocket.WebSocketMessage) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      server.on('messageReceive', handler);
    }, 'webSocketServer.messageReceive');
  }

  static unsubscribeWebSocketServerMessage(
    server: webSocket.WebSocketServer,
    handler: (message: webSocket.WebSocketMessage) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      server.off('messageReceive', handler);
    }, 'webSocketServer.messageReceive');
  }

  static subscribeTcpConnectionMessage(
    connection: socket.TCPSocketConnection,
    handler: (value: socket.SocketMessageInfo) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      connection.on('message', handler);
    }, 'tcpConnection.message');
  }

  static unsubscribeTcpConnectionMessage(
    connection: socket.TCPSocketConnection,
    handler: (value: socket.SocketMessageInfo) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      connection.off('message', handler);
    }, 'tcpConnection.message');
  }

  static subscribeTcpServerConnect(
    server: socket.TCPSocketServer,
    handler: (client: socket.TCPSocketConnection) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      server.on('connect', handler);
    }, 'tcpServer.connect');
  }

  static unsubscribeTcpServerConnect(
    server: socket.TCPSocketServer,
    handler: (client: socket.TCPSocketConnection) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      server.off('connect', handler);
    }, 'tcpServer.connect');
  }

  static unsubscribeHttpHeadersReceive(
    client: http.HttpRequest,
    handler: (header: object) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('headersReceive', handler);
    }, 'http.headersReceive');
  }
}
