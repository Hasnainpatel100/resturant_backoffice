import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/user_profile_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/branch_model.dart';

enum UserStatus { initial, loading, loaded, error }

class StateUser extends Equatable {
  final UserStatus status;
  final UserProfileModel? user;
  final List<UserData> users;
  final MetaData? meta;
  final List<BranchBasicModel> branches;
  final String? errorMessage;

  const StateUser({
    this.status = UserStatus.initial,
    this.user,
    this.users = const [],
    this.meta,
    this.branches = const [],
    this.errorMessage,
  });

  StateUser copyWith({
    UserStatus? status,
    UserProfileModel? user,
    List<UserData>? users,
    MetaData? meta,
    List<BranchBasicModel>? branches,
    String? errorMessage,
  }) {
    return StateUser(
      status: status ?? this.status,
      user: user ?? this.user,
      users: users ?? this.users,
      meta: meta ?? this.meta,
      branches: branches ?? this.branches,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, users, meta, branches, errorMessage];
}