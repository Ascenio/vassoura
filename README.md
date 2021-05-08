# 🧹 vassoura

## What is it?

Find files your project doesn't need anymore and make your project cleaner.

> It's recommended to use it only once all files are commited, *just in case*.

## Installation

Run the following command:

```sh
pub global activate vassoura
```

Let's make sure it works. Try to run the following and see if it prompts the [usage](#usage).
```sh
vas
```

If it didn't worked that means you should add `.pub-cache` to your `PATH`. If you're on Linux put the following in your `.bashrc` or equivalent.

```sh
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

> If you are on Windows the same principle applies. Just add the path to your env variable.
> For more info head over to [dart.dev](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path)

## Usage

Just type `vas` and see what is available.

```
Vassoura: removes files not referenced in the project
Usage: vas <command>

Available commands:
-l, --list    lists all files available to deletion
```

**NOTE**: For now you should run the command from your project's root as we need to gather the project name from `pubspec.yaml`.

### Example

Running `vas -l` from this repo produces this:

```
It seems like these files have no use: 
/home/ascenio/code/vassoura/test/fixtures/some_folder/another_hello.dart
/home/ascenio/code/vassoura/test/fixtures/folder_with_recursive_files/some_folder/another_hello.dart
```

That's because they are indeed just fixtures for tests. Not too shabby huh?