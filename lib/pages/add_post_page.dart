import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/utils/snackbars.dart';
import 'package:lost_and_found/providers/auth_provider.dart';
import 'package:lost_and_found/providers/post_provider.dart';
import 'package:lost_and_found/widgets/post_form.dart';

class AddPostPage extends StatelessWidget {
  const AddPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final authProvider = context.read<AuthProvider>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.text('addPost'))),
      body: PostForm(
        isLoading: postProvider.isLoading,
        onSubmit: (data) async {
          final user = authProvider.firebaseUser;
          if (user == null) {
            AppSnackbars.showError(context, l.text('genericError'));
            return;
          }

          final success = await context.read<PostProvider>().addPost(
            title: data.title,
            description: data.description,
            category: data.category,
            type: data.type,
            location: data.location,
            wilaya: data.wilaya,
            district: data.district,
            locationDescription: data.locationDescription,
            contact: data.contact,
            userId: user.uid,
            userName: authProvider.appUser?.name ?? user.email ?? 'User',
            date: data.date,
            imageFile: data.imageFile,
          );

          if (!context.mounted) return;
          if (success) {
            if (data.imageFile != null) {
              AppSnackbars.showSuccess(context, l.text('imageUploaded'));
            }
            AppSnackbars.showSuccess(context, l.text('postCreated'));
            Navigator.pop(context);
          } else {
            AppSnackbars.showError(
              context,
              context.read<PostProvider>().errorMessage ??
                  l.text('genericError'),
            );
          }
        },
      ),
    );
  }
}
