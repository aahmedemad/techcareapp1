import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SugarMeasurementCubit extends HydratedCubit<String> {
  SugarMeasurementCubit() : super("");  // قيمة البداية (فارغة)

  void setFirstMeasurement(String value) {
    emit(value);  // تحديث الحالة
  }

  @override
  String? fromJson(Map<String, dynamic> json) {
    return json['firstMeasurement'] as String?;  // تحويل JSON إلى حالة
  }

  @override
  Map<String, dynamic>? toJson(String state) {
    return {'firstMeasurement': state};  // تحويل الحالة إلى JSON
  }
}