import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_profile.dart';
import '../services/session_service.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}

class ProfileSaved extends ProfileEvent {
  const ProfileSaved(this.profile);

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

enum ProfileStatus { initial, loading, ready, saving, success, failure }

class ProfileState extends Equatable {
  const ProfileState({required this.status, this.profile, this.message});

  const ProfileState.initial() : this(status: ProfileStatus.initial);

  final ProfileStatus status;
  final UserProfile? profile;
  final String? message;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? message,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, profile, message];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._sessionService) : super(const ProfileState.initial()) {
    on<ProfileLoaded>(_onLoaded);
    on<ProfileSaved>(_onSaved);
  }

  final SessionService _sessionService;

  Future<void> _onLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    emit(
      ProfileState(
        status: ProfileStatus.ready,
        profile: await _sessionService.loadProfile(),
      ),
    );
  }

  Future<void> _onSaved(ProfileSaved event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving, message: null));
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await _sessionService.saveSession(event.profile);
      emit(
        ProfileState(
          status: ProfileStatus.success,
          profile: event.profile,
          message: 'Profile updated successfully.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          message: 'Unable to update profile right now.',
        ),
      );
    }
  }
}
