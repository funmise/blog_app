import 'dart:io';

import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/core/constants/constants.dart';
import 'package:blog_app/core/theme/app_pallete.dart';
import 'package:blog_app/core/utils/pick_image.dart';
import 'package:blog_app/core/utils/show_snackbar.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddNewBlogPage());
  const AddNewBlogPage({super.key});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
  File? image;

  void selectImage() async {
    final pickedImage = await pickImage();

    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void uploadBlog() {
    if (formKey.currentState!.validate() &&
        selectedTopics.isNotEmpty &&
        image != null) {
      final posterId =
          ((context.read<AppUserCubit>().state) as AppUserLoggedIn).user.id;
      context.read<BlogBloc>().add(
        BlogUpload(
          image: image!,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          posterId: posterId,
          topics: selectedTopics,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: uploadBlog,
            icon: const Icon(Icons.done_rounded),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogUploadSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              BlogPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // image picker wrapped with formfield
                    FormField<File?>(
                      validator: (value) {
                        if (image == null) {
                          return 'Please select an image';
                        }
                        return null;
                      },
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          image != null
                              ? GestureDetector(
                                  onTap: selectImage,
                                  child: SizedBox(
                                    height: 150,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        image!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    selectImage();
                                  },
                                  child: const DottedBorder(
                                    options: RoundedRectDottedBorderOptions(
                                      color: AppPallete.borderColor,
                                      dashPattern: [10, 4],
                                      radius: Radius.circular(10),
                                      strokeCap: StrokeCap.round,
                                    ),

                                    child: SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.folder_open, size: 40),

                                          SizedBox(height: 15),

                                          Text(
                                            "Select your image",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.errorText!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),

                    //////
                    // image != null
                    //     ? GestureDetector(
                    //         onTap: selectImage,
                    //         child: SizedBox(
                    //           height: 150,
                    //           width: double.infinity,
                    //           child: ClipRRect(
                    //             borderRadius: BorderRadius.circular(10),
                    //             child: Image.file(image!, fit: BoxFit.cover),
                    //           ),
                    //         ),
                    //       )
                    //     : GestureDetector(
                    //         onTap: () {
                    //           selectImage();
                    //         },
                    //         child: DottedBorder(
                    //           options: const RoundedRectDottedBorderOptions(
                    //             color: AppPallete.borderColor,
                    //             dashPattern: [10, 4],
                    //             radius: Radius.circular(10),
                    //             strokeCap: StrokeCap.round,
                    //           ),

                    //           child: Container(
                    //             height: 150,
                    //             width: double.infinity,
                    //             child: const Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Icon(Icons.folder_open, size: 40),

                    //                 SizedBox(height: 15),

                    //                 Text(
                    //                   "Select your image",
                    //                   style: TextStyle(fontSize: 15),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    const SizedBox(height: 20),

                    FormField<List<String>>(
                      validator: (value) {
                        if (selectedTopics.isEmpty) {
                          return 'Please select at least one topic';
                        }
                        return null;
                      },

                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: Constants.topics
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (selectedTopics.contains(e)) {
                                            selectedTopics.remove(e);
                                          } else {
                                            selectedTopics.add(e);
                                          }
                                          setState(() {});
                                        },
                                        child: Chip(
                                          label: Text(e),
                                          color: selectedTopics.contains(e)
                                              ? const WidgetStatePropertyAll(
                                                  AppPallete.gradient1,
                                                )
                                              : null,
                                          side: selectedTopics.contains(e)
                                              ? null
                                              : const BorderSide(
                                                  color: AppPallete.borderColor,
                                                ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),

                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                field.errorText!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children:
                    //         [
                    //               'Technology',
                    //               'Business',
                    //               'Programming',
                    //               'Entertainment',
                    //             ]
                    //             .map(
                    //               (e) => Padding(
                    //                 padding: const EdgeInsets.all(5.0),
                    //                 child: GestureDetector(
                    //                   onTap: () {
                    //                     if (selectedTopics.contains(e)) {
                    //                       selectedTopics.remove(e);
                    //                     } else {
                    //                       selectedTopics.add(e);
                    //                     }
                    //                     setState(() {});
                    //                   },
                    //                   child: Chip(
                    //                     label: Text(e),
                    //                     color: selectedTopics.contains(e)
                    //                         ? const WidgetStatePropertyAll(
                    //                             AppPallete.gradient1,
                    //                           )
                    //                         : null,
                    //                     side: selectedTopics.contains(e)
                    //                         ? null
                    //                         : const BorderSide(
                    //                             color: AppPallete.borderColor,
                    //                           ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             )
                    //             .toList(),
                    //   ),
                    // ),
                    const SizedBox(height: 10),

                    BlogEditor(
                      controller: titleController,
                      hintText: "Blog title",
                    ),

                    const SizedBox(height: 10),
                    BlogEditor(
                      controller: contentController,
                      hintText: "Blog content",
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
