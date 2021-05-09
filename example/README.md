# Example

To illustrate a simple case let's download this very repo and run `vas` on it. Run the commands:

```bash
git clone https://github.com/Ascenio/vassoura
cd vassoura
vas -l
```

You'll get this response: 

```bash
It seems like these files have no use:
/tmp/tmp.BjD5aQB2dD/vassoura/test/fixtures/some_folder/another_hello.dart
/tmp/tmp.BjD5aQB2dD/vassoura/test/fixtures/folder_with_recursive_files/some_folder/another_hello.dart
```

If you take a look at them you'll see that they are basically this:

```dart
// vassoura/test/fixtures/some_folder/another_hello.dart
import 'dart:math';

double coolFunction() {
  return pow(2, 10) as double;
}

// vassoura/test/fixtures/folder_with_recursive_files/some_folder/another_hello.dart
import 'dart:math';

double coolFunction() {
  return pow(2, 10) as double;
}
```

Nowhere in this package they are imported, they are used only indirectly because they are fixtures for tests. Hopefully this has given an idea of how useful it can be in bigger code bases and made you consider trying it.

Remember, It's very common during refactoring to leave a class or two which will accumulate over time, so it's always a good practice to clean up your project for the same reasons you refactored in the first place.