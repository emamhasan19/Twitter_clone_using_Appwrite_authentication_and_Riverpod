import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';

import 'package:twitter_clone/features/user_profile/view/edit_profile_view.dart';
import 'package:twitter_clone/features/user_profile/widget/follow_count.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

import '../../../models/tweet_model.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic.isEmpty
                            ? Container(
                                color: Pallete.blueColor,
                              )
                            : Image.network(
                                user.bannerPic,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                            onPressed: () {
                              //edit profile
                              if (currentUser.uid == user.uid) {
                                Navigator.push(
                                    context, EditProfileView.route());
                              } else {
                                // ref
                                //         .read(userProfileControllerProvider.notifier)
                                //         .followUser(
                                //           user: user,
                                //           context: context,
                                //           currentUser: currentUser,
                                //         );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: Pallete.whiteColor,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                              ),
                            ),
                            child: Text(
                              currentUser.uid == user.uid
                                  ? "Edit profile"
                                  : "Follow",
                              style: const TextStyle(
                                color: Pallete.whiteColor,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "@${user.name}",
                          style: const TextStyle(
                            fontSize: 17,
                            color: Pallete.greyColor,
                          ),
                        ),
                        Text(
                          user.bio,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            FollowCount(
                                count: user.followers.length,
                                text: "Followers"),
                            const SizedBox(
                              width: 15,
                            ),
                            FollowCount(
                                count: user.following.length,
                                text: "Following"),
                          ],
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const Divider(
                          color: Pallete.greyColor,
                        )
                      ],
                    ),
                  ),
                )
              ];
            },
            body: ref.watch(getUserTweetsProvider(user.uid)).when(
                data: (tweets) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          final latestTweet = Tweet.fromMap(data.payload);
                          bool isTweetAlreadyPresent = false;
                          for (final tweetModel in tweets) {
                            if (tweetModel.id == latestTweet.id) {
                              isTweetAlreadyPresent = true;
                              break;
                            }
                          }
                          if (!isTweetAlreadyPresent) {
                            if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetCollection}.documents.*.create',
                            )) {
                              tweets.insert(0, Tweet.fromMap(data.payload));
                            } else if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetCollection}.documents.*.update',
                            )) {
                              // get id of original tweet
                              final startingPoint =
                                  data.events[0].lastIndexOf('documents.');
                              final endPoint =
                                  data.events[0].lastIndexOf('.update');
                              final tweetId = data.events[0]
                                  .substring(startingPoint + 10, endPoint);

                              var tweet = tweets
                                  .where((element) => element.id == tweetId)
                                  .first;

                              final tweetIndex = tweets.indexOf(tweet);
                              tweets.removeWhere(
                                  (element) => element.id == tweetId);

                              tweet = Tweet.fromMap(data.payload);
                              tweets.insert(tweetIndex, tweet);
                            }
                          }

                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (BuildContext context, int index) {
                                final tweet = tweets[index];
                                return TweetCard(tweet: tweet);
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) => ErrorText(
                          error: error.toString(),
                        ),
                        loading: () {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (BuildContext context, int index) {
                                final tweet = tweets[index];
                                return TweetCard(tweet: tweet);
                              },
                            ),
                          );
                        },
                      ); // return ListView.builder(
                  //   itemCount: tweets.length,
                  //   itemBuilder: (BuildContext context, int index) {
                  //     final tweet = tweets[index];
                  //     return TweetCard(tweet: tweet);
                  //   },
                  // );
                },
                error: (error, st) => ErrorText(
                      error: error.toString(),
                    ),
                loading: () => Loader()),
          );
  }
}
