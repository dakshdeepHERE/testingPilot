import { Component, computed, input, output } from '@angular/core';
import { Plant } from '../../models/plant.model';
import { hydrationPercent, isThirsty } from '../../rules/plant-care';

@Component({
  selector: 'app-plant-card',
  templateUrl: './plant-card.html',
  styleUrl: './plant-card.css',
})
export class PlantCard {
  readonly plant = input.required<Plant>();
  /** True while this card's plant is being watered, which plays the rain animation. */
  readonly watering = input(false);
  /** True while any plant is being watered, so the button cannot be pressed twice. */
  readonly disabled = input(false);

  readonly water = output<void>();

  protected readonly thirsty = computed(() => isThirsty(this.plant()));
  protected readonly hydration = computed(() => hydrationPercent(this.plant()));
  protected readonly drops = [0, 1, 2, 3, 4, 5, 6, 7];
}
