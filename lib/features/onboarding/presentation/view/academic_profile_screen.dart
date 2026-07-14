import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/academic_profile_bloc.dart';
import '../bloc/academic_profile_event.dart';
import '../bloc/academic_profile_state.dart';

class AcademicProfileScreen extends StatelessWidget {
  const AcademicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AcademicProfileBloc(),
      child: const _AcademicProfileView(),
    );
  }
}

class _AcademicProfileView extends StatefulWidget {
  const _AcademicProfileView();

  @override
  State<_AcademicProfileView> createState() => _AcademicProfileViewState();
}

class _AcademicProfileViewState extends State<_AcademicProfileView> {
  late final TextEditingController _classController;
  late final TextEditingController _schoolNameController;
  late final TextEditingController _academicPerformanceController;

  @override
  void initState() {
    super.initState();
    _classController = TextEditingController();
    _schoolNameController = TextEditingController();
    _academicPerformanceController = TextEditingController();
  }

  @override
  void dispose() {
    _classController.dispose();
    _schoolNameController.dispose();
    _academicPerformanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AcademicProfileBloc, AcademicProfileState>(
      listenWhen: (previous, current) =>
          previous.submissionSuccess != current.submissionSuccess ||
          previous.errorMessage != current.errorMessage ||
          previous.className != current.className ||
          previous.schoolName != current.schoolName ||
          previous.academicPerformance != current.academicPerformance,
      listener: (context, state) {
        if (_classController.text != state.className) {
          _classController.text = state.className;
        }
        if (_schoolNameController.text != state.schoolName) {
          _schoolNameController.text = state.schoolName;
        }
        if (_academicPerformanceController.text != state.academicPerformance) {
          _academicPerformanceController.text = state.academicPerformance;
        }

        if (state.submissionSuccess) {
          context.go('/onboarding/step5');
        }
      },
      builder: (context, state) {
        final bloc = context.read<AcademicProfileBloc>();

        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),

          // ── AppBar + Progress Bar ──────────────────────────────────────
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.white,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                              onPressed: () => context.go('/onboarding/step3'),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                state.stepTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0x99000F12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 56),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 3,
                              color: const Color(0xFFCAE8EE),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: constraints.maxWidth *
                                  state.progress.clamp(0.0, 1.0),
                              height: 3,
                              color: const Color(0xFF2F7E8F),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.heading,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000F12),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0x99000F12),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Class ───────────────────────────────────────────────
                _fieldLabel(state.classLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _classController,
                  hint: state.classHint,
                  isInvalid: _isClassInvalid(state),
                  onChanged: (v) => bloc.add(OnClassChanged(v)),
                ),
                const SizedBox(height: 18),

                // ── School Name ─────────────────────────────────────────
                _fieldLabel(state.schoolNameLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _schoolNameController,
                  hint: state.schoolNameHint,
                  isInvalid: _isSchoolNameInvalid(state),
                  onChanged: (v) => bloc.add(OnSchoolNameChanged(v)),
                ),
                const SizedBox(height: 18),

                // ── Academic Performance ─────────────────────────────────
                _fieldLabel(state.academicPerformanceLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _academicPerformanceController,
                  hint: state.academicPerformanceHint,
                  isInvalid: _isAcademicPerformanceInvalid(state),
                  onChanged: (v) =>
                      bloc.add(OnAcademicPerformanceChanged(v)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // ── CTA Button ──────────────────────────────────────────────────
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isValid
                      ? () => bloc.add(const OnAcademicProfileSubmit())
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7E8F),
                    disabledBackgroundColor:
                        const Color(0xFF2F7E8F).withValues(alpha: 0.45),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.85),
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    state.ctaLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isClassInvalid(AcademicProfileState state) =>
      state.errorMessage == 'Please enter your class';

  bool _isSchoolNameInvalid(AcademicProfileState state) =>
      state.errorMessage == 'Please enter your school name';

  bool _isAcademicPerformanceInvalid(AcademicProfileState state) =>
      state.errorMessage == 'Please enter your academic performance';

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0x99000F12),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required bool isInvalid,
    required ValueChanged<String> onChanged,
  }) {
    final borderColor =
        isInvalid ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF000F12),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0x66000F12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2F7E8F), width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
