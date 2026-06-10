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
    final hasKnownDistrict =
        hasKnownWilaya &&
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

  Future<void> _searchLocation() async {
    final l = AppLocalizations.of(context);
    setState(() => _isSearchingLocation = true);
    try {
      final query = [
        _wilaya,
        _district,
        _locationDescriptionController.text,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
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
        AppSnackbars.showInfo(context, l.text('locationSearchOptionalFailed'));
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
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' - ');

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final requiredMessage = l.text('required');

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          PostTypeSelector(
            value: _type,
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 16),
          ImageInput(
            initialImageUrl: widget.initialPost?.imageUrl ?? '',
            onChanged: (file) => _imageFile = file,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CustomTextField(
                  controller: _titleController,
                  label: l.text('title'),
                  validator: (value) =>
                      Validators.requiredField(value, requiredMessage),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _descriptionController,
                  label: l.text('description'),
                  maxLines: 4,
                  validator: (value) =>
                      Validators.requiredField(value, requiredMessage),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: l.text('category')),
                  menuMaxHeight: 320,
                  items: PostCategories.values
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(PostCategories.label(l, category)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value),
                  validator: (value) =>
                      Validators.requiredField(value, requiredMessage),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _wilaya,
                  decoration: InputDecoration(labelText: l.text('wilaya')),
                  menuMaxHeight: 320,
                  items: MauritaniaLocations.wilayas
                      .map(
                        (wilaya) => DropdownMenuItem(
                          value: wilaya,
                          child: Text(wilaya),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _wilaya = value;
                      _district = null;
                    });
                  },
                  validator: (value) =>
                      Validators.requiredField(value, requiredMessage),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _district,
                  decoration: InputDecoration(labelText: l.text('district')),
                  menuMaxHeight: 320,
                  items: MauritaniaLocations.districtsFor(_wilaya)
                      .map(
                        (district) => DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        ),
                      )
                      .toList(),
                  onChanged: _wilaya == null
                      ? null
                      : (value) => setState(() => _district = value),
                  validator: (value) =>
                      Validators.requiredField(value, requiredMessage),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _locationDescriptionController,
                  label: l.text('locationDescription'),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: _isSearchingLocation ? null : _searchLocation,
                  icon: _isSearchingLocation
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.map_outlined),
                  label: Text(l.text('chooseLocationFromMap')),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l.text('mapOptionalHint'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.subtext),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _contactController,
                  label: l.text('contact'),
                  validator: (value) =>
                      Validators.requiredField(value, requiredMessage),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _dateController,
                  label: l.text('date'),
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (value) =>
                      Validators.requiredField(value, requiredMessage),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: InputDecoration(labelText: l.text('status')),
                  items: [
                    DropdownMenuItem(
                      value: 'open',
                      child: Text(l.text('open')),
                    ),
                    DropdownMenuItem(
                      value: 'closed',
                      child: Text(l.text('closed')),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: l.text('save'),
            icon: Icons.check_rounded,
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
