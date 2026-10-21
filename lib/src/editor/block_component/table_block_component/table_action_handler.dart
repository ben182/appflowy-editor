import 'dart:math' as math;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_menu.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';

class TableActionHandler extends StatefulWidget {
  const TableActionHandler({
    super.key,
    this.visible = false,
    this.height,
    required this.node,
    required this.editorState,
    required this.position,
    required this.alignment,
    required this.transform,
    required this.dir,
    this.menuBuilder,
  });

  final bool visible;
  final Node node;
  final EditorState editorState;
  final int position;
  final Alignment alignment;
  final Matrix4 transform;
  final double? height;
  final TableDirection dir;

  final TableBlockComponentMenuBuilder? menuBuilder;

  @override
  State<TableActionHandler> createState() => _TableActionHandlerState();
}

class _TableActionHandlerState extends State<TableActionHandler> {
  bool _visible = false;
  bool _menuShown = false;

  // Touch: kein Überfahren. Der Griff zeigt sich an der Zeile bzw. Spalte
  // mit dem Cursor.
  bool _hasCursor = false;

  @override
  void initState() {
    super.initState();
    if (PlatformExtension.isMobile) {
      widget.editorState.selectionNotifier.addListener(_onSelection);
      _hasCursor = _cursorHere();
    }
  }

  @override
  void dispose() {
    widget.editorState.selectionNotifier.removeListener(_onSelection);
    super.dispose();
  }

  void _onSelection() {
    final here = _cursorHere();
    if (here != _hasCursor && mounted) setState(() => _hasCursor = here);
  }

  bool _cursorHere() {
    final selection = widget.editorState.selection;
    if (selection == null) return false;
    final table = widget.node.path;
    final at = selection.start.path;
    if (at.length <= table.length || !at.sublist(0, table.length).equals(table)) {
      return false;
    }
    final cell = widget.editorState.getNodeAtPath([...table, at[table.length]]);
    final key = widget.dir == TableDirection.col
        ? TableCellBlockKeys.colPosition
        : TableCellBlockKeys.rowPosition;
    return cell?.attributes[key] == widget.position;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.alignment,
      transform: widget.transform,
      height: widget.height,
      child: Visibility(
        visible:
            (widget.visible || _visible || _menuShown || _hasCursor) &&
            widget.editorState.editable,
        child: MouseRegion(
          onEnter: (_) => setState(() => _visible = true),
          onExit: (_) => setState(() => _visible = false),
          child: widget.menuBuilder != null
              ? widget.menuBuilder!(
                  widget.node,
                  widget.editorState,
                  widget.position,
                  widget.dir,
                  () => _menuShown = true,
                  () => setState(() => _menuShown = false),
                )
              : defaultMenuBuilder(
                  context,
                  widget.node,
                  widget.editorState,
                  widget.position,
                  widget.dir,
                ),
        ),
      ),
    );
  }
}

Widget defaultMenuBuilder(
  BuildContext context,
  Node node,
  EditorState editorState,
  int position,
  TableDirection dir,
) {
  return Card(
    elevation: 3.0,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showActionMenu(context, node, editorState, position, dir),
        child: dir == TableDirection.col
            ? Transform.rotate(
                angle: math.pi / 2,
                child: TableDefaults.handlerIcon,
              )
            : TableDefaults.handlerIcon,
      ),
    ),
  );
}
