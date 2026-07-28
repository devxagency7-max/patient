import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/assignment_request_entity.dart';

abstract class MyRequestsState extends Equatable {
  const MyRequestsState();

  @override
  List<Object?> get props => [];
}

class MyRequestsInitial extends MyRequestsState {}

class MyRequestsLoading extends MyRequestsState {}

class MyRequestsLoaded extends MyRequestsState {
  final List<AssignmentRequestEntity> requests;

  const MyRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class MyRequestsError extends MyRequestsState {
  final String message;

  const MyRequestsError(this.message);

  @override
  List<Object?> get props => [message];
}
