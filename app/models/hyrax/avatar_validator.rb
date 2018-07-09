# Modified from Hyrax Gem 2.1.0
# - Increasing avator file size limit to 10 MB to accomodate SEAMUS profile images.
# - NOTE: I originally attempted to override this validator via prepend, but I
#         kept getting what looked like namespace issues, so I gave up.
# - TODO: Consider making this avatar file limit size configurable.
module Hyrax
  class AvatarValidator < ActiveModel::Validator
    def validate(record)
      return unless record.avatar?
      record.errors.add(:avatar_file_size, 'must be less than 10MB') if record.avatar.size > 10.megabytes.to_i
    end
  end
end
