/**
 * Maher Zero-Emoji SVG Icon Generator (Node.js)
 * Generates high-quality SVG vector icons to replace all emojis across the Maher Quiz App.
 */

const fs = require('fs');
const path = require('path');

const iconsDir = path.join(__dirname, '..', 'assets', 'icons');
if (!fs.existsSync(iconsDir)) {
  fs.mkdirSync(iconsDir, { recursive: true });
}

const icons = {
  // 1st Place / Champion Crown
  'crown_gold.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#D97706">
  <path d="M2 19h20v2.5H2V19zm1-8l4.5 4L12 7l4.5 8L21 11v6H3v-6zm3-4a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm12 0a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm-6-2a2 2 0 1 0 0-4 2 2 0 0 0 0 4z"/>
</svg>`,

  // 2nd Place Silver Medal
  'medal_silver.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#64748B">
  <circle cx="12" cy="14" r="7" stroke="#475569" stroke-width="1.5" fill="#E2E8F0"/>
  <path d="M10.5 12h2.5c.8 0 1.5.7 1.5 1.5 0 .6-.4 1.1-.9 1.3l-3.1 2.2h4" fill="none" stroke="#334155" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M8 2l4 6 4-6" fill="none" stroke="#059669" stroke-width="2" stroke-linecap="round"/>
</svg>`,

  // 3rd Place Bronze Medal
  'medal_bronze.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#B45309">
  <circle cx="12" cy="14" r="7" stroke="#78350F" stroke-width="1.5" fill="#FDE68A"/>
  <path d="M10 12h3c.6 0 1 .4 1 1s-.4 1-1 1h-1.5m1.5 0c.6 0 1 .4 1 1s-.4 1-1 1h-3" fill="none" stroke="#78350F" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M8 2l4 6 4-6" fill="none" stroke="#D97706" stroke-width="2" stroke-linecap="round"/>
</svg>`,

  // Bookmark Outline (Unsaved)
  'bookmark_outline.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
</svg>`,

  // Bookmark Filled (Saved)
  'bookmark_filled.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#D97706">
  <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
</svg>`,

  // Star / Favorite / Rub el Hizb
  'star_islamic.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#F59E0B">
  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
</svg>`,

  // Sparkle / MashaAllah Shine
  'sparkle_shine.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#10B981">
  <path d="M12 0L14.59 9.41L24 12L14.59 14.59L12 24L9.41 14.59L0 12L9.41 9.41L12 0Z"/>
</svg>`,

  // Badge Verified Seal (Replaces ✓)
  'badge_verified.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#059669">
  <path d="M12 2l2.4 2.1 3.2-.4 1.2 3 3 1.2-.4 3.2 2.1 2.4-2.1 2.4.4 3.2-3 1.2-1.2 3-3.2-.4L12 22l-2.4-2.1-3.2.4-1.2-3-3-1.2.4-3.2L.5 10.5 2.6 8.1l-.4-3.2 3-1.2 1.2-3 3.2.4L12 2z"/>
  <polyline points="8.5 12 10.8 14.5 15.5 9.5" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>`,

  // Trophy Cup
  'trophy_cup.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M6 9H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h2M18 9h2a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-2M4 22h16M10 14.66V17c0 .55-.45 1-1 1H8c-.55 0-1 .45-1 1v1h10v-1c0-.55-.45-1-1-1h-1c-.55 0-1-.45-1-1v-2.34M6 3h12v7a6 6 0 0 1-12 0V3z"/>
</svg>`,

  // Flame Streak
  'flame_streak.svg': `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#D97706">
  <path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>
</svg>`
};

console.log('Generating SVG icons into assets/icons/...');
for (const [filename, content] of Object.entries(icons)) {
  const filePath = path.join(iconsDir, filename);
  fs.writeFileSync(filePath, content.trim(), 'utf8');
  console.log(`✓ Generated: assets/icons/${filename}`);
}

console.log(`\nSuccessfully generated all ${Object.keys(icons).length} SVG icons!`);
