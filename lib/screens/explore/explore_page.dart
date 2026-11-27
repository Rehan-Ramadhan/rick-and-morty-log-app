import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/character_model.dart';
import '../../routing/app_routing.dart';
import '../../services/character_service.dart';
import '../../widgets/character_card.dart';

/// Main Explore character database screen connected to Rick and Morty API.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final CharacterService _characterService = CharacterService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<CharacterModel> _characters = [];
  Timer? _debounce;

  static const List<String> _statusFilters = [
    'All',
    'Alive',
    'Dead',
    'Unknown',
  ];

  String _selectedStatus = 'All';
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasNextPage = true;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadCharacters(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 320;
    if (_scrollController.position.pixels >= threshold) {
      if (!_isInitialLoading && !_isLoadingMore && _hasNextPage) {
        _loadCharacters(reset: false);
      }
    }
  }

  Future<void> _loadCharacters({required bool reset}) async {
    if (reset) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _hasNextPage = true;
      });
    } else {
      if (_isLoadingMore || !_hasNextPage) return;
      setState(() {
        _isLoadingMore = true;
      });
    }

    final targetPage = reset ? 1 : _currentPage + 1;

    try {
      final result = await _characterService.fetchCharacters(
        page: targetPage,
        name: _searchController.text,
        status: _selectedStatus,
      );

      if (!mounted) return;
      setState(() {
        if (reset) {
          _characters
            ..clear()
            ..addAll(result.characters);
        } else {
          _characters.addAll(result.characters);
        }
        _currentPage = result.currentPage;
        _totalCount = result.totalCount;
        _hasNextPage = result.hasNextPage;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (reset) {
        setState(() {
          _errorMessage = e.toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _loadCharacters(reset: true);
    });
  }

  void _onSelectStatus(String status) {
    if (_selectedStatus == status) return;
    setState(() => _selectedStatus = status);
    _loadCharacters(reset: true);
  }

  int _gridCountForWidth(double width) {
    if (width >= 1320) return 5;
    if (width >= 1020) return 4;
    if (width >= 680) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _gridCountForWidth(constraints.maxWidth);
          final horizontalPadding = constraints.maxWidth >= 860 ? 28.0 : 16.0;

          return RefreshIndicator(
            color: AppColors.primaryNeonGreen,
            backgroundColor: AppColors.surface,
            onRefresh: () => _loadCharacters(reset: true),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(textTheme),
                        const SizedBox(height: 18),
                        _buildSearchAndFilters(textTheme),
                      ],
                    ),
                  ),
                ),
                if (_isInitialLoading)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      24,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: CharacterGridSkeleton(
                        itemCount: crossAxisCount * 2,
                        crossAxisCount: crossAxisCount,
                      ),
                    ),
                  )
                else if (_errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: AppErrorWidget(
                        title: 'Multiverse Scanner Disrupted',
                        message: _errorMessage!,
                        onRetry: () => _loadCharacters(reset: true),
                      ),
                    ),
                  )
                else if (_characters.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: AppErrorWidget(
                        title: 'No Entities Detected',
                        message:
                            'No characters match your current dimension query or status filter.',
                        icon: Icons.travel_explore_rounded,
                        isEmptyState: true,
                        retryLabel: 'Reset Scanner',
                        onRetry: () {
                          _searchController.clear();
                          setState(() => _selectedStatus = 'All');
                          _loadCharacters(reset: true);
                        },
                      ),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      16,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.74,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final character = _characters[index];
                          return CharacterCard(
                            character: character,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.exploreDetail,
                                arguments: character,
                              );
                            },
                          ).animate().fadeIn(
                                duration: 280.ms,
                                delay: ((index % 8) * 25).ms,
                              );
                        },
                        childCount: _characters.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        8,
                        horizontalPadding,
                        32,
                      ),
                      child: Center(
                        child: _isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryNeonGreen,
                                  ),
                                ),
                              )
                            : _hasNextPage
                                ? AppButton(
                                    label: 'LOAD MORE ENTITIES',
                                    icon: Icons.expand_more_rounded,
                                    isFullWidth: false,
                                    variant: AppButtonVariant.secondary,
                                    onPressed: () =>
                                        _loadCharacters(reset: false),
                                  )
                                : Text(
                                    'End of scanned multiverse ($_totalCount entities)',
                                    style: textTheme.bodySmall,
                                  ),
                      ),
                    ),
                  ),
                ],
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
      runSpacing: 12,
      spacing: 12,
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
                    color: AppColors.primaryNeonGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'CITADEL CHARACTER DATABASE',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryNeonGreen,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Explore Multiverse',
              style: textTheme.headlineLarge,
            ),
          ],
        ),
        if (_totalCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.cyan.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.hub_outlined,
                  size: 16,
                  color: AppColors.cyan,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_totalCount Entities',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.mainText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSearchAndFilters(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onSubmitted: (_) => _loadCharacters(reset: true),
          style: textTheme.bodyLarge,
          cursorColor: AppColors.primaryNeonGreen,
          decoration: InputDecoration(
            hintText: 'Search character name (e.g. Rick, Morty, Birdperson)...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchController.clear();
                      _loadCharacters(reset: true);
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _statusFilters.map((status) {
              final selected = _selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(status),
                  selected: selected,
                  onSelected: (_) => _onSelectStatus(status),
                  backgroundColor: AppColors.surface,
                  selectedColor:
                      AppColors.primaryNeonGreen.withValues(alpha: 0.18),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primaryNeonGreen
                        : AppColors.borderSubtle,
                  ),
                  labelStyle: textTheme.bodySmall?.copyWith(
                    color: selected
                        ? AppColors.primaryNeonGreen
                        : AppColors.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
