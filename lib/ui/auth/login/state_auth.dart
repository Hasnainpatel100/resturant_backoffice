import 'package:equatable/equatable.dart';

class StateAuth extends Equatable {
  final bool isLoading;

  const StateAuth({required this.isLoading});

  const StateAuth.initial() : isLoading = false;

  StateAuth copyWith({bool? isLoading}) {
    return StateAuth(isLoading: isLoading ?? this.isLoading);
  }

  @override
  List<Object?> get props => [isLoading];
}
