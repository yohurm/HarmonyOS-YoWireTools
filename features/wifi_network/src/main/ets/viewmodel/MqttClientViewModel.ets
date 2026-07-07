import { MqttConnectConfig, MqttClientPhase, MqttMessageRecord } from '../domain/model/MqttModels';
import { OpenMqttSessionUseCase } from '../domain/usecase/WifiNetworkExtendedUseCases';

@ObservedV2
export class MqttClientViewModel {
  @Trace brokerHost: string = '127.0.0.1';
  @Trace brokerPort: number = 1883;
  @Trace clientId: string = 'yowire-mqtt';
  @Trace username: string = '';
  @Trace password: string = '';
  @Trace topic: string = 'test/topic';
  @Trace publishPayload: string = 'hello';
  @Trace phase: MqttClientPhase = MqttClientPhase.IDLE;
  @Trace sessionId: string = '';
  @Trace messages: MqttMessageRecord[] = [];
  @Trace statusMessage: string = '';

  private readonly openMqtt: OpenMqttSessionUseCase = new OpenMqttSessionUseCase();

  private appendMessage(record: MqttMessageRecord): void {
    const next: MqttMessageRecord[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      next.push(this.messages[i]);
    }
    next.push(record);
    this.messages = next;
  }

  async connectAction(): Promise<void> {
    this.phase = MqttClientPhase.CONNECTING;
    this.statusMessage = '等待 CONNACK/SUBACK...';
    const config = new MqttConnectConfig(
      this.brokerHost,
      this.brokerPort,
      this.clientId,
      this.username,
      this.password,
      this.topic
    );
    const result = await this.openMqtt.execute(config);
    if (!result.success || result.value === undefined) {
      this.phase = MqttClientPhase.FAILED;
      this.statusMessage = result.error?.message ?? 'MQTT 连接失败';
      return;
    }
    this.sessionId = result.value;
    this.phase = MqttClientPhase.CONNECTED;
    this.statusMessage = 'MQTT 已连接（已通过 CONNACK/SUBACK）';
    const subscribed = this.openMqtt.getDataSource().onMessage((payload: string) => {
      this.appendMessage(new MqttMessageRecord('RX', this.topic, payload));
    });
    if (!subscribed.success) {
      this.statusMessage = subscribed.error?.message ?? '订阅消息监听失败';
    }
  }

  async publishAction(): Promise<void> {
    const result = await this.openMqtt.getDataSource().publish(this.topic, this.publishPayload);
    if (result.success) {
      this.appendMessage(new MqttMessageRecord('TX', this.topic, this.publishPayload));
      this.statusMessage = '已发布';
    } else {
      this.statusMessage = result.error?.message ?? '发布失败';
    }
  }

  async disconnectAction(): Promise<void> {
    if (this.sessionId.length === 0) {
      this.phase = MqttClientPhase.IDLE;
      return;
    }
    this.phase = MqttClientPhase.DISCONNECTING;
    const sessionId = this.sessionId;
    const result = await this.openMqtt.disconnect(sessionId);
    this.sessionId = '';
    this.phase = MqttClientPhase.IDLE;
    this.statusMessage = result.success ? '已断开' : (result.error?.message ?? '断开失败');
  }
}
