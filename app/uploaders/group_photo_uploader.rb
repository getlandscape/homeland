# frozen_string_literal: true

class GroupPhotoUploader < BaseUploader
  # Override the filename of the uploaded files:
  def filename
    if super.present?
      @name ||= SecureRandom.uuid + Time.now.to_i.to_s
      "group_photo/#{@name}.#{file.extension.downcase}"
    end
  end
end
