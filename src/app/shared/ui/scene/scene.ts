import { booleanAttribute, Component, input } from '@angular/core';
import { Rain } from '../rain/rain';
import { Sun } from '../sun/sun';

/** The leafy backdrop with the sun and falling rain, used behind both pages. */
@Component({
  selector: 'app-scene',
  imports: [Rain, Sun],
  templateUrl: './scene.html',
  styleUrl: './scene.css',
})
export class Scene {
  /** Darkens the backdrop so content on top stays readable. */
  readonly dimmed = input(false, { transform: booleanAttribute });
  /** Slowly drifts the backdrop from side to side. */
  readonly drift = input(false, { transform: booleanAttribute });
}
