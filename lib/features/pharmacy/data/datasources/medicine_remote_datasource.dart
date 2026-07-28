import 'package:pharmacare/features/pharmacy/data/models/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<List<MedicineModel>> searchMedicines({
    String? query,
    required int page,
    required int pageSize,
  });
  Future<MedicineModel> getMedicineDetail(String id);
}
