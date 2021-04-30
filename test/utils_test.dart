import 'package:test/test.dart';
import 'package:vassoura/vassoura.dart';

void main() {
  group('detects files with main method', () {
    test('when main has void return type', () {
      final program = '''
        void main() {
          print('Hello World');
        }
      ''';
      final hasMain = programHasMain(program);
      expect(hasMain, isTrue);
    });

    test('when main doesn\'t have any return type', () {
      final program = '''
        main() {
          print('Hello World');
        }
      ''';
      final hasMain = programHasMain(program);
      expect(hasMain, isTrue);
    });

    test('when main and brackets are in multiple lines', () {
      final program = '''
        main
        ()
        {
          print('Hello World');
        }
      ''';
      final hasMain = programHasMain(program);
      expect(hasMain, isTrue);
    });

    test('when main has arguments', () {
      final program = '''
        void main(List<String> arguments) {
          print('Hello World');
        }
      ''';
      final hasMain = programHasMain(program);
      expect(hasMain, isTrue);
    });
  });

  test('detects no main when there isn\'t any', () {
    final program = '''
        int fib(int n) {
          if (n == 1) {
            return 0;
          }
          if (n == 2) {
            return 1;
          }
          return fib(n - 1) + fib(n - 2);
        }

        double squared(double num) => num * num;
      ''';
    final hasMain = programHasMain(program);
    expect(hasMain, isFalse);
  });
}
