import 'package:animations/animations.dart';
import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/src/blocs/selected_movie_bloc.dart';
import 'package:movies/src/components/movie_tile.dart';
import 'package:movies/src/model/movie/movie.dart';
import 'package:movies/src/pages/details/movie_details_page.dart';

final resultsPagingController = PagingController<int, Movie>(firstPageKey: 1);

final resultsScrollController = ScrollController();

/// Shows the results of the movie search
class ResultList extends StatelessWidget {
  const ResultList({
    Key? key,
    required this.movies,
    required this.pagingController,
    required this.scrollController,
  }) : super(key: key);

  final List<Movie> movies;
  final PagingController<int, Movie> pagingController;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        height: movies.isEmpty ? 0 : MediaQuery.of(context).size.height,
        child: PagedListView<int, Movie>(
          pagingController: pagingController,
          scrollController: scrollController,
          shrinkWrap: true,
          // allows the ListView to restore the scroll position
          restorationId: 'sampleItemListView',
          builderDelegate: PagedChildBuilderDelegate<Movie>(
            noItemsFoundIndicatorBuilder: (context) => const Offstage(),
            itemBuilder: (context, item, index) {
              final movie = movies[index];

              return Entry.all(
                delay: const Duration(milliseconds: 80),
                duration: const Duration(milliseconds: 200),
                xOffset: -MediaQuery.of(context).size.width / 2,
                child: OpenContainer(
                  transitionType: ContainerTransitionType.fadeThrough,
                  openBuilder: (context, action) => const MovieDetailsPage(),
                  closedColor: Theme.of(context).scaffoldBackgroundColor,
                  openColor: Theme.of(context).scaffoldBackgroundColor,
                  middleColor: Theme.of(context).scaffoldBackgroundColor,
                  closedElevation: 0,
                  closedBuilder: (context, action) => GestureDetector(
                    onTap: () {
                      context.read<SelectedMovieBloc>().add(SelectMovie(movie));
                      action();
                    },
                    child: Container(
                      height: 160,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: MovieTile(movie: movie, titleSize: 22),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}
