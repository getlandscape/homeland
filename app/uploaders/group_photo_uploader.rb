# frozen_string_literal: true

class GroupPhotoUploader < BaseUploader
  # Override the filename of the uploaded files:
  def filename
    if super.present?
      @name ||= SecureRandom.uuid
      "group_photo_#{model.id}/#{@name}.#{file.extension.downcase}"
    end
  end
end
