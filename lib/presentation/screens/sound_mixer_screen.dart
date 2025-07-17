// lib/presentation/screens/sound_mixer_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sound_mixer_provider.dart';
import '../../data/models/sound_mixer_models.dart';
import 'sound_search_delegate.dart';

/// SoundMixerProvider를 생성하고 실제 UI 위젯(_SoundMixerScreenView)에 제공하는 역할을 합니다.
/// 이 구조는 Provider의 생명주기를 화면과 일치시켜 상태 유실 및 context 관련 에러를 방지합니다.
class SoundMixerScreen extends StatelessWidget {
  const SoundMixerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SoundMixerProvider()..loadInitialData(),
      child: const _SoundMixerScreenView(),
    );
  }
}

/// 실제 사운드 믹서의 UI를 구성하고 사용자 상호작용을 처리하는 위젯입니다.
class _SoundMixerScreenView extends StatelessWidget {
  const _SoundMixerScreenView();

  void _searchFreesound(BuildContext context) {
    // 검색창을 열 때, 현재 Provider의 인스턴스를 전달합니다.
    showSearch(
      context: context,
      // SoundSearchDelegate에 현재 Provider를 전달하여 context 문제를 해결합니다.
      delegate: SoundSearchDelegate(
        Provider.of<SoundMixerProvider>(context, listen: false),
      ),
    );
  }

  Future<void> _showSaveMixDialog(BuildContext context) async {
    final provider = Provider.of<SoundMixerProvider>(context, listen: false);
    if (provider.activeSounds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장할 사운드가 없습니다.')),
      );
      return;
    }

    final nameController = TextEditingController();
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('믹스를 저장하려면 로그인이 필요합니다.')),
      );
      return;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('나의 믹스 저장'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "믹스 이름 입력 (예: 비 오는 날)"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  provider.saveCurrentMix(nameController.text, token).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('믹스가 저장되었습니다!')),
                    );
                  }).catchError((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('저장에 실패했습니다.')),
                    );
                  });
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SoundMixerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // 밝은 회색 배경
      appBar: AppBar(
        title: const Text('사운드 믹서', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF4F6F8),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            tooltip: 'Freesound 검색',
            onPressed: () => _searchFreesound(context),
          ),
          IconButton(
            icon: const Icon(Icons.save_alt_outlined, color: Colors.black54),
            tooltip: '현재 믹스 저장',
            onPressed: () => _showSaveMixDialog(context),
          ),
        ],
      ),
      body: (provider.isLoading && provider.internalSounds.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSectionCard(
                title: '사운드 선택',
                child: _buildSoundSelectionPanel(provider),
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: '현재 믹서',
                child: _buildActiveMixerPanel(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSoundSelectionPanel(SoundMixerProvider provider) {
    if (provider.internalSounds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('사운드를 불러오지 못했습니다.', style: TextStyle(color: Colors.grey))),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: provider.internalSounds.map((sound) {
        final bool isPlaying = provider.activeSounds.containsKey(sound.id);
        return _SoundSelectionItem(
          sound: sound,
          isPlaying: isPlaying,
          onTap: () => provider.togglePlay(sound),
        );
      }).toList(),
    );
  }

  Widget _buildActiveMixerPanel(SoundMixerProvider provider) {
    final activeSounds = provider.activeSounds.values.toList();
    if (activeSounds.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text('위에서 사운드를 선택하여 믹스를 시작하세요.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeSounds.length,
      itemBuilder: (context, index) {
        final activeSound = activeSounds[index];
        return _ActiveMixerItem(
          activeSound: activeSound,
          onVolumeChanged: (volume) => provider.changeVolume(activeSound.soundInfo.id, volume),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF4F6F8)),
    );
  }
}

class _SoundSelectionItem extends StatelessWidget {
  final SoundInfo sound;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SoundSelectionItem({required this.sound, required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPlaying ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sound.icon ?? '🎵', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(sound.name.split(' ').first, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _ActiveMixerItem extends StatelessWidget {
  final ActiveSound activeSound;
  final ValueChanged<double> onVolumeChanged;

  const _ActiveMixerItem({required this.activeSound, required this.onVolumeChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(activeSound.soundInfo.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.grey),
            Expanded(
              child: Slider(
                value: activeSound.volume,
                onChanged: onVolumeChanged,
                activeColor: Colors.blue,
                inactiveColor: Colors.blue.withOpacity(0.2),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text('${(activeSound.volume * 100).toInt()}%', textAlign: TextAlign.right),
            ),
          ],
        ),
      ],
    );
  }
}
