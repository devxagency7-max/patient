import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/nearby_pharmacy_entity.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_branch_entity.dart';
import 'package:pharmacare/features/pharmacy/domain/entities/pharmacy_entity.dart';

abstract class PharmacyRepository {
  Future<ApiResult<List<String>>> getGovernorates();

  Future<ApiResult<List<PharmacyEntity>>> getPharmacies({
    String? governorate,
    required int page,
    required int pageSize,
  });

  Future<ApiResult<PharmacyEntity>> getPharmacyDetail(String id);

  Future<ApiResult<List<PharmacyBranchEntity>>> getPharmacyBranches(String pharmacyId);

  Future<ApiResult<List<NearbyPharmacyEntity>>> getNearbyPharmacies({
    required double lat,
    required double lng,
    double radius,
  });
}
