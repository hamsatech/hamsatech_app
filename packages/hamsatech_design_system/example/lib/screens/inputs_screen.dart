import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../widgets/showcase_helpers.dart';

class InputsScreen extends StatefulWidget {
  const InputsScreen({super.key});
  @override
  State<InputsScreen> createState() => _InputsScreenState();
}

class _InputsScreenState extends State<InputsScreen> {
  final _basic = TextEditingController();
  final _error = TextEditingController(text: 'bad@input');
  final _filled = TextEditingController(text: 'Hamsatech.com');
  final _search = TextEditingController();
  final _url = TextEditingController();
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  final _pwd = TextEditingController();
  final _area = TextEditingController();
  final _group = TextEditingController();
  final _referral = TextEditingController(text: 'WELCOME25');
  final _comboCtrl = TextEditingController();

  String? _comboValue;
  final Set<String> _multiValues = {};

  final _comboItems = const [
    DSComboboxItem(value: 'vegetarian', label: 'Vegetarian'),
    DSComboboxItem(value: 'vegan', label: 'Vegan'),
    DSComboboxItem(value: 'gluten', label: 'Gluten-Free'),
    DSComboboxItem(value: 'mediterranean', label: 'Mediterranean'),
    DSComboboxItem(value: 'lowcarb', label: 'Low-Carb'),
    DSComboboxItem(value: 'dairyfree', label: 'Dairy-Free'),
  ];

  @override
  void dispose() {
    for (final c in [_basic, _error, _filled, _search, _url, _phone, _amount, _pwd, _area, _group, _referral, _comboCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseBody(
            sections: [
        // ── DSTextInput States ──────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSTEXTINPUT · STATES',
          description: 'Normal · error · disabled · loading',
          children: [
            ShowcaseCard(
              code: "DSTextInput(\n  controller: ctrl,\n  label: 'Label',\n  isRequired: true,\n  placeholder: 'Placeholder',\n  helperText: 'Helper text',\n)",
              child: Column(children: [
                DSTextInput(controller: _basic, label: 'Default', isRequired: true, showInfoIcon: true, placeholder: 'Enter value…', helperText: 'Helper text below the field'),
                const SizedBox(height: 14),
                DSTextInput(controller: _filled, label: 'Filled', isRequired: true, placeholder: 'Enter value…'),
                const SizedBox(height: 14),
                DSTextInput(controller: _error, label: 'Error', isRequired: true, state: DSInputState.error, errorText: 'This field contains invalid input'),
                const SizedBox(height: 14),
                DSTextInput(controller: TextEditingController(text: 'Disabled value'), label: 'Disabled', state: DSInputState.disabled, placeholder: 'Disabled'),
                const SizedBox(height: 14),
                DSTextInput(controller: TextEditingController(), label: 'Loading', state: DSInputState.loading, placeholder: 'Fetching…'),
              ]),
            ),
          ],
        ),
        // ── Specialised inputs ───────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSSEARCHINPUT',
          children: [
            ShowcaseCard(
              code: "DSSearchInput(controller: ctrl, placeholder: 'Search for anything')",
              child: DSSearchInput(controller: _search, placeholder: 'Search for anything', helperText: 'Agree Terms and Conditions'),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSURLINPUT',
          children: [
            ShowcaseCard(
              code: "DSUrlInput(controller: ctrl, placeholder: 'hamsatech.com')",
              child: DSUrlInput(controller: _url, label: 'Website URL', isRequired: true, placeholder: 'hamsatech.com', helperText: 'This is the URL we use to link your profile'),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSPHONEINPUT',
          children: [
            ShowcaseCard(
              code: "DSPhoneInput(controller: ctrl, label: 'Phone number', isRequired: true)",
              child: DSPhoneInput(controller: _phone, label: 'Phone number', isRequired: true, helperText: 'Agree Terms and Conditions'),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSAMOUNTINPUT',
          children: [
            ShowcaseCard(
              code: "DSAmountInput(controller: ctrl, label: 'Set budget', currencyCode: 'USD')",
              child: DSAmountInput(controller: _amount, label: 'Set budget', isRequired: true, currencyCode: 'USD', helperText: 'Enter the amount in US dollars'),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSTAGSINPUT',
          children: [
            ShowcaseCard(
              code: "DSTagsInput(label: 'Enter tags', isRequired: true, helperText: 'Press enter to add')",
              child: DSTagsInput(label: 'Enter tags', isRequired: true, showInfoIcon: true, helperText: 'Add tags to categorise or describe your item'),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSPASSWORDINPUT',
          children: [
            ShowcaseCard(
              code: "DSPasswordInput(controller: ctrl, label: 'Confirm password', isRequired: true)",
              child: DSPasswordInput(controller: _pwd, label: 'Confirm password', isRequired: true, showInfoIcon: true, helperText: 'Include at least one special character (!, @, #, \$)'),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSREFERRALINPUT',
          children: [
            ShowcaseCard(
              code: "DSReferralInput(controller: ctrl, label: 'Referral code')",
              child: DSReferralInput(controller: _referral, label: 'Referral code', showInfoIcon: true, helperText: 'Enter a referral code if you have one'),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSDATEINPUT',
          children: [
            ShowcaseCard(
              code: "DSDateInput(controller: ctrl, label: 'Select date', isRequired: true)",
              child: DSDateInput(controller: TextEditingController(), label: 'Select date', isRequired: true, showInfoIcon: true, helperText: 'Pick a date from the calendar'),
            ),
          ],
        ),
        // ── DSTextArea ────────────────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSTEXTAREA',
          description: 'Multi-line with optional character counter',
          children: [
            ShowcaseCard(
              code: "DSTextArea(\n  controller: ctrl,\n  label: 'Send message',\n  isRequired: true,\n  maxLength: 500,\n  placeholder: 'Write your message here…',\n)",
              child: Column(children: [
                DSTextArea(controller: _area, label: 'Send message', isRequired: true, showInfoIcon: true, placeholder: 'Write your message here…', maxLength: 500),
                const SizedBox(height: 14),
                DSTextArea(controller: TextEditingController(text: 'I am reaching out to inquire about your services.'), label: 'Filled', isRequired: true, maxLength: 500),
                const SizedBox(height: 14),
                DSTextArea(controller: TextEditingController(), label: 'Error state', isRequired: true, state: DSInputState.error, errorText: 'Max length: 500 characters. Please shorten your message.', maxLength: 500),
              ]),
            ),
          ],
        ),
        // ── DSInputGroup ─────────────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSINPUTGROUP',
          description: 'Inline input + button joined inside one border',
          children: [
            ShowcaseCard(
              code: "DSInputGroup(\n  controller: ctrl,\n  label: 'Subscribe to Newsletter',\n  placeholder: 'Enter your email address',\n  buttonLabel: 'Subscribe',\n  onButtonPressed: () {},\n)",
              child: DSInputGroup(
                controller: _group,
                label: 'Subscribe to Newsletter',
                isRequired: true,
                placeholder: 'Enter your email address',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.email_outlined, size: 18, color: DSColors.textMuted),
                ),
                helperText: 'Agree Terms and Conditions',
                buttonLabel: 'Subscribe',
                onButtonPressed: () {},
              ),
            ),
          ],
        ),
        // ── DSCombobox ────────────────────────────────────────────────────────
        ShowcaseSection(
          title: 'DSCOMBOBOX',
          description: 'Single-select searchable dropdown',
          children: [
            ShowcaseCard(
              code: "DSCombobox<String>(\n  items: items,\n  value: _value,\n  label: 'Diet preference',\n  onSelected: (item) => setState(() => _value = item.value),\n)",
              child: DSCombobox<String>(
                items: _comboItems,
                value: _comboValue,
                label: 'Diet preference',
                isRequired: true,
                placeholder: 'Select a preference…',
                helperText: 'Tap to open the dropdown',
                onSelected: (item) => setState(() => _comboValue = item.value),
              ),
            ),
          ],
        ),
        ShowcaseSection(
          title: 'DSMULTICOMBOBOX',
          description: 'Multi-select with inline checkboxes',
          children: [
            ShowcaseCard(
              code: "DSMultiCombobox<String>(\n  items: items,\n  values: _values,\n  label: 'Enter tags',\n  onChanged: (v) => setState(() => _values = v),\n)",
              child: DSMultiCombobox<String>(
                items: _comboItems,
                values: _multiValues,
                label: 'Enter tags',
                isRequired: true,
                showInfoIcon: true,
                placeholder: 'Search and select tags…',
                helperText: 'Add tags to categorise or describe your item',
                onChanged: (v) => setState(() {
                  _multiValues
                    ..clear()
                    ..addAll(v);
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
