import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../gen/assets.gen.dart';
import '../../gen/colors.gen.dart';
import '../../injection/injection.dart';
import '../bloc/call_kit/call_kit_cubit.dart';
import '../bloc/navigation/bottom_navigation_page.dart';
import '../bloc/navigation/navigation_cubit.dart';
import '../bloc/user_personal_data/user_personal_data_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _userPersonalDataCubit = getIt.get<UserPersonalDataCubit>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  void _updateNameControllers(BuildContext _, UserPersonalDataState state) {
    if (state is! UserPersonalDataLoaded) return;

    final nameSplit = state.user.name?.split(' ');
    if (nameSplit == null || nameSplit.isEmpty) return;

    _firstNameController.text = nameSplit.first;

    if (nameSplit.length > 1) {
      _lastNameController.text = nameSplit.last;
    }
  }

  void _save() {
    _userPersonalDataCubit.changeUserName(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.background.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: BlocConsumer<UserPersonalDataCubit, UserPersonalDataState>(
              bloc: _userPersonalDataCubit,
              listener: _updateNameControllers,
              builder: (context, state) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    _AppBar(
                      onSave: state is! UserPersonalDataLoading &&
                              state is! UserPersonalDataLoadingError
                          ? _save
                          : null,
                      loading: state is UserPersonalDataUpdating,
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _PersonalName(
                        state: state,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _CallKitSetup(),
                    ),
                    const Spacer(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  _AppBar({
    required VoidCallback? onSave,
    required bool loading,
  })  : _onSave = onSave,
        _loading = loading;

  final _navigationCubit = getIt.get<NavigationCubit>();

  final VoidCallback? _onSave;
  final bool _loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () =>
                  _navigationCubit.navigateTo(BottomNavigationPage.calls.index),
              child: Assets.icons.back.svg(),
            ),
          ),
        ),
        Expanded(
          child: Align(
            child: Text(
              'My Profile',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.black2,
                  ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _loading
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: _onSave,
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.green,
                          ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PersonalName extends StatelessWidget {
  const _PersonalName({
    required UserPersonalDataState state,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
  })  : _state = state,
        _firstNameController = firstNameController,
        _lastNameController = lastNameController;

  final UserPersonalDataState _state;
  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;

  InputDecoration _textFieldDecoration(BuildContext context) {
    return InputDecoration(
      helperStyle: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: AppColors.gray),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstNameController,
                  style: Theme.of(context).textTheme.labelMedium,
                  decoration: _textFieldDecoration(context).copyWith(
                    hintText: 'First Name',
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: TextField(
                  controller: _lastNameController,
                  style: Theme.of(context).textTheme.labelMedium,
                  decoration: _textFieldDecoration(context).copyWith(
                    hintText: 'Last Name',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state is UserPersonalDataLoadingError)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.red),
              ),
            ),
          if (state is UserPersonalDataUpdatingError)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.red),
              ),
            ),
        ],
      ),
    );
  }
}

class _CallKitSetup extends StatelessWidget {
  final _callKitCubit = getIt.get<CallKitCubit>();

  /// Retries the CallKit initialization.
  void _retryInit() {
    _callKitCubit.initTelecomServices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallKitCubit, CallKitState>(
      bloc: _callKitCubit,
      builder: (context, state) {
        if (state is CallKitInitialized) {
          return Text(
            'CallKit setup completed. You can receive calls from other users.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          );
        } else if (state is CallKitNotInitialized || state is CallKitError) {
          return Column(
            children: [
              if (state is CallKitNotInitialized) ...[
                if (Platform.isIOS)
                  Text(
                    "CallKit setup failed, other users can't call you. May be "
                    'you are not sign in or there was an issue of getting your '
                    'IPhone VoIP token.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Text(
                    "CallKit setup failed, other users can't call you. May be "
                    'you are not sign in or rejected to give Notifications or '
                    'Phone permissions.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ] else if (state is CallKitError) ...[
                Text(
                  state.error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.red),
                ),
              ],
              const SizedBox(height: 67),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  onPressed: _retryInit,
                  child: const Text('Try again'),
                ),
              ),
            ],
          );
        }
        return Column(
          children: <Widget>[
            Text(
              'CallKit is setting up. Please wait...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}
