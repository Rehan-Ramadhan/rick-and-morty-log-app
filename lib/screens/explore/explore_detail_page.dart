import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/portal_image.dart';
import '../../models/character_model.dart';
import '../../models/dimension_model.dart';
import '../../services/char_log_service.dart';
import '../../services/character_service.dart';
import '../../services/dimension_service.dart';
import '../../widgets/portal_background.dart';

/// Character dossier detail page with "Save to Collection" backed by Laravel API.
class ExploreDetailPage extends StatefulWidget {
  const ExploreDetailPage({
    super.key,
    this.character,
    this.characterId,
  });

  final CharacterModel? character;
  final int? characterId;

  @override
  State<ExploreDetailPage> createState() => _ExploreDetailPageState();
}

class _ExploreDetailPageState extends State<ExploreDetailPage> {
  final CharacterService _characterService = CharacterService();

  CharacterModel? _character;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.character != null) {
      _character = widget.character;
    } else if (widget.characterId != null) {
      _fetchCharacter(widget.characterId!);
    } else {
      _errorMessage = 'Character identifier was not provided.';
    }
  }

  Future<void> _fetchCharacter(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetched = await _characterService.fetchCharacterById(id);
      if (!mounted) return;
      setState(() => _character = fetched);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return AppColors.primaryNeonGreen;
      case 'dead':
        return AppColors.error;
      default:
        return AppColors.cyan;
    }
  }

  Future<void> _openSaveToCollectionSheet(CharacterModel character) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => _SaveToCollectionSheet(character: character),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryNeonGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${character.name} logged to your personal collection!',
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PortalBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton.outlined(
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              side: const BorderSide(color: AppColors.borderSubtle),
              foregroundColor: AppColors.mainText,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENTITY DOSSIER',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.cyan,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  _character?.name ?? 'Scanning...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading entity telemetry...');
    }

    if (_errorMessage != null || _character == null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: AppErrorWidget(
          title: 'Dossier Unavailable',
          message: _errorMessage ?? 'Entity data could not be loaded.',
          onRetry: widget.characterId != null
              ? () => _fetchCharacter(widget.characterId!)
              : null,
        ),
      );
    }

    final character = _character!;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(character.status);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 820;

        final portraitSection = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Hero(
                tag: 'character_avatar_${character.id}',
                child: AspectRatio(
                  aspectRatio: isWide ? 0.95 : 1.15,
                  child: PortalNetworkImage(
                    imageUrl: character.image,
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        character.status.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.mainText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms).scale(
              begin: const Offset(0.96, 0.96),
            );

        final detailsSection = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          'ID #${character.id}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (character.episodeCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${character.episodeCount} Episodes',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    character.name,
                    style: textTheme.displayMedium,
                  ),
                  const SizedBox(height: 20),
                  _InfoRowTile(
                    icon: Icons.favorite_border_rounded,
                    label: 'Status',
                    value: character.status,
                    accent: statusColor,
                  ),
                  const SizedBox(height: 12),
                  _InfoRowTile(
                    icon: Icons.biotech_rounded,
                    label: 'Species',
                    value: character.type.isNotEmpty
                        ? '${character.species} (${character.type})'
                        : character.species,
                    accent: AppColors.purple,
                  ),
                  const SizedBox(height: 12),
                  _InfoRowTile(
                    icon: Icons.wc_rounded,
                    label: 'Gender',
                    value: character.gender,
                    accent: AppColors.cyan,
                  ),
                  const SizedBox(height: 12),
                  _InfoRowTile(
                    icon: Icons.public_rounded,
                    label: 'Origin',
                    value: character.originName,
                    accent: AppColors.primaryNeonGreen,
                  ),
                  const SizedBox(height: 12),
                  _InfoRowTile(
                    icon: Icons.location_on_outlined,
                    label: 'Last Known Location',
                    value: character.locationName,
                    accent: AppColors.cyan,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
            const SizedBox(height: 18),
            AppButton(
              label: 'SAVE TO COLLECTION',
              icon: Icons.bookmark_add_rounded,
              height: 54,
              onPressed: () => _openSaveToCollectionSheet(character),
            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
          ],
        );

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1060),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: portraitSection),
                        const SizedBox(width: 28),
                        Expanded(flex: 6, child: detailsSection),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        portraitSection,
                        const SizedBox(height: 20),
                        detailsSection,
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRowTile extends StatelessWidget {
  const _InfoRowTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    letterSpacing: 0.9,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveToCollectionSheet extends StatefulWidget {
  const _SaveToCollectionSheet({required this.character});

  final CharacterModel character;

  @override
  State<_SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<_SaveToCollectionSheet> {
  final DimensionService _dimensionService = DimensionService();
  final CharLogService _charLogService = CharLogService();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _newDimensionController = TextEditingController();

  List<DimensionModel> _dimensions = [];
  int? _selectedDimensionId;
  bool _isLoadingDimensions = true;
  bool _isSaving = false;
  bool _showCreateDimension = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDimensions();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _newDimensionController.dispose();
    super.dispose();
  }

  Future<void> _loadDimensions() async {
    setState(() {
      _isLoadingDimensions = true;
      _error = null;
    });
    try {
      final dims = await _dimensionService.fetchDimensions();
      if (!mounted) return;
      setState(() {
        _dimensions = dims;
        if (dims.isNotEmpty) {
          _selectedDimensionId = dims.first.id;
          _showCreateDimension = false;
        } else {
          _showCreateDimension = true;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingDimensions = false);
    }
  }

  Future<void> _createQuickDimension() async {
    final name = _newDimensionController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a dimension name.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final created = await _dimensionService.createDimension(name);
      if (!mounted) return;
      setState(() {
        _dimensions.add(created);
        _selectedDimensionId = created.id;
        _showCreateDimension = false;
        _newDimensionController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveCharLog() async {
    if (_selectedDimensionId == null) {
      setState(() => _error = 'Select or create a dimension first.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _charLogService.createCharLog(
        dimensionId: _selectedDimensionId!,
        title: widget.character.name,
        species: widget.character.species,
        imageUrl: widget.character.image,
        notes: _notesController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PortalNetworkImage(
                      imageUrl: widget.character.image,
                      width: 52,
                      height: 52,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save to Collection',
                            style: textTheme.titleLarge,
                          ),
                          Text(
                            '${widget.character.name} • ${widget.character.species}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.cyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (_isLoadingDimensions)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryNeonGreen,
                        ),
                      ),
                    ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TARGET DIMENSION',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => setState(
                                  () => _showCreateDimension =
                                      !_showCreateDimension,
                                ),
                        icon: Icon(
                          _showCreateDimension
                              ? Icons.close_rounded
                              : Icons.add_rounded,
                          size: 16,
                        ),
                        label: Text(
                          _showCreateDimension
                              ? 'Use Existing'
                              : 'New Dimension',
                        ),
                      ),
                    ],
                  ),
                  if (_showCreateDimension) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _newDimensionController,
                            label: '',
                            hint: 'e.g. Dimension C-137',
                            prefixIcon: Icons.public_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'Add',
                          isFullWidth: false,
                          height: 50,
                          variant: AppButtonVariant.secondary,
                          isLoading: _isSaving,
                          onPressed: _createQuickDimension,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    DropdownButtonFormField<int>(
                      initialValue: _selectedDimensionId,
                      dropdownColor: AppColors.elevatedSurface,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.workspaces_outline),
                      ),
                      items: _dimensions
                          .map(
                            (d) => DropdownMenuItem<int>(
                              value: d.id,
                              child: Text(d.name),
                            ),
                          )
                          .toList(),
                      onChanged: _isSaving
                          ? null
                          : (val) => setState(() => _selectedDimensionId = val),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    controller: _notesController,
                    label: 'FIELD NOTES (OPTIONAL)',
                    hint: 'Record observations, anomalies, or status...',
                    prefixIcon: Icons.edit_note_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'ARCHIVE CHARACTER LOG',
                    icon: Icons.save_rounded,
                    isLoading: _isSaving,
                    onPressed: _saveCharLog,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
