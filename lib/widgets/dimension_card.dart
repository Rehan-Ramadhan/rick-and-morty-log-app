import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/portal_image.dart';
import '../models/char_log_model.dart';
import '../models/dimension_model.dart';

/// Sci-fi dimension container card displaying a dimension and its archived character logs.
class DimensionCard extends StatelessWidget {
  const DimensionCard({
    super.key,
    required this.dimension,
    required this.logs,
    required this.onEditDimension,
    required this.onDeleteDimension,
    required this.onAddLogToDimension,
    required this.onEditLog,
    required this.onDeleteLog,
  });

  final DimensionModel dimension;
  final List<CharLogModel> logs;
  final VoidCallback onEditDimension;
  final VoidCallback onDeleteDimension;
  final VoidCallback onAddLogToDimension;
  final ValueChanged<CharLogModel> onEditLog;
  final ValueChanged<CharLogModel> onDeleteLog;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.primaryNeonGreen,
          collapsedIconColor: AppColors.secondaryText,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.dimensionalGradient,
              border: Border.all(
                color: AppColors.primaryNeonGreen.withValues(alpha: 0.55),
              ),
            ),
            child: const Icon(
              Icons.public_rounded,
              color: AppColors.primaryNeonGreen,
              size: 22,
            ),
          ),
          title: Text(
            dimension.name,
            style: textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${logs.length} ${logs.length == 1 ? 'Log' : 'Logs'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (dimension.createdAt != null)
                  Text(
                    'Created ${DateFormat('dd MMM yyyy').format(dimension.createdAt!)}',
                    style: textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Add log to this dimension',
                onPressed: onAddLogToDimension,
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.primaryNeonGreen,
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: 'Edit dimension',
                onPressed: onEditDimension,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.cyan,
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: 'Delete dimension',
                onPressed: onDeleteDimension,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            ],
          ),
          children: [
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 14),
            if (logs.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      color: AppColors.secondaryText.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No character logs archived in this dimension yet.',
                        style: textTheme.bodySmall,
                      ),
                    ),
                    TextButton(
                      onPressed: onAddLogToDimension,
                      child: const Text(
                        'Add Log',
                        style: TextStyle(color: AppColors.primaryNeonGreen),
                      ),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final useTwoColumns = constraints.maxWidth >= 640;
                  if (!useTwoColumns) {
                    return Column(
                      children: [
                        for (var i = 0; i < logs.length; i++) ...[
                          _CharLogTile(
                            log: logs[i],
                            onEdit: () => onEditLog(logs[i]),
                            onDelete: () => onDeleteLog(logs[i]),
                          ),
                          if (i != logs.length - 1) const SizedBox(height: 10),
                        ],
                      ],
                    );
                  }

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: logs
                        .map(
                          (log) => SizedBox(
                            width: (constraints.maxWidth - 12) / 2,
                            child: _CharLogTile(
                              log: log,
                              onEdit: () => onEditLog(log),
                              onDelete: () => onDeleteLog(log),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CharLogTile extends StatelessWidget {
  const _CharLogTile({
    required this.log,
    required this.onEdit,
    required this.onDelete,
  });

  final CharLogModel log;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortalNetworkImage(
            imageUrl: log.imageUrl,
            width: 68,
            height: 68,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.biotech_rounded,
                      size: 13,
                      color: AppColors.purple,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        log.species,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  (log.notes != null && log.notes!.trim().isNotEmpty)
                      ? log.notes!
                      : 'No field notes recorded.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: (log.notes != null && log.notes!.trim().isNotEmpty)
                        ? AppColors.mainText.withValues(alpha: 0.85)
                        : AppColors.secondaryText.withValues(alpha: 0.7),
                    fontStyle:
                        (log.notes != null && log.notes!.trim().isNotEmpty)
                            ? FontStyle.normal
                            : FontStyle.italic,
                  ),
                ),
                if (log.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(log.createdAt!),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 10.5,
                      color: AppColors.secondaryText.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit character log',
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.cyan,
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: 'Delete character log',
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 19,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
