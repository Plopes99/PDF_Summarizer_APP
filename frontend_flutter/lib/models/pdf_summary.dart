class PdfSummary {
  final String fileId;
  final String summary;

  PdfSummary({required this.fileId, required this.summary});

  factory PdfSummary.fromJson(Map<String, dynamic> json) {
    return PdfSummary(
      fileId: json['file_id'],
      summary: json['summary'],
    );
  }
}
