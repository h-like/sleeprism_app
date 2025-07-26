import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../../data/models/post_category.dart';
import '../providers/post_provider.dart';

/// 새 게시글을 작성하거나 기존 게시글을 수정하는 화면
class PostEditScreen extends StatefulWidget {
  const PostEditScreen({super.key});

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final _titleController = TextEditingController();
  final _quillController = QuillController.basic();
  PostCategory _selectedCategory = PostCategory.DREAM_DIARY;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  /// 게시글 저장 로직
  Future<void> _savePost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    if (_quillController.document.isEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final deltaJson = _quillController.document.toDelta().toJson();
      final converter = QuillDeltaToHtmlConverter(deltaJson);
      final htmlContent = converter.convert();

      // [수정 필요] PostProvider에 아래와 같은 시그니처의 createPost 메소드를 구현해야 합니다.
      await Provider.of<PostProvider>(context, listen: false).createPost(
        title: _titleController.text,
        content: htmlContent,
        category: _selectedCategory,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 성공적으로 등록되었습니다.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              onPressed: _savePost,
              tooltip: '저장',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '제목',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<PostCategory>(
                  value: _selectedCategory,
                  items: PostCategory.values
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.displayName),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          // [수정됨] flutter_quill 최신 버전에 맞게 QuillToolbar 위젯 사용
          // QuillEditor(
          //   configurations: QuillToolbarConfigurations(
          //     controller: _quillController,
          //     showAlignmentButtons: true,
          //     // TODO: 이미지 업로드 핸들러 추가
          //   ),
          // ),
          const Divider(height: 1, thickness: 1),
          // [수정됨] flutter_quill 최신 버전에 맞게 QuillEditor 위젯과 configurations 사용
          // Expanded(
            // child: QuillEditor(
            //   configurations    A: QuillEditorConfigurations(
            //     controller: _quillController,
            //     readOnly: false, // readOnly는 configurations 안으로 이동
            //     padding: const EdgeInsets.all(16), // padding은 configurations 안으로 이동
            //   ),
            // ),
          // )
        ],
      ),
    );
  }
}
