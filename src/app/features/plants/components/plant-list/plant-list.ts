import { Component, inject } from '@angular/core';
import { PlantStore } from '../../state/plant.store';
import { PlantCard } from '../plant-card/plant-card';

@Component({
  selector: 'app-plant-list',
  imports: [PlantCard],
  templateUrl: './plant-list.html',
  styleUrl: './plant-list.css',
})
export class PlantList {
  protected readonly store = inject(PlantStore);
}
