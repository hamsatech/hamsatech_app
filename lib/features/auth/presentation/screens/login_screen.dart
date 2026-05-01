import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../viewmodels/phone_verification_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _PhoneVerificationView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _PhoneVerificationView extends StatefulWidget {
  const _PhoneVerificationView();

  @override
  State<_PhoneVerificationView> createState() => _PhoneVerificationViewState();
}

class _PhoneVerificationViewState extends State<_PhoneVerificationView> {
  final _controller = TextEditingController();

  DSCountryCode _selectedCountry = PhoneVerificationViewModel.defaultCountry;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final digits = _controller.text.trim();
    if (!PhoneVerificationViewModel.isPhoneValid(digits)) return;
    HapticFeedback.lightImpact();
    final fullPhone = PhoneVerificationViewModel.buildFullPhone(
      _selectedCountry,
      digits,
    );
    context.read<AuthBloc>().add(AuthSendOtpRequested(fullPhone));
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet<DSCountryCode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CountryPickerSheet(
        countries: PhoneVerificationViewModel.countryCodes,
        selected: _selectedCountry,
        onSelect: (country) {
          setState(() => _selectedCountry = country);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.push('/otp', extra: state.phoneOrEmail);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: DSTypography.bodyMd.copyWith(color: Colors.white),
              ),
              backgroundColor: DSColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.md)),
            ),
          );
        }
      },
      child: Theme(
        data: ThemeData(useMaterial3: true, brightness: Brightness.light),
        child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/welcome'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF0D1F2D)),
          ),
          title: Text(
            PhoneVerificationViewModel.screenTitle,
            style: DSTypography.headingMd
                .copyWith(color: const Color(0xFF0D1F2D)),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                SvgPicture.asset(
                  'assets/icons/hand_holding_phone.svg',
                  width: 129,
                  height: 157,
                ),
                const SizedBox(height: 32),
                Text(
                  PhoneVerificationViewModel.heading,
                  style: DSTypography.onboardingCaption
                      .copyWith(color: const Color(0xFF0D1F2D)),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    return DSPhoneInput(
                      controller: _controller,
                      label: 'Mobile number',
                      selectedCountry: _selectedCountry,
                      onCountryTap: () => _showCountryPicker(context),
                      placeholder: '123-456-7890',
                      helperText: PhoneVerificationViewModel.helperText,
                      onChanged: (_) => setState(() {}),
                    );
                  },
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {},
                  child: Center(
                    child: Text(
                      PhoneVerificationViewModel.changeNumberText,
                      style: DSTypography.labelMd.copyWith(
                        color: DSColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthOtpSending;
                    final isEnabled = PhoneVerificationViewModel.isPhoneValid(
                        _controller.text.trim());
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isEnabled ? 1.0 : 0.45,
                      child: DSPrimaryButton(
                        label: PhoneVerificationViewModel.continueLabel,
                        color: DSColors.terracotta,
                        isLoading: isLoading,
                        onPressed: (isEnabled && !isLoading)
                            ? () => _submit(context)
                            : () {},
                        textStyle: DSTypography.headingMd.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ── Country Picker Bottom Sheet ───────────────────────────────────────────────

class _CountryPickerSheet extends StatelessWidget {
  const _CountryPickerSheet({
    required this.countries,
    required this.selected,
    required this.onSelect,
  });

  final List<DSCountryCode> countries;
  final DSCountryCode selected;
  final ValueChanged<DSCountryCode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: DSColors.gray300,
            borderRadius: BorderRadius.circular(DSRadius.full),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Select country',
            style: DSTypography.headingMd
                .copyWith(color: const Color(0xFF0D1F2D)),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: countries.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 56, endIndent: 16),
            itemBuilder: (_, i) {
              final country = countries[i];
              final isSelected = country.code == selected.code;
              return ListTile(
                leading: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(
                  country.name,
                  style: DSTypography.bodyMd.copyWith(
                    color: const Color(0xFF0D1F2D),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: Text(
                  country.dialCode,
                  style: DSTypography.labelMd
                      .copyWith(color: const Color(0xFF6B7280)),
                ),
                selected: isSelected,
                selectedTileColor: DSColors.terracotta.withValues(alpha: 0.06),
                onTap: () => onSelect(country),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
      ],
    );
  }
}
