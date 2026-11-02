import { Component, signal } from '@angular/core';

interface Drop {
  id: number;
  x: number;
  size: number;
  alpha: number;
  drift: number;
  duration: number;
  delay: number;
}

const between = (min: number, max: number) => min + Math.random() * (max - min);

function look(id: number, duration: number, delay: number): Drop {
  return {
    id,
    x: between(2, 98),
    size: between(12, 30),
    alpha: between(0.35, 0.85),
    drift: between(-40, 40),
    duration,
    delay,
  };
}

@Component({
  selector: 'app-rain',
  templateUrl: './rain.html',
  styleUrl: './rain.css',
})
export class Rain {
  // Each drop keeps its own speed. A negative delay means the drops are already mid-fall on load.
  protected readonly drops = signal<Drop[]>(
    Array.from({ length: 20 }, (_, id) => look(id, between(6, 13), -between(0, 13))),
  );

  // When a drop reaches the bottom and starts again, it comes back in a new place and size.
  // The timing stays the same so the animation does not jump.
  protected respawn(drop: Drop): void {
    this.drops.update((list) =>
      list.map((d) => (d.id === drop.id ? look(d.id, d.duration, d.delay) : d)),
    );
  }
}
