import { Component, output } from '@angular/core';
import { Scene } from '../../shared/ui/scene/scene';

@Component({
  selector: 'app-landing',
  imports: [Scene],
  templateUrl: './landing.html',
  styleUrl: './landing.css',
})
export class Landing {
  readonly start = output<void>();
}
