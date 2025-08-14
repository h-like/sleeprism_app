import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:provider/provider.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../../data/models/post_category.dart';
import '../providers/post_provider.dart';

/// 새 게시글을 작성하거나 기존 게시글을 수정하는 화면
class PostEditScreen extends StatefulWidget {
  const PostEditScreen({
    super.key,
    this.initialHtml, // 기존 글 수정 시 들어오는 HTML
    this.postId,
    this.initialTitle,
    this.initialCategory,
  });

  final String? initialHtml;
  final int? postId;
  final String? initialTitle;
  final PostCategory? initialCategory;

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  late final QuillController _controller;
  final _titleCtrl = TextEditingController();
  late PostCategory _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.initialTitle ?? '';
    _selectedCategory = widget.initialCategory ?? PostCategory.values.first;

    if ((widget.initialHtml ?? '').trim().isNotEmpty) {
      final ops = HtmlToDelta().convert(widget.initialHtml!);
      _controller = QuillController(
        document: Document.fromJson(ops.toJson()),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final deltaJson = _controller.document.toDelta().toJson();
    final html = QuillDeltaToHtmlConverter(deltaJson).convert();
    final provider = context.read<PostProvider>();

    try {
      if (widget.postId != null) {
        // 기존 게시글 수정
        await provider.updatePost (
          id: widget.postId.toString(),
          title: _titleCtrl.text.trim(),
          contentHtml: html,
          category: _selectedCategory,
        );
        // TODO: 수정 완료 후 상세 페이지로 돌아가는 로직 추가
      } else {
        // 새 게시글 저장
        await provider.createPost(
          title: _titleCtrl.text.trim(),
          content: html,
          category: _selectedCategory,
        );
        // TODO: 작성 완료 후 목록 페이지로 돌아가는 로직 추가
      }
      // 저장 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 성공적으로 저장되었습니다.')),
      );
      // 저장 성공 후 화면 닫기
      Navigator.of(context).pop();
    } catch (e) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postId == null ? '글쓰기' : '글 수정'),
        actions: [
          // 포스팅/저장 버튼
          _isSaving
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.send),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 카테고리 드롭다운
            _buildCategoryDropdown(),
            // 제목 입력 필드
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // QuillEditor
            Expanded(
              child: QuillEditor.basic(
                controller: _controller,
                config: QuillEditorConfig(
                  padding: EdgeInsets.zero,
                  autoFocus: true,
                  checkBoxReadOnly: false,
                ),
              ),
            ),
            // 툴바는 위젯 상단에 위치
            QuillSimpleToolbar(
              controller: _controller,
              config: const QuillSimpleToolbarConfig(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButton<PostCategory>(
      value: _selectedCategory,
      underline: const SizedBox(),
      onChanged: (PostCategory? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
        }
      },
      items: PostCategory.values.map<DropdownMenuItem<PostCategory>>(
            (PostCategory category) {
          return DropdownMenuItem<PostCategory>(
            value: category,
            child: Text(category.displayName),
          );
        },
      ).toList(),
    );
  }
}
