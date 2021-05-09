class ProjectNameNotFound implements Exception {
  final String? message;

  const ProjectNameNotFound([this.message]);

  @override
  String toString() {
    if (message != null) {
      return message!;
    }
    return 'Project name not found';
  }
}
