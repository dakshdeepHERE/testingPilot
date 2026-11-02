import { Plant } from '../models/plant.model';

/** A plant is thirsty once it has gone as many days as its watering interval without water. */
export function isThirsty(plant: Plant): boolean {
  return plant.daysSinceWatered >= plant.wateringEveryDays;
}

/** How much water is left, from 0 (thirsty) to 100 (just watered). */
export function hydrationPercent(plant: Plant): number {
  const left = 1 - plant.daysSinceWatered / plant.wateringEveryDays;
  return Math.round(Math.max(0, left) * 100);
}
