import { Observable, Subscription, TimeUtil } from 'common_core';
import { PairingEvent, PairingState } from '../model/PairingState';
import { BluetoothRepository } from '../../data/repository/BluetoothRepository';

type PairingListener = (event: PairingEvent) => void;

/**
 * Manages bondStateChange subscription lifecycle per architecture bluetooth/01-§7.2.
 */
export class PairingCoordinator {
  private static instance: PairingCoordinator | undefined;
  private readonly repository: BluetoothRepository;
  private readonly pairingObservable: Observable<PairingEvent>;
  private started: boolean = false;

  private constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
    this.pairingObservable = new Observable<PairingEvent>(
      new PairingEvent('', PairingState.UNKNOWN, 0)
    );
  }

  static getInstance(): PairingCoordinator {
    if (PairingCoordinator.instance === undefined) {
      PairingCoordinator.instance = new PairingCoordinator();
    }
    return PairingCoordinator.instance;
  }

  ensureStarted(): void {
    if (this.started) {
      return;
    }
    this.repository.onBondStateChange((event: PairingEvent) => {
      this.repository.applyPairingEvent(event);
      this.pairingObservable.next(event);
    });
    this.started = true;
  }

  stop(): void {
    if (!this.started) {
      return;
    }
    this.repository.offBondStateChange();
    this.started = false;
  }

  observe(): Observable<PairingEvent> {
    this.ensureStarted();
    return this.pairingObservable;
  }

  subscribe(listener: PairingListener): Subscription {
    this.ensureStarted();
    return this.pairingObservable.subscribe(listener);
  }
}
