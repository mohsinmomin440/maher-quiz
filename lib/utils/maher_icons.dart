import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Maher Zero-Emoji Vector SVG Icon Engine
/// Provides pure SVG vector graphics for all visual indicators in the app.
class MaherIcons {
  static const String _crescentStarSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M12 3a9 9 0 1 0 9 9c0-.46-.04-.92-.1-1.36a5.389 5.389 0 0 1-4.4 2.26 5.403 5.403 0 0 1-3.14-9.8c-.44-.06-.9-.1-1.36-.1z"/>
  <polygon points="19 3 20 6 23 6 20.5 8 21.5 11 19 9 16.5 11 17.5 8 15 6 18 6" fill="currentColor"/>
</svg>
''';

  static const String _mosqueSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
  <path d="M3 21h18M4 21V10l2-2v13M18 21V8l2 2v11M10 21V13a2 2 0 0 1 4 0v8M12 3c-2.5 2-4 4.5-4 7h8c0-2.5-1.5-5-4-7z"/>
  <circle cx="12" cy="2" r="1" fill="currentColor"/>
</svg>
''';

  static const String _quranBookSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20M4 19.5A2.5 2.5 0 0 0 6.5 22H20V2H6.5A2.5 2.5 0 0 0 4 4.5v15z"/>
  <path d="M8 7h8M8 11h5"/>
</svg>
''';

  static const String _timerClockSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <circle cx="12" cy="12" r="10"/>
  <polyline points="12 6 12 12 16 14"/>
</svg>
''';

  static const String _flameStreakSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>
</svg>
''';

  static const String _trophySvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M6 9H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h2M18 9h2a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-2M4 22h16M10 14.66V17c0 .55-.45 1-1 1H8c-.55 0-1 .45-1 1v1h10v-1c0-.55-.45-1-1-1h-1c-.55 0-1-.45-1-1v-2.34M6 3h12v7a6 6 0 0 1-12 0V3z"/>
</svg>
''';

  static const String _checkCircleSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
  <circle cx="12" cy="12" r="10"/>
  <polyline points="16 9 10.5 14.5 8 12"/>
</svg>
''';

  static const String _crossCircleSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
  <circle cx="12" cy="12" r="10"/>
  <line x1="15" y1="9" x2="9" y2="15"/>
  <line x1="9" y1="9" x2="15" y2="15"/>
</svg>
''';

  static const String _userSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
  <circle cx="12" cy="7" r="4"/>
</svg>
''';

  static const String _usersGroupSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
  <circle cx="9" cy="7" r="4"/>
  <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
  <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
</svg>
''';

  static const String _lockSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
  <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
</svg>
''';

  static const String _mailSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
  <polyline points="22,6 12,13 2,6"/>
</svg>
''';

  static const String _globeSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <circle cx="12" cy="12" r="10"/>
  <line x1="2" y1="12" x2="22" y2="12"/>
  <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
</svg>
''';

  static const String _rubElHizbSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <rect x="4" y="4" width="16" height="16" rx="2" fill="currentColor"/>
  <rect x="4" y="4" width="16" height="16" rx="2" transform="rotate(45 12 12)" fill="currentColor"/>
  <circle cx="12" cy="12" r="3.5" fill="#044E3D"/>
</svg>
''';

  static const String _eyeSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
  <circle cx="12" cy="12" r="3"/>
</svg>
''';

  static const String _eyeOffSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
  <line x1="1" y1="1" x2="23" y2="23"/>
</svg>
''';

  static const String _shieldCheckSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
  <polyline points="9 12 11 14 15 10"/>
</svg>
''';

  static const String _shieldAlertSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
  <line x1="12" y1="8" x2="12" y2="12"/>
  <line x1="12" y1="16" x2="12.01" y2="16"/>
</svg>
''';

  static const String _refreshSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <polyline points="23 4 23 10 17 10"/>
  <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/>
</svg>
''';

  static const String _sparkleSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M12 0L14.59 9.41L24 12L14.59 14.59L12 24L9.41 14.59L0 12L9.41 9.41L12 0Z"/>
</svg>
''';

  static const String _chevronRightSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
  <polyline points="9 18 15 12 9 6"/>
</svg>
''';

  static const String _arrowLeftSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
  <line x1="19" y1="12" x2="5" y2="12"/>
  <polyline points="12 19 5 12 12 5"/>
</svg>
''';

  static const String _logoutSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
  <polyline points="16 17 21 12 16 7"/>
  <line x1="21" y1="12" x2="9" y2="12"/>
</svg>
''';

  static const String _searchSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <circle cx="11" cy="11" r="8"/>
  <line x1="21" y1="21" x2="16.65" y2="16.65"/>
</svg>
''';

  static const String _trashSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <polyline points="3 6 5 6 21 6"/>
  <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
</svg>
''';

  static const String _keySvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M21 2l-2 2m-1.5 1.5L16 7l-2-2-4 4 1 1-2 2-1-1-2 2 1 1-3 3a5.5 5.5 0 1 1-7.78-7.78 5.5 5.5 0 0 1 7.78 0l1 1 2-2-1-1 2-2 1 1 2-2z"/>
</svg>
''';

  static const String _adminCrownSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M2 19h20v2H2v-2zm1-8l4.5 4L12 7l4.5 8L21 11v6H3v-6zm3-4a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm12 0a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm-6-2a2 2 0 1 0 0-4 2 2 0 0 0 0 4z"/>
</svg>
''';

  static const String _chartBarSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <line x1="18" y1="20" x2="18" y2="10"/>
  <line x1="12" y1="20" x2="12" y2="4"/>
  <line x1="6" y1="20" x2="6" y2="14"/>
  <line x1="2" y1="20" x2="22" y2="20"/>
</svg>
''';

  static const String _studentCapSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
  <path d="M6 12v5c3 3 9 3 12 0v-5"/>
</svg>
''';

  static const String _pencilSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 20h9"/>
  <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
</svg>
''';

  static const String _cameraSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
  <circle cx="12" cy="13" r="4"/>
</svg>
''';

  static const String _phoneSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
</svg>
''';

  static const String _kaabaSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <rect x="4" y="4" width="16" height="16" rx="2" fill="#1E293B"/>
  <rect x="4" y="8" width="16" height="2.5" fill="#F59E0B"/>
  <rect x="13" y="12" width="4.5" height="8" rx="0.5" fill="#F59E0B"/>
</svg>
''';

  // Maher Islamic Logo Vector (Luxury Rub el Hizb Star + Open Quran)
  static const String _maherLogoSvg = '''
<svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="logoBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#065F46"/>
      <stop offset="50%" stop-color="#047857"/>
      <stop offset="100%" stop-color="#022C22"/>
    </linearGradient>
    <linearGradient id="goldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FDE68A"/>
      <stop offset="35%" stop-color="#F59E0B"/>
      <stop offset="70%" stop-color="#D97706"/>
      <stop offset="100%" stop-color="#92400E"/>
    </linearGradient>
    <linearGradient id="goldLightGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#FEF3C7"/>
      <stop offset="100%" stop-color="#F59E0B"/>
    </linearGradient>
  </defs>
  <!-- Squircle Base -->
  <rect x="2" y="2" width="96" height="96" rx="24" fill="url(#logoBg)" stroke="url(#goldGrad)" stroke-width="2.2"/>
  
  <!-- Outer 8-Pointed Star (Rub el Hizb) Outline -->
  <g transform="translate(50, 50) scale(1.15)">
    <rect x="-24" y="-24" width="48" height="48" rx="4" fill="none" stroke="url(#goldGrad)" stroke-width="2.2"/>
    <rect x="-24" y="-24" width="48" height="48" rx="4" transform="rotate(45)" fill="none" stroke="url(#goldGrad)" stroke-width="2.2"/>
  </g>

  <!-- Open Holy Quran Book (Centered) -->
  <g transform="translate(50, 48)">
    <!-- Left Page -->
    <path d="M-2 -8 C-8 -12 -16 -12 -22 -9 C-22 6 -16 6 -2 10 Z" fill="url(#goldLightGrad)" stroke="url(#goldGrad)" stroke-width="1.2"/>
    <!-- Right Page -->
    <path d="M2 -8 C8 -12 16 -12 22 -9 C22 6 16 6 2 10 Z" fill="url(#goldLightGrad)" stroke="url(#goldGrad)" stroke-width="1.2"/>
    <!-- Page Turn Lines -->
    <path d="M-2 -6 C-7 -9 -14 -9 -19 -7" stroke="#92400E" stroke-width="0.8" fill="none"/>
    <path d="M2 -6 C7 -9 14 -9 19 -7" stroke="#92400E" stroke-width="0.8" fill="none"/>
    <!-- Rehal (Book Stand) -->
    <path d="M-15 15 L15 25 M15 15 L-15 25" stroke="url(#goldGrad)" stroke-width="2.5" stroke-linecap="round"/>
    <!-- Star sparkle at top -->
    <polygon points="0,-18 2,-14 6,-12 2,-10 0,-6 -2,-10 -6,-12 -2,-14" fill="#FEF3C7"/>
  </g>
</svg>
''';

  static const String _crownGoldSvg = '''
<svg viewBox="0 0 24 24" fill="#D97706">
  <path d="M2 19h20v2.5H2V19zm1-8l4.5 4L12 7l4.5 8L21 11v6H3v-6zm3-4a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm12 0a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm-6-2a2 2 0 1 0 0-4 2 2 0 0 0 0 4z"/>
</svg>
''';

  static const String _medalSilverSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
  <circle cx="12" cy="14" r="7" stroke="#64748B" stroke-width="1.8" fill="#E2E8F0"/>
  <path d="M10.5 12h2.5c.8 0 1.5.7 1.5 1.5 0 .6-.4 1.1-.9 1.3l-3.1 2.2h4" stroke="#334155" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M8 2l4 6 4-6" stroke="#059669" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  static const String _medalBronzeSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
  <circle cx="12" cy="14" r="7" stroke="#78350F" stroke-width="1.8" fill="#FDE68A"/>
  <path d="M10 12h3c.6 0 1 .4 1 1s-.4 1-1 1h-1.5m1.5 0c.6 0 1 .4 1 1s-.4 1-1 1h-3" stroke="#78350F" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M8 2l4 6 4-6" stroke="#D97706" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  static const String _bookmarkFilledSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
</svg>
''';

  static const String _bookmarkOutlineSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
</svg>
''';

  static const String _starIslamicSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
</svg>
''';

  static const String _badgeVerifiedSvg = '''
<svg viewBox="0 0 24 24" fill="#059669">
  <path d="M12 2l2.4 2.1 3.2-.4 1.2 3 3 1.2-.4 3.2 2.1 2.4-2.1 2.4.4 3.2-3 1.2-1.2 3-3.2-.4L12 22l-2.4-2.1-3.2.4-1.2-3-3-1.2.4-3.2L.5 10.5 2.6 8.1l-.4-3.2 3-1.2 1.2-3 3.2.4L12 2z"/>
  <polyline points="8.5 12 10.8 14.5 15.5 9.5" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  static const String _homeSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
</svg>
''';

  static const String _homeOutlineSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
  <polyline points="9 22 9 12 15 12 15 22"/>
</svg>
''';

  static const String _googleSvg = '''
<svg viewBox="0 0 24 24">
  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
</svg>
''';

  // SVG Helper Widget Factory
  static Widget get(
    String iconName, {
    double size = 24.0,
    Color? color,
  }) {
    String rawSvg;
    switch (iconName) {
      case 'logo':
        return SvgPicture.string(_maherLogoSvg, width: size, height: size);
      case 'home':
        rawSvg = _homeSvg;
        break;
      case 'home-outline':
        rawSvg = _homeOutlineSvg;
        break;
      case 'crescent-star':
        rawSvg = _crescentStarSvg;
        break;
      case 'mosque':
        rawSvg = _mosqueSvg;
        break;
      case 'book-quran':
        rawSvg = _quranBookSvg;
        break;
      case 'timer-clock':
        rawSvg = _timerClockSvg;
        break;
      case 'flame-streak':
        rawSvg = _flameStreakSvg;
        break;
      case 'trophy':
        rawSvg = _trophySvg;
        break;
      case 'check-circle':
        rawSvg = _checkCircleSvg;
        break;
      case 'cross-circle':
        rawSvg = _crossCircleSvg;
        break;
      case 'user':
        rawSvg = _userSvg;
        break;
      case 'users-group':
        rawSvg = _usersGroupSvg;
        break;
      case 'lock':
        rawSvg = _lockSvg;
        break;
      case 'mail':
        rawSvg = _mailSvg;
        break;
      case 'globe':
        rawSvg = _globeSvg;
        break;
      case 'rub-el-hizb':
        rawSvg = _rubElHizbSvg;
        break;
      case 'eye':
        rawSvg = _eyeSvg;
        break;
      case 'eye-off':
        rawSvg = _eyeOffSvg;
        break;
      case 'shield-check':
        rawSvg = _shieldCheckSvg;
        break;
      case 'shield-alert':
        rawSvg = _shieldAlertSvg;
        break;
      case 'refresh':
        rawSvg = _refreshSvg;
        break;
      case 'sparkle':
        rawSvg = _sparkleSvg;
        break;
      case 'chevron-right':
        rawSvg = _chevronRightSvg;
        break;
      case 'arrow-left':
        rawSvg = _arrowLeftSvg;
        break;
      case 'logout':
        rawSvg = _logoutSvg;
        break;
      case 'search':
        rawSvg = _searchSvg;
        break;
      case 'trash':
        rawSvg = _trashSvg;
        break;
      case 'key':
        rawSvg = _keySvg;
        break;
      case 'admin-crown':
        rawSvg = _adminCrownSvg;
        break;
      case 'crown-gold':
        rawSvg = _crownGoldSvg;
        break;
      case 'medal-silver':
        rawSvg = _medalSilverSvg;
        break;
      case 'medal-bronze':
        rawSvg = _medalBronzeSvg;
        break;
      case 'bookmark':
      case 'bookmark-filled':
        rawSvg = _bookmarkFilledSvg;
        break;
      case 'bookmark-outline':
        rawSvg = _bookmarkOutlineSvg;
        break;
      case 'star-islamic':
        rawSvg = _starIslamicSvg;
        break;
      case 'badge-verified':
        rawSvg = _badgeVerifiedSvg;
        break;
      case 'chart-bar':
        rawSvg = _chartBarSvg;
        break;
      case 'student-cap':
        rawSvg = _studentCapSvg;
        break;
      case 'pencil':
      case 'edit':
        rawSvg = _pencilSvg;
        break;
      case 'camera':
        rawSvg = _cameraSvg;
        break;
      case 'phone':
        rawSvg = _phoneSvg;
        break;
      case 'kaaba':
        rawSvg = _kaabaSvg;
        break;
      case 'google':
        rawSvg = _googleSvg;
        break;
      default:
        rawSvg = _rubElHizbSvg;
    }

    return SvgPicture.string(
      rawSvg,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}
