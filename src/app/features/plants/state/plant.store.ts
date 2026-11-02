import { computed, Injectable, signal } from '@angular/core';
import { PLANTS } from '../data/plants';
import { Plant } from '../models/plant.model';

/** How long the rain falls before the plant has "drunk" and turns happy. */
const DRINK_DELAY_MS = 700;
/** How long the whole watering animation lasts. */
const WATERING_DURATION_MS = 1500;

/** Holds the plants and the watering action, so the components only have to show them. */
@Injectable({ providedIn: 'root' })
export class PlantStore {
  readonly plants = signal<Plant[]>(PLANTS);

  /** The plant being watered right now, or null when nothing is being watered. */
  readonly wateringId = signal<number | null>(null);

  readonly isBusy = computed(() => this.wateringId() !== null);

  water(id: number): void {
    if (this.isBusy()) {
      return;
    }
    this.wateringId.set(id);
    setTimeout(() => {
      this.plants.update((list) =>
        list.map((plant) => (plant.id === id ? { ...plant, daysSinceWatered: 0 } : plant)),
      );
    }, DRINK_DELAY_MS);
    setTimeout(() => this.wateringId.set(null), WATERING_DURATION_MS);
  }
}
