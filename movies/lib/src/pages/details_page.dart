import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movies/src/blocs/movie_details_cubit.dart';
import 'package:movies/src/blocs/selected_movie_bloc.dart';
import 'package:movies/src/components/genre_chips.dart';
import 'package:movies/src/components/movie_chips.dart';
import 'package:movies/src/components/poster.dart';
import 'package:movies/src/model/movie/movie.dart';
import 'package:movies/src/model/movie_details/movie_details.dart';
import 'package:movies/src/model/movie_details/movie_details_state.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// Displays detailed information about a movie
class DetailsPage extends StatelessWidget {
  const DetailsPage({
    super.key,
  });

  static const routeName = '/sample_item';

  @override
  Widget build(BuildContext context) => BlocBuilder<SelectedMovieBloc, Movie?>(
        builder: (context, movie) {
          if (movie == null) {
            return const CircularProgressIndicator();
          }
          final hasBackdrop = movie.backdropPath != null;

          return WillPopScope(
            onWillPop: () async {
              context.read<SelectedMovieBloc>().add(DeselectMovie());

              return true;
            },
            child: SafeArea(
              child: Scaffold(
                body: Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          automaticallyImplyLeading: false,
                          leading: IconButton(
                            onPressed: () {
                              context
                                  .read<SelectedMovieBloc>()
                                  .add(DeselectMovie());
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                          expandedHeight: hasBackdrop ? 200 : 0,
                          flexibleSpace: hasBackdrop
                              ? FlexibleSpaceBar(
                                  background: Hero(
                                    tag: movie.id,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fitWidth,
                                      imageUrl: movie.backdrop,
                                      placeholder: (context, _) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        SliverPinnedHeader(
                          child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Poster(
                                  url: movie.smallPoster,
                                  heroTag: movie.id,
                                  height: 184,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                          fontSize: 28,
                                        ),
                                      ),
                                      if (movie.title != movie.originalTitle)
                                        Text('(${movie.originalTitle})'),
                                      const SizedBox(height: 4),
                                      GenreChips(genreIds: movie.genreIds),
                                      MovieChips(movie: movie),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).synopsis,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  movie.overview,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: BlocBuilder<MovieDetailsCubit,
                                MovieDetailsState>(
                              builder: (context, state) => state.when(
                                loading: () =>
                                    const Center(child: CircularProgressIndicator()),
                                noSelection: () => const Offstage(),
                                error: (_) => Text(
                                    AppLocalizations.of(context).errorHappened),
                                details: (movieDetails) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (movieDetails.tagline != null)
                                      Text(movieDetails.tagline!),
                                    Text(movieDetails.homepage),
                                    Text(movieDetails.status),
                                    Text('\$${movieDetails.budget}'),
                                    Text('\$${movieDetails.revenue}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    /*Positioned(
                    top: 8,
                    left: 8,
                    child: SafeArea(
                      child: FloatingActionButton.small(
                        child: const Icon(Icons.arrow_back),
                        onPressed: () {
                          context
                              .read<SelectedMovieBloc>()
                              .add(DeselectMovie());
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  )*/
                  ],
                ),
              ),
            ),
          );
        },
      );
}
