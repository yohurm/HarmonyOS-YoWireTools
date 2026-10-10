import { ModuleType } from '../enums/DomainEnums';

/**
 * Stable module identity shared by the shell and the three radio features.
 * Values match ModuleType so there is not a second id space.
 */
export class FeatureModuleId {
  static readonly BLUETOOTH: string = ModuleType.BLUETOOTH;
  static readonly WIFI: string = ModuleType.WIFI;
  static readonly NEARLINK: string = ModuleType.NEARLINK;
}
