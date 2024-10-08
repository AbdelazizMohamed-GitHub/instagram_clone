
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_app/core/errors/failure.dart';
import 'package:instagram_app/core/utils/app_images.dart';
import 'package:instagram_app/core/widget/custom_picture.dart';
import 'package:instagram_app/features/auth/data/model/user_model.dart';
import 'package:instagram_app/features/profile/presention/view/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? searchText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {});
                  },
                  icon: const Icon(Icons.search),
                ),
                hintText: "Search",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Search Result"),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('id',
                        isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .where('username', isGreaterThanOrEqualTo: searchText)
                    .where('username', isLessThanOrEqualTo: '$searchText\uf8ff')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${Failure(message: snapshot.error.toString())}"),
                    );
                  }
                  final users = snapshot.data!.docs.map((doc) {
                    return UserModel.fromMap(
                      doc.data(),
                    );
                  }).toList();
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No results found"));
                  }
                  return Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                     
                      itemCount: users.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(thickness: 1);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                          uid: users[index].id.toString(),
                                        )));
                          },
                          leading: CustomPicture(
                              radius: 50,
                              image: users[index].profilePictureUrl != ''
                                  ? CachedNetworkImage(
                                      imageUrl: users[index]
                                          .profilePictureUrl
                                          .toString(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  : Image.asset(AppImages.emptyUser)),
                          title: Text(
                            users[index].username,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 18),
                          ),
                          subtitle: Text(users[index].bio),
                        );
                      },
                    ),
                  );
                })
          ],
        ),
      ),
    ));
  }
}
