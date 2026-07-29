/// A Notion-inspired, block-based rich text editor built entirely from
/// scratch in Flutter/Dart.
///
/// Phase 1 exports cover the pure-Dart document model and core engine.
/// Phase 2 adds the EditorSelection model for cross-block selection.
/// Phase 3 adds the plugin system, registry, and built-in block plugins.
/// Phase 4 adds the FormattingToolbar, SlashCommandMenu and BlockActionMenu.
library;

export 'src/model/inline_attributes.dart';
export 'src/model/delta_op.dart';
export 'src/model/text_delta.dart';
export 'src/model/block_node.dart';
export 'src/model/block_document.dart';
export 'src/controller/block_controller.dart';
export 'src/model/block_types.dart';
export 'src/model/editor_selection.dart';
export 'src/rendering/rich_text_renderer.dart';
export 'src/rendering/block_event.dart';
export 'src/rendering/block_widgets.dart';
export 'src/rendering/block_renderer.dart';
export 'src/rendering/block_cursor.dart';
export 'src/rendering/block_selection_overlay.dart';
export 'src/rendering/block_editor_widget.dart';
export 'src/editing/editor_editing_operations.dart';
export 'src/rendering/block_drag_handle.dart';
export 'src/rendering/block_editor_scope.dart';
export 'src/plugins/block_plugin.dart';
export 'src/plugins/slash_command_config.dart';
export 'src/plugins/toolbar_button_config.dart';
export 'src/plugins/block_registry.dart';
export 'src/plugins/built_in/built_in_block_plugins.dart';
export 'src/plugins/built_in/image_block_config.dart';
export 'src/plugins/built_in/video_block_config.dart';
export 'src/plugins/built_in/youtube_block_config.dart';
export 'src/plugins/built_in/file_block_config.dart';
export 'src/plugins/built_in/code_block_config.dart';
export 'src/plugins/built_in/callout_block_config.dart';
export 'src/plugins/built_in/link_block_config.dart';
export 'src/plugins/built_in/image_block.dart';
export 'src/plugins/built_in/video_block.dart';
export 'src/plugins/built_in/youtube_block.dart';
export 'src/plugins/built_in/file_block.dart';
export 'src/plugins/built_in/code_block.dart';
export 'src/plugins/built_in/callout_block.dart';
export 'src/plugins/built_in/link_block.dart';
export 'src/rendering/cursor_color_scope.dart';
export 'src/rendering/keyboard_shortcuts.dart';
export 'src/rendering/formatting_toolbar.dart';
export 'src/rendering/slash_command_menu.dart';
export 'src/rendering/block_action_menu.dart';
export 'src/export/block_document_exporter.dart';
export 'src/export/block_document_importer.dart';
export 'src/export/json_exporter.dart';
export 'src/export/json_importer.dart';
export 'src/export/plain_text_exporter.dart';
export 'src/export/markdown_exporter.dart';
export 'src/export/markdown_importer.dart';
export 'src/export//html_exporter.dart';
