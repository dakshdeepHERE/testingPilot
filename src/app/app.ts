import { Component, computed, signal } from '@angular/core';
import { Plant } from './plant';
import { PLANTS } from './plants';

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  protected readonly plants = signal<Plant[]>(PLANTS);

  protected readonly thirstyCount = computed(
    () => this.plants().filter((plant) => this.isThirsty(plant)).length,
  );

  protected isThirsty(plant: Plant): boolean {
    return plant.daysSinceWatered >= plant.wateringEveryDays;
  }

  protected water(plant: Plant): void {
    this.plants.update((list) =>
      list.map((p) => (p.id === plant.id ? { ...p, daysSinceWatered: 0 } : p)),
    );
  }
}
