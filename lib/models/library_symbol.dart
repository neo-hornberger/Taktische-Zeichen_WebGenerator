class LibrarySymbol {
  const LibrarySymbol(this.name, this.category);

  final String name;
  final String category;

  String get path => '$category/$name.j2';

  factory LibrarySymbol.parse(String path) {
    final match = _symbolPattern.firstMatch(path);

    if (match == null) {
      throw FormatException('Invalid library symbol path: $path');
    }

    return LibrarySymbol(
      match.namedGroup('name')!,
      match.namedGroup('category')!,
    );
  }
}

final RegExp _symbolPattern = RegExp(r'^(?<category>.+)/(?<name>[^/]+).j2$');
