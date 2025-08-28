dynamic sanitizeJson(dynamic input) {
  if (input == null) return null;

  if (input is Map<String, dynamic>) {
    final out = <String, dynamic>{};
    input.forEach((k, v) => out[k] = sanitizeJson(v));
    return out;
  }

  if (input is Map) {
    final out = <String, dynamic>{};
    input.forEach((k, v) => out[k.toString()] = sanitizeJson(v));
    return out;
  }

  if (input is List) {
    return input.map((e) => sanitizeJson(e)).toList();
  }

  return input;
}
