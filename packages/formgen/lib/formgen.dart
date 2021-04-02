library formgen;

class FormGen {
  const FormGen({this.allRequired = false});

  final bool allRequired;
}

class EnumField {
  const EnumField();
}

class FormInput<T> {
  const FormInput({
    this.label,
    String? description,
    this.width,
    this.validate,
  }): description = description ?? "";
  final String? label;
  final String description;

  final double? width;
  final String? Function(T form)? validate;
}
