import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/medicine_entity.dart';

abstract class MedicineRepository {
  Future<ApiResult<List<MedicineEntity>>> searchMedicines({
    String? query,
    required int page,
    required int pageSize,
  });
  Future<ApiResult<MedicineEntity>> getMedicineDetail(String id);
}
