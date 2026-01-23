# Field Logger Color Scheme Reference

## CSS Variables (Define in `:root`)

```css
:root {
    /* Primary Colors */
    --green: #2d5016;
    --green-dark: #1d3a0e;
    --green-light: #3d6e22;
    --gold: #f4e157;
    --gold-light: #fff176;
    
    /* Background Colors */
    --bg: #f5f5f0;
    --bg-wheat: #f5f1e8;
    --bg-wheat-dark: #e8e2d5;
    
    /* Text Colors */
    --text: #333;
    --text-muted: #666;
    --text-dark: #1a1a1a;
    --text-medium: #4a4a4a;
    
    /* UI Colors */
    --border: #ddd;
    --danger: #c62828;
    --success: #2e7d32;
    --warning: #f57c00;
    
    /* Utility */
    --shadow: rgba(0, 0, 0, 0.12);
    --card-bg: rgba(255, 255, 255, 0.95);
}
```

---

## Color Usage Guide

### Primary Brand Colors

| Color | Variable | Hex | Usage |
|-------|----------|-----|-------|
| Baldwin Green | `--green` | `#2d5016` | Primary buttons, headers, accents, borders |
| Baldwin Green Dark | `--green-dark` | `#1d3a0e` | Hover states, text accents |
| Baldwin Green Light | `--green-light` | `#3d6e22` | Gradients, lighter accents |
| Baldwin Gold | `--gold` | `#f4e157` | Accent highlights, special selections |
| Baldwin Gold Light | `--gold-light` | `#fff176` | Hover states for gold elements |

### Background Colors

| Color | Variable | Hex | Usage |
|-------|----------|-----|-------|
| Light Gray | `--bg` | `#f5f5f0` | Info rows, secondary backgrounds |
| Wheat | `--bg-wheat` | `#f5f1e8` | Page background (gradient start) |
| Wheat Dark | `--bg-wheat-dark` | `#e8e2d5` | Page background (gradient end) |

### Text Colors

| Color | Variable | Hex | Usage |
|-------|----------|-----|-------|
| Primary Text | `--text` | `#333` | Main body text |
| Muted Text | `--text-muted` | `#666` | Secondary text, labels |
| Dark Text | `--text-dark` | `#1a1a1a` | Headers, emphasis |

### Status Colors

| Color | Variable | Hex | Usage |
|-------|----------|-----|-------|
| Danger/Error | `--danger` | `#c62828` | Errors, delete buttons, warnings |
| Success | `--success` | `#2e7d32` | Success states, confirmations |
| Warning | `--warning` | `#f57c00` | Caution states, alerts |

---

## Component-Specific Styling

### Buttons

```css
/* Primary Button */
.btn-primary { 
    background: var(--green);      /* #2d5016 */
    color: white; 
}
.btn-primary:hover { 
    background: var(--green-dark); /* #1d3a0e */
}

/* Gold Button */
.btn-gold { 
    background: var(--gold);       /* #f4e157 */
    color: var(--green-dark);      /* #1d3a0e */
}

/* Outline Button */
.btn-outline { 
    border: 2px solid var(--green);
    color: var(--green); 
}

/* Danger Button */
.btn-danger { 
    background: var(--danger);     /* #c62828 */
    color: white; 
}
```

### Input Fields

```css
input:focus, select:focus { 
    border-color: var(--green);    /* #2d5016 */
    box-shadow: 0 0 0 3px rgba(45, 80, 22, 0.15); 
}

input[readonly] { 
    background: #f5f5f0; 
    color: var(--text-muted);      /* #666 */
}
```

### Cards

```css
.card { 
    background: white;
    border: 2px solid var(--border); /* #ddd */
}
.card:hover { 
    border-color: var(--green);      /* #2d5016 */
}
```

### Info Display

```css
.info-row { 
    background: var(--bg);           /* #f5f5f0 */
}
.info-value { 
    color: var(--green);             /* #2d5016 */
}
```

### Special Elements

```css
/* Product substitution dropdown (gold border) */
.product-select-dropdown {
    border: 2px solid var(--gold);   /* #f4e157 */
    background: rgba(244, 225, 87, 0.1);
}

/* Common name header */
.product-general-header {
    color: var(--green-dark);        /* #1d3a0e */
}
```

---

## Typography

### Font Families
```css
/* Headers */
font-family: 'Bebas Neue', sans-serif;

/* Body Text */
font-family: 'IBM Plex Sans', sans-serif;
```

### Google Fonts Import
```html
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
```

---

## Page Background Gradient

```css
body {
    background: linear-gradient(135deg, var(--bg-wheat) 0%, var(--bg-wheat-dark) 100%);
    /* Equivalent to: linear-gradient(135deg, #f5f1e8 0%, #e8e2d5 100%) */
}
```

---

## Quick Reference Summary

| Element | Color | Hex |
|---------|-------|-----|
| Primary buttons | Baldwin Green | `#2d5016` |
| Button hover | Baldwin Green Dark | `#1d3a0e` |
| Accent highlights | Baldwin Gold | `#f4e157` |
| Page background | Wheat gradient | `#f5f1e8` → `#e8e2d5` |
| Body text | Dark gray | `#333` |
| Secondary text | Muted gray | `#666` |
| Borders | Light gray | `#ddd` |
| Error/delete | Red | `#c62828` |
| Success | Green | `#2e7d32` |

---

*Field Logger Color Scheme Reference*  
*Based on Baldwin Ag Design System v1.0.0*
