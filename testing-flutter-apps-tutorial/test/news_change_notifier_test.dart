import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test('initial values are correct', () {
    expect(sut.articles, []);
    expect(sut.isLoading, false);
  });

  group('getArticles', () {
    final articles = [
      Article(title: 'Test 1', content: 'Content 1'),
      Article(title: 'Test 2', content: 'Content 2'),
      Article(title: 'Test 3', content: 'Content 3'),
    ];
    void arrangeNewsServiceReturns3Articles() {
      when(() => mockNewsService.getArticles())
          .thenAnswer((_) async => articles);
    }

    test('gets articles using the NewsService', () async {
      arrangeNewsServiceReturns3Articles();
      await sut.getArticles();
      verify(() => mockNewsService.getArticles()).called(1);
    });
    test(
      """
      indicates loading of data,
      sets articles to the ones from the service,
      indicates that data is not being loaded anymore
      """,
      () async {
        arrangeNewsServiceReturns3Articles();

        ///Can't wait for this call because otherwise it wills not be possible 
        ///to check `isLoading` is `true` and then becomes `false`
        final call = sut.getArticles();
        expect(sut.isLoading, true);
        await call;
        expect(sut.articles, articles);
        expect(sut.isLoading, false);
      },
    );
  });
}
