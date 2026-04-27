/// A customizable multi-select widget for Flutter.
library;

import 'package:flutter/material.dart';

/// A multi-select input widget that displays selected items as deletable chips
/// and provides a live-search dropdown overlay for selecting more items.
///
/// [MultiSelect] is a controlled widget — the parent owns [selectedItems] and
/// receives updates via [onChanged]. It integrates seamlessly with Flutter's
/// [Form] / [FormField] system for validation.
///
/// **Basic usage:**
/// ```dart
/// MultiSelect(
///   items: const ['Apple', 'Banana', 'Cherry'],
///   selectedItems: _selectedFruits,
///   onChanged: (updated) => setState(() => _selectedFruits = updated),
///   label: 'Fruits',
///   hint: 'Search fruits…',
/// )
/// ```
class MultiSelect extends StatefulWidget {
  /// All available items to choose from.
  final List<String> items;

  /// The currently selected items.
  ///
  /// This widget is *controlled*: it does not maintain its own selection state.
  /// Provide the list from your parent widget and update it in [onChanged].
  final List<String> selectedItems;

  /// Called with the complete updated selection whenever an item is added or
  /// removed. The parent should call `setState` to refresh [selectedItems].
  final ValueChanged<List<String>>? onChanged;

  /// Optional label rendered above the input field.
  final String? label;

  /// Placeholder text shown inside the text field when it is empty.
  final String? hint;

  /// Validator for use inside a [Form].
  ///
  /// Receives the currently selected items joined by `', '`.
  /// Return `null` for valid input, or an error string to display below the
  /// widget.
  ///
  /// Example:
  /// ```dart
  /// validator: (value) {
  ///   if (value == null || value.isEmpty) return 'Please select at least one item';
  ///   return null;
  /// },
  /// ```
  final FormFieldValidator<String>? validator;

  /// Maximum number of items visible in the dropdown at one time.
  ///
  /// Defaults to `5`. Items beyond this limit require scrolling.
  final int maxDropdownItems;

  /// An optional external [TextEditingController] to observe or control the
  /// search text field.
  ///
  /// If not provided, an internal controller is created and managed
  /// automatically.
  final TextEditingController? controller;

  /// Optional decoration for the outer container box.
  ///
  /// When omitted, a rounded border using [ColorScheme.outline] (or
  /// [ColorScheme.error] on validation failure) is applied.
  final BoxDecoration? decoration;

  /// Creates a [MultiSelect] widget.
  const MultiSelect({
    super.key,
    required this.items,
    required this.selectedItems,
    this.onChanged,
    this.label,
    this.hint,
    this.validator,
    this.maxDropdownItems = 5,
    this.controller,
    this.decoration,
  });

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();

  late final TextEditingController _textController;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
  }

  // Items that match the search query and are not yet selected.
  List<String> get _filteredItems {
    final query = _textController.text.toLowerCase();
    return widget.items
        .where((item) => !widget.selectedItems.contains(item))
        .where(
          (item) => query.isEmpty || item.toLowerCase().contains(query),
        )
        .toList();
  }

  // ── Overlay management ─────────────────────────────────────────────────────

  void _showOverlay() {
    final filtered = _filteredItems;
    if (filtered.isEmpty) {
      _removeOverlay();
      return;
    }

    if (_overlayEntry != null) {
      // Already visible — just rebuild to reflect the new filter.
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(builder: (_) => _buildOverlayContent());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlayContent() {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final fieldWidth = renderBox.size.width;
    final filtered = _filteredItems;
    final visibleCount = filtered.length.clamp(1, widget.maxDropdownItems);
    const itemHeight = 48.0;

    return Stack(
      children: [
        // Transparent full-screen tap target to close the overlay.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeOverlay,
          ),
        ),
        Positioned(
          width: fieldWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, renderBox.size.height + 4),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: itemHeight * visibleCount,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final item = filtered[index];
                    return ListTile(
                      dense: true,
                      title: Text(item),
                      onTap: () => _addItem(item),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Selection logic ────────────────────────────────────────────────────────

  /// Adds [item] to the selection and clears the search field.
  void _addItem(String item) {
    widget.onChanged?.call([...widget.selectedItems, item]);
    _textController.clear();
    _removeOverlay();
  }

  /// Removes [item] from the selection.
  void _removeItem(String item) {
    widget.onChanged
        ?.call(widget.selectedItems.where((s) => s != item).toList());
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _removeOverlay();
    // Only dispose the controller if we created it ourselves.
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<String>(
      validator:
          widget.validator == null
              ? null
              : (_) => widget.validator!(widget.selectedItems.join(', ')),
      builder: (state) {
        final borderColor =
            state.hasError
                ? theme.colorScheme.error
                : theme.colorScheme.outline;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Optional label
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  widget.label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            // Input container
            Container(
              decoration:
                  widget.decoration ??
                  BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Chips for currently selected items
                  if (widget.selectedItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildChips(),
                    ),

                  // Search text field anchored to the overlay
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextFormField(
                      key: _fieldKey,
                      controller: _textController,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: widget.hint,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: _showOverlay,
                      onChanged: (_) => _showOverlay(),
                    ),
                  ),
                ],
              ),
            ),

            // Validation error text
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  state.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children:
          widget.selectedItems.map((item) {
            return Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(item),
              onDeleted: () => _removeItem(item),
            );
          }).toList(),
    );
  }
}
