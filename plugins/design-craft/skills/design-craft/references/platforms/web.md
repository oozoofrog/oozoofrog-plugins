# Web Platform Design Guidelines Summary

Default reference document for the web-designer agent.

## Official Sources

- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [MDN Web Docs](https://developer.mozilla.org/)

## Core Quantitative Criteria

### Accessibility (WCAG 2.2)

| Item | AA criterion | AAA criterion |
|------|---------|---------|
| Text contrast ratio | 4.5:1 | 7:1 |
| Large text contrast ratio (≥18pt/14pt bold) | 3:1 | 4.5:1 |
| UI component contrast ratio | 3:1 | — |
| Minimum touch target | 24×24px (2.5.8) | 44×44px |
| Focus indicator thickness | 2px or more | — |

### Responsive Breakpoints

| Name | Range | Use |
|------|------|------|
| mobile | 0-639px | Portrait mobile |
| tablet | 640-1023px | Tablet / landscape mobile |
| desktop | 1024-1279px | Standard desktop |
| wide | 1280px+ | Wide monitor |

### Typography (Modular Scale)

| Style | Size | Line height | Note |
|--------|------|------|------|
| Display | clamp(2rem, 5vw, 3.5rem) | 1.1 | Hero area |
| H1 | clamp(1.75rem, 4vw, 2.5rem) | 1.2 | |
| H2 | clamp(1.5rem, 3vw, 2rem) | 1.25 | |
| H3 | 1.25rem | 1.3 | |
| Body | 1rem (16px) | 1.5 | Minimum body size |
| Small | 0.875rem (14px) | 1.4 | Secondary text |
| Caption | 0.75rem (12px) | 1.3 | Caption / label |

### Spacing (4px-based)

| Token | Value |
|------|-----|
| spacing-xs | 4px |
| spacing-sm | 8px |
| spacing-md | 16px |
| spacing-lg | 24px |
| spacing-xl | 32px |
| spacing-2xl | 48px |
| spacing-3xl | 64px |

### Color

| Item | Light | Dark |
|------|-------|------|
| Background (primary) | #FFFFFF | #121212 |
| Background (secondary) | #F5F5F5 | #1E1E1E |
| Text (primary) | #1A1A1A | #E0E0E0 |
| Text (secondary) | #666666 | #A0A0A0 |
| Divider | #E0E0E0 | #333333 |

### Z-Index System

| Layer | Value |
|--------|-----|
| Base | 0 |
| Dropdown | 100 |
| Sticky | 200 |
| Overlay | 300 |
| Modal | 400 |
| Toast | 500 |

### Elevation (Box Shadow)

| Level | Value |
|------|-----|
| level-1 | 0 1px 2px rgba(0,0,0,0.05) |
| level-2 | 0 2px 4px rgba(0,0,0,0.1) |
| level-3 | 0 4px 8px rgba(0,0,0,0.12) |
| level-4 | 0 8px 16px rgba(0,0,0,0.15) |

## CSS Mapping Hints

```css
/* Typography — fluid */
font-size: clamp(1rem, 0.5rem + 1vw, 1.25rem);
line-height: 1.5;

/* Spacing — CSS custom properties */
--spacing-unit: 4px;
gap: calc(var(--spacing-unit) * 4); /* 16px */

/* Responsive */
@media (min-width: 640px) { /* tablet */ }
@media (min-width: 1024px) { /* desktop */ }

/* Dark mode */
@media (prefers-color-scheme: dark) { }
```
