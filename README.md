# 🧹 vassoura

## What is it?

Find files your project doesn't need anymore and make your project cleaner.

> It's recommended to always use it only once all files are commited and the project uses Git as version control, so that *just in case* you can rollback if needed.

## Installation

Run the following command:

```sh
pub global activate vassoura
```


Let's make sure it works. Try to run the following and see if it prompts the [usage](#usage)
```sh
vas
```

If it didn't worked it means you should add  added `.pub-cache` to your `PATH`. If you're on Linux put the following in your `.bashrc` or equivalent.

> If you are on Windows the same principle applies. Just add the path to your env variable.
> For more info head over to [dart.dev](https://dart.dev/tools/pub/cmd/pub-global)

```sh
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

## Usage

Running the `vas` command should prompt the available options. Currently looks like this:

```
Vassoura: removes files not referenced in the project
Usage: vas <command>

Available commands:
-l, --list    lists all files available to deletion
```

Currently you should run the command from your project's root as we need to gather the project name from `pubspec.yaml`.

### Example

Running `vas -l` from [vassoura](#vassoura)'s root we get this output:

```
It seems like these files have no use: 
/home/ascenio/code/vassoura/test/fixtures/some_folder/another_hello.dart
/home/ascenio/code/vassoura/test/fixtures/folder_with_recursive_files/some_folder/another_hello.dart
```

That's because they are indeed just fixtures for tests. Not too shabby huh?