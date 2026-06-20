import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/chat/domain/entities/chat_room.dart';

enum AppDrawerSection { camera, history }

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.width,
    this.selectedSection = AppDrawerSection.camera,
    this.onSectionSelected,
    this.onOpenSettings,
    this.onOpenProfile,
    this.onNewChat,
    this.chatRooms = const <ChatRoom>[],
    this.onSelectChatRoom,
    this.onDeleteChatRoom,
    super.key,
  });

  final double width;
  final AppDrawerSection selectedSection;
  final ValueChanged<AppDrawerSection>? onSectionSelected;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;

  /// Starts a fresh consultation (a new chat session) from the camera home.
  final VoidCallback? onNewChat;

  /// Saved chat rooms listed under "최근 항목"; tapping one loads it on the home.
  final List<ChatRoom> chatRooms;
  final ValueChanged<ChatRoom>? onSelectChatRoom;

  /// Called when a chat room is swiped away to delete it.
  final ValueChanged<ChatRoom>? onDeleteChatRoom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SafeArea(
        bottom: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(36),
          ),
          child: Material(
            color: AppColors.cardWhite,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: AppSpacing.topBarHeight + 10,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAssets.logoAll,
                            width: 52,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(),
                          _ProfileCircleButton(onTap: onOpenProfile),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DrawerTile(
                    icon: Icons.camera_alt_outlined,
                    label: '카메라',
                    selected: selectedSection == AppDrawerSection.camera,
                    onTap: () =>
                        onSectionSelected?.call(AppDrawerSection.camera),
                  ),
                  _DrawerTile(
                    icon: Icons.history_rounded,
                    label: '최근 판단',
                    selected: selectedSection == AppDrawerSection.history,
                    onTap: () =>
                        onSectionSelected?.call(AppDrawerSection.history),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '최근 항목',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.72),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: chatRooms.isEmpty
                        ? const Align(
                            alignment: Alignment.topLeft,
                            child: _RecentText('아직 대화 기록이 없어요.'),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: chatRooms.length,
                            itemBuilder: (context, index) {
                              final room = chatRooms[index];
                              return Dismissible(
                                key: ValueKey(room.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) =>
                                    onDeleteChatRoom?.call(room),
                                background: const _ChatRoomDeleteBackground(),
                                child: _ChatRoomTile(
                                  title: room.title,
                                  onTap: () => onSelectChatRoom?.call(room),
                                ),
                              );
                            },
                          ),
                  ),
                  Row(
                    children: [
                      _NewChatChip(onTap: onNewChat),
                      const Spacer(),
                      Tooltip(
                        message: '설정',
                        child: InkWell(
                          onTap: onOpenSettings,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppAssets.settings,
                              width: 34,
                              height: 34,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.10),
        selectedColor: AppColors.primary,
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RecentText extends StatelessWidget {
  const _RecentText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _NewChatChip extends StatelessWidget {
  const _NewChatChip({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.30),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                '새로운 고민',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatRoomDeleteBackground extends StatelessWidget {
  const _ChatRoomDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xxs),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: AppColors.pass.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: AppColors.pass,
        size: 22,
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCircleButton extends StatelessWidget {
  const _ProfileCircleButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '프로필',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 22,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
