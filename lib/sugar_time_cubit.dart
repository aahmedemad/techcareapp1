import 'package:hydrated_bloc/hydrated_bloc.dart';

class SugarTimeCubit extends HydratedCubit<Map<String, String>> {
  SugarTimeCubit() : super({'first': '', 'second': ''});

  void updateFirst(String newTime) => emit({'first': newTime, 'second': state['second'] ?? ''});
  void updateSecond(String newTime) => emit({'first': state['first'] ?? '', 'second': newTime});

  @override
  Map<String, String>? fromJson(Map<String, dynamic> json) {
    if (json['first'] != null && json['second'] != null) {
      return {'first': json['first'], 'second': json['second']};
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(Map<String, String> state) {
    return {'first': state['first'], 'second': state['second']};
  }
}