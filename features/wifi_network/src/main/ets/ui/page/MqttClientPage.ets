import { EmptyPageView } from 'common_ui';

@ComponentV2
export struct MqttClientPage {
  build() {
    EmptyPageView({ title: 'MQTT 客户端' })
  }
}
