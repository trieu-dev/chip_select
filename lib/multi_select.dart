library;
import 'package:flutter/material.dart';

class MultiSelect extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<String>? onSelected;
  
  const MultiSelect({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    required this.items,
    required this.selectedItems,
    this.onSelected,
  });

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _fieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  void _showOverlay(List<String> items) {
    if (_overlayEntry != null) return;

    final renderBox =
        _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    int count = items.length;
    if (count > 8) {
      count = 8;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
            ),
          ),
          
          Positioned(
            width: size.width,
            height: size.height * count,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: size.height * count,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: items.map((item) {
                      return ListTile(
                        title: Text(item),
                        onTap: () {
                          widget.onSelected?.call(item);
                          _removeOverlay();
                        },
                      );
                    }).toList(),
                  )
                )
              )
            )
          )
        ]
      )
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        _buildSelectedItems(),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            key: _fieldKey,
            controller: _controller,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            onTap: () => _showOverlay(widget.items),
            onChanged: (value) {
              var list = widget.items
                  .where((item) =>
                      item.toLowerCase().contains(value.toLowerCase()))
                  .toList();
              _removeOverlay();
              _showOverlay(list);
            },
          )
        )
      ]),
    );
  }

  Widget _buildSelectedItems() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.selectedItems.map((item) {
        return Chip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: Text(item),
          onDeleted: () {
            widget.onSelected?.call(item);
            setState(() {});
          },
        );
      }).toList(),
    );
  }
}

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
