/**
 * Maps Bluetooth CoD (MajorClass / MajorMinorClass) to HarmonyOS Symbol resources.
 * Values from ohos.bluetooth.constant MajorClass / MajorMinorClass.
 */
export class ClassicDeviceSymbolResolver {
  private static readonly MAJOR_COMPUTER: number = 0x0100;
  private static readonly MAJOR_PHONE: number = 0x0200;
  private static readonly MAJOR_NETWORKING: number = 0x0300;
  private static readonly MAJOR_AUDIO_VIDEO: number = 0x0400;
  private static readonly MAJOR_PERIPHERAL: number = 0x0500;
  private static readonly MAJOR_IMAGING: number = 0x0600;
  private static readonly MAJOR_WEARABLE: number = 0x0700;
  private static readonly MAJOR_TOY: number = 0x0800;
  private static readonly MAJOR_HEALTH: number = 0x0900;

  private static readonly AUDIO_VIDEO_WEARABLE_HEADSET: number = 0x0404;
  private static readonly AUDIO_VIDEO_HANDSFREE: number = 0x0408;
  private static readonly AUDIO_VIDEO_MICROPHONE: number = 0x0410;
  private static readonly AUDIO_VIDEO_LOUDSPEAKER: number = 0x0414;
  private static readonly AUDIO_VIDEO_HEADPHONES: number = 0x0418;
  private static readonly AUDIO_VIDEO_CAR_AUDIO: number = 0x0420;
  private static readonly AUDIO_VIDEO_HIFI_AUDIO: number = 0x0428;
  private static readonly AUDIO_VIDEO_VIDEO_CAMERA: number = 0x0430;
  private static readonly AUDIO_VIDEO_CAMCORDER: number = 0x0434;
  private static readonly AUDIO_VIDEO_VIDEO_MONITOR: number = 0x0438;
  private static readonly AUDIO_VIDEO_VIDEO_DISPLAY_AND_LOUDSPEAKER: number = 0x043C;
  private static readonly AUDIO_VIDEO_VIDEO_GAMING_TOY: number = 0x0448;

  private static readonly PERIPHERAL_KEYBOARD: number = 0x0540;
  private static readonly PERIPHERAL_POINTING_DEVICE: number = 0x0580;
  private static readonly PERIPHERAL_JOYSTICK: number = 0x0504;
  private static readonly PERIPHERAL_GAMEPAD: number = 0x0508;

  private static readonly IMAGING_DISPLAY: number = 0x0610;
  private static readonly IMAGING_CAMERA: number = 0x0620;
  private static readonly IMAGING_PRINTER: number = 0x0680;

  private static readonly WEARABLE_WRIST_WATCH: number = 0x0704;

  private static readonly TOY_ROBOT: number = 0x0804;
  private static readonly TOY_VEHICLE: number = 0x0808;
  private static readonly TOY_GAME: number = 0x0814;

  static resolve(majorClass: number, majorMinorClass: number): Resource {
    const byMinor = ClassicDeviceSymbolResolver.resolveMinor(majorMinorClass);
    if (byMinor !== undefined) {
      return byMinor;
    }
    return ClassicDeviceSymbolResolver.resolveMajor(majorClass);
  }

  private static resolveMinor(majorMinorClass: number): Resource | undefined {
    if (majorMinorClass === 0) {
      return undefined;
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_HEADPHONES ||
      majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_WEARABLE_HEADSET ||
      majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_HANDSFREE) {
      return $r('sys.symbol.headphones');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_LOUDSPEAKER ||
      majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_HIFI_AUDIO ||
      majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_MICROPHONE) {
      return $r('sys.symbol.speaker');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_CAR_AUDIO ||
      majorMinorClass === ClassicDeviceSymbolResolver.TOY_VEHICLE) {
      return $r('sys.symbol.car');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_VIDEO_CAMERA ||
      majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_CAMCORDER ||
      majorMinorClass === ClassicDeviceSymbolResolver.IMAGING_CAMERA) {
      return $r('sys.symbol.camera');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_VIDEO_MONITOR ||
      majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_VIDEO_DISPLAY_AND_LOUDSPEAKER ||
      majorMinorClass === ClassicDeviceSymbolResolver.IMAGING_DISPLAY) {
      return $r('sys.symbol.display');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.AUDIO_VIDEO_VIDEO_GAMING_TOY ||
      majorMinorClass === ClassicDeviceSymbolResolver.PERIPHERAL_GAMEPAD ||
      majorMinorClass === ClassicDeviceSymbolResolver.PERIPHERAL_JOYSTICK ||
      majorMinorClass === ClassicDeviceSymbolResolver.TOY_GAME) {
      return $r('sys.symbol.gamecontroller');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.PERIPHERAL_KEYBOARD) {
      return $r('sys.symbol.keyboard');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.PERIPHERAL_POINTING_DEVICE) {
      return $r('sys.symbol.mouse');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.IMAGING_PRINTER) {
      return $r('sys.symbol.printer');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.WEARABLE_WRIST_WATCH) {
      return $r('sys.symbol.watch');
    }
    if (majorMinorClass === ClassicDeviceSymbolResolver.TOY_ROBOT) {
      return $r('sys.symbol.robot');
    }
    return undefined;
  }

  private static resolveMajor(majorClass: number): Resource {
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_COMPUTER) {
      return $r('sys.symbol.computer');
    }
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_PHONE) {
      return $r('sys.symbol.phone');
    }
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_NETWORKING) {
      return $r('sys.symbol.wifi');
    }
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_AUDIO_VIDEO) {
      return $r('sys.symbol.headphones');
    }
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_PERIPHERAL) {
      return $r('sys.symbol.keyboard');
    }
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_IMAGING) {
      return $r('sys.symbol.camera');
    }
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_WEARABLE) {
      return $r('sys.symbol.watch');
    }
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_TOY) {
      return $r('sys.symbol.robot');
    }
    if (majorClass === ClassicDeviceSymbolResolver.MAJOR_HEALTH) {
      return $r('sys.symbol.heart');
    }
    return $r('sys.symbol.bluetooth');
  }
}
