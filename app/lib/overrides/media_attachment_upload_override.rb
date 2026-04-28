# app/lib/overrides/media_attachment_upload_override.rb
# frozen_string_literal: true

module Overrides::MediaAttachmentUploadOverride
  UPLOAD_LIMIT = 100.megabytes

  IMAGE_FILE_EXTENSIONS = %w(.jpg .jpeg .png .gif .webp .heic .heif .avif).freeze
  VIDEO_FILE_EXTENSIONS = %w(.webm .mp4 .m4v .mov).freeze
  AUDIO_FILE_EXTENSIONS = %w(.ogg .oga .mp3 .wav .flac .opus .aac .m4a .3gp .wma).freeze
  DOCUMENT_FILE_EXTENSIONS = %w(
    .pdf .doc .docx .xls .xlsx .csv .ppt .pptx .txt .rtf .odt .ods .odp .epub
  ).freeze

  DOCUMENT_MIME_TYPES = %w(
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    text/csv
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.presentationml.presentation
    text/plain
    application/rtf
    text/rtf
    application/vnd.oasis.opendocument.text
    application/vnd.oasis.opendocument.spreadsheet
    application/vnd.oasis.opendocument.presentation
    application/epub+zip
  ).freeze
  IMAGE_MIME_TYPES             = %w(image/jpeg image/png image/gif image/heic image/heif image/webp image/avif).freeze
  IMAGE_CONVERTIBLE_MIME_TYPES = %w(image/heic image/heif image/avif).freeze
  VIDEO_MIME_TYPES             = %w(video/webm video/mp4 video/quicktime video/ogg).freeze
  VIDEO_CONVERTIBLE_MIME_TYPES = %w(video/webm video/quicktime).freeze
  AUDIO_MIME_TYPES             = %w(audio/wave audio/wav audio/x-wav audio/x-pn-wave audio/vnd.wave audio/ogg audio/vorbis audio/mpeg audio/mp3 audio/webm audio/flac audio/aac audio/m4a audio/x-m4a audio/mp4 audio/3gpp video/x-ms-asf).freeze


  # included do
  #   validates_attachment_content_type :file, content_type: IMAGE_MIME_TYPES + VIDEO_MIME_TYPES + AUDIO_MIME_TYPES + DOCUMENT_MIME_TYPES
  # end


  module ClassMethods
    def supported_mime_types
      IMAGE_MIME_TYPES + VIDEO_MIME_TYPES + AUDIO_MIME_TYPES + DOCUMENT_MIME_TYPES
    end

    def supported_file_extensions
      IMAGE_FILE_EXTENSIONS + VIDEO_FILE_EXTENSIONS + AUDIO_FILE_EXTENSIONS + DOCUMENT_FILE_EXTENSIONS
    end

    private

    def file_styles(attachment)
      return {} if DOCUMENT_MIME_TYPES.include?(attachment.instance.file_content_type)

      super
    end

    def file_processors(instance)
      return [:type_corrector] if DOCUMENT_MIME_TYPES.include?(instance.file_content_type)

      super
    end
  end

  def self.prepended(base)
    base.singleton_class.prepend(ClassMethods)

    base.send(:remove_const, :IMAGE_LIMIT) if base.const_defined?(:IMAGE_LIMIT, false)
    base.const_set(:IMAGE_LIMIT, UPLOAD_LIMIT)

    base.send(:remove_const, :VIDEO_LIMIT) if base.const_defined?(:VIDEO_LIMIT, false)
    base.const_set(:VIDEO_LIMIT, UPLOAD_LIMIT)

    base.send(:remove_const, :DOCUMENT_FILE_EXTENSIONS) if base.const_defined?(:DOCUMENT_FILE_EXTENSIONS, false)
    base.const_set(:DOCUMENT_FILE_EXTENSIONS, DOCUMENT_FILE_EXTENSIONS)

    if base.const_defined?(:DOCUMENT_MIME_TYPES, false)
      base.send(:remove_const, :DOCUMENT_MIME_TYPES)
    end
    base.const_set(:DOCUMENT_MIME_TYPES, DOCUMENT_MIME_TYPES)

    base.validators_on(:file).each do |validator|
      # Duplicate the frozen hash to create a mutable copy
      new_options = validator.options.dup
      
      if new_options.key?(:content_type)
        new_options[:content_type] = base.supported_mime_types
      end

      if new_options.key?(:less_than)
        new_options[:less_than] = ->(_attachment) { UPLOAD_LIMIT }
      end

      # validator.options can be frozen; replace the backing ivar instead
      validator.instance_variable_set(:@options, new_options.freeze)
    end
  end

  private

  def set_type_and_extension
    return self.type = :unknown if self.class::DOCUMENT_MIME_TYPES.include?(file_content_type)

    super
  end
end