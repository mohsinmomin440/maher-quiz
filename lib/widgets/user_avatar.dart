import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/maher_icons.dart';
import '../utils/maher_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? avatar;
  final String name;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool showEditBadge;
  final VoidCallback? onEditTap;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.avatar,
    this.name = '',
    this.size = 56,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 2.0,
    this.showEditBadge = false,
    this.onEditTap,
    this.onTap,
  });

  String get _initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'M';
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) {
      final chars = parts[0].characters;
      return chars.take(chars.length >= 2 ? 2 : 1).toString().toUpperCase();
    }
    final firstChar = parts[0].characters.first;
    final secondChar = parts[1].characters.first;
    return '$firstChar$secondChar'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ?? MaherTheme.goldPrimary.withValues(alpha: 0.6);

    Widget avatarWidget = _buildAvatarContent();

    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(
                    color: effectiveBorderColor,
                    width: borderWidth,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: size * 0.15,
                offset: Offset(0, size * 0.05),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarWidget,
          ),
        ),
        if (showEditBadge)
          Positioned(
            right: -2,
            bottom: -2,
            child: GestureDetector(
              onTap: onEditTap ?? onTap,
              child: Container(
                padding: EdgeInsets.all(size * 0.08),
                decoration: BoxDecoration(
                  color: MaherTheme.goldPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: MaherIcons.get(
                  'camera',
                  size: size * 0.26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  // A few recent avatars, keyed by their base64 string. Several avatars are
  // on screen at once and rebuild often, so decoding each time is wasteful.
  static final Map<String, Uint8List> _decodedCache = {};
  static const int _maxCacheEntries = 12;

  static Uint8List _decodeCached(String raw) {
    final cached = _decodedCache.remove(raw);
    if (cached != null) {
      _decodedCache[raw] = cached; // mark as most recently used
      return cached;
    }
    final base64String = raw.contains(',') ? raw.split(',').last : raw;
    final bytes = base64Decode(base64String);
    if (_decodedCache.length >= _maxCacheEntries) {
      _decodedCache.remove(_decodedCache.keys.first);
    }
    _decodedCache[raw] = bytes;
    return bytes;
  }

  Widget _buildAvatarContent() {
    final raw = avatar?.trim() ?? '';

    // Base64 image
    if (raw.startsWith('data:image') || (raw.length > 100 && !raw.startsWith('avatar_'))) {
      try {
        final bytes = _decodeCached(raw);
        return Image.memory(
          bytes,
          // Same bytes instance across rebuilds, so Flutter's image cache
          // reuses the decoded image instead of re-decoding it
          gaplessPlayback: true,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsFallback(),
        );
      } catch (_) {
        // Fallback on decode failure
      }
    }

    // Default: Elegant Initials Avatar (No cartoon presets or URLs)
    return _buildInitialsFallback();
  }

  Widget _buildInitialsFallback() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MaherTheme.emeraldPrimary,
            MaherTheme.emeraldDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: MaherTheme.goldLight,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
