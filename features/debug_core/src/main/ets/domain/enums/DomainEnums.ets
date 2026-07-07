export enum ModuleType {
  BLUETOOTH = 'bluetooth',
  WIFI = 'wifi',
  NEARLINK = 'nearlink',
  SYSTEM = 'system'
}

export enum ProtocolType {
  CLASSIC_SCAN = 'classic_scan',
  SPP = 'spp',
  BLE_SCAN = 'ble_scan',
  BLE_GATT = 'ble_gatt',
  WIFI_SCAN = 'wifi_scan',
  NETWORK_DIAGNOSTICS = 'network_diagnostics',
  TCP_CLIENT = 'tcp_client',
  TCP_SERVER = 'tcp_server',
  UDP = 'udp',
  HTTP = 'http',
  WEBSOCKET = 'websocket',
  MQTT = 'mqtt',
  MDNS = 'mdns',
  SSDP = 'ssdp',
  NEARLINK_SCAN = 'nearlink_scan',
  SSAP = 'ssap',
  DATA_TRANSFER = 'data_transfer',
  NONE = 'none'
}

export enum SessionType {
  SCAN = 'scan',
  CONNECTION = 'connection',
  DIAGNOSTIC = 'diagnostic',
  COMMAND = 'command',
  EXPORT = 'export'
}

export enum SessionState {
  CREATED = 'CREATED',
  PREPARING = 'PREPARING',
  RUNNING = 'RUNNING',
  SUSPENDED = 'SUSPENDED',
  STOPPING = 'STOPPING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
  CANCELLED = 'CANCELLED'
}

export enum Direction {
  INBOUND = 'inbound',
  OUTBOUND = 'outbound',
  INTERNAL = 'internal'
}

export enum LogRecordType {
  BYTES = 'bytes',
  TEXT = 'text',
  STATE = 'state',
  ERROR = 'error',
  METRIC = 'metric',
  PERMISSION = 'permission',
  LIFECYCLE = 'lifecycle'
}

export enum DisplayHint {
  TEXT = 'text',
  HEX = 'hex',
  MIXED = 'mixed',
  JSON = 'json',
  NONE = 'none'
}

export enum AppMode {
  EXPERT = 'expert',
  LIGHT = 'light'
}

export enum TransportState {
  IDLE = 'idle',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  DISCONNECTING = 'disconnecting',
  DISCONNECTED = 'disconnected',
  FAILED = 'failed'
}

export enum LogCaptureState {
  RECORDING = 'recording',
  FLUSHING = 'flushing',
  EXPORTING = 'exporting',
  PAUSED = 'paused',
  ERROR = 'error'
}

export enum ErrorSeverity {
  INFO = 'info',
  WARNING = 'warning',
  ERROR = 'error',
  FATAL = 'fatal'
}

export enum PayloadEncoding {
  TEXT = 'text',
  HEX = 'hex',
  BASE64 = 'base64',
  FILE = 'file'
}

export enum LineEndingMode {
  NONE = 'none',
  CR = 'cr',
  LF = 'lf',
  CRLF = 'crlf'
}

export enum WriteMode {
  ONCE = 'once',
  REPEAT = 'repeat',
  SEQUENCE = 'sequence'
}
