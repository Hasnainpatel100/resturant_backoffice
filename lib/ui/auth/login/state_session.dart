import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/user_model.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class StateSession extends Equatable {
  final SessionStatus status;
  final AppUser? user;

  const StateSession({
    this.status = SessionStatus.unknown,
    this.user,
  });

  const StateSession.unknown() : this();
  const StateSession.authenticated(AppUser user) : this(status: SessionStatus.authenticated, user: user);
  const StateSession.unauthenticated() : this(status: SessionStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}
