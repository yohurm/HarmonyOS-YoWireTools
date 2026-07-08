import { Subscription } from './Subscription';
type Observer<T> = (value: T) => void;
/**
 * In-memory observable for single-writer state publication.
 * Not a UI binding mechanism — ViewModel maps snapshots to @Local/@Trace fields.
 */
export class Observable<T> {
  private value: T;
  private readonly observers: Set<Observer<T>> = new Set();
  constructor(initialValue: T) {
    this.value = initialValue;
  }
  get snapshot(): T {
    return this.value;
  }
  next(value: T): void {
    this.value = value;
    this.observers.forEach((observer: Observer<T>) => {
      observer(value);
    });
  }
  update(mutator: (current: T) => T): void {
    this.next(mutator(this.value));
  }
  subscribe(observer: Observer<T>, emitCurrent: boolean = true): Subscription {
    this.observers.add(observer);
    if (emitCurrent) {
      observer(this.value);
    }
    return new Subscription(() => {
      this.observers.delete(observer);
    });
  }
  clearObservers(): void {
    this.observers.clear();
  }
}
