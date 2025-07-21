enum AttachmentType { image, pdf, other }

class Attachment {
  final String id;
  final AttachmentType fileType;
  final String filePath;

  Attachment({
    required this.id,
    required this.fileType,
    required this.filePath,
  });
}
