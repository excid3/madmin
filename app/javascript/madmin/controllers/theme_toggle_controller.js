/**
 * Theme Toggle Controller
 *
 * Handles light/dark theme switching with system prefs,
 * persistence (4h), multi-instance sync, and smooth transitions.
 */

import { Controller } from "@hotwired/stimulus"

const STORAGE_PREFIX = 'madmin_'

document.addEventListener('turbo:load', () => {
  const theme = getSavedTheme();
  setTheme(theme);
});

//// controller
export default class extends Controller {
  static targets = ["select"]

  connect() {
    // subscribe
    controllers.add(this);
    this.updateTheme(this.theme);
  }

  disconnect() {
    // unsubscribe
    controllers.delete(this);
  }

  updateTheme(theme) {
    this.selectTargets.forEach(select => {
      if (select.dataset.setTheme === theme) {
        select.classList.add(select.dataset.toggleClass);
      } else {
        select.classList.remove(select.dataset.toggleClass);
      }
    });
  }

  async changeTheme(event) {
    const newTheme = event.currentTarget.dataset.setTheme;
    await this.smoothThemeTransition(newTheme, event);
  }

  async smoothThemeTransition(newTheme, event) {
    if (!document.startViewTransition) {
      setTheme(newTheme, true);
      return;
    }

    const transition = document.startViewTransition(() => {
      setTheme(newTheme, true);
    });

    const button = event.currentTarget;
    const { top, left, width, height } = button.getBoundingClientRect();
    const x = left + width / 2;
    const y = top + height / 2;
    const maxRadius = Math.hypot(
      Math.max(left, window.innerWidth - left),
      Math.max(top, window.innerHeight - top)
    );

    await transition.ready;

    document.documentElement.animate(
      {
        clipPath: [
          `circle(0px at ${x}px ${y}px)`,
          `circle(${maxRadius}px at ${x}px ${y}px)`,
        ],
      },
      {
        duration: 750,
        easing: "ease-in-out",
        pseudoElement: "::view-transition-new(root)",
      }
    );

    await transition.finished;
  }

  get theme() { return getSavedTheme() }
}

//// outer functions

// a simple observer pub/sub to broadcast to all instance of this controller
const controllers = new Set();

const broadcastTheme = (theme) => {
  controllers.forEach((controller) => controller.updateTheme(theme));
};

const getSystemTheme = () => {
  if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    return 'dark';
  }
  return 'light';
}

const getStoredThemeData = () => {
  const saved = localStorage.getItem(`${STORAGE_PREFIX}theme`);
  return saved ? JSON.parse(saved) : {};
}

const getSavedTheme = () => {
  const saved = getStoredThemeData();
  if (saved.value && new Date(saved.expiry) > new Date()) {
    return saved.value;
  }
  return getSystemTheme();
}

const setTheme = (theme, force = false) => {
  const saved = getStoredThemeData();
  const now = new Date();

  // only set if has expired or user toggles
  if (force || !saved.value || new Date(saved.expiry) <= now) {
    // Set expiry time to 4 hours from now
    now.setHours(now.getHours() + 4);
    const themeData = {
      value: theme,
      expiry: now.toISOString()
    };
    localStorage.setItem(`${STORAGE_PREFIX}theme`, JSON.stringify(themeData));
  }

  document.documentElement.setAttribute('data-theme', theme);
  broadcastTheme(theme);
}

// Add CSS for smooth transitions
const style = document.createElement('style');
style.textContent = `
  ::view-transition-old(root),
  ::view-transition-new(root) {
    animation: none;
    mix-blend-mode: normal;
  }
`;
document.head.appendChild(style);
