import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/constants/mauritania_locations.dart';
import 'package:lost_and_found/core/constants/post_categories.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/services/geocoding_service.dart';
import 'package:lost_and_found/core/utils/date_hepler.dart';
import 'package:lost_and_found/core/utils/snackbars.dart';
import 'package:lost_and_found/core/utils/validators.dart';
import 'package:lost_and_found/core/widgets/custom_button.dart';
import 'package:lost_and_found/core/widgets/custom_text_field.dart';
import 'package:lost_and_found/models/post_model.dart';
import 'package:lost_and_found/widgets/image_input.dart';
import 'package:lost_and_found/widgets/post_type_selector.dart';

// ── PostFormData (unchanged) ──────────────────────────────────────────────────
class PostFormData {
  const PostFormData({
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.location,
    required this.wilaya,
    required this.district,
    required this.locationDescription,
    required this.contact,
    required this.date,
    required this.status,
    required this.imageUrl,
    this.imageFile,
  });

  final String title;
  final String description;
  final String category;
  final String type;
  final String location;
  final String wilaya;
  final String district;
  final String locationDescription;
  final String contact;
  final String date;
  final String status;
  final String imageUrl;
  final XFile? imageFile;
}

// ── PostForm widget ───────────────────────────────────────────────────────────
class PostForm extends StatefulWidget {
  const PostForm({
    super.key,
    required this.onSubmit,
    this.initialPost,
    this.isLoading = false,
  });

  final Future<void> Function(PostFormData data) onSubmit;
  final PostModel? initialPost;
  final bool isLoading;

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  final _geocodingService = GeocodingService();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationDescriptionController;
  late final TextEditingController _contactController;
  late final TextEditingController _dateController;
  late String _type;
  late String _status;
  String? _category;
  String? _wilaya;
  String? _district;
  XFile? _imageFile;
  bool _isSearchingLocation = false;

  @override
  void initState() {
    super.initState();
    final post = widget.initialPost;
    _titleController = TextEditingController(text: post?.title ?? '');
    _descriptionController = TextEditingController(
      text: post?.description ?? '',
    );
    _category = post == null
        ? null
        : PostCategories.values.contains(post.category)
            ? post.category
            : PostCategories.other;
    final hasKnownWilaya =
        post != null && MauritaniaLocations.wilayas.contains(post.wilaya);
    final hasKnownDistrict = hasKnownWilaya &&
        MauritaniaLocations.districtsFor(post.wilaya).contains(post.district);
    _locationDescriptionController = TextEditingController(
      text: post?.locationDescription.isNotEmpty == true
          ? post!.locationDescription
          : hasKnownWilaya
              ? ''
              : post?.location ?? '',
    );
    _contactController = TextEditingController(text: post?.contact ?? '');
    _dateController = TextEditingController(text: post?.date ?? '');
    _type = post?.type ?? 'lost';
    _status = post?.status ?? 'open';
    _wilaya = hasKnownWilaya ? post.wilaya : null;
    _district = hasKnownDistrict ? post.district : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationDescriptionController.dispose();
    _contactController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // ── Logic (unchanged) ────────────────────────────────────────────────────────
  Future<void> _searchLocation() async {
    final l = AppLocalizations.of(context);
    setState(() => _isSearchingLocation = true);
    try {
      final query = [
        _wilaya,
        _district,
        _locationDescriptionController.text,
      ]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(', ');
      final results = await _geocodingService.search(query);
      if (!mounted) return;
      if (results.isEmpty) {
        AppSnackbars.showInfo(context, l.text('locationNotFound'));
        return;
      }
      _locationDescriptionController.text = results.first.displayName;
      AppSnackbars.showSuccess(context, l.text('locationFound'));
    } catch (_) {
      if (mounted) {
        AppSnackbars.showInfo(
            context, l.text('locationSearchOptionalFailed'));
      }
    } finally {
      if (mounted) setState(() => _isSearchingLocation = false);
    }
  }

  Future<void> _pickDate() async {
    final initialDate =
        DateHelper.parseIsoDate(_dateController.text) ??
            widget.initialPost?.createdAt ??
            DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null) return;
    _dateController.text = DateHelper.formatIsoDate(selectedDate);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final location = [
      _wilaya,
      _district,
      _locationDescriptionController.text,
    ]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' - ');

    await widget.onSubmit(
      PostFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category ?? PostCategories.other,
        type: _type,
        location: location,
        wilaya: _wilaya ?? '',
        district: _district ?? '',
        locationDescription: _locationDescriptionController.text.trim(),
        contact: _contactController.text.trim(),
        date: _dateController.text.trim(),
        status: _status,
        imageUrl: widget.initialPost?.imageUrl ?? '',
        imageFile: _imageFile,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final requiredMessage = l.text('required');

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Post Type Selector ────────────────────────────────────
            _PostTypeCard(
              type: _type,
              onChanged: (v) => setState(() => _type = v),
              l: l,
            ),

            const SizedBox(height: 16),

            // ── Image Upload ──────────────────────────────────────────
            _SectionCard(
              icon: Icons.photo_camera_outlined,
              title: l.text('photo'),
              child: ImageInput(
                initialImageUrl: widget.initialPost?.imageUrl ?? '',
                onChanged: (file) => _imageFile = file,
              ),
            ),

            const SizedBox(height: 16),

            // ── Basic Information ─────────────────────────────────────
            _SectionCard(
              icon: Icons.edit_note_rounded,
              title: l.text('basicInfo'),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _titleController,
                    label: l.text('title'),
                    validator: (v) =>
                        Validators.requiredField(v, requiredMessage),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _descriptionController,
                    label: l.text('description'),
                    maxLines: 4,
                    validator: (v) =>
                        Validators.requiredField(v, requiredMessage),
                  ),
                  const SizedBox(height: 14),
                  _StyledDropdown<String>(
                    value: _category,
                    labelText: l.text('category'),
                    hint: l.text('selectCategory'),
                    items: PostCategories.values
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(PostCategories.label(l, c)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) =>
                        Validators.requiredField(v, requiredMessage),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _dateController,
                    label: l.text('date'),
                    readOnly: true,
                    onTap: _pickDate,
                    prefixIcon: Icons.calendar_today_outlined,
                    validator: (v) =>
                        Validators.requiredField(v, requiredMessage),
                  ),
                  const SizedBox(height: 14),
                  _StyledDropdown<String>(
                    value: _status,
                    labelText: l.text('status'),
                    items: [
                      DropdownMenuItem(
                          value: 'open', child: Text(l.text('open'))),
                      DropdownMenuItem(
                          value: 'closed', child: Text(l.text('closed'))),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _status = v);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Location Information ──────────────────────────────────
            _SectionCard(
              icon: Icons.location_on_outlined,
              title: l.text('locationInfo'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StyledDropdown<String>(
                    value: _wilaya,
                    labelText: l.text('wilaya'),
                    hint: l.text('selectWilaya'),
                    items: MauritaniaLocations.wilayas
                        .map((w) => DropdownMenuItem(
                              value: w,
                              child: Text(w),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _wilaya = v;
                      _district = null;
                    }),
                    validator: (v) =>
                        Validators.requiredField(v, requiredMessage),
                  ),
                  const SizedBox(height: 14),
                  _StyledDropdown<String>(
                    value: _district,
                    labelText: l.text('district'),
                    hint: l.text('selectDistrict'),
                    items: MauritaniaLocations.districtsFor(_wilaya)
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d),
                            ))
                        .toList(),
                    onChanged: _wilaya == null
                        ? null
                        : (v) => setState(() => _district = v),
                    validator: (v) =>
                        Validators.requiredField(v, requiredMessage),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _locationDescriptionController,
                    label: l.text('locationDescription'),
                    prefixIcon: Icons.place_outlined,
                  ),
                  const SizedBox(height: 8),
                  // Map search button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isSearchingLocation ? null : _searchLocation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isSearchingLocation
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  )
                                : const Icon(Icons.map_outlined,
                                    size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              l.text('chooseLocationFromMap'),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.text('mapOptionalHint'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.subtext,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Contact Information ───────────────────────────────────
            _SectionCard(
              icon: Icons.contact_phone_outlined,
              title: l.text('contactInfo'),
              child: CustomTextField(
                controller: _contactController,
                label: l.text('contact'),
                prefixIcon: Icons.phone_outlined,
                validator: (v) =>
                    Validators.requiredField(v, requiredMessage),
              ),
            ),

            const SizedBox(height: 28),

            // ── Publish Button ────────────────────────────────────────
            _PublishButton(
              isLoading: widget.isLoading,
              onPressed: _submit,
              label: l.text('add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private helper widgets ────────────────────────────────────────────────────

/// Card that holds the Lost / Found selector with a type-tinted accent strip.
class _PostTypeCard extends StatelessWidget {
  const _PostTypeCard({
    required this.type,
    required this.onChanged,
    required this.l,
  });

  final String type;
  final ValueChanged<String> onChanged;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final isLost = type == 'lost';
    final accentColor = isLost
        ? const Color(0xFFE15C4F) // error-red for "lost"
        : AppColors.success; // green for "found"

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: accentColor.withOpacity(0.25), width: 1.2),
      ),
      child: Column(
        children: [
          // Colored top strip
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isLost
                            ? Icons.search_rounded
                            : Icons.inventory_2_outlined,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l.text('postType'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtext,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PostTypeSelector(
                  value: type,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable section card with an icon, title, and content area.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 17, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border.withOpacity(0.8),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Styled dropdown that matches the CustomTextField aesthetic.
class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.hint,
    this.validator,
  });

  final T? value;
  final String labelText;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      menuMaxHeight: 320,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF2E2E2E).withOpacity(0.35),
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF2E2E2E).withOpacity(0.55),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE8E2D9), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE8E2D9), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.red.shade400, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.red.shade400, width: 1.8),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary, size: 22),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
    );
  }
}

/// Premium publish / save button.
class _PublishButton extends StatelessWidget {
  const _PublishButton({
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isLoading ? null : onPressed,
          splashColor: Colors.white.withOpacity(0.15),
          child: Center(
            child: isLoading
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
