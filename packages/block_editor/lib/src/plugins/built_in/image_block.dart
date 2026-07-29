library;

import 'package:flutter/material.dart';
import 'package:block_editor/block_editor.dart';

/// A [BlockPlugin] for [BlockTypes.image].
///
/// Supports three source variants stored in [BlockNode.attributes]:
/// - `source: 'network'` — renders a network image from `attributes['url']`.
/// - `source: 'local'` — renders a local file image from `attributes['path']`.
/// - `source: 'upload_pending'` — shows a loading indicator while the host
///   app performs an upload.
///
/// When no URL is present and the editor is not in read-only mode, a
/// placeholder input UI is shown with two tabs:
/// - **URL tab** — a text field and confirm button. Confirming calls
///   `controller.updateAttributes` with `{'url': value, 'source': 'network'}`.
/// - **File tab** — a button that fires a [CustomBlockEvent] with
///   `eventType: 'image_file_pick_requested'`. The host app opens a file
///   picker and calls `controller.updateAttributes` with the result.
///
/// In read-only mode, an empty image block renders as a neutral placeholder
/// with no interactive elements.
///
/// The consuming app must call `WidgetsFlutterBinding.ensureInitialized()`
/// before using any image functionality that depends on platform plugins.
///
/// Configuration is read from [ImageBlockConfig] via [BlockEditorScope].
final class ImageBlock extends BlockPlugin {
  /// Creates an [ImageBlock].
  ImageBlock();

  @override
  String get blockType => BlockTypes.image;

  @override
  Widget build(
    BlockNode node,
    EditorSelection selection,
    void Function(BlockEvent) onEvent,
  ) {
    return _ImageBlockWidget(node: node, onEvent: onEvent);
  }

  @override
  Map<String, dynamic> serialize(BlockNode node) => node.toJson();

  @override
  BlockNode deserialize(Map<String, dynamic> json) => BlockNode.fromJson(json);

  @override
  SlashCommandConfig slashCommandItem() => SlashCommandConfig(
    label: 'Image',
    group: 'Media',
    icon: const Icon(Icons.image_outlined),
    onSelected: () {},
  );

  @override
  String slashCommandGroup() => 'Media';

  @override
  String? exportAsPlainText(BlockNode node) {
    final url = node.attributes['url'] as String?;
    if (url != null && url.isNotEmpty) return '[Image: $url]';
    return '[Image]';
  }

  @override
  String? exportAsMarkdown(BlockNode node) {
    final url = node.attributes['url'] as String? ?? '';
    final alt = node.attributes['alt'] as String? ?? 'image';
    if (url.isEmpty) return null;
    return '![$alt]($url)';
  }

  @override
  String? exportAsHtml(BlockNode node) {
    final url = node.attributes['url'] as String? ?? '';
    final alt = node.attributes['alt'] as String? ?? '';
    if (url.isEmpty) return null;
    return '<img src="$url" alt="$alt">';
  }
}

class _ImageBlockWidget extends StatelessWidget {
  const _ImageBlockWidget({required this.node, required this.onEvent});

  final BlockNode node;
  final void Function(BlockEvent) onEvent;

  static const double _defaultHeight = 200.0;
  static const Color _defaultBackground = Color(0xFFF5F5F5);

  bool get _hasUrl {
    final url = node.attributes['url'] as String?;
    return url != null && url.isNotEmpty;
  }

  bool get _isPending {
    final source = node.attributes['source'] as String?;
    return source == 'upload_pending';
  }

  @override
  Widget build(BuildContext context) {
    final config = BlockEditorScope.maybeOf(context)?.imageConfig;
    final readOnly = BlockEditorScope.maybeOf(context)?.readOnly ?? false;
    final fit = config?.fit ?? BoxFit.contain;
    final scale = config?.scale ?? 1.0;
    final borderRadius = config?.borderRadius ?? BorderRadius.zero;

    if (_isPending) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: config?.onLoading?.call(context) ?? _loadingWidget(),
      );
    }

    if (!_hasUrl) {
      if (readOnly) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: _readOnlyPlaceholder(),
        );
      }
      return ClipRRect(
        borderRadius: borderRadius,
        child: _InputPlaceholder(node: node, onEvent: onEvent, config: config),
      );
    }

    final source = node.attributes['source'] as String? ?? 'network';

    return ClipRRect(
      borderRadius: borderRadius,
      child: Transform.scale(
        scale: scale,
        child: _buildRendered(context, source, fit, config),
      ),
    );
  }

  Widget _buildRendered(
    BuildContext context,
    String source,
    BoxFit fit,
    ImageBlockConfig? config,
  ) {
    if (source == 'local') {
      final path = node.attributes['path'] as String? ?? '';
      if (path.isEmpty) return _errorWidget();
      onEvent(
        CustomBlockEvent(
          blockId: node.id,
          eventType: 'image_upload_requested',
          payload: path,
        ),
      );
      return config?.onLoading?.call(context) ?? _loadingWidget();
    }

    final url = node.attributes['url'] as String? ?? '';
    if (url.isEmpty) return _errorWidget();

    return Image.network(
      url,
      fit: fit,
      height: _defaultHeight,
      errorBuilder: (ctx, error, _) =>
          config?.onError?.call(ctx, error) ?? _errorWidget(),
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return config?.onLoading?.call(ctx) ?? _loadingWidget();
      },
    );
  }

  Widget _readOnlyPlaceholder() {
    return Container(
      height: _defaultHeight,
      color: _defaultBackground,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: Color(0xFFBDBDBD)),
      ),
    );
  }

  Widget _loadingWidget() {
    return Container(
      height: _defaultHeight,
      color: _defaultBackground,
      child: const Center(child: Text('Loading…')),
    );
  }

  Widget _errorWidget() {
    return Container(
      height: _defaultHeight,
      color: _defaultBackground,
      child: const Center(child: Text('Failed to load image')),
    );
  }
}

class _InputPlaceholder extends StatefulWidget {
  const _InputPlaceholder({
    required this.node,
    required this.onEvent,
    required this.config,
  });

  final BlockNode node;
  final void Function(BlockEvent) onEvent;
  final ImageBlockConfig? config;

  @override
  State<_InputPlaceholder> createState() => _InputPlaceholderState();
}

class _InputPlaceholderState extends State<_InputPlaceholder>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _urlController;
  bool _urlError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _confirmUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _urlError = true);
      return;
    }
    setState(() => _urlError = false);
    widget.onEvent(
      CustomBlockEvent(
        blockId: widget.node.id,
        eventType: 'image_url_confirmed',
        payload: {'url': url, 'source': 'network'},
      ),
    );
  }

  void _pickFile() {
    widget.onEvent(
      CustomBlockEvent(
        blockId: widget.node.id,
        eventType: 'image_file_pick_requested',
        payload: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF333333),
            unselectedLabelColor: const Color(0xFF999999),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'URL'),
              Tab(text: 'Upload'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UrlTab(
                  controller: _urlController,
                  hasError: _urlError,
                  onConfirm: _confirmUrl,
                ),
                _FileTab(onPick: _pickFile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UrlTab extends StatelessWidget {
  const _UrlTab({
    required this.controller,
    required this.hasError,
    required this.onConfirm,
  });

  final TextEditingController controller;
  final bool hasError;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Paste image URL…',
                errorText: hasError ? 'URL cannot be empty' : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => onConfirm(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: onConfirm, child: const Text('Embed')),
        ],
      ),
    );
  }
}

class _FileTab extends StatelessWidget {
  const _FileTab({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.upload_file),
        label: const Text('Choose image file'),
      ),
    );
  }
}
