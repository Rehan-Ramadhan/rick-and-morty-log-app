import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/char_log_model.dart';
import '../../models/dimension_model.dart';
import '../../services/char_log_service.dart';
import '../../services/dimension_service.dart';
import '../../widgets/dimension_card.dart';

/// Personal Collection page managing Dimensions and CharLogs CRUD via Laravel API.
class CollectionPage extends StatefulWidget {
  const CollectionPage({
    super.key,
    this.refreshTick = 0,
  });

  final int refreshTick;

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final DimensionService _dimensionService = DimensionService();
  final CharLogService _charLogService = CharLogService();

  List<DimensionModel> _dimensions = [];
  List<CharLogModel> _charLogs = [];
  int? _selectedDimensionFilterId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  @override
  void didUpdateWidget(covariant CollectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      _loadCollection();
    }
  }

  Future<void> _loadCollection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _dimensionService.fetchDimensions(),
        _charLogService.fetchCharLogs(),
      ]);

      if (!mounted) return;
      final fetchedDimensions = results[0] as List<DimensionModel>;
      final fetchedLogs = results[1] as List<CharLogModel>;

      setState(() {
        _dimensions = fetchedDimensions;
        _charLogs = fetchedLogs;
        if (_selectedDimensionFilterId != null &&
            !fetchedDimensions.any((d) => d.id == _selectedDimensionFilterId)) {
          _selectedDimensionFilterId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<CharLogModel> _logsForDimension(int dimensionId) {
    return _charLogs.where((log) => log.dimensionId == dimensionId).toList();
  }

  Future<void> _showDimensionDialog({DimensionModel? existing}) async {
    final controller = TextEditingController(text: existing?.name ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    String? dialogError;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existing == null ? 'New Dimension' : 'Edit Dimension',
              ),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (dialogError != null) ...[
                        Text(
                          dialogError!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: 12),
                      ],
                      AppTextField(
                        controller: controller,
                        label: 'DIMENSION DESIGNATION',
                        hint: 'e.g. Dimension C-137, Cronenberg World',
                        prefixIcon: Icons.public_rounded,
                        validator: (val) {
                          if ((val?.trim() ?? '').isEmpty) {
                            return 'Dimension name is required.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                AppButton(
                  label: existing == null ? 'Create' : 'Save',
                  isFullWidth: false,
                  height: 42,
                  isLoading: isSubmitting,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() {
                      isSubmitting = true;
                      dialogError = null;
                    });
                    try {
                      if (existing == null) {
                        await _dimensionService.createDimension(controller.text);
                      } else {
                        await _dimensionService.updateDimension(
                          existing.id,
                          controller.text,
                        );
                      }
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(true);
                      }
                    } catch (e) {
                      setDialogState(() {
                        isSubmitting = false;
                        dialogError = e.toString();
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    if (saved == true && mounted) {
      _showToast(
        existing == null
            ? 'Dimension registered in archive.'
            : 'Dimension updated successfully.',
      );
      await _loadCollection();
    }
  }

  Future<void> _confirmDeleteDimension(DimensionModel dimension) async {
    final logCount = _logsForDimension(dimension.id).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Collapse Dimension?'),
        content: Text(
          logCount > 0
              ? 'Delete "${dimension.name}" and its $logCount archived character log(s)? This action cannot be undone.'
              : 'Delete "${dimension.name}" from your archive?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Delete',
            variant: AppButtonVariant.danger,
            isFullWidth: false,
            height: 42,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _dimensionService.deleteDimension(dimension.id);
      if (!mounted) return;
      _showToast('Dimension "${dimension.name}" deleted.');
      await _loadCollection();
    } catch (e) {
      if (!mounted) return;
      _showToast('Failed to delete dimension: $e', isError: true);
    }
  }

  Future<void> _showCharLogDialog({
    CharLogModel? existing,
    int? presetDimensionId,
  }) async {
    if (_dimensions.isEmpty) {
      _showToast('Create a dimension first before adding character logs.',
          isError: true);
      await _showDimensionDialog();
      return;
    }

    final titleController = TextEditingController(text: existing?.title ?? '');
    final speciesController = TextEditingController(
      text: existing?.species ?? '',
    );
    final imageController = TextEditingController(
      text: existing?.imageUrl ?? '',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');
    int selectedDimensionId = existing?.dimensionId ??
        presetDimensionId ??
        _selectedDimensionFilterId ??
        _dimensions.first.id;
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    String? dialogError;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existing == null ? 'Log Character' : 'Edit Character Log',
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (dialogError != null) ...[
                          Text(
                            dialogError!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.error),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          'DIMENSION',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: selectedDimensionId,
                          dropdownColor: AppColors.elevatedSurface,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.public_rounded),
                          ),
                          items: _dimensions
                              .map(
                                (d) => DropdownMenuItem<int>(
                                  value: d.id,
                                  child: Text(d.name),
                                ),
                              )
                              .toList(),
                          onChanged: isSubmitting
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setDialogState(
                                      () => selectedDimensionId = val,
                                    );
                                  }
                                },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: titleController,
                          label: 'CHARACTER NAME / TITLE',
                          hint: 'e.g. Evil Morty',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if ((val?.trim() ?? '').isEmpty) {
                              return 'Character title is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: speciesController,
                          label: 'SPECIES',
                          hint: 'e.g. Human, Alien, Cyborg',
                          prefixIcon: Icons.biotech_rounded,
                          validator: (val) {
                            if ((val?.trim() ?? '').isEmpty) {
                              return 'Species is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: imageController,
                          label: 'IMAGE URL',
                          hint: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
                          prefixIcon: Icons.image_outlined,
                          keyboardType: TextInputType.url,
                          validator: (val) {
                            final v = val?.trim() ?? '';
                            if (v.isEmpty) {
                              return 'Image URL is required.';
                            }
                            if (!v.startsWith('http://') &&
                                !v.startsWith('https://')) {
                              return 'Enter a valid http/https image URL.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: notesController,
                          label: 'FIELD NOTES (OPTIONAL)',
                          hint: 'Observations, threat level, portal origin...',
                          prefixIcon: Icons.edit_note_rounded,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                AppButton(
                  label: existing == null ? 'Save Log' : 'Update Log',
                  isFullWidth: false,
                  height: 42,
                  isLoading: isSubmitting,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() {
                      isSubmitting = true;
                      dialogError = null;
                    });
                    try {
                      if (existing == null) {
                        await _charLogService.createCharLog(
                          dimensionId: selectedDimensionId,
                          title: titleController.text,
                          species: speciesController.text,
                          imageUrl: imageController.text,
                          notes: notesController.text,
                        );
                      } else {
                        await _charLogService.updateCharLog(
                          id: existing.id,
                          dimensionId: selectedDimensionId,
                          title: titleController.text,
                          species: speciesController.text,
                          imageUrl: imageController.text,
                          notes: notesController.text,
                        );
                      }
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(true);
                      }
                    } catch (e) {
                      setDialogState(() {
                        isSubmitting = false;
                        dialogError = e.toString();
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    speciesController.dispose();
    imageController.dispose();
    notesController.dispose();

    if (saved == true && mounted) {
      _showToast(
        existing == null
            ? 'Character log saved to archive.'
            : 'Character log updated.',
      );
      await _loadCollection();
    }
  }

  Future<void> _confirmDeleteCharLog(CharLogModel log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Character Log?'),
        content: Text(
          'Remove "${log.title}" from your archived logs? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Delete',
            variant: AppButtonVariant.danger,
            isFullWidth: false,
            height: 42,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _charLogService.deleteCharLog(log.id);
      if (!mounted) return;
      _showToast('"${log.title}" removed from archive.');
      await _loadCollection();
    } catch (e) {
      if (!mounted) return;
      _showToast('Failed to delete character log: $e', isError: true);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: isError ? AppColors.error : AppColors.primaryNeonGreen,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visibleDimensions = _selectedDimensionFilterId == null
        ? _dimensions
        : _dimensions
            .where((d) => d.id == _selectedDimensionFilterId)
            .toList();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 860 ? 28.0 : 16.0;

          return RefreshIndicator(
            color: AppColors.primaryNeonGreen,
            backgroundColor: AppColors.surface,
            onRefresh: _loadCollection,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    14,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(textTheme),
                        const SizedBox(height: 16),
                        _buildFilterChips(textTheme),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingWidget(
                      message: 'Syncing dimensional vault...',
                    ),
                  )
                else if (_errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: AppErrorWidget(
                        title: 'Vault Sync Failed',
                        message: _errorMessage!,
                        onRetry: _loadCollection,
                      ),
                    ),
                  )
                else if (_dimensions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: AppErrorWidget(
                        title: 'No Dimensions Created',
                        message:
                            'Create your first dimension (such as C-137) to start organizing personal character logs.',
                        icon: Icons.workspaces_outline,
                        isEmptyState: true,
                        retryLabel: 'Create First Dimension',
                        onRetry: () => _showDimensionDialog(),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      4,
                      horizontalPadding,
                      32,
                    ),
                    sliver: SliverList.separated(
                      itemCount: visibleDimensions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final dimension = visibleDimensions[index];
                        final logs = _logsForDimension(dimension.id);
                        return DimensionCard(
                          dimension: dimension,
                          logs: logs,
                          onEditDimension: () =>
                              _showDimensionDialog(existing: dimension),
                          onDeleteDimension: () =>
                              _confirmDeleteDimension(dimension),
                          onAddLogToDimension: () => _showCharLogDialog(
                            presetDimensionId: dimension.id,
                          ),
                          onEditLog: (log) =>
                              _showCharLogDialog(existing: log),
                          onDeleteLog: _confirmDeleteCharLog,
                        ).animate().fadeIn(
                              duration: 280.ms,
                              delay: (index * 45).ms,
                            );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'PERSONAL DIMENSION VAULT',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.cyan,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'My Collection',
              style: textTheme.headlineLarge,
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            AppButton(
              label: 'New Dimension',
              icon: Icons.add_location_alt_outlined,
              isFullWidth: false,
              height: 44,
              variant: AppButtonVariant.secondary,
              onPressed: () => _showDimensionDialog(),
            ),
            AppButton(
              label: 'Add Char Log',
              icon: Icons.post_add_rounded,
              isFullWidth: false,
              height: 44,
              onPressed: () => _showCharLogDialog(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChips(TextTheme textTheme) {
    if (_dimensions.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('All Dimensions (${_charLogs.length})'),
              selected: _selectedDimensionFilterId == null,
              onSelected: (_) =>
                  setState(() => _selectedDimensionFilterId = null),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryNeonGreen.withValues(alpha: 0.18),
              side: BorderSide(
                color: _selectedDimensionFilterId == null
                    ? AppColors.primaryNeonGreen
                    : AppColors.borderSubtle,
              ),
              labelStyle: textTheme.bodySmall?.copyWith(
                color: _selectedDimensionFilterId == null
                    ? AppColors.primaryNeonGreen
                    : AppColors.secondaryText,
                fontWeight: FontWeight.w700,
              ),
              showCheckmark: false,
            ),
          ),
          for (final dim in _dimensions)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${dim.name} (${_logsForDimension(dim.id).length})'),
                selected: _selectedDimensionFilterId == dim.id,
                onSelected: (_) =>
                    setState(() => _selectedDimensionFilterId = dim.id),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.cyan.withValues(alpha: 0.16),
                side: BorderSide(
                  color: _selectedDimensionFilterId == dim.id
                      ? AppColors.cyan
                      : AppColors.borderSubtle,
                ),
                labelStyle: textTheme.bodySmall?.copyWith(
                  color: _selectedDimensionFilterId == dim.id
                      ? AppColors.cyan
                      : AppColors.secondaryText,
                  fontWeight: FontWeight.w700,
                ),
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}
