import { Component, signal } from '@angular/core';
import { Landing } from './features/landing/landing';
import { PlantList } from './features/plants/components/plant-list/plant-list';
import { Scene } from './shared/ui/scene/scene';

/** How long the intro takes to slide away, in milliseconds. */
const LANDING_EXIT_MS = 700;

@Component({
  selector: 'app-root',
  imports: [Landing, PlantList, Scene],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  protected readonly showLanding = signal(true);
  protected readonly leaving = signal(false);

  protected enter(): void {
    if (this.leaving()) {
      return;
    }
    this.leaving.set(true);
    setTimeout(() => this.showLanding.set(false), LANDING_EXIT_MS);
  }
}
