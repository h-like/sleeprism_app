// lib/presentation/screens/sound_search_delegate.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sound_mixer_provider.dart';

class SoundSearchDelegate extends SearchDelegate {
  final SoundMixerProvider soundMixerProvider;

  SoundSearchDelegate(this.soundMixerProvider);

  @override
  String get searchFieldLabel => 'Freesound 검색 (예: rain, forest)';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // 검색어가 입력되면 즉시 검색 실행
    soundMixerProvider.searchFreesound(query);

    // 이제 Provider를 context에서 찾지 않고, 전달받은 인스턴스를 직접 사용합니다.
    // Consumer 대신 AnimatedBuilder를 사용하여 더 효율적으로 UI를 업데이트할 수 있습니다.
    return AnimatedBuilder(
      animation: soundMixerProvider,
      builder: (context, child) {
        if (soundMixerProvider.isSearching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (soundMixerProvider.searchError != null) {
          return Center(child: Text('오류: ${soundMixerProvider.searchError}'));
        }
        if (soundMixerProvider.searchResults.isEmpty) {
          return const Center(child: Text('검색 결과가 없습니다.'));
        }

        return ListView.builder(
          itemCount: soundMixerProvider.searchResults.length,
          itemBuilder: (context, index) {
            final sound = soundMixerProvider.searchResults[index];
            final bool isPlaying = soundMixerProvider.activeSounds.containsKey(sound.id);
            return ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(sound.name),
              trailing: IconButton(
                icon: Icon(
                  isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                  color: isPlaying ? Colors.red : Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  soundMixerProvider.togglePlay(sound);
                  // 검색창을 닫고 메인 화면으로 돌아가서 재생 상태 확인
                  close(context, null);
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 제안 기능은 비워둠
    return const Center(
      child: Text('검색어를 입력하고 엔터 키를 누르세요.'),
    );
  }
}
