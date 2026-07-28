import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/core/services/local_notifications_service.dart';
import 'package:pharmacare/core/services/care_request_cache_service.dart';
import 'package:pharmacare/core/services/secure_storage_service.dart';
import 'package:pharmacare/features/devices/data/datasources/device_remote_datasource.dart';
import 'package:pharmacare/features/devices/data/datasources/device_remote_datasource_impl.dart';
import 'package:pharmacare/features/devices/data/services/chat_push_handler.dart';
import 'package:pharmacare/features/devices/data/services/device_push_service.dart';
import 'package:pharmacare/features/telemetry/data/datasources/telemetry_remote_datasource.dart';
import 'package:pharmacare/features/telemetry/data/datasources/telemetry_remote_datasource_impl.dart';
import 'package:pharmacare/features/telemetry/data/services/telemetry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmacare/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacare/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:pharmacare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';
import 'package:pharmacare/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/login_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/register_usecase.dart';
import 'package:pharmacare/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pharmacare/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:pharmacare/features/profile/data/datasources/profile_remote_datasource_impl.dart';
import 'package:pharmacare/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:pharmacare/features/profile/domain/repositories/profile_repository.dart';
import 'package:pharmacare/features/profile/domain/usecases/complete_profile_usecase.dart';
import 'package:pharmacare/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:pharmacare/features/home/presentation/controllers/home_controller.dart';
import 'package:pharmacare/features/file_upload/data/datasources/file_remote_datasource.dart';
import 'package:pharmacare/features/file_upload/data/repositories/file_repository_impl.dart';
import 'package:pharmacare/features/file_upload/domain/repositories/file_repository.dart';
import 'package:pharmacare/features/file_upload/domain/usecases/upload_file_usecase.dart';
import 'package:pharmacare/features/file_upload/presentation/cubit/file_upload_cubit.dart';
import 'package:pharmacare/features/prescription/data/datasources/prescription_remote_datasource.dart';
import 'package:pharmacare/features/prescription/data/datasources/prescription_remote_datasource_impl.dart';
import 'package:pharmacare/features/prescription/data/repositories/prescription_repository_impl.dart';
import 'package:pharmacare/features/prescription/domain/repositories/prescription_repository.dart';
import 'package:pharmacare/features/prescription/domain/usecases/create_prescription_usecase.dart';
import 'package:pharmacare/features/prescription/presentation/cubit/prescription_cubit.dart';
import 'package:pharmacare/features/prescription/presentation/cubit/my_prescriptions_cubit.dart';
import 'package:pharmacare/features/health_readings/data/datasources/health_remote_datasource.dart';
import 'package:pharmacare/features/health_readings/data/repositories/health_repository_impl.dart';
import 'package:pharmacare/features/health_readings/domain/repositories/health_repository.dart';
import 'package:pharmacare/features/health_readings/domain/usecases/health_usecases.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_cubit.dart';
import 'package:pharmacare/features/profile/data/datasources/address_remote_datasource.dart';
import 'package:pharmacare/features/profile/data/datasources/address_remote_datasource_impl.dart';
import 'package:pharmacare/features/profile/data/repositories/address_repository_impl.dart';
import 'package:pharmacare/features/profile/domain/repositories/address_repository.dart';
import 'package:pharmacare/features/profile/presentation/cubit/address_cubit.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/medicine_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/medicine_remote_datasource_impl.dart';
import 'package:pharmacare/features/pharmacy/data/repositories/medicine_repository_impl.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/medicine_repository.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/medicine_search_cubit.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/order_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/order_remote_datasource_impl.dart';
import 'package:pharmacare/features/pharmacy/data/repositories/order_repository_impl.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/order_repository.dart';
import 'package:pharmacare/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:pharmacare/features/notifications/data/datasources/notification_remote_datasource_impl.dart';
import 'package:pharmacare/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:pharmacare/features/notifications/domain/repositories/notification_repository.dart';
import 'package:pharmacare/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:pharmacare/features/medical_records/data/datasources/medical_record_remote_datasource.dart';
import 'package:pharmacare/features/medical_records/data/datasources/medical_record_remote_datasource_impl.dart';
import 'package:pharmacare/features/medical_records/data/repositories/medical_record_repository_impl.dart';
import 'package:pharmacare/features/medical_records/domain/repositories/medical_record_repository.dart';
import 'package:pharmacare/features/medical_records/presentation/cubit/medical_record_cubit.dart';
import 'package:pharmacare/features/patient_conditions/data/datasources/patient_condition_remote_datasource.dart';
import 'package:pharmacare/features/patient_conditions/data/datasources/patient_condition_remote_datasource_impl.dart';
import 'package:pharmacare/features/patient_conditions/data/repositories/patient_condition_repository_impl.dart';
import 'package:pharmacare/features/patient_conditions/domain/repositories/patient_condition_repository.dart';
import 'package:pharmacare/features/patient_conditions/presentation/cubit/patient_condition_cubit.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/order_cubit.dart';
import 'package:pharmacare/features/ratings/data/datasources/rating_remote_datasource.dart';
import 'package:pharmacare/features/ratings/data/datasources/rating_remote_datasource_impl.dart';
import 'package:pharmacare/features/ratings/data/repositories/rating_repository_impl.dart';
import 'package:pharmacare/features/ratings/domain/repositories/rating_repository.dart';
import 'package:pharmacare/features/ratings/presentation/cubit/rating_cubit.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/pharmacy_remote_datasource.dart';
import 'package:pharmacare/features/pharmacy/data/datasources/pharmacy_remote_datasource_impl.dart';
import 'package:pharmacare/features/pharmacy/data/repositories/pharmacy_repository_impl.dart';
import 'package:pharmacare/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:pharmacare/features/pharmacy/presentation/cubit/pharmacy_cubit.dart';
import 'package:pharmacare/features/reminders/data/datasources/reminders_remote_datasource.dart';
import 'package:pharmacare/features/reminders/data/datasources/reminders_remote_datasource_impl.dart';
import 'package:pharmacare/features/reminders/data/repositories/reminders_repository_impl.dart';
import 'package:pharmacare/features/reminders/domain/repositories/reminders_repository.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/reminders_cubit.dart';
import 'package:pharmacare/features/reminders/presentation/cubit/adherence_cubit.dart';
import 'package:pharmacare/features/pharmacist/data/datasources/pharmacist_remote_datasource.dart';
import 'package:pharmacare/features/pharmacist/data/datasources/pharmacist_remote_datasource_impl.dart';
import 'package:pharmacare/features/pharmacist/data/repositories/pharmacist_repository_impl.dart';
import 'package:pharmacare/features/pharmacist/domain/repositories/pharmacist_repository.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/pharmacist_cubit.dart';
import 'package:pharmacare/features/pharmacist/presentation/cubit/my_requests_cubit.dart';
import 'package:pharmacare/features/chat/data/services/chat_signalr_service.dart';
import 'package:pharmacare/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:pharmacare/features/chat/data/datasources/chat_remote_datasource_impl.dart';
import 'package:pharmacare/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:pharmacare/features/chat/domain/repositories/chat_repository.dart';
import 'package:pharmacare/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:pharmacare/features/home/data/datasources/health_insight_remote_datasource.dart';
import 'package:pharmacare/features/home/data/datasources/health_insight_remote_datasource_impl.dart';
import 'package:pharmacare/features/home/data/repositories/health_insight_repository_impl.dart';
import 'package:pharmacare/features/home/domain/repositories/health_insight_repository.dart';
import 'package:pharmacare/features/home/presentation/cubit/health_insight_cubit.dart';

final sl = GetIt.instance; // sl: Service Locator
final getIt = sl;

Future<void> initDi() async {
  // ==========================================
  // Features - Auth
  // ==========================================

  // Bloc / Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getProfileUseCase: sl(),
      googleSignInUseCase: sl(),
    ),
  );

  // Singleton: ChatPushHandler needs to switch tabs on the same instance
  // main.dart's BlocProvider hands to CustomNavBar/MainShellScreen — a
  // factory would give each caller its own isolated NavigationCubit and the
  // push-driven tab switch would silently do nothing to the visible UI.
  sl.registerLazySingleton(() => NavigationCubit());

  // ==========================================
  // Features - Profile
  // ==========================================

  // Bloc / Cubit
  sl.registerFactory(() => ProfileCubit(completeProfileUseCase: sl()));

  // Use Cases
  sl.registerLazySingleton(() => CompleteProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  // Address
  sl.registerFactory(() => AddressCubit(addressRepository: sl()));
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(apiClient: sl()),
  );

  // Pharmacy / Medicine
  sl.registerFactory(() => MedicineSearchCubit(medicineRepository: sl()));
  sl.registerLazySingleton<MedicineRepository>(
    () => MedicineRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MedicineRemoteDataSource>(
    () => MedicineRemoteDataSourceImpl(apiClient: sl()),
  );

  // Pharmacy / Order
  sl.registerFactory(() => OrderCubit(orderRepository: sl()));
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(apiClient: sl()),
  );

  // Pharmacy / Discovery
  sl.registerFactory(() => PharmacyCubit(pharmacyRepository: sl()));
  sl.registerLazySingleton<PharmacyRepository>(
    () => PharmacyRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PharmacyRemoteDataSource>(
    () => PharmacyRemoteDataSourceImpl(apiClient: sl()),
  );

  // Notifications
  sl.registerFactory(() => NotificationCubit(notificationRepository: sl()));
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl()),
  );

  // Devices (push token registration)
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<DevicePushService>(
    () => DevicePushService(remoteDataSource: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton(() => LocalNotificationsService());
  // Shared with MaterialApp(navigatorKey: ...) in main.dart so push
  // notification deep-links can navigate without a BuildContext of their own.
  sl.registerLazySingleton(() => GlobalKey<NavigatorState>());
  sl.registerLazySingleton(() => ChatPushHandler(sl(), sl(), sl()));

  // Telemetry (engagement heartbeat)
  sl.registerLazySingleton<TelemetryRemoteDataSource>(
    () => TelemetryRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TelemetryService>(
    () => TelemetryService(remoteDataSource: sl()),
  );

  // Ratings
  sl.registerFactory(() => RatingCubit(ratingRepository: sl()));
  sl.registerLazySingleton<RatingRepository>(
    () => RatingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RatingRemoteDataSource>(
    () => RatingRemoteDataSourceImpl(apiClient: sl()),
  );

  // Reminders
  sl.registerFactory(() => RemindersCubit(remindersRepository: sl()));
  sl.registerFactory(() => AdherenceCubit(remindersRepository: sl()));
  sl.registerLazySingleton<RemindersRepository>(
    () => RemindersRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RemindersRemoteDataSource>(
    () => RemindersRemoteDataSourceImpl(apiClient: sl()),
  );

  // Medical Records
  sl.registerFactory(
    () =>
        MedicalRecordCubit(medicalRecordRepository: sl(), fileRepository: sl()),
  );
  sl.registerLazySingleton<MedicalRecordRepository>(
    () => MedicalRecordRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MedicalRecordRemoteDataSource>(
    () => MedicalRecordRemoteDataSourceImpl(apiClient: sl()),
  );

  // Patient Conditions
  sl.registerFactory(() => PatientConditionCubit(conditionRepository: sl()));
  sl.registerLazySingleton<PatientConditionRepository>(
    () => PatientConditionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PatientConditionRemoteDataSource>(
    () => PatientConditionRemoteDataSourceImpl(apiClient: sl()),
  );

  // Pharmacist Care
  sl.registerFactory(() => PharmacistCubit(pharmacistRepository: sl()));
  sl.registerFactory(
    () => MyRequestsCubit(
      pharmacistRepository: sl(),
      careRequestCacheService: sl(),
    ),
  );
  sl.registerLazySingleton<PharmacistRepository>(
    () => PharmacistRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PharmacistRemoteDataSource>(
    () => PharmacistRemoteDataSourceImpl(apiClient: sl()),
  );

  // Chat
  sl.registerFactory(
    () => ChatCubit(
      chatRepository: sl(),
      signalRService: sl(),
      fileRepository: sl(),
      pharmacistRepository: sl(),
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ChatSignalRService>(
    () => ChatSignalRService(apiClient: sl()),
  );

  // AI Health Insights
  sl.registerFactory(() => HealthInsightCubit(healthInsightRepository: sl()));
  sl.registerLazySingleton<HealthInsightRepository>(
    () => HealthInsightRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HealthInsightRemoteDataSource>(
    () => HealthInsightRemoteDataSourceImpl(apiClient: sl()),
  );

  // ==========================================
  // Features - File Upload
  // ==========================================

  // Bloc / Cubit
  sl.registerFactory(() => FileUploadCubit(uploadFileUseCase: sl()));

  // Use Cases
  sl.registerLazySingleton(() => UploadFileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<FileRepository>(
    () => FileRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<FileRemoteDataSource>(
    () => FileRemoteDataSourceImpl(apiClient: sl()),
  );

  // ==========================================
  // Features - Prescription
  // ==========================================

  // Bloc / Cubit
  sl.registerFactory(() => PrescriptionCubit(createPrescriptionUseCase: sl()));
  sl.registerFactory(() => MyPrescriptionsCubit(prescriptionRepository: sl()));

  // Use Cases
  sl.registerLazySingleton(() => CreatePrescriptionUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PrescriptionRepository>(
    () => PrescriptionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<PrescriptionRemoteDataSource>(
    () => PrescriptionRemoteDataSourceImpl(apiClient: sl()),
  );

  // ==========================================
  // Features - Health Readings
  // ==========================================

  // Bloc / Cubit
  // Singleton: shared across Home's stat cards and the add-reading screen so
  // a newly added reading is reflected immediately without a manual refresh.
  sl.registerLazySingleton(
    () => HealthCubit(
      addReadingUseCase: sl(),
      getReadingsUseCase: sl(),
      getHistoryUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddHealthReadingUseCase(sl()));
  sl.registerLazySingleton(() => GetHealthReadingsUseCase(sl()));
  sl.registerLazySingleton(() => GetHealthHistoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<HealthRemoteDataSource>(
    () => HealthRemoteDataSourceImpl(apiClient: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
      devicePushService: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl(), firebaseAuth: sl()),
  );

  // ==========================================
  // Core & External
  // ==========================================
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => SecureStorageService());
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);
  sl.registerLazySingleton(() => CareRequestCacheService(sl()));
}
