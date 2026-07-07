import { webSocket } from '@kit.NetworkKit';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';

/**
 * WebSocket Server capability probe per architecture 03-§8.2 and WSL API 23+.
 */
export class WebSocketServerCapabilityProbe {
  static probeSupported(): boolean {
    try {
      const server = webSocket.createWebSocketServer();
      return server !== undefined;
    } catch (_error) {
      return false;
    }
  }

  static capabilityMessage(): string {
    return WebSocketServerCapabilityProbe.probeSupported()
      ? 'WebSocket Server supported on this device (API 23+)'
      : `WebSocket Server unavailable (${WifiNetworkErrorCodes.WS_SERVER_UNSUPPORTED})`;
  }
}
