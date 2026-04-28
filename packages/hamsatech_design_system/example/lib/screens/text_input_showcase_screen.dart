import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class TextInputShowcaseScreen extends StatefulWidget {
  const TextInputShowcaseScreen({super.key});

  @override
  State<TextInputShowcaseScreen> createState() =>
      _TextInputShowcaseScreenState();
}

class _TextInputShowcaseScreenState extends State<TextInputShowcaseScreen> {
  // Controllers for each input type × state column
  // States: normal/empty, filled, focused(normal), error, disabled, loading

  // Search
  final _searchEmpty = TextEditingController();
  final _searchFilled = TextEditingController(text: 'Spaghetti carbonara');
  final _searchError = TextEditingController(text: 'Spaghetti carbonara');
  final _searchDisabled = TextEditingController(text: 'Spaghetti carbonara');
  final _searchLoading = TextEditingController(text: 'Spaghetti carbonara');

  // URL
  final _urlEmpty = TextEditingController();
  final _urlFilled = TextEditingController(text: 'hamsatech.com');
  final _urlError = TextEditingController(text: 'hamsatech.com');
  final _urlDisabled = TextEditingController(text: 'hamsatech.com');
  final _urlLoading = TextEditingController(text: 'hamsatech.com');

  // Phone
  final _phoneEmpty = TextEditingController();
  final _phoneFilled = TextEditingController(text: '9876543210');
  final _phoneError = TextEditingController(text: '9876543210');
  final _phoneDisabled = TextEditingController(text: '9876543210');
  final _phoneLoading = TextEditingController(text: '9876543210');

  // Amount
  final _amountEmpty = TextEditingController();
  final _amountFilled = TextEditingController(text: '100.00');
  final _amountError = TextEditingController(text: '100.00');
  final _amountDisabled = TextEditingController(text: '100.00');
  final _amountLoading = TextEditingController(text: '100.00');

  // Password
  final _passEmpty = TextEditingController();
  final _passFilled = TextEditingController(text: 'MySecretPass123');
  final _passError = TextEditingController(text: 'MySecretPass123');
  final _passDisabled = TextEditingController(text: 'MySecretPass123');
  final _passLoading = TextEditingController(text: 'MySecretPass123');

  // Referral
  final _refEmpty = TextEditingController();
  final _refFilled = TextEditingController(text: 'WELCOME25');
  final _refError = TextEditingController(text: 'WELCOME25');
  final _refDisabled = TextEditingController(text: 'WELCOME25');
  final _refLoading = TextEditingController(text: 'WELCOME25');

  // Date
  final _dateEmpty = TextEditingController();
  final _dateFilled = TextEditingController(text: '12/15/2024');
  final _dateError = TextEditingController(text: '12/15/2024');
  final _dateDisabled = TextEditingController(text: '12/15/2024');
  final _dateLoading = TextEditingController(text: '12/15/2024');

  String _currency = 'USD';

  @override
  void dispose() {
    for (final c in [
      _searchEmpty, _searchFilled, _searchError, _searchDisabled, _searchLoading,
      _urlEmpty, _urlFilled, _urlError, _urlDisabled, _urlLoading,
      _phoneEmpty, _phoneFilled, _phoneError, _phoneDisabled, _phoneLoading,
      _amountEmpty, _amountFilled, _amountError, _amountDisabled, _amountLoading,
      _passEmpty, _passFilled, _passError, _passDisabled, _passLoading,
      _refEmpty, _refFilled, _refError, _refDisabled, _refLoading,
      _dateEmpty, _dateFilled, _dateError, _dateDisabled, _dateLoading,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Text', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _statesHeader(),
          const SizedBox(height: 16),
          _card(
            title: 'Search',
            children: [
              _StateRow(label: 'Default', child: DSSearchInput(controller: _searchEmpty, label: 'Search', isRequired: true, showInfoIcon: true, helperText: 'Agree Terms and Conditions')),
              _StateRow(label: 'Filled', child: DSSearchInput(controller: _searchFilled, label: 'Search', isRequired: true, showInfoIcon: true, helperText: 'Agree Terms and Conditions')),
              _StateRow(label: 'Error', child: DSSearchInput(controller: _searchError, label: 'Search', isRequired: true, state: DSInputState.error, errorText: 'This field is currently blocked. Please try again.')),
              _StateRow(label: 'Disabled', child: DSSearchInput(controller: _searchDisabled, label: 'Search', isRequired: true, state: DSInputState.disabled, helperText: 'This balance is currently disabled')),
              _StateRow(label: 'Loading', child: DSSearchInput(controller: _searchLoading, label: 'Search', isRequired: true, state: DSInputState.loading, helperText: 'This balance is currently verifying')),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Website URL',
            children: [
              _StateRow(label: 'Default', child: DSUrlInput(controller: _urlEmpty, label: 'Website URL', isRequired: true, showInfoIcon: true, helperText: 'This is the URL you use to link to your profile')),
              _StateRow(label: 'Filled', child: DSUrlInput(controller: _urlFilled, label: 'Website URL', isRequired: true, showInfoIcon: true, helperText: 'This is the URL you use to link to your profile')),
              _StateRow(label: 'Error', child: DSUrlInput(controller: _urlError, label: 'Website URL', isRequired: true, state: DSInputState.error, errorText: 'This URL is already in use, try another one')),
              _StateRow(label: 'Disabled', child: DSUrlInput(controller: _urlDisabled, label: 'Website URL', isRequired: true, state: DSInputState.disabled, helperText: 'This is the URL, edit your link in profile')),
              _StateRow(label: 'Loading', child: DSUrlInput(controller: _urlLoading, label: 'Website URL', isRequired: true, state: DSInputState.loading, helperText: 'This balance is currently verifying')),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Phone Number',
            children: [
              _StateRow(label: 'Default', child: DSPhoneInput(controller: _phoneEmpty, label: 'Phone number', isRequired: true, showInfoIcon: true, helperText: 'Agree Terms and Conditions')),
              _StateRow(label: 'Filled', child: DSPhoneInput(controller: _phoneFilled, label: 'Phone number', isRequired: true, showInfoIcon: true, helperText: 'Agree Terms and Conditions')),
              _StateRow(label: 'Error', child: DSPhoneInput(controller: _phoneError, label: 'Phone number', isRequired: true, state: DSInputState.error, errorText: 'Amount must be in USD only (e.g. \$10)')),
              _StateRow(label: 'Disabled', child: DSPhoneInput(controller: _phoneDisabled, label: 'Phone number', isRequired: true, state: DSInputState.disabled, helperText: 'Enter the amount in USD only')),
              _StateRow(label: 'Loading', child: DSPhoneInput(controller: _phoneLoading, label: 'Phone number', isRequired: true, state: DSInputState.loading, helperText: 'This balance is currently verifying')),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Set Budget (Amount)',
            children: [
              _StateRow(label: 'Default', child: DSAmountInput(controller: _amountEmpty, label: 'Set budget', isRequired: true, showInfoIcon: true, helperText: 'Enter the amount in USD only', currencyCode: _currency, onCurrencyChanged: (c) => setState(() => _currency = c))),
              _StateRow(label: 'Filled', child: DSAmountInput(controller: _amountFilled, label: 'Set budget', isRequired: true, showInfoIcon: true, helperText: 'Enter the amount in USD only', currencyCode: _currency)),
              _StateRow(label: 'Error', child: DSAmountInput(controller: _amountError, label: 'Set budget', isRequired: true, state: DSInputState.error, errorText: 'Enter the amount in USD only (e.g. \$10)', currencyCode: _currency)),
              _StateRow(label: 'Disabled', child: DSAmountInput(controller: _amountDisabled, label: 'Set budget', isRequired: true, state: DSInputState.disabled, helperText: 'Enter the amount in USD only', currencyCode: _currency)),
              _StateRow(label: 'Loading', child: DSAmountInput(controller: _amountLoading, label: 'Set budget', isRequired: true, state: DSInputState.loading, helperText: 'This balance is currently verifying', currencyCode: _currency)),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Tags',
            children: [
              _StateRow(
                label: 'Default',
                child: DSTagsInput(
                  label: 'Enter tags',
                  isRequired: true,
                  showInfoIcon: true,
                  helperText: 'Type and press enter to add a tag',
                ),
              ),
              _StateRow(
                label: 'Filled',
                child: DSTagsInput(
                  label: 'Enter tags',
                  isRequired: true,
                  showInfoIcon: true,
                  initialTags: const ['Mediterranean', 'Italian'],
                  helperText: 'Type and press enter to add a tag',
                ),
              ),
              _StateRow(
                label: 'Error',
                child: DSTagsInput(
                  label: 'Enter tags',
                  isRequired: true,
                  initialTags: const ['Mediterranean'],
                  errorText: 'At least 3 tags are required',
                ),
              ),
              _StateRow(
                label: 'Disabled',
                child: DSTagsInput(
                  label: 'Enter tags',
                  isRequired: true,
                  isDisabled: true,
                  initialTags: const ['Mediterranean'],
                  helperText: 'Tags cannot be edited',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Referral Code',
            children: [
              _StateRow(label: 'Default', child: DSReferralInput(controller: _refEmpty, label: 'Referral code', isRequired: true, showInfoIcon: true, helperText: 'Enter a referral code if you have one')),
              _StateRow(label: 'Filled', child: DSReferralInput(controller: _refFilled, label: 'Referral code', isRequired: true, showInfoIcon: true, helperText: 'Enter a referral code if you have one')),
              _StateRow(label: 'Error', child: DSReferralInput(controller: _refError, label: 'Referral code', isRequired: true, state: DSInputState.error, errorText: 'This referral code is invalid')),
              _StateRow(label: 'Disabled', child: DSReferralInput(controller: _refDisabled, label: 'Referral code', isRequired: true, state: DSInputState.disabled, helperText: 'Enter a referral code if you have one')),
              _StateRow(label: 'Loading', child: DSReferralInput(controller: _refLoading, label: 'Referral code', isRequired: true, state: DSInputState.loading, helperText: 'This balance is currently verifying')),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Confirm Password',
            children: [
              _StateRow(label: 'Default', child: DSPasswordInput(controller: _passEmpty, label: 'Confirm password', isRequired: true, showInfoIcon: true, helperText: 'Include at least one character from A-Z, a-z, 0-9.')),
              _StateRow(label: 'Filled', child: DSPasswordInput(controller: _passFilled, label: 'Confirm password', isRequired: true, showInfoIcon: true, helperText: 'Include at least one character from A-Z, a-z, 0-9.')),
              _StateRow(label: 'Error', child: DSPasswordInput(controller: _passError, label: 'Confirm password', isRequired: true, state: DSInputState.error, errorText: 'Password does not meet the required format')),
              _StateRow(label: 'Disabled', child: DSPasswordInput(controller: _passDisabled, label: 'Confirm password', isRequired: true, state: DSInputState.disabled, helperText: 'Include at least one character from A-Z, a-z, 0-9.')),
              _StateRow(label: 'Loading', child: DSPasswordInput(controller: _passLoading, label: 'Confirm password', isRequired: true, state: DSInputState.loading, helperText: 'This balance is currently verifying')),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Date Picker',
            children: [
              _StateRow(label: 'Default', child: DSDateInput(controller: _dateEmpty, label: 'Select date', isRequired: true, showInfoIcon: true, helperText: 'Pick a date from the calendar')),
              _StateRow(label: 'Filled', child: DSDateInput(controller: _dateFilled, label: 'Select date', isRequired: true, showInfoIcon: true, helperText: 'Pick a date from the calendar')),
              _StateRow(label: 'Error', child: DSDateInput(controller: _dateError, label: 'Select date', isRequired: true, state: DSInputState.error, errorText: 'Please select a valid date in the United States (MM/DD/YYYY)')),
              _StateRow(label: 'Disabled', child: DSDateInput(controller: _dateDisabled, label: 'Select date', isRequired: true, state: DSInputState.disabled, helperText: 'Pick a date from the calendar')),
              _StateRow(label: 'Loading', child: DSDateInput(controller: _dateLoading, label: 'Select date', isRequired: true, state: DSInputState.loading, helperText: 'Pick a date from the calendar')),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statesHeader() {
    final states = ['Default', 'Filled', 'Focused', 'Error', 'Disabled', 'Loading'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: states
          .map(
            (s) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2235) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2235) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
