import 'package:pharmacare/features/pharmacy/data/models/nearby_pharmacy_model.dart';
import 'package:pharmacare/features/pharmacy/data/models/pharmacy_branch_model.dart';
import 'package:pharmacare/features/pharmacy/data/models/pharmacy_model.dart';

abstract class PharmacyRemoteDataSource {
  Future<List<String>> getGovernorates();

  Future<List<PharmacyModel>> getPharmacies({
    String? governorate,
    required int page,
    required int pageSize,
  });

  Future<PharmacyModel> getPharmacyDetail(String id);

  Future<List<PharmacyBranchModel>> getPharmacyBranches(String pharmacyId);

  Future<List<NearbyPharmacyModel>> getNearbyPharmacies({
    required double lat,
    required double lng,
    double radius,
  });
}
