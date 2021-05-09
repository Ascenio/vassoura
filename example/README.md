# Example

To illustrate a simple case let's download this very repo and run `vas` on it.

```bash
git clone https://github.com/Ascenio/vassoura
cd vassoura
vas -l
```

You'll get this response: 

```bash
Scanning vassoura..
It seems like these files have no use: 
/home/ascenio/code/vassoura/test/fixtures/parts_example/printer.dart
/home/ascenio/code/vassoura/test/fixtures/some_folder/another_hello.dart
/home/ascenio/code/vassoura/test/fixtures/folder_with_recursive_files/some_folder/another_hello.dart
/home/ascenio/code/vassoura/test/fixtures/file_with_imports.dart
/home/ascenio/code/vassoura/lib/src/terminal/terminal.dart
```

The first four files do nothing, they are only read as files in tests.
The last file is suspected not to be used, but that's because it's an entry point for the `lib/`. In this cases the file isn't imported directly, but may be used by the client, so we need to keep it.

> As seen above, sometimes you need to use your own judgement. It does work on packages, but you have to ignore the entry points.
